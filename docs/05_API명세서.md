# PICOFriends API 명세서

## 1. API 개요

### 1.1 Base URL
```
Development: http://localhost:8080/api
Production: https://api.picofriends.com/api
```

### 1.2 인증
- **방식**: JWT (JSON Web Token)
- **Header**: `Authorization: Bearer {token}`
- **Token 유효기간**: 24시간

### 1.3 공통 응답 형식

#### 성공 응답
```json
{
  "success": true,
  "data": {},
  "message": "Success",
  "timestamp": "2025-10-20T10:00:00"
}
```

#### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": []
  },
  "timestamp": "2025-10-20T10:00:00"
}
```

### 1.4 HTTP 상태 코드
- `200 OK`: 요청 성공
- `201 Created`: 리소스 생성 성공
- `204 No Content`: 요청 성공, 응답 데이터 없음
- `400 Bad Request`: 잘못된 요청
- `401 Unauthorized`: 인증 실패
- `403 Forbidden`: 권한 없음
- `404 Not Found`: 리소스를 찾을 수 없음
- `409 Conflict`: 리소스 충돌
- `500 Internal Server Error`: 서버 오류

## 2. 인증 API

### 2.1 로그인
**POST** `/auth/login`

**Request**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "홍길동",
      "role": "PICOFRIEND",
      "university": "서울대학교"
    }
  },
  "message": "로그인 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

**Error Responses**
- `401 Unauthorized`: 이메일 또는 비밀번호가 잘못됨
- `403 Forbidden`: 승인되지 않은 사용자

### 2.2 회원가입
**POST** `/auth/register`

**Request**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "홍길동",
  "phoneNumber": "010-1234-5678",
  "university": "서울대학교"
}
```

**Response** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "newuser@example.com",
    "name": "홍길동",
    "phoneNumber": "010-1234-5678",
    "university": "서울대학교",
    "role": "PICOFRIEND",
    "status": "PENDING"
  },
  "message": "회원가입 성공. 관리자 승인을 기다려주세요.",
  "timestamp": "2025-10-20T10:00:00"
}
```

**Error Responses**
- `400 Bad Request`: 유효성 검증 실패
- `409 Conflict`: 이미 존재하는 이메일

### 2.3 로그아웃
**POST** `/auth/logout`

**Headers**
```
Authorization: Bearer {token}
```

**Response** `204 No Content`

### 2.4 프로필 조회
**GET** `/auth/profile`

**Headers**
```
Authorization: Bearer {token}
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "phoneNumber": "010-1234-5678",
    "university": "서울대학교",
    "role": "PICOFRIEND",
    "status": "APPROVED"
  },
  "message": "프로필 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

## 3. 사용자 관리 API (관리자 전용)

### 3.1 사용자 목록 조회
**GET** `/users`

**Query Parameters**
- `role` (optional): `ADMIN` | `PICOFRIEND`
- `status` (optional): `PENDING` | `APPROVED` | `REJECTED`
- `page` (optional): 페이지 번호 (default: 0)
- `size` (optional): 페이지 크기 (default: 10)

**Example Request**
```
GET /users?role=PICOFRIEND&status=PENDING&page=0&size=10
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "email": "user@example.com",
        "name": "홍길동",
        "phoneNumber": "010-1234-5678",
        "university": "서울대학교",
        "role": "PICOFRIEND",
        "status": "PENDING",
        "adminComment": null,
        "createdAt": "2025-10-20T10:00:00",
        "updatedAt": "2025-10-20T10:00:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "totalPages": 5,
      "totalElements": 50
    }
  },
  "message": "사용자 목록 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 3.2 사용자 상세 조회
**GET** `/users/{id}`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "phoneNumber": "010-1234-5678",
    "university": "서울대학교",
    "role": "PICOFRIEND",
    "status": "APPROVED",
    "adminComment": "승인 완료",
    "createdAt": "2025-10-20T10:00:00",
    "updatedAt": "2025-10-20T10:00:00"
  },
  "message": "사용자 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 3.3 사용자 정보 수정
**PUT** `/users/{id}`

**Request**
```json
{
  "name": "홍길동",
  "phoneNumber": "010-9876-5432",
  "university": "연세대학교"
}
```

**Response** `200 OK`

### 3.4 사용자 승인 상태 변경
**PATCH** `/users/{id}/status`

**Query Parameters**
- `status`: `APPROVED` | `REJECTED`
- `adminComment` (optional): 관리자 코멘트

**Example Request**
```
PATCH /users/1/status?status=APPROVED&adminComment=승인완료
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "status": "APPROVED",
    "adminComment": "승인완료"
  },
  "message": "사용자 상태 변경 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 3.5 사용자 CSV 다운로드
