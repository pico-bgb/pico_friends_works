# 피코프렌즈 API 명세서

## 1. API 개요

### 1.1 기술 스택
- **Java 21**
- **Spring Boot 3.5.6**
- **Spring Security** (JWT 인증)
- **Spring Data JPA** + **QueryDSL**
- **PostgreSQL** (데이터베이스)
- **Redis** (토큰 저장소)
- **SpringDoc OpenAPI** (Swagger)
- **Gradle** (빌드 도구)

### 1.2 Base URL
```
개발: http://localhost:8080/api
운영: https://api.picofriends.com/api
```

### 1.3 인증 방식
- **JWT (JSON Web Token)** 기반 인증
- **Access Token**: 1시간 유효
- **Refresh Token**: 7일 유효
- **Redis** 기반 토큰 관리 및 블랙리스트
- **Authorization 헤더**: `Bearer {access_token}`

### 1.4 공통 응답 형식

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
    "message": "에러 메시지"
  }
}
```

### 1.5 역할 기반 접근 제어

| 역할 | 코드 | 설명 |
|------|------|------|
| 일반 사용자 | ROLE_USER | 피코프렌즈 영업사원 |
| 뷰어 | ROLE_VIEWER | 읽기 전용 사용자 |
| 관리자 | ROLE_ADMIN | 전체 권한 |

### 1.6 API 문서

애플리케이션 실행 후 Swagger UI 접속:
```
http://localhost:8080/swagger-ui.html
```

## 2. 인증 API (`/api/auth`)

### 2.1 로그인
```
POST /api/auth/login
```

**Request Body:**
```json
{
  "userid": "user001",
  "userpw": "password123"
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
    "member": {
      "id": 1,
      "memberNo": 123,
      "name": "홍길동",
      "email": "user@example.com",
      "status": "ACTIVE",
      "roles": ["ROLE_USER"]
    }
  }
}
```

**보안:**
- BCrypt 비밀번호 암호화 (10 rounds)
- Access Token은 Redis에 저장 (1시간 TTL)
- Refresh Token은 Redis에 저장 (7일 TTL)

### 2.2 로그아웃
```
POST /api/auth/logout
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

**처리 과정:**
1. Access Token을 Redis 블랙리스트에 추가
2. Refresh Token 삭제

### 2.3 토큰 갱신
```
POST /api/auth/refresh
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
    "tokenType": "Bearer",
    "expiresIn": 3600
  }
}
```

**처리 과정:**
1. Refresh Token 유효성 검증
2. Redis에서 Refresh Token 확인
3. 새로운 Access Token 발급
4. 기존 Access Token은 블랙리스트 추가

## 3. 피코프렌즈 멤버 관리 API (`/api/members`)

### 3.1 멤버 목록 조회 (관리자)
```
GET /api/admin/members?page=0&size=20&status=ACTIVE&search=홍길동
```

**Query Parameters:**
- `page`: 페이지 번호 (default: 0)
- `size`: 페이지 크기 (default: 20)
- `status`: 상태 필터 (PENDING, ACTIVE, INACTIVE)
- `search`: 검색어 (이름 또는 이메일)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "memberNo": 123,
        "name": "홍길동",
        "email": "user@example.com",
        "mobileNumber": "01012345678",
        "schoolCode": "SEOUL_UNIV",
        "schoolName": "서울대학교",
        "status": "ACTIVE",
        "description": "비고",
        "createDate": "2025-01-01T00:00:00Z"
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

### 3.2 멤버 승인/거부 (관리자)
```
PATCH /api/admin/members/{memberId}/status
```

**Request Body:**
```json
{
  "status": "ACTIVE",
  "description": "승인 완료"
}
```

### 3.3 현재 사용자 정보 조회
```
GET /api/members/me
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "memberNo": 123,
    "name": "홍길동",
    "email": "user@example.com",
    "mobileNumber": "01012345678",
    "schoolCode": "SEOUL_UNIV",
    "status": "ACTIVE",
    "roles": ["ROLE_USER"]
  }
}
```

## 4. 게시판 API (`/api/boards`)

### 4.1 게시판 타입

| 타입 | 코드 | 설명 | 권한 |
|------|------|------|------|
| 공지사항 | NOTICE | 관리자 공지 | 작성: ADMIN, 조회: ALL |
| 업무분배요청 | WORK_REQUEST | 업무 요청 | 작성: USER, 조회: ALL |

