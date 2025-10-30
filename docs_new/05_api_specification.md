# 피코프렌즈 API 명세서 v1.0 (Phase 1)

> **버전**: 1.0
> **상태**: Phase 1 구현 완료
> **최종 업데이트**: 2025-10-29
> **포함 API**: 20개 엔드포인트

## 문서 정보

이 문서는 **실제 구현된 API만** 포함합니다. 미구현 기능은 [부록. Phase 2 이후 개발 예정 기능](#부록-phase-2-이후-개발-예정-기능)을 참고하세요.

## 1. API 개요

### 1.1 기술 스택
- **Java 21**
- **Spring Boot 3.3.5**
- **Spring Security** (JWT 인증)
- **Spring Data JPA** + **QueryDSL 5.0.0**
- **PostgreSQL** (데이터베이스)
- **Redis** (토큰 저장소)
- **SpringDoc OpenAPI 2.6.0** (Swagger)
- **Gradle** (빌드 도구)
- **패키지명**: `mall.pico_friends_api`

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

**⚠️ 프론트엔드 구현 필수사항:**
- Access Token이 1시간 후 만료되므로 **자동 갱신 로직**이 필요합니다
- 401 에러 발생 시 Refresh Token으로 자동 재발급 처리
- 토큰 만료 5분 전 선제적 갱신 권장

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

---

## 2. 인증 API (`/api/auth`)

### 2.1 회원가입
```
POST /api/auth/signup
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123",
  "name": "홍길동",
  "mobileNumber": "01012345678",
  "schoolCode": "SEOUL_UNIV"
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
    "mobileNumber": "01012345678",
    "schoolCode": "SEOUL_UNIV",
    "status": "PENDING"
  },
  "message": "회원가입 성공"
}
```

**참고:**
- 회원가입 시 초기 상태는 PENDING (승인 대기)
- 비밀번호는 BCrypt로 암호화되어 저장됨

### 2.2 로그인
```
POST /api/auth/login
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

### 2.3 로그아웃
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

### 2.4 토큰 갱신
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

**프론트엔드 자동 갱신 구현 가이드:**

1. **HTTP Interceptor 방식**
   ```javascript
   // API 응답 인터셉터에서 401 에러 처리
   axios.interceptors.response.use(
     response => response,
     async error => {
       if (error.response?.status === 401 && !error.config._retry) {
         error.config._retry = true;
         const refreshToken = getRefreshToken();
         const { accessToken } = await refreshAccessToken(refreshToken);
         error.config.headers.Authorization = `Bearer ${accessToken}`;
         return axios(error.config);
       }
       return Promise.reject(error);
     }
   );
   ```

2. **선제적 갱신 방식 (권장)**
   ```javascript
   // 토큰 만료 5분 전에 자동 갱신
   setInterval(async () => {
     const expiresAt = getTokenExpirationTime();
     const now = Date.now();
     if (expiresAt - now < 5 * 60 * 1000) { // 5분 전
       await refreshAccessToken();
     }
   }, 60000); // 1분마다 체크
   ```

3. **주의사항**
   - Refresh Token도 만료되면 재로그인 필요
   - 다중 탭 환경에서 토큰 동기화 고려 (localStorage 이벤트 활용)
   - 네트워크 오류 시 재시도 로직 구현

---

## 3. 게시판 API (`/api/boards`)

### 3.1 게시판 타입

| 타입 | 코드 | 설명 | 권한 |
|------|------|------|------|
| 공지사항 | NOTICE | 관리자 공지 | 작성: ADMIN, 조회: ALL |
| 업무분배요청 | WORK_REQUEST | 업무 요청 | 작성: USER, 조회: ALL |

### 3.2 게시글 작성
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

### 3.3 게시글 목록 조회
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
    "page": {
      "number": 0,
      "size": 20,
      "totalElements": 50,
      "totalPages": 3
    }
  }
}
```

**필터링:**
- 소프트 삭제된 게시글(is_deleted=true)은 제외

### 3.4 게시글 상세 조회
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

### 3.5 게시글 수정
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

### 3.6 게시글 삭제 (소프트 삭제)
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

---

## 4. 약국 관리 API (`/api/pharmacies`)

### 4.1 방문 상태 코드

| 상태 | 코드 | 설명 |
|------|------|------|
| 미방문 | NOT_VISITED | 아직 방문하지 않음 |
| 방문완료 | VISITED | 방문 완료 |
| 방문거절 | REJECTED | 약국에서 방문 거절 |

### 4.2 약국 등록
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

### 4.3 내 약국 목록 조회
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
    "page": {
      "number": 0,
      "size": 20,
      "totalElements": 10,
      "totalPages": 1
    }
  }
}
```

**필터링:**
- 로그인한 사용자의 charge_member_id와 일치하는 약국만 조회

### 4.4 약국 상세 조회
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
        "createDate": "2025-01-16T10:00:00Z"
      }
    ],
    "createDate": "2025-01-15T10:00:00Z",
    "updateDate": "2025-01-15T10:00:00Z"
  }
}
```