**GET** `/users/csv/download`

**Response** `200 OK`
```
Content-Type: text/csv
Content-Disposition: attachment; filename="users_20251020.csv"

ID,이메일,이름,전화번호,대학교,역할,상태,생성일
1,user@example.com,홍길동,010-1234-5678,서울대학교,PICOFRIEND,APPROVED,2025-10-20
```

## 4. 약국 관리 API

### 4.1 약국 목록 조회
**GET** `/pharmacies`

**Query Parameters**
- `name` (optional): 약국명 검색
- `address` (optional): 주소 검색
- `page` (optional): 페이지 번호 (default: 0)
- `size` (optional): 페이지 크기 (default: 10)

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "name": "서울시 약국",
        "address": "서울시 강남구 테헤란로 123",
        "phoneNumber": "02-1234-5678",
        "pharmacistName": "약사 홍길동",
        "pharmacistContact": "010-1234-5678",
        "createdAt": "2025-10-20T10:00:00",
        "updatedAt": "2025-10-20T10:00:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "totalPages": 10,
      "totalElements": 100
    }
  },
  "message": "약국 목록 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 4.2 약국 상세 조회
**GET** `/pharmacies/{id}`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "서울시 약국",
    "address": "서울시 강남구 테헤란로 123",
    "phoneNumber": "02-1234-5678",
    "pharmacistName": "약사 홍길동",
    "pharmacistContact": "010-1234-5678",
    "onlineUsageStatus": "카카오톡 사용 중",
    "mainProducts": "일반의약품, 건강기능식품",
    "urgentNeeds": "마케팅 지원",
    "marketingConcerns": "온라인 홍보 방법",
    "picoResponse": "긍정적",
    "fieldActivitySummary": "방문 완료",
    "nextStepPlan": "회원가입 진행 예정",
    "createdAt": "2025-10-20T10:00:00",
    "updatedAt": "2025-10-20T10:00:00"
  },
  "message": "약국 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 4.3 약국 등록
**POST** `/pharmacies`

**Request**
```json
{
  "name": "서울시 약국",
  "address": "서울시 강남구 테헤란로 123",
  "phoneNumber": "02-1234-5678",
  "pharmacistName": "약사 홍길동",
  "pharmacistContact": "010-1234-5678"
}
```

**Response** `201 Created`

### 4.4 약국 정보 수정
**PUT** `/pharmacies/{id}`

**Request**
```json
{
  "name": "서울시 약국",
  "address": "서울시 강남구 테헤란로 456",
  "phoneNumber": "02-1234-5678",
  "pharmacistName": "약사 홍길동",
  "pharmacistContact": "010-1234-5678"
}
```

**Response** `200 OK`

### 4.5 약국 삭제
**DELETE** `/pharmacies/{id}`

**Response** `204 No Content`

### 4.6 약국 CSV 업로드
**POST** `/pharmacies/csv/upload`

**Request**
```
Content-Type: multipart/form-data

file: [CSV 파일]
```

