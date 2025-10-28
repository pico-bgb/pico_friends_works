# 피코프렌즈 API 명세서

## 1. API 개요

### 1.1 Base URL
```
개발: http://localhost:8080/api/v1
운영: https://api.picofriends.com/api/v1
```

### 1.2 인증 방식
- JWT (JSON Web Token) 기반 인증
- Authorization 헤더에 Bearer 토큰 포함
```
Authorization: Bearer {access_token}
```

### 1.3 공통 응답 형식

#### 성공 응답
```json
{
  "success": true,
  "data": { ... },
  "message": "Success"
}
```

#### 에러 응답
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "에러 메시지",
    "details": { ... }
  }
}
```

#### HTTP 상태 코드
- `200`: 성공
- `201`: 생성 성공
- `400`: 잘못된 요청
- `401`: 인증 실패
- `403`: 권한 없음
- `404`: 리소스 없음
- `500`: 서버 에러

### 1.4 페이지네이션
```json
{
  "content": [ ... ],
  "page": {
    "number": 0,
    "size": 20,
    "totalElements": 100,
    "totalPages": 5
  }
}
```

## 2. 인증 API

### 2.1 회원가입
```
POST /auth/register
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "phone": "010-1234-5678",
  "university": "서울대학교"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "role": "FIELD_AGENT",
    "status": "PENDING"
  },
  "message": "회원가입이 완료되었습니다. 관리자 승인을 기다려주세요."
}
```

### 2.2 로그인
```
POST /auth/login
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "name": "홍길동",
      "role": "FIELD_AGENT",
      "status": "APPROVED"
    }
  }
}
```

### 2.3 토큰 갱신
```
POST /auth/refresh
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600
  }
}
```

### 2.4 로그아웃
```
POST /auth/logout
```

**Headers:**
```
Authorization: Bearer {access_token}
```

**Response (200):**
```json
{
  "success": true,
  "message": "로그아웃되었습니다."
}
```

## 3. 사용자 관리 API

### 3.1 현재 사용자 정보 조회
```
GET /users/me
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "홍길동",
    "phone": "010-1234-5678",
    "role": "FIELD_AGENT",
    "university": "서울대학교",
    "status": "APPROVED",
    "profileImageUrl": "https://...",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### 3.2 사용자 목록 조회 (관리자)
```
GET /admin/users?page=0&size=20&role=FIELD_AGENT&status=APPROVED&search=홍길동
```

**Query Parameters:**
- `page`: 페이지 번호 (0부터 시작)
- `size`: 페이지 크기
- `role`: 역할 필터 (ADMIN, FIELD_AGENT, PENDING)
- `status`: 상태 필터 (PENDING, APPROVED, REJECTED, SUSPENDED)
- `search`: 검색어 (이름 또는 이메일)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "email": "user@example.com",
        "name": "홍길동",
        "phone": "010-1234-5678",
        "role": "FIELD_AGENT",
        "university": "서울대학교",
        "status": "APPROVED",
        "createdAt": "2025-01-01T00:00:00Z"
      }
    ],
    "page": {
      "number": 0,
      "size": 20,
      "totalElements": 50,
      "totalPages": 3
    }
  }
}
```

### 3.3 사용자 생성 (관리자)
```
POST /admin/users
```

**Request Body:**
```json
{
  "email": "newuser@example.com",
  "password": "password123",
  "name": "김철수",
  "phone": "010-9876-5432",
  "role": "FIELD_AGENT",
  "university": "고려대학교",
  "status": "APPROVED"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "email": "newuser@example.com",
    "name": "김철수",
    "role": "FIELD_AGENT",
    "status": "APPROVED"
  }
}
```

### 3.4 사용자 수정 (관리자)
```
PUT /admin/users/{userId}
```

**Request Body:**
```json
{
  "name": "김철수",
  "phone": "010-9876-5432",
  "role": "FIELD_AGENT",
  "university": "고려대학교",
  "status": "APPROVED"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "email": "newuser@example.com",
    "name": "김철수",
    "role": "FIELD_AGENT",
    "status": "APPROVED"
  }
}
```

### 3.5 사용자 삭제 (관리자)
```
DELETE /admin/users/{userId}
```

**Response (200):**
```json
{
  "success": true,
  "message": "사용자가 삭제되었습니다."
}
```

### 3.6 사용자 승인/거부 (관리자)
```
PATCH /admin/users/{userId}/approval
```

**Request Body:**
```json
{
  "status": "APPROVED"
  // APPROVED, REJECTED
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 2,
    "status": "APPROVED"
  },
  "message": "사용자가 승인되었습니다."
}
```

### 3.7 CSV Export (관리자)
```
GET /admin/users/export?role=FIELD_AGENT&status=APPROVED
```

**Response:** CSV 파일 다운로드

### 3.8 CSV Import (관리자)
```
POST /admin/users/import
```

**Request:** multipart/form-data
```
file: users.csv
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalRows": 100,
    "successCount": 95,
    "errorCount": 5,
    "errors": [
      {
        "row": 10,
        "error": "이메일 중복"
      }
    ]
  }
}
```

## 4. 약국 관리 API

### 4.1 약국 목록 조회
```
GET /pharmacies?page=0&size=20&search=약국명&region=서울시
```

**Query Parameters:**
- `page`, `size`: 페이지네이션
- `search`: 검색어 (약국명)
- `region`: 지역 필터

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "name": "OOO약국",
        "businessNumber": "000-0000-0000",
        "address": "서울시 강남구 테헤란로 123",
        "phone": "02-1234-5678",
        "pharmacistName": "홍약사",
        "region": "서울시",
        "district": "강남구"
      }
    ],
    "page": { ... }
  }
}
```