### 4.5 약국 수정
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

### 4.6 약국 삭제
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

---

## 5. 리포트 API (`/api/reports`)

### 5.1 리포트 작성 (약국 방문 메모)
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
    "createDate": "2025-01-15T10:30:00Z"
  },
  "message": "리포트가 작성되었습니다."
}
```

**비즈니스 룰:**
- 약국 + 설문 + 작성자 조합은 유일 (중복 작성 불가)
- 로그인한 사용자의 리포트만 작성 가능

### 5.2 약국별 리포트 목록 조회
```
GET /api/reports/pharmacy/{pharmacyId}
```

**Path Parameters:**
- `pharmacyId`: 약국 ID (필수)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "pharmacy": {
        "id": 1,
        "name": "OOO약국",
        "businessNumber": "1234567890"
      },
      "createDate": "2025-01-15T10:30:00Z",
      "updateDate": "2025-01-15T11:00:00Z"
    }
  ]
}
```

**참고:**
- 특정 약국의 리포트 목록을 조회합니다
- 페이지네이션은 현재 미적용 (전체 목록 반환)

### 5.3 리포트 상세 조회
```
GET /api/reports/{id}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "pharmacy": {
      "id": 1,
      "name": "OOO약국",
      "businessNumber": "1234567890"
    },
    "answers": {
      "BASIC_Q1": {
        "value": "OOO약국",
        "type": "TEXT"
      }
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

### 5.4 리포트 수정
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
    }
  }
}
```

**소유권 검증:**
- 본인의 리포트만 수정 가능

### 5.5 리포트 삭제
```
DELETE /api/reports/{id}
```

**Response (200):**
```json
{
  "success": true,
  "message": "리포트가 삭제되었습니다."
}
```

**소유권 검증:**
- 본인의 리포트만 삭제 가능

---

## 6. 통계 API (`/api/statistics`)

### 6.1 약국별 회원 수 통계 (QueryDSL)
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

---

## 7. 에러 코드

| HTTP | 코드 | 메시지 |
|------|------|--------|
| 401 | INVALID_CREDENTIALS | 로그인 정보가 올바르지 않습니다. |
| 401 | TOKEN_EXPIRED | 토큰이 만료되었습니다. |
| 401 | TOKEN_BLACKLISTED | 블랙리스트에 등록된 토큰입니다. |
| 403 | ACCESS_DENIED | 접근 권한이 없습니다. |
| 403 | NOT_OWNER | 본인의 리소스만 접근할 수 있습니다. |
| 404 | MEMBER_NOT_FOUND | 멤버를 찾을 수 없습니다. |
| 404 | PHARMACY_NOT_FOUND | 약국을 찾을 수 없습니다. |
| 404 | REPORT_NOT_FOUND | 리포트를 찾을 수 없습니다. |
| 404 | BOARD_NOT_FOUND | 게시글을 찾을 수 없습니다. |
| 400 | DUPLICATE_BUSINESS_NUMBER | 이미 등록된 사업자번호입니다. |
| 400 | DUPLICATE_EMAIL | 이미 사용 중인 이메일입니다. |
| 400 | DUPLICATE_REPORT | 이미 작성한 리포트가 있습니다. |
| 400 | INVALID_BOARD_TYPE | 해당 게시판에 글을 작성할 권한이 없습니다. |