**CSV 형식**
```csv
name,address,phoneNumber,pharmacistName,pharmacistContact
서울시 약국,서울시 강남구 테헤란로 123,02-1234-5678,약사 홍길동,010-1234-5678
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "totalRows": 100,
    "successCount": 95,
    "failCount": 5,
    "errors": [
      {
        "row": 10,
        "reason": "중복된 약국명"
      }
    ]
  },
  "message": "CSV 업로드 완료",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 4.7 약국 CSV 다운로드
**GET** `/pharmacies/csv/download`

**Response** `200 OK`
```
Content-Type: text/csv
Content-Disposition: attachment; filename="pharmacies_20251020.csv"
```

## 5. 업무 관리 API

### 5.1 배정된 업무 조회
**GET** `/works/assigned`

**Headers**
```
Authorization: Bearer {token}
```

**Response** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "title": "2025년 하반기 약국 방문",
      "description": "약국 방문 및 피코프렌즈 소개",
      "status": "IN_PROGRESS",
      "pharmacy": {
        "id": 1,
        "name": "서울시 약국",
        "address": "서울시 강남구 테헤란로 123"
      },
      "assignmentStatus": "VISITED",
      "visitedAt": "2025-10-20T14:30:00",
      "registeredAt": null,
      "surveyUrl": "https://forms.google.com/...",
      "surveyCompleted": true
    }
  ],
  "message": "배정된 업무 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 5.2 업무 상세 조회
**GET** `/works/{id}`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "2025년 하반기 약국 방문",
    "description": "약국 방문 및 피코프렌즈 소개",
    "status": "IN_PROGRESS",
    "startDate": "2025-10-01",
    "endDate": "2025-12-31",
    "assignments": [
      {
        "id": 1,
        "user": {
          "id": 1,
          "name": "홍길동",
          "university": "서울대학교"
        },
        "pharmacy": {
          "id": 1,
          "name": "서울시 약국",
          "address": "서울시 강남구 테헤란로 123"
        },
        "status": "VISITED",
        "visitedAt": "2025-10-20T14:30:00",
        "registeredAt": null
      }
    ],
    "createdAt": "2025-10-20T10:00:00",
    "updatedAt": "2025-10-20T10:00:00"
  },
  "message": "업무 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 5.3 업무 생성 (관리자 전용)
**POST** `/works`

**Request**
```json
{
  "title": "2025년 하반기 약국 방문",
  "description": "약국 방문 및 피코프렌즈 소개",
  "startDate": "2025-10-01",
  "endDate": "2025-12-31"
}
```

**Response** `201 Created`

### 5.4 업무 수정 (관리자 전용)
**PUT** `/works/{id}`

**Request**
```json
{
  "title": "2025년 하반기 약국 방문 (수정)",
  "description": "약국 방문 및 피코프렌즈 소개",
  "status": "IN_PROGRESS",
  "startDate": "2025-10-01",
  "endDate": "2025-12-31"
}
```

**Response** `200 OK`

### 5.5 업무 삭제 (관리자 전용)
**DELETE** `/works/{id}`

**Response** `204 No Content`

### 5.6 업무 배정 (관리자 전용)
**POST** `/works/{workId}/assignments`

**Request**
```json
{
  "userId": 1,
  "pharmacyId": 1,
  "surveyUrl": "https://forms.google.com/..."
}
```

**Response** `201 Created`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "workId": 1,
    "userId": 1,
    "pharmacyId": 1,
    "status": "ASSIGNED",
    "surveyUrl": "https://forms.google.com/...",
    "createdAt": "2025-10-20T10:00:00"
  },
  "message": "업무 배정 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 5.7 방문 인증
**PATCH** `/works/assignments/{assignmentId}/visit`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "status": "VISITED",
    "visitedAt": "2025-10-20T14:30:00"
  },
  "message": "방문 인증 완료",
  "timestamp": "2025-10-20T14:30:00"
}
```