### 4.2 게시글 작성
```
POST /api/boards
```

**Request Body:**
```json
{
  "boardType": "WORK_REQUEST",
  "title": "제목",
  "content": "내용"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "boardType": "WORK_REQUEST",
    "title": "제목",
    "content": "내용",
    "writer": {
      "id": 1,
      "name": "홍길동"
    },
    "viewCount": 0,
    "isDeleted": false,
    "createDate": "2025-01-15T10:00:00Z"
  }
}
```

**권한 검증:**
- NOTICE: ROLE_ADMIN만 작성 가능
- WORK_REQUEST: ROLE_USER 이상 작성 가능

### 4.3 게시글 목록 조회
```
GET /api/boards?boardType=NOTICE&page=0&size=20
```

**Query Parameters:**
- `boardType`: 게시판 타입 (NOTICE, WORK_REQUEST)
- `page`, `size`: 페이지네이션

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "boardType": "NOTICE",
        "title": "2025년 상반기 활동 안내",
        "content": "내용...",
        "writer": {
          "id": 1,
          "name": "관리자"
        },
        "viewCount": 100,
        "isDeleted": false,
        "createDate": "2025-01-01T00:00:00Z"
      }
    ],
    "page": { ... }
  }
}
```

**필터링:**
- 소프트 삭제된 게시글(is_deleted=true)은 제외

### 4.4 게시글 상세 조회
```
GET /api/boards/{id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "boardType": "NOTICE",
    "title": "제목",
    "content": "내용",
    "writer": {
      "id": 1,
      "name": "관리자"
    },
    "viewCount": 101,
    "isDeleted": false,
    "createDate": "2025-01-01T00:00:00Z",
    "updateDate": "2025-01-01T00:00:00Z"
  }
}
```

**처리:**
- 조회수 자동 증가 (viewCount++)

### 4.5 게시글 수정
```
PUT /api/boards/{id}
```

**Request Body:**
```json
{
  "title": "수정된 제목",
  "content": "수정된 내용"
}
```

**소유권 검증:**
- 작성자 본인만 수정 가능
- 관리자는 모든 게시글 수정 가능

### 4.6 게시글 삭제 (소프트 삭제)
```
DELETE /api/boards/{id}
```

**Response (200):**
```json
{
  "success": true,
  "message": "게시글이 삭제되었습니다."
}
```

**처리:**
- is_deleted 플래그를 true로 설정 (물리적 삭제 아님)
- 작성자 본인 또는 관리자만 삭제 가능

## 5. 약국 관리 API (`/api/pharmacies`)

### 5.1 방문 상태 코드

| 상태 | 코드 | 설명 |
|------|------|------|
| 미방문 | NOT_VISITED | 아직 방문하지 않음 |
| 방문완료 | VISITED | 방문 완료 |
| 방문거절 | REJECTED | 약국에서 방문 거절 |

### 5.2 약국 등록
```
POST /api/pharmacies
```

**Request Body:**
```json
{
  "businessNumber": "1234567890",
  "name": "OOO약국",
  "address": "서울시 강남구 테헤란로 123",
  "telNumber": "021234567"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "businessNumber": "1234567890",
    "name": "OOO약국",
    "address": "서울시 강남구 테헤란로 123",
    "telNumber": "021234567",
    "chargeMember": {
      "id": 1,
      "name": "홍길동"
    },
    "isVisited": false,
    "createDate": "2025-01-15T10:00:00Z"
  }
}
```

**처리:**
- charge_member_id는 로그인한 사용자로 자동 설정
- business_number 중복 체크

### 5.3 내 약국 목록 조회
```
GET /api/pharmacies/my?page=0&size=20
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "businessNumber": "1234567890",
        "name": "OOO약국",
        "address": "서울시 강남구 테헤란로 123",
        "telNumber": "021234567",
        "isVisited": false,
        "reportCount": 2,
        "createDate": "2025-01-15T10:00:00Z"
      }
    ],
    "page": { ... }
  }
}
```

**필터링:**
- 로그인한 사용자의 charge_member_id와 일치하는 약국만 조회

### 5.4 약국 상세 조회
```
GET /api/pharmacies/{id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "businessNumber": "1234567890",
    "name": "OOO약국",
    "address": "서울시 강남구 테헤란로 123",
    "telNumber": "021234567",
    "chargeMember": {
      "id": 1,
      "name": "홍길동",
      "email": "user@example.com"
    },
    "isVisited": false,
    "reports": [
      {
        "id": 1,
        "survey": {
          "version": "1.0.0",
          "title": "2025년 상반기 설문"
        },
        "createDate": "2025-01-16T10:00:00Z"
      }
    ],
    "createDate": "2025-01-15T10:00:00Z",
    "updateDate": "2025-01-15T10:00:00Z"
  }
}
```

### 5.5 약국 수정
```
PUT /api/pharmacies/{id}
```

**Request Body:**
```json
{
  "name": "OOO약국",
  "address": "서울시 강남구 테헤란로 456",
  "telNumber": "029876543"
}
```

**소유권 검증:**
- 담당자 본인만 수정 가능 (charge_member_id 확인)

**변경 이력 자동 추적:**
- 수정된 필드는 t_pico_friends_pharmacy_history에 자동 기록
- 변경 전/후 값 저장

### 5.6 약국 삭제
```
DELETE /api/pharmacies/{id}
```

**Response (200):**
```json
{
  "success": true,
  "message": "약국이 삭제되었습니다."
}
```

**소유권 검증:**
- 담당자 본인만 삭제 가능

### 5.7 약국 변경 이력 조회 (관리자)
```
GET /api/admin/pharmacies/{pharmacyId}/history
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "changeColumnName": "address",
      "beforeValue": "서울시 강남구 테헤란로 123",
      "afterValue": "서울시 강남구 테헤란로 456",
      "changedBy": {
        "id": 1,
        "name": "홍길동"
      },
      "createDate": "2025-01-20T10:00:00Z"
    }
  ]
}
```

## 6. 설문지 관리 API (`/api/surveys`)

### 6.1 활성 설문지 조회
```
GET /api/surveys/active
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "title": "2025년 상반기 약국 설문조사",
    "description": "약국 현황 파악을 위한 설문",
    "version": "1.0.0",
    "questions": [
      {
        "id": 1,
        "questionCode": "BASIC_Q1",
        "questionText": "약국명을 입력해주세요",
        "questionType": "TEXT",
        "displayOrder": 1,
        "isRequired": true,
        "config": {
          "placeholder": "예: OOO약국"
        }
      }
    ]
  }
}
```

### 6.2 설문지 생성 (관리자)
```
POST /api/admin/surveys
```

**Request Body:**
```json
{
  "title": "2025년 하반기 약국 설문조사",
  "description": "약국 현황 파악",
  "version": "2.0.0",
  "questions": [
    {
      "questionCode": "BASIC_Q1",
      "questionText": "약국명을 입력해주세요",
      "questionType": "TEXT",
      "displayOrder": 1,
      "isRequired": true,
      "config": {
        "placeholder": "예: OOO약국"
      }
    }
  ]
}
```

### 6.3 설문지 활성화 (관리자)
```
PATCH /api/admin/surveys/{surveyId}/activate
```

**처리:**
- 기존 활성 설문지(is_active=true)를 비활성화
- 선택한 설문지를 활성화
- 항상 1개의 활성 설문지만 존재

## 7. 리포트 API (`/api/reports`)

### 7.1 리포트 작성 (약국 방문 메모)
```
POST /api/reports
```

**Request Body:**
```json
{
  "pharmacyId": 1,
  "surveyId": 1,
  "answers": {
    "BASIC_Q1": {
      "value": "OOO약국",
      "type": "TEXT"
    },
    "PRODUCT_Q1": {
      "value": "전문의약품",
      "type": "RADIO"
    },
    "PRODUCT_Q2": {
      "value": ["HMP몰", "새로망"],
      "type": "CHECKBOX"
    }
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "pharmacy": {
      "id": 1,
      "name": "OOO약국"
    },
    "survey": {
      "id": 1,
      "version": "1.0.0"
    },
    "createDate": "2025-01-15T10:30:00Z"
  },
  "message": "리포트가 작성되었습니다."
}
```

**비즈니스 룰:**
- 약국 + 설문 + 작성자 조합은 유일 (중복 작성 불가)
- 로그인한 사용자의 리포트만 작성 가능

### 7.2 내 리포트 목록 조회
```
GET /api/reports/my?page=0&size=20&pharmacyId=1
```

**Query Parameters:**
- `pharmacyId`: 약국 ID 필터 (선택사항)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "content": [
      {
        "id": 1,
        "pharmacy": {
          "id": 1,
          "name": "OOO약국",
          "businessNumber": "1234567890"
        },
        "survey": {
          "id": 1,
          "version": "1.0.0",
          "title": "2025년 상반기 설문"
        },
        "createDate": "2025-01-15T10:30:00Z",
        "updateDate": "2025-01-15T11:00:00Z"
      }
    ],
    "page": { ... }
  }
}
```

