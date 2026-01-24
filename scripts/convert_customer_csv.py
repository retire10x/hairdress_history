#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Customer All.csv와 CustomerService All.csv를 Flutter 앱 복원 형식으로 변환하는 스크립트
"""
import csv
import sys
from pathlib import Path
from datetime import datetime

def convert_payment_type(pay_type):
    """결제 타입을 Flutter 앱 형식으로 변환"""
    if not pay_type:
        return 'cash'
    
    pay_type = pay_type.strip()
    if pay_type == '현금':
        return 'cash'
    elif pay_type == '카드':
        return 'card'
    elif pay_type in ['송금', '계좌이체', '이체', '무통장입금']:
        return 'transfer'
    else:
        return 'cash'  # 기본값

def convert_csv(customer_file, service_file, output_file):
    """
    Customer All.csv와 CustomerService All.csv를 Flutter 앱 복원 형식으로 변환
    """
    current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    
    with open(output_file, 'w', encoding='utf-8-sig', newline='') as outfile:
        writer = csv.writer(outfile)
        
        # CUSTOMER 헤더 행 추가
        writer.writerow(['TYPE', 'id', 'name', 'phone', 'memo', 'created_at'])
        
        # Customer All.csv 읽기 및 변환
        try:
            with open(customer_file, 'r', encoding='utf-8-sig') as infile:
                reader = csv.reader(infile)
                for row in reader:
                    if not row or len(row) == 0:
                        continue
                    
                    # id, name, phone, NULL (4개 컬럼)
                    if len(row) >= 3:
                        customer_id = row[0].strip() if len(row) > 0 else ''
                        name = row[1].strip() if len(row) > 1 else ''
                        phone = row[2].strip() if len(row) > 2 else ''
                        memo = ''  # NULL은 빈 값으로
                        
                        # phone이 NULL이면 빈 값으로
                        if phone.upper() == 'NULL' or phone == '':
                            phone = ''
                        
                        writer.writerow([
                            'CUSTOMER',
                            customer_id,
                            name,
                            phone,
                            memo,
                            current_time,
                        ])
        except Exception as e:
            print(f"고객 파일 읽기 오류: {e}")
            return False
        
        # SERVICE_RECORD 헤더 행 추가
        writer.writerow(['TYPE', 'id', 'customer_id', 'service_date', 'service_content', 
                        'product_name', 'payment_type', 'amount', 'memo', 'created_at'])
        
        # CustomerService All.csv 읽기 및 변환
        try:
            with open(service_file, 'r', encoding='utf-8-sig') as infile:
                reader = csv.reader(infile)
                for row in reader:
                    if not row or len(row) == 0:
                        continue
                    
                    # Service_Id, CustomerId, Service_Date, Service_Contents, Service_PayType, Service_Pay, Service_Remarks, Service_Sales (8개 컬럼)
                    if len(row) >= 6:
                        service_id = row[0].strip() if len(row) > 0 else ''
                        customer_id = row[1].strip() if len(row) > 1 else ''
                        service_date = row[2].strip() if len(row) > 2 else ''
                        service_content = row[3].strip() if len(row) > 3 else ''
                        pay_type = row[4].strip() if len(row) > 4 else ''
                        amount = row[5].strip() if len(row) > 5 else ''
                        remarks = row[6].strip() if len(row) > 6 else ''  # Service_Remarks
                        sales = row[7].strip() if len(row) > 7 else ''  # Service_Sales
                        
                        # NULL 처리
                        if remarks.upper() == 'NULL':
                            remarks = ''
                        if sales.upper() == 'NULL':
                            sales = ''
                        
                        # 결제 타입 변환
                        payment_type = convert_payment_type(pay_type)
                        
                        writer.writerow([
                            'SERVICE_RECORD',
                            service_id,
                            customer_id,
                            service_date,
                            service_content,
                            sales,  # Service_Sales -> product_name
                            payment_type,
                            amount,
                            remarks,  # Service_Remarks -> memo
                            current_time,
                        ])
        except Exception as e:
            print(f"서비스 파일 읽기 오류: {e}")
            return False
    
    return True

if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("사용법: python convert_customer_csv.py <Customer All.csv> <CustomerService All.csv> [출력파일]")
        print("예: python convert_customer_csv.py 'Customer All.csv' 'CustomerService All.csv' 'hairdress_restore.csv'")
        sys.exit(1)
    
    customer_file = sys.argv[1]
    service_file = sys.argv[2]
    output_file = sys.argv[3] if len(sys.argv) > 3 else 'hairdress_restore.csv'
    
    if not Path(customer_file).exists():
        print(f"오류: 고객 파일을 찾을 수 없습니다: {customer_file}")
        sys.exit(1)
    
    if not Path(service_file).exists():
        print(f"오류: 서비스 파일을 찾을 수 없습니다: {service_file}")
        sys.exit(1)
    
    print(f"변환 중: {customer_file} + {service_file} -> {output_file}")
    if convert_csv(customer_file, service_file, output_file):
        print(f"완료: {output_file} 파일이 생성되었습니다.")
        print(f"이 파일을 Flutter 앱의 '복원' 기능으로 사용하세요.")
    else:
        print("오류: 변환 중 오류가 발생했습니다.")
        sys.exit(1)