### 5.8 회원가입 인증
**PATCH** `/works/assignments/{assignmentId}/registration`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "status": "REGISTERED",
    "registeredAt": "2025-10-20T15:00:00"
  },
  "message": "회원가입 인증 완료",
  "timestamp": "2025-10-20T15:00:00"
}
```

### 5.9 업무 CSV 다운로드 (관리자 전용)
**GET** `/works/csv/download`

**Query Parameters**
- `name` (optional): 이름 검색
- `region` (optional): 지역 검색
- `pharmacyName` (optional): 약국명 검색
- `userId` (optional): 사용자 ID

**Response** `200 OK`
```
Content-Type: text/csv
Content-Disposition: attachment; filename="works_20251020.csv"
```

## 6. 공지사항 API

### 6.1 공지사항 목록 조회
**GET** `/notices`

**Query Parameters**
- `page` (optional): 페이지 번호 (default: 0)
- `size` (optional): 페이지 크기 (default: 10)

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "category": "공지",
        "title": "2025년 하반기 일정 안내",
        "author": "관리자",
        "hasImage": true,
        "viewCount": 150,
        "createdAt": "2025-10-20T10:00:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "totalPages": 3,
      "totalElements": 25
    }
  },
  "message": "공지사항 목록 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 6.2 공지사항 상세 조회
**GET** `/notices/{id}`

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "id": 1,
    "category": "공지",
    "title": "2025년 하반기 일정 안내",
    "content": "<p>공지사항 내용...</p>",
    "author": "관리자",
    "hasImage": true,
    "viewCount": 151,
    "createdAt": "2025-10-20T10:00:00",
    "updatedAt": "2025-10-20T10:00:00"
  },
  "message": "공지사항 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 6.3 공지사항 등록 (관리자 전용)
**POST** `/notices`

**Request**
```json
{
  "category": "공지",
  "title": "2025년 하반기 일정 안내",
  "content": "<p>공지사항 내용...</p>",
  "author": "관리자",
  "hasImage": true
}
```

**Response** `201 Created`

### 6.4 공지사항 수정 (관리자 전용)
**PUT** `/notices/{id}`

**Request**
```json
{
  "category": "공지",
  "title": "2025년 하반기 일정 안내 (수정)",
  "content": "<p>공지사항 내용...</p>",
  "author": "관리자",
  "hasImage": true
}
```

**Response** `200 OK`

### 6.5 공지사항 삭제 (관리자 전용)
**DELETE** `/notices/{id}`

**Response** `204 No Content`

### 6.6 공지사항 조회수 증가
**PATCH** `/notices/{id}/view`

**Response** `204 No Content`

## 7. 관리자 대시보드 API

### 7.1 대시보드 통계
**GET** `/admin/dashboard`

**Query Parameters**
- `startDate` (optional): 시작일 (YYYY-MM-DD)
- `endDate` (optional): 종료일 (YYYY-MM-DD)

**Response** `200 OK`
```json
{
  "success": true,
  "data": {
    "today": {
      "pharmacyVisits": 25,
      "registrations": 15,
      "conversionRate": 60.0
    },
    "week": {
      "pharmacyVisits": 180,
      "registrations": 120,
      "conversionRate": 66.67
    },
    "total": {
      "pharmacyVisits": 1200,
      "registrations": 800,
      "conversionRate": 66.67
    }
  },
  "message": "대시보드 통계 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 7.2 랭킹 조회
**GET** `/admin/rankings`

**Query Parameters**
- `period`: `daily` | `weekly` | `monthly`
- `date` (optional): 기준일 (YYYY-MM-DD, default: 오늘)

**Response** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "rank": 1,
      "user": {
        "id": 1,
        "name": "홍길동",
        "university": "서울대학교"
      },
      "visitCount": 14,
      "registrationCount": 10,
      "totalScore": 24,
      "conversionRate": 71.43,
      "firstRecordTime": "2025-10-20T09:00:00"
    },
    {
      "rank": 2,
      "user": {
        "id": 2,
        "name": "김철수",
        "university": "연세대학교"
      },
      "visitCount": 12,
      "registrationCount": 8,
      "totalScore": 20,
      "conversionRate": 66.67,
      "firstRecordTime": "2025-10-20T09:15:00"
    }
  ],
  "message": "랭킹 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

### 7.3 통계 그래프 데이터
**GET** `/admin/statistics`