**필터링:**
- 로그인한 사용자(create_no)의 리포트만 조회

### 7.3 리포트 상세 조회
```
GET /api/reports/{id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "pharmacy": { ... },
    "survey": { ... },
    "answers": {
      "BASIC_Q1": {
        "value": "OOO약국",
        "type": "TEXT"
      },
      ...
    },
    "creator": {
      "id": 1,
      "name": "홍길동"
    },
    "createDate": "2025-01-15T10:30:00Z",
    "updateDate": "2025-01-15T10:30:00Z"
  }
}
```

**소유권 검증:**
- 본인의 리포트만 조회 가능
- 관리자는 모든 리포트 조회 가능

### 7.4 리포트 수정
```
PUT /api/reports/{id}
```

**Request Body:**
```json
{
  "answers": {
    "BASIC_Q1": {
      "value": "수정된 약국명",
      "type": "TEXT"
    },
    ...
  }
}
```

**소유권 검증:**
- 본인의 리포트만 수정 가능

### 7.5 리포트 삭제
```
DELETE /api/reports/{id}
```

**소유권 검증:**
- 본인의 리포트만 삭제 가능

## 8. 통계 API (`/api/statistics`) - 관리자 전용

### 8.1 대시보드 통계
```
GET /api/admin/statistics/dashboard
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalMembers": 37,
    "activeMembers": 30,
    "totalPharmacies": 500,
    "visitedPharmacies": 350,
    "totalReports": 400,
    "visitRate": 70.0
  }
}
```

