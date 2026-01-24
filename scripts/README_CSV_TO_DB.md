# CSV to DB 변환 스크립트

Customer All.csv와 CustomerService All.csv 파일을 SQLite DB 파일로 변환하는 스크립트입니다.

## 사용법

```bash
python scripts/csv_to_db.py "Customer All.csv" "CustomerService All.csv" "hairdress_history.db"
```

## 입력 파일 형식

### Customer All.csv
- 형식: `Customer_Id,Customer_Name,Customer_Phone,Customer_Picture`
- 헤더 없음
- 예시:
  ```
  100020,진미진,010-2689-4823,NULL
  100030,배은숙,010-9638-6385,NULL
  ```

### CustomerService All.csv
- 형식: `Service_Id,CustomerId,Service_Date,Service_Contents,Service_PayType,Service_Pay,Service_Remarks,Service_Sales`
- 헤더 없음
- 예시:
  ```
  105,100020,2024-02-26,5호다대,현금,30000,,
  110,100037,2024-03-02,매직셋팅C컬20호 아들컷,카드,120000,,
  ```

## 출력

- `hairdress_history.db`: SQLite 데이터베이스 파일
- 생성된 DB 파일은 Flutter 앱에서 바로 사용 가능합니다.

## 주의사항

1. CSV 파일은 UTF-8 인코딩이어야 합니다.
2. 기존 DB 파일이 있으면 덮어씁니다.
3. 고객 ID는 자동으로 재생성되며, 서비스 기록의 customer_id는 새로운 ID로 매핑됩니다.

## 배포

생성된 `hairdress_history.db` 파일을 Flutter 앱 설치 시 함께 배포하면 됩니다.