### 4.2 약국 상세 조회
```
GET /pharmacies/{pharmacyId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "OOO약국",
    "businessNumber": "000-0000-0000",
    "address": "서울시 강남구 테헤란로 123",
    "phone": "02-1234-5678",
    "pharmacistName": "홍약사",
    "contactNumber": "010-1234-5678",
    "region": "서울시",
    "district": "강남구",
    "notes": "관리자 메모",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### 4.3 약국 생성 (관리자)
```
POST /admin/pharmacies
```

**Request Body:**
```json
{
  "name": "OOO약국",
  "businessNumber": "000-0000-0000",
  "address": "서울시 강남구 테헤란로 123",
  "phone": "02-1234-5678",
  "pharmacistName": "홍약사",
  "contactNumber": "010-1234-5678",
  "region": "서울시",
  "district": "강남구",
  "notes": "메모"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "OOO약국",
    ...
  }
}
```

### 4.4 약국 수정 (관리자)
```
PUT /admin/pharmacies/{pharmacyId}
```

**Request Body:** (약국 생성과 동일)

### 4.5 약국 삭제 (관리자)
```
DELETE /admin/pharmacies/{pharmacyId}
```

### 4.6 약국 방문 히스토리 조회
```
GET /pharmacies/{pharmacyId}/visits
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "visitId": 1,
      "visitDate": "2025-01-15T10:30:00Z",
      "userName": "홍길동",
      "userEmail": "user@example.com",
      "photoUrl": "https://...",
      "surveyId": 1,
      "registrationId": null,
      "registrationDate": null,
      "notes": "방문 메모"
    }
  ]
}
```

### 4.7 CSV Export (관리자)
```
GET /admin/pharmacies/export
```

### 4.8 CSV Import (관리자)
```
POST /admin/pharmacies/import
```

## 5. 업무 관리 API

### 5.1 배정된 업무 목록 조회 (피코프렌즈)
```
GET /tasks/my?status=ASSIGNED&date=2025-01-15
```

**Query Parameters:**
- `status`: 업무 상태 (ASSIGNED, IN_PROGRESS, COMPLETED)
- `date`: 날짜 필터

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "taskId": 1,
      "pharmacy": {
        "id": 1,
        "name": "OOO약국",
        "businessNumber": "000-0000-0000",
        "address": "서울시 강남구 테헤란로 123",
        "phone": "02-1234-5678"
      },
      "status": "ASSIGNED",
      "assignedAt": "2025-01-10T09:00:00Z",
      "completedAt": null
    }
  ]
}
```

### 5.2 업무 목록 조회 (관리자)
```
GET /admin/tasks?page=0&size=20&userId=1&pharmacyId=2&status=ASSIGNED
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "user": {
          "id": 1,
          "name": "홍길동",
          "email": "user@example.com"
        },
        "pharmacy": {
          "id": 1,
          "name": "OOO약국",
          "address": "서울시 강남구 테헤란로 123"
        },
        "status": "ASSIGNED",
        "assignedAt": "2025-01-10T09:00:00Z",
        "completedAt": null,
        "notes": "관리자 메모"
      }
    ],
    "page": { ... }
  }
}
```

### 5.3 업무 배정 (관리자)
```
POST /admin/tasks/assign
```

**Request Body:**
```json
{
  "userIds": [1, 2, 3],
  "pharmacyIds": [10, 11, 12],
  "notes": "주의사항"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "totalAssigned": 9,
    "tasks": [
      {
        "id": 1,
        "userId": 1,
        "pharmacyId": 10,
        "status": "ASSIGNED"
      }
    ]
  },
  "message": "9개 업무가 배정되었습니다."
}
```

