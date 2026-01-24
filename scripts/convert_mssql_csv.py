#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
MSSQL에서 추출한 CSV 파일을 Flutter 앱 복원 형식으로 변환하는 스크립트
"""
import csv
import sys
from pathlib import Path

def convert_csv(input_file, output_file):
    """
    MSSQL CSV를 Flutter 앱 복원 형식으로 변환
    """
    with open(input_file, 'r', encoding='utf-8-sig') as infile, \
         open(output_file, 'w', encoding='utf-8-sig', newline='') as outfile:
        
        reader = csv.reader(infile)
        writer = csv.writer(outfile)
        
        # 헤더 행 추가 (CUSTOMER용)
        writer.writerow(['TYPE', 'id', 'name', 'phone', 'memo', 'created_at'])
        
        current_headers = None
        service_header_written = False
        
        for row in reader:
            if not row or len(row) == 0:
                continue
            
            row_type = row[0].strip().upper() if row[0] else ''
            
            if row_type == 'CUSTOMER':
                # CUSTOMER 행: TYPE,id,name,phone,memo,created_at,NULL,NULL,NULL,NULL,NULL,NULL
                # 변환: TYPE,id,name,phone,memo,created_at
                if len(row) >= 6:
                    writer.writerow([
                        row[0],  # TYPE
                        row[1] if len(row) > 1 else '',  # id
                        row[2] if len(row) > 2 else '',  # name
                        row[3] if len(row) > 3 else '',  # phone
                        row[4] if len(row) > 4 else '',  # memo
                        row[5] if len(row) > 5 else '',  # created_at
                    ])
            
            elif row_type == 'SERVICE_RECORD':
                # SERVICE_RECORD 행: TYPE,id,NULL,NULL,memo,created_at,customer_id,service_date,service_content,product_name,payment_type,amount
                # 변환: TYPE,id,customer_id,service_date,service_content,product_name,payment_type,amount,memo,created_at
                
                # SERVICE_RECORD 헤더는 첫 번째 SERVICE_RECORD 행 전에 한 번만 작성
                if not service_header_written:
                    writer.writerow(['TYPE', 'id', 'customer_id', 'service_date', 'service_content', 
                                   'product_name', 'payment_type', 'amount', 'memo', 'created_at'])
                    service_header_written = True
                
                if len(row) >= 12:
                    writer.writerow([
                        row[0],  # TYPE
                        row[1] if len(row) > 1 else '',  # id
                        row[6] if len(row) > 6 else '',  # customer_id
                        row[7] if len(row) > 7 else '',  # service_date
                        row[8] if len(row) > 8 else '',  # service_content
                        row[9] if len(row) > 9 else '',  # product_name
                        row[10] if len(row) > 10 else '',  # payment_type
                        row[11] if len(row) > 11 else '',  # amount
                        row[4] if len(row) > 4 else '',  # memo
                        row[5] if len(row) > 5 else '',  # created_at
                    ])

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("사용법: python convert_mssql_csv.py <입력파일> [출력파일]")
        print("예: python convert_mssql_csv.py 'mssql all data.csv' 'hairdress_restore.csv'")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else 'hairdress_restore.csv'
    
    if not Path(input_file).exists():
        print(f"오류: 입력 파일을 찾을 수 없습니다: {input_file}")
        sys.exit(1)
    
    print(f"변환 중: {input_file} -> {output_file}")
    convert_csv(input_file, output_file)
    print(f"완료: {output_file} 파일이 생성되었습니다.")
    print(f"이 파일을 Flutter 앱의 '복원' 기능으로 사용하세요.")