### 8.2 약국별 회원 수 통계 (QueryDSL)
```
GET /api/statistics/pharmacy-members
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "pharmacyId": 1,
      "pharmacyName": "OOO약국",
      "memberCount": 5,
      "reportCount": 12
    }
  ]
}
```

**구현:**
- QueryDSL을 사용한 복잡한 집계 쿼리
- 약국별 담당 멤버 수 및 리포트 수 계산

### 8.3 영업사원별 실적 통계
```
GET /api/admin/statistics/members?startDate=2025-01-01&endDate=2025-01-31
```

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "memberId": 1,
      "memberName": "홍길동",
      "totalPharmacies": 50,
      "visitedPharmacies": 35,
      "totalReports": 40,
      "visitRate": 70.0
    }
  ]
}
```

### 8.4 설문 응답 통계 (특정 질문)
```
GET /api/admin/statistics/survey-answers?surveyId=1&questionCode=PRODUCT_Q1
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "questionCode": "PRODUCT_Q1",
    "questionText": "주력 판매 상품군은 무엇입니까?",
    "questionType": "RADIO",
    "totalResponses": 100,
    "distribution": [
      {
        "value": "전문의약품",
        "count": 60,
        "percentage": 60.0
      },
      {
        "value": "일반의약품",
        "count": 30,
        "percentage": 30.0
      }
    ]
  }
}
```

**구현:**
- PostgreSQL JSONB 쿼리 활용
- QueryDSL로 복잡한 통계 계산

## 9. 파일 관리 API (`/api/files`)

### 9.1 파일 업로드
```
POST /api/files/upload
```

**Request:** multipart/form-data
```
file: (파일)
referenceType: "PHARMACY" | "REPORT"
referenceId: 1
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "fileId": 1,
    "referenceType": "REPORT",
    "referenceId": 1,
    "fileUrl": "https://storage.picofriends.com/files/abc123.jpg",
    "fileName": "abc123.jpg",
    "fileSize": 102400
  }
}
```

### 9.2 파일 목록 조회
```
GET /api/files?referenceType=REPORT&referenceId=1
```

## 10. 에러 코드

| HTTP | 코드 | 메시지 |
|------|------|--------|
| 401 | INVALID_CREDENTIALS | 로그인 정보가 올바르지 않습니다. |
| 401 | TOKEN_EXPIRED | 토큰이 만료되었습니다. |
| 401 | TOKEN_BLACKLISTED | 블랙리스트에 등록된 토큰입니다. |
| 403 | ACCESS_DENIED | 접근 권한이 없습니다. |
| 403 | NOT_OWNER | 본인의 리소스만 접근할 수 있습니다. |
| 404 | MEMBER_NOT_FOUND | 멤버를 찾을 수 없습니다. |
| 404 | PHARMACY_NOT_FOUND | 약국을 찾을 수 없습니다. |
| 404 | SURVEY_NOT_FOUND | 설문지를 찾을 수 없습니다. |
| 404 | REPORT_NOT_FOUND | 리포트를 찾을 수 없습니다. |
| 404 | BOARD_NOT_FOUND | 게시글을 찾을 수 없습니다. |
| 400 | DUPLICATE_BUSINESS_NUMBER | 이미 등록된 사업자번호입니다. |
| 400 | DUPLICATE_EMAIL | 이미 사용 중인 이메일입니다. |
| 400 | DUPLICATE_REPORT | 이미 작성한 리포트가 있습니다. |
| 400 | INVALID_BOARD_TYPE | 해당 게시판에 글을 작성할 권한이 없습니다. |

## 11. 보안

### 11.1 인증 보안
- **BCrypt**: 비밀번호 암호화 (10 rounds)
- **JWT**: HS256 알고리즘
- **JWT Secret**: 최소 256비트 이상의 안전한 키
- **Token Storage**: Redis에 저장
- **Token Blacklist**: 로그아웃 시 블랙리스트 등록

### 11.2 Redis 토큰 관리
```
# Access Token 저장
Key: access_token:{userId}
Value: {accessToken}
TTL: 3600 (1시간)