### 5.4 업무 수정 (관리자)
```
PUT /admin/tasks/{taskId}
```

**Request Body:**
```json
{
  "status": "COMPLETED",
  "notes": "수정된 메모"
}
```

### 5.5 업무 삭제 (관리자)
```
DELETE /admin/tasks/{taskId}
```

### 5.6 업무 CSV Export (관리자)
```
GET /admin/tasks/export
```

## 6. 방문 기록 API

### 6.1 방문 인증
```
POST /visits
```

**Request:** multipart/form-data
```
taskId: 1
pharmacyId: 1
photo: (image file)
latitude: 37.123456
longitude: 127.123456
notes: "방문 메모"
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "visitId": 1,
    "taskId": 1,
    "pharmacyId": 1,
    "photoUrl": "https://...",
    "visitedAt": "2025-01-15T10:30:00Z"
  },
  "message": "방문 인증이 완료되었습니다."
}
```

### 6.2 방문 기록 목록 조회
```
GET /visits?page=0&size=20&userId=1&pharmacyId=2
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "user": {
          "id": 1,
          "name": "홍길동"
        },
        "pharmacy": {
          "id": 1,
          "name": "OOO약국"
        },
        "photoUrl": "https://...",
        "visitedAt": "2025-01-15T10:30:00Z",
        "notes": "방문 메모"
      }
    ],
    "page": { ... }
  }
}
```

## 7. 설문조사 API

### 7.1 설문조사 제출
```
POST /surveys
```

**Request Body:**
```json
{
  "visitId": 1,
  "pharmacyId": 1,
  "responses": {
    "pharmacy_info": {
      "name": "OOO약국",
      "manager": "홍약사",
      "phone": "010-1234-5678"
    },
    "online_usage": {
      "platforms": ["HMP몰", "새로망"],
      "other": null
    },
    "main_products": "전문의약품",
    "urgent_needs": "고혈압 치료제",
    "marketing_concerns": ["SNS 광고", "지역 홍보물"],
    "pico_feedback": "매우 좋음",
    "additional_notes": "추가 메모"
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "surveyId": 1,
    "visitId": 1,
    "pharmacyId": 1,
    "submittedAt": "2025-01-15T10:45:00Z"
  },
  "message": "설문조사가 제출되었습니다."
}
```

### 7.2 설문조사 조회
```
GET /surveys/{surveyId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "visit": {
      "id": 1,
      "visitedAt": "2025-01-15T10:30:00Z"
    },
    "pharmacy": {
      "id": 1,
      "name": "OOO약국"
    },
    "user": {
      "id": 1,
      "name": "홍길동"
    },
    "responses": { ... },
    "submittedAt": "2025-01-15T10:45:00Z"
  }
}
```

### 7.3 설문조사 목록 조회
```
GET /admin/surveys?page=0&size=20&userId=1&pharmacyId=2
```

## 8. 약국 회원가입 API

### 8.1 약국 회원가입 등록
```
POST /pharmacy-registrations
```

**Request Body:**
```json
{
  "pharmacyId": 1,
  "visitId": 1,
  "notes": "메모"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "pharmacyId": 1,
    "visitId": 1,
    "userId": 1,
    "registeredAt": "2025-01-15T11:00:00Z",
    "status": "ACTIVE"
  },
  "message": "약국 회원가입이 등록되었습니다."
}
```

## 9. 공지사항 API

### 9.1 공지사항 목록 조회
```
GET /notices?page=0&size=10&category=일반
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "title": "2025년 상반기 활동 안내",
        "content": "공지사항 내용...",
        "category": "일반",
        "author": {
          "id": 1,
          "name": "관리자"
        },
        "imageUrl": "https://...",
        "isPinned": true,
        "viewCount": 100,
        "publishedAt": "2025-01-01T00:00:00Z",
        "createdAt": "2025-01-01T00:00:00Z"
      }
    ],
    "page": { ... }
  }
}
```

### 9.2 공지사항 상세 조회
```
GET /notices/{noticeId}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "2025년 상반기 활동 안내",
    "content": "공지사항 내용...",
    "category": "일반",
    "author": {
      "id": 1,
      "name": "관리자"
    },
    "imageUrl": "https://...",
    "isPinned": true,
    "viewCount": 101,
    "publishedAt": "2025-01-01T00:00:00Z",
    "createdAt": "2025-01-01T00:00:00Z"
  }
}
```

### 9.3 공지사항 생성 (관리자)
```
POST /admin/notices
```