**Query Parameters**
- `groupBy`: `day` | `week` | `month`
- `startDate`: 시작일 (YYYY-MM-DD)
- `endDate`: 종료일 (YYYY-MM-DD)

**Response** `200 OK`
```json
{
  "success": true,
  "data": [
    {
      "date": "2025-10-20",
      "pharmacyVisits": 25,
      "registrations": 15,
      "conversionRate": 60.0
    },
    {
      "date": "2025-10-21",
      "pharmacyVisits": 30,
      "registrations": 20,
      "conversionRate": 66.67
    }
  ],
  "message": "통계 데이터 조회 성공",
  "timestamp": "2025-10-20T10:00:00"
}
```

## 8. 에러 코드

| 에러 코드 | 설명 | HTTP 상태 |
|----------|------|-----------|
| AUTH_001 | 인증 토큰이 유효하지 않음 | 401 |
| AUTH_002 | 인증 토큰이 만료됨 | 401 |
| AUTH_003 | 로그인 정보가 올바르지 않음 | 401 |
| AUTH_004 | 권한이 없음 | 403 |
| AUTH_005 | 승인되지 않은 사용자 | 403 |
| USER_001 | 사용자를 찾을 수 없음 | 404 |
| USER_002 | 이미 존재하는 이메일 | 409 |
| USER_003 | 유효하지 않은 사용자 정보 | 400 |
| PHARMACY_001 | 약국을 찾을 수 없음 | 404 |
| PHARMACY_002 | 중복된 약국 | 409 |
| WORK_001 | 업무를 찾을 수 없음 | 404 |
| WORK_002 | 업무 배정을 찾을 수 없음 | 404 |
| WORK_003 | 이미 배정된 업무 | 409 |
| NOTICE_001 | 공지사항을 찾을 수 없음 | 404 |
| FILE_001 | 파일 업로드 실패 | 400 |
| FILE_002 | 잘못된 파일 형식 | 400 |
| FILE_003 | 파일 크기 초과 | 400 |
| VALIDATION_001 | 유효성 검증 실패 | 400 |
| SERVER_001 | 서버 내부 오류 | 500 |

## 9. 페이지네이션

모든 목록 조회 API는 다음과 같은 페이지네이션 파라미터를 지원합니다:

**Query Parameters**
- `page`: 페이지 번호 (0부터 시작, default: 0)
- `size`: 페이지 크기 (default: 10, max: 100)
- `sort`: 정렬 기준 (예: `createdAt,desc`)

**Response Structure**
```json
{
  "content": [],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10,
    "totalPages": 5,
    "totalElements": 50,
    "first": true,
    "last": false
  }
}
```

## 10. 필터링 및 검색

대부분의 목록 조회 API는 필터링 및 검색을 지원합니다:

**Example**
```
GET /pharmacies?name=서울&address=강남구&page=0&size=10&sort=createdAt,desc
```

## 11. 날짜 형식

- **날짜**: `YYYY-MM-DD` (예: 2025-10-20)
- **날짜/시간**: ISO 8601 형식 `YYYY-MM-DDTHH:mm:ss` (예: 2025-10-20T10:00:00)
- **Timezone**: Asia/Seoul (KST)

## 12. API 버전 관리

향후 API 변경 시 다음과 같이 버전을 관리합니다:
- `/api/v1/...`
- `/api/v2/...`

현재는 버전 없이 `/api/...`를 사용합니다.

## 13. Rate Limiting

API 요청 제한:
- **인증된 사용자**: 1000 requests/hour
- **관리자**: 5000 requests/hour

제한 초과 시 `429 Too Many Requests` 응답

## 14. CORS

허용된 Origin:
- Development: `http://localhost:3000`
- Production: `https://picofriends.com`

허용된 Method: `GET, POST, PUT, PATCH, DELETE, OPTIONS`

## 15. API 테스트

### Swagger UI
```
http://localhost:8080/swagger-ui.html
```

### Postman Collection
프로젝트 루트의 `postman_collection.json` 파일을 Postman에서 Import하여 사용