# Refresh Token 저장
Key: refresh_token:{userId}
Value: {refreshToken}
TTL: 604800 (7일)

# Blacklist
Key: blacklist:{accessToken}
Value: "logout"
TTL: 3600 (남은 유효시간)
```

### 11.3 CORS 설정
```yaml
# application.yml
spring:
  web:
    cors:
      allowed-origins:
        - http://localhost:3000
        - https://www.picofriends.com
      allowed-methods: GET, POST, PUT, DELETE, PATCH, OPTIONS
      allowed-headers: "*"
      allow-credentials: true
```

## 12. 환경 설정

### 12.1 필수 환경 변수

```bash
# Database
DB_USERNAME=postgres
DB_PASSWORD=your-password

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379
REDIS_PASSWORD=

# JWT
JWT_SECRET=your-secret-key-must-be-at-least-256-bits-long-change-this-in-production
```

### 12.2 데이터베이스 초기화

```bash
# src/main/resources/db/migration/ 디렉토리의 스크립트 순서대로 실행
psql -U postgres -d pico_friends -f V1__create_tables.sql
psql -U postgres -d pico_friends -f V2__insert_common_codes.sql
```

## 13. 개발 가이드

### 13.1 로컬 개발 환경 구성

```bash
# 1. Redis 실행
docker run -d -p 6379:6379 redis:latest

# 2. PostgreSQL 실행 (Docker)
docker run -d -p 5432:5432 \
  -e POSTGRES_DB=pico_friends \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=password \
  postgres:14

# 3. QueryDSL Q-클래스 생성
./gradlew compileJava

# 4. 애플리케이션 실행
./gradlew bootRun
```

### 13.2 테스트

```bash
# 전체 테스트
./gradlew test

# 특정 테스트
./gradlew test --tests "PharmacyServiceTest"

# 테스트 커버리지
./gradlew test jacocoTestReport
```

### 13.3 빌드

```bash
# JAR 파일 생성
./gradlew build

# Docker 이미지 빌드
docker build -t picofriends-api:latest .
```

## 14. 참고 문서

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/v3/api-docs
- **GitHub Repository**: https://github.com/yourorg/pico-friends-api
- **Jira**: https://picoinnov.atlassian.net