**Request:** multipart/form-data
```
title: "제목"
content: "내용"
category: "일반"
isPinned: true
image: (image file, optional)
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "제목",
    ...
  }
}
```

### 9.4 공지사항 수정 (관리자)
```
PUT /admin/notices/{noticeId}
```

### 9.5 공지사항 삭제 (관리자)
```
DELETE /admin/notices/{noticeId}
```

## 10. 통계 API

### 10.1 대시보드 요약 통계
```
GET /admin/statistics/dashboard
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalPharmacies": 500,
    "totalAgents": 37,
    "totalVisits": 1200,
    "totalRegistrations": 300,
    "todayVisits": 50,
    "todayRegistrations": 12,
    "conversionRate": 25.0,
    "weeklyVisits": [
      {
        "date": "2025-01-13",
        "count": 10
      }
    ]
  }
}
```

### 10.2 사용자별 통계
```
GET /admin/statistics/users?startDate=2025-01-01&endDate=2025-01-31
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "userId": 1,
      "userName": "홍길동",
      "university": "서울대학교",
      "visitCount": 50,
      "registrationCount": 12,
      "totalScore": 1700,
      "conversionRate": 24.0
    }
  ]
}
```

### 10.3 CSV Export
```
GET /admin/statistics/export?startDate=2025-01-01&endDate=2025-01-31
```

## 11. 리더보드 API

### 11.1 리더보드 조회
```
GET /leaderboard?weekStartDate=2025-01-15
```

**Query Parameters:**
- `weekStartDate`: 주차 시작일 (월요일, 옵션)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "weekStartDate": "2025-01-13",
    "rankings": [
      {
        "rank": 1,
        "rankChange": 0,
        "user": {
          "id": 1,
          "name": "홍길동",
          "university": "서울대학교"
        },
        "visitCount": 14,
        "registrationCount": 4,
        "totalScore": 540
      }
    ]
  }
}
```

### 11.2 내 순위 조회
```
GET /leaderboard/my-rank
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "rank": 5,
    "rankChange": 2,
    "visitCount": 10,
    "registrationCount": 2,
    "totalScore": 300
  }
}
```

## 12. 파일 업로드 API

### 12.1 이미지 업로드
```
POST /upload/image
```

**Request:** multipart/form-data
```
file: (image file)
type: visit_photo | profile_image | notice_image
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "fileUrl": "https://storage.picofriends.com/images/abc123.jpg",
    "fileName": "abc123.jpg",
    "fileSize": 102400,
    "contentType": "image/jpeg"
  }
}
```

## 13. 에러 코드

| 코드 | 메시지 | HTTP 상태 |
|------|--------|-----------|
| `INVALID_CREDENTIALS` | 이메일 또는 비밀번호가 올바르지 않습니다. | 401 |
| `TOKEN_EXPIRED` | 토큰이 만료되었습니다. | 401 |
| `INVALID_TOKEN` | 유효하지 않은 토큰입니다. | 401 |
| `UNAUTHORIZED` | 인증이 필요합니다. | 401 |
| `FORBIDDEN` | 권한이 없습니다. | 403 |
| `USER_NOT_FOUND` | 사용자를 찾을 수 없습니다. | 404 |
| `PHARMACY_NOT_FOUND` | 약국을 찾을 수 없습니다. | 404 |
| `TASK_NOT_FOUND` | 업무를 찾을 수 없습니다. | 404 |
| `EMAIL_ALREADY_EXISTS` | 이미 사용 중인 이메일입니다. | 400 |
| `INVALID_INPUT` | 입력값이 유효하지 않습니다. | 400 |
| `FILE_TOO_LARGE` | 파일 크기가 너무 큽니다. | 400 |
| `INVALID_FILE_TYPE` | 허용되지 않는 파일 형식입니다. | 400 |
| `INTERNAL_SERVER_ERROR` | 서버 오류가 발생했습니다. | 500 |

## 14. Rate Limiting

API 요청 빈도 제한:
- 인증 API: 분당 10회
- 일반 API: 분당 60회
- 파일 업로드: 분당 10회

초과 시 HTTP 429 (Too Many Requests) 반환

## 15. CORS 설정

허용된 Origins:
- `http://localhost:3000` (개발)
- `https://www.picofriends.com` (운영)
- `https://admin.picofriends.com` (백오피스)

허용된 Methods: GET, POST, PUT, DELETE, PATCH, OPTIONS

## 16. API 버전 관리

- 현재 버전: v1
- URL에 버전 포함: `/api/v1/...`
- 하위 호환성 유지
- 주요 변경 시 새 버전 출시 (v2, v3, ...)

