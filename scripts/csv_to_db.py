#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
CSV 파일을 SQLite DB 파일로 변환하는 스크립트

사용법:
    python csv_to_db.py <Customer_All.csv> <CustomerService_All.csv> <output.db>

예시:
    python csv_to_db.py "Customer All.csv" "CustomerService All.csv" "hairdress_history.db"
"""

import sqlite3
import csv
import sys
from datetime import datetime
from pathlib import Path


def create_database(db_path):
    """SQLite 데이터베이스 생성 및 테이블 생성"""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # customers 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS customers (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            phone TEXT,
            memo TEXT,
            created_at TEXT NOT NULL
        )
    ''')
    
    # service_records 테이블 생성
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS service_records (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER NOT NULL,
            service_date TEXT NOT NULL,
            service_content TEXT NOT NULL,
            product_name TEXT,
            payment_type TEXT NOT NULL,
            amount INTEGER NOT NULL,
            memo TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
        )
    ''')
    
    # 인덱스 생성
    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_customer_id ON service_records(customer_id)
    ''')
    cursor.execute('''
        CREATE INDEX IF NOT EXISTS idx_service_date ON service_records(service_date)
    ''')
    
    # FOREIGN KEY 활성화
    cursor.execute('PRAGMA foreign_keys = ON')
    
    conn.commit()
    return conn, cursor


def parse_customer_csv(customer_file, cursor):
    """Customer All.csv 파일을 읽어서 customers 테이블에 삽입"""
    customer_id_map = {}  # 원본 ID -> 새 ID 매핑
    now = datetime.now().isoformat()
    
    with open(customer_file, 'r', encoding='utf-8-sig') as f:  # utf-8-sig로 BOM 자동 제거
        reader = csv.reader(f)
        for row in reader:
            if not row or len(row) < 2:
                continue
            
            # Customer All.csv 형식: Customer_Id,Customer_Name,Customer_Phone,Customer_Picture
            original_id = row[0].strip()
            # BOM 제거 (혹시 모를 경우 대비)
            original_id = original_id.lstrip('\ufeff')
            name = row[1].strip() if len(row) > 1 else ''
            phone = row[2].strip() if len(row) > 2 and row[2].strip() != 'NULL' else None
            # Customer_Picture는 사용하지 않음
            
            if not name:
                continue
            
            try:
                original_id_int = int(original_id)
            except ValueError:
                print(f"고객 ID 파싱 실패, 스킵: {original_id}")
                continue
            
            # 고객 삽입
            cursor.execute('''
                INSERT INTO customers (name, phone, memo, created_at)
                VALUES (?, ?, ?, ?)
            ''', (name, phone, None, now))
            
            new_id = cursor.lastrowid
            customer_id_map[original_id_int] = new_id
    
    return customer_id_map


def parse_service_csv(service_file, cursor, customer_id_map):
    """CustomerService All.csv 파일을 읽어서 service_records 테이블에 삽입"""
    now = datetime.now().isoformat()
    
    # 결제 타입 매핑 (한국어 -> 영어)
    payment_type_map = {
        '현금': 'cash',
        '카드': 'card',
        '송금': 'transfer',
        '계좌이체': 'transfer',
        '이체': 'transfer',
        '무통장입금': 'transfer'
    }
    
    with open(service_file, 'r', encoding='utf-8-sig') as f:  # utf-8-sig로 BOM 자동 제거
        reader = csv.reader(f)
        for row in reader:
            if not row or len(row) < 6:
                continue
            
            # CustomerService All.csv 형식: 
            # Service_Id,CustomerId,Service_Date,Service_Contents,Service_PayType,Service_Pay,Service_Remarks,Service_Sales
            original_customer_id = int(row[1].strip()) if row[1].strip() else None
            service_date_str = row[2].strip() if len(row) > 2 else ''
            service_content = row[3].strip() if len(row) > 3 else ''
            payment_type_kr = row[4].strip() if len(row) > 4 else '현금'
            amount_str = row[5].strip() if len(row) > 5 else '0'
            memo = row[6].strip() if len(row) > 6 and row[6].strip() else None
            product_name = row[7].strip() if len(row) > 7 and row[7].strip() else None
            
            if not original_customer_id or original_customer_id not in customer_id_map:
                continue  # 고객이 없으면 스킵
            
            new_customer_id = customer_id_map[original_customer_id]
            
            # 날짜 파싱 (YYYY-MM-DD 형식으로 변환)
            try:
                # 다양한 날짜 형식 지원
                if len(service_date_str) == 10:  # YYYY-MM-DD
                    service_date = service_date_str
                elif len(service_date_str) == 8:  # YYYYMMDD
                    service_date = f"{service_date_str[:4]}-{service_date_str[4:6]}-{service_date_str[6:8]}"
                else:
                    # datetime 파싱 시도
                    service_date_obj = datetime.strptime(service_date_str, '%Y-%m-%d')
                    service_date = service_date_obj.strftime('%Y-%m-%d')
            except:
                print(f"날짜 파싱 실패: {service_date_str}, 기본값 사용")
                service_date = datetime.now().strftime('%Y-%m-%d')
            
            # 시간 추가 (기본값: 현재 시간)
            service_datetime = f"{service_date}T{datetime.now().strftime('%H:%M:%S')}"
            
            # 결제 타입 변환
            payment_type = payment_type_map.get(payment_type_kr, 'cash')
            
            # 금액 변환
            try:
                amount = int(amount_str)
            except:
                amount = 0
            
            if not service_content:
                continue
            
            # 서비스 기록 삽입
            cursor.execute('''
                INSERT INTO service_records 
                (customer_id, service_date, service_content, product_name, payment_type, amount, memo, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (new_customer_id, service_datetime, service_content, product_name, payment_type, amount, memo, now))


def main():
    if len(sys.argv) != 4:
        print("사용법: python csv_to_db.py <Customer_All.csv> <CustomerService_All.csv> <output.db>")
        print("예시: python csv_to_db.py \"Customer All.csv\" \"CustomerService All.csv\" \"hairdress_history.db\"")
        sys.exit(1)
    
    customer_file = sys.argv[1]
    service_file = sys.argv[2]
    output_db = sys.argv[3]
    
    # 파일 존재 확인
    if not Path(customer_file).exists():
        print(f"오류: {customer_file} 파일을 찾을 수 없습니다.")
        sys.exit(1)
    
    if not Path(service_file).exists():
        print(f"오류: {service_file} 파일을 찾을 수 없습니다.")
        sys.exit(1)
    
    # 기존 DB 파일이 있으면 삭제
    if Path(output_db).exists():
        print(f"기존 DB 파일 삭제: {output_db}")
        Path(output_db).unlink()
    
    print(f"DB 파일 생성 중: {output_db}")
    conn, cursor = create_database(output_db)
    
    try:
        print(f"고객 데이터 로딩 중: {customer_file}")
        customer_id_map = parse_customer_csv(customer_file, cursor)
        print(f"고객 {len(customer_id_map)}명 로드 완료")
        
        print(f"서비스 기록 데이터 로딩 중: {service_file}")
        parse_service_csv(service_file, cursor, customer_id_map)
        
        conn.commit()
        print(f"DB 파일 생성 완료: {output_db}")
        
        # 통계 출력
        cursor.execute("SELECT COUNT(*) FROM customers")
        customer_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM service_records")
        record_count = cursor.fetchone()[0]
        
        print(f"\n통계:")
        print(f"  고객: {customer_count}명")
        print(f"  서비스 기록: {record_count}건")
        
    except Exception as e:
        conn.rollback()
        print(f"오류 발생: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        conn.close()


if __name__ == '__main__':
    main()