---

## 8. 보안

### 8.1 인증 보안
- **BCrypt**: 비밀번호 암호화 (10 rounds)
- **JWT**: HS256 알고리즘
- **JWT Secret**: 최소 256비트 이상의 안전한 키
- **Token Storage**: Redis에 저장
- **Token Blacklist**: 로그아웃 시 블랙리스트 등록

### 8.2 Redis 토큰 관리
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

### 8.3 CORS 설정
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

---

## 9. 환경 설정

### 9.1 필수 환경 변수

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

### 9.2 데이터베이스 초기화

```bash
# src/main/resources/db/migration/ 디렉토리의 스크립트 순서대로 실행
psql -U postgres -d pico_friends -f V1__create_tables.sql
psql -U postgres -d pico_friends -f V2__insert_common_codes.sql
```

---

## 10. 개발 가이드

### 10.1 로컬 개발 환경 구성

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

### 10.2 테스트

```bash
# 전체 테스트
./gradlew test

# 특정 테스트
./gradlew test --tests "PharmacyServiceTest"

# 테스트 커버리지
./gradlew test jacocoTestReport
```

### 10.3 빌드

```bash
# JAR 파일 생성
./gradlew build

# Docker 이미지 빌드
docker build -t picofriends-api:latest .
```

---

## 11. 참고 문서

- **Swagger UI**: http://localhost:8080/swagger-ui.html
- **API Docs**: http://localhost:8080/v3/api-docs
- **GitHub Repository**: https://github.com/yourorg/pico-friends-api
- **Jira**: https://picoinnov.atlassian.net

---

## 부록. Phase 2 이후 개발 예정 기능

다음 기능들은 Phase 1에 포함되지 않았으며, 향후 개발 예정입니다:

### A. 멤버 관리 API
관리자의 멤버 승인/거부 및 사용자 정보 조회 기능
- `GET /api/admin/members` - 멤버 목록 조회 (관리자)
- `PATCH /api/admin/members/{memberId}/status` - 멤버 승인/거부
- `GET /api/members/me` - 현재 사용자 정보 조회

### B. 설문지 관리 API
동적 설문지 생성 및 버전 관리 기능
- `GET /api/surveys/active` - 활성 설문지 조회
- `POST /api/admin/surveys` - 설문지 생성 (관리자)
- `PATCH /api/admin/surveys/{surveyId}/activate` - 설문지 활성화

### C. 약국 변경 이력 API
약국 정보 변경 추적 기능
- `GET /api/admin/pharmacies/{pharmacyId}/history` - 약국 변경 이력 조회 (관리자)

### D. 고급 통계 API
대시보드 및 상세 분석 기능
- `GET /api/admin/statistics/dashboard` - 대시보드 통계
- `GET /api/admin/statistics/members` - 영업사원별 실적 통계
- `GET /api/admin/statistics/survey-answers` - 설문 응답 통계 (특정 질문)

### E. 파일 관리 API
이미지 업로드 및 첨부파일 관리 기능
- `POST /api/files/upload` - 파일 업로드
- `GET /api/files` - 파일 목록 조회

---

**문서 버전 이력:**
- v1.0 (2025-10-29): Phase 1 구현 완료 범위로 재작성
- v0.9 (2025-10-27): 초안 작성
