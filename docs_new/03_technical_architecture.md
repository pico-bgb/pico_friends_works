# 피코프렌즈 현장 활동 관리 시스템 기술 아키텍처

## 1. 시스템 개요

피코프렌즈 현장 활동 관리 시스템은 약국 방문 및 설문조사를 수행하는 피코프렌즈(현장 요원)와 이를 관리하는 관리자를 위한 웹 기반 플랫폼입니다.

### 1.1 시스템 구성
- **프론트엔드(Mobile Web)**: 피코프렌즈용 모바일 웹 애플리케이션
- **프론트엔드(Admin Web)**: 관리자용 백오피스 웹 애플리케이션
- **백엔드 API**: RESTful API 서버
- **데이터베이스**: PostgreSQL

## 2. 기술 스택

### 2.1 Frontend

#### Next.js (React Framework)
- **버전**: Next.js 14+ (App Router)
- **주요 기능**:
  - Server-Side Rendering (SSR) 및 Static Site Generation (SSG)
  - API Routes
  - 이미지 최적화
  - 파일 기반 라우팅

#### UI/UX 라이브러리
- **UI 컴포넌트**:
  - Tailwind CSS (스타일링)
  - Shadcn/ui 또는 Material-UI (컴포넌트 라이브러리)
- **폼 관리**: React Hook Form
- **상태 관리**:
  - Zustand 또는 Redux Toolkit
  - React Query (서버 상태 관리)
- **차트/그래프**: Recharts 또는 Chart.js
- **날짜 선택**: react-datepicker
- **리치 텍스트 에디터**: TinyMCE 또는 Quill

#### 모바일 최적화
- Responsive Design
- Touch-friendly UI
- 이미지 압축 및 업로드
- Progressive Web App (PWA) 지원 고려

### 2.2 Backend

#### Spring Boot
- **Java 21**
- **Spring Boot 3.3.5**
- **주요 의존성**:
  - **Spring Web**: REST API
  - **Spring Data JPA**: ORM
  - **QueryDSL 5.0.0**: 복잡한 동적 쿼리 및 통계 처리
  - **Spring Security**: 인증/인가
  - **Spring Validation**: 입력값 검증
  - **SpringDoc OpenAPI 2.6.0**: Swagger API 문서화
  - **Lombok**: 보일러플레이트 코드 제거
  - **Gradle**: 빌드 도구

#### 인증/보안
- **JWT (JSON Web Token)**: 토큰 기반 인증
  - Access Token: 1시간 유효
  - Refresh Token: 7일 유효
- **Spring Security**:
  - Role-based Access Control (ROLE_USER, ROLE_VIEWER, ROLE_ADMIN)
  - Password Encoding (BCrypt, 10 rounds)
- **Redis**: 토큰 저장소 및 블랙리스트 관리
- **HTTPS**: SSL/TLS 암호화 통신

#### 데이터 처리
- **QueryDSL**: 타입 안전한 쿼리 작성
  - 복잡한 통계 쿼리
  - 동적 검색 조건
  - JOIN 최적화
- **JSONB 쿼리**: PostgreSQL JSONB 활용
  - 설문 응답 데이터 저장 및 검색
  - 유연한 스키마

#### 파일 처리
- **이미지 업로드**:
  - Multipart File Upload
  - 이미지 리사이징 및 압축
- **CSV 처리**:
  - OpenCSV 라이브러리
  - Apache POI (엑셀 처리 옵션)

### 2.3 Database

#### PostgreSQL
- **버전**: PostgreSQL 13+ (14 권장)
- **주요 기능**:
  - **JSONB 데이터 타입**: 설문조사 응답 데이터 저장
  - **GIN 인덱스**: JSONB 검색 성능 최적화
  - **Full-text Search**: 텍스트 검색
  - **트랜잭션 지원**: ACID 보장
  - **인덱싱 및 쿼리 최적화**

#### ORM 및 쿼리
- **JPA/Hibernate**: 객체-관계 매핑
- **QueryDSL**: 복잡한 동적 쿼리 처리
  - 타입 안전한 쿼리 작성
  - 통계 및 집계 쿼리
  - N+1 문제 해결

#### Redis
- **사용 목적**:
  - **Access Token 저장**: TTL 1시간
  - **Refresh Token 저장**: TTL 7일
  - **Token Blacklist**: 로그아웃 시 블랙리스트 관리
- **데이터 구조**:
  ```
  access_token:{userId} -> {token}
  refresh_token:{userId} -> {token}
  blacklist:{token} -> "logout"
  ```

### 2.4 인프라 및 배포

#### 개발 환경
- **버전 관리**: Git
- **빌드 도구**:
  - Gradle (Backend)
  - npm 또는 yarn (Frontend)
- **개발 서버**:
  - Next.js Dev Server
  - Spring Boot Embedded Tomcat

#### 프로덕션 환경 (권장)
- **컨테이너화**: Docker
- **오케스트레이션**: Docker Compose 또는 Kubernetes
- **웹 서버**: Nginx (리버스 프록시)
- **CI/CD**: GitHub Actions, Jenkins, 또는 GitLab CI
- **모니터링**:
  - Application: Spring Boot Actuator
  - Logging: Logback, ELK Stack (옵션)

## 3. 시스템 아키텍처

### 3.1 전체 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                    Client Layer                          │
├──────────────────────┬──────────────────────────────────┤
│  Mobile Web (Next.js)│   Admin Web (Next.js)            │
│  - 피코프렌즈용       │   - 관리자용 백오피스             │
│  - PWA 지원          │   - 대시보드, 통계                │
└──────────────────────┴──────────────────────────────────┘
                          │
                          │ HTTPS/REST API
                          ▼
┌─────────────────────────────────────────────────────────┐
│              API Gateway / Load Balancer                 │
│                     (Nginx)                              │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                Application Layer                         │
│              Spring Boot API Server                      │
├─────────────────────────────────────────────────────────┤
│  - REST Controllers                                      │
│  - Business Logic (Services)                             │
│  - Data Access (Repositories)                            │
│  - Security (JWT, Spring Security)                       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  Data Layer                              │
│                 PostgreSQL Database                      │
├─────────────────────────────────────────────────────────┤
│  - Users (사용자)                                         │
│  - Pharmacies (약국)                                     │
│  - Tasks (업무)                                          │
│  - Visits (방문 기록)                                     │
│  - Surveys (설문조사)                                     │
│  - Notices (공지사항)                                     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                  File Storage                            │
│            (로컬 스토리지 또는 S3)                         │
└─────────────────────────────────────────────────────────┘
```

### 3.2 계층별 설명

#### 3.2.1 Presentation Layer (Frontend)

**Mobile Web (Next.js)**
```
/app
  /(auth)
    /login              # 로그인
    /register           # 회원가입
  /(main)
    /tasks              # 배정된 업무 목록
    /tasks/[id]         # 업무 상세 (약국 정보)
    /visit/[taskId]     # 방문 인증
    /survey/[taskId]    # 설문조사
    /mypage             # 마이페이지 (리더보드)
  /components           # 재사용 가능한 컴포넌트
  /lib                  # 유틸리티, API 클라이언트
```

**Admin Web (Next.js)**
```
/app
  /(auth)
    /login              # 관리자 로그인
  /(admin)
    /dashboard          # 대시보드 (AD-020)
    /users              # 사용자 관리 (AD-030)
    /pharmacies         # 약국 관리 (AD-040)
    /tasks              # 업무 분배 (AD-050)
    /notices            # 계시판 관리 (AD-060)
    /statistics         # 통계 (AD-070)
  /components
  /lib
```

#### 3.2.2 Application Layer (Backend)

**패키지 구조**
```
mall.pico_friends_api
  ├── common              # 공통 클래스 (ApiResponse, PageResponse 등)
  ├── config              # 설정 (Security, JPA, QueryDSL, etc.)
  ├── controller          # REST API Controllers
  │   ├── AuthController         # 인증 관련 (/api/auth)
  │   ├── BoardController        # 게시판 (/api/boards)
  │   ├── PharmacyController     # 약국 관리 (/api/pharmacies)
  │   ├── ReportController       # 리포트/설문 (/api/reports)
  │   └── StatisticsController   # 통계 (/api/statistics)
  ├── service             # 비즈니스 로직
  ├── domain              # 도메인 모델
  │   ├── entity          # JPA 엔티티
  │   │   ├── base        # 기본 엔티티 (BaseEntity 등)
  │   │   ├── CommonCode
  │   │   ├── FileInfo
  │   │   ├── PicoFriendsBoard
  │   │   ├── PicoFriendsMember
  │   │   ├── PicoFriendsPharmacy
  │   │   ├── PicoFriendsPharmacyHistory
  │   │   ├── PicoFriendsReport
  │   │   └── User
  │   └── repository      # 데이터 액세스 (Spring Data JPA)
  ├── dto                 # Data Transfer Objects
  │   ├── request         # API 요청 DTO
  │   └── response        # API 응답 DTO
  ├── security            # 보안 관련 (JWT, Filter 등)
  ├── exception           # 예외 처리 (Custom Exceptions, Handler)
  ├── util                # 유틸리티 (SecurityUtil 등)
  └── PicoFriendsApiApplication.java    # Main Application
```

#### 3.2.3 Data Layer (Database)

주요 테이블 구조는 별도 문서 참조 (04_database_schema.md)

## 4. 주요 기능별 기술 설계

### 4.1 인증/인가

#### 인증 플로우
1. 사용자가 이메일/비밀번호로 로그인 요청
2. Backend에서 사용자 검증 및 JWT 토큰 발급
3. Frontend는 토큰을 localStorage 또는 httpOnly cookie에 저장
4. 이후 모든 API 요청에 토큰을 Authorization 헤더에 포함
5. Backend는 JWT 필터에서 토큰 검증 및 권한 확인

#### 역할 기반 접근 제어
- **ROLE_ADMIN**: 관리자 (백오피스 전체 기능)
- **ROLE_FIELD_AGENT**: 피코프렌즈 (모바일 웹 기능)
- **ROLE_PENDING**: 승인 대기 사용자 (제한된 접근)

### 4.2 이미지 업로드

#### 프로세스
1. Frontend에서 이미지 선택 (카메라 또는 갤러리)
2. 클라이언트 측에서 이미지 압축 (Canvas API)
3. Multipart/form-data로 Backend에 업로드
4. Backend에서 이미지 검증 (크기, 형식)
5. 파일 저장 (로컬 또는 S3)
6. 이미지 URL 반환 및 DB에 저장

#### 기술 스택
- Frontend: react-image-file-resizer
- Backend: Spring MultipartFile, ImageIO

### 4.3 CSV Import/Export

#### Import 프로세스
1. 관리자가 CSV 파일 업로드
2. Backend에서 CSV 파싱 (OpenCSV)
3. 데이터 검증 (필수 필드, 형식 체크)
4. Batch Insert (JPA saveAll)
5. 결과 반환 (성공/실패 건수)

#### Export 프로세스
1. 조건에 맞는 데이터 조회 (Repository)
2. CSV 파일 생성 (OpenCSV)
3. HTTP Response로 파일 다운로드

### 4.4 리더보드 (랭킹)

#### 계산 로직
- **기본 점수**: 방문 1회 = 10점
- **보너스 점수**: 회원 가입 성공 = 100점
- **정렬**: 총 점수 DESC, 동점 시 회원가입 수 DESC, 방문 수 DESC

#### 구현 방식
- 실시간 계산 (쿼리) 또는 배치 작업으로 주기적 계산
- Redis 캐싱으로 성능 최적화 (옵션)

### 4.5 설문조사

#### 데이터 구조
- **동적 폼**: JSON 형태로 설문 항목 저장
- **PostgreSQL JSONB**: 유연한 설문 데이터 저장
- **응답 데이터**: JSONB로 저장하여 다양한 형식 지원

#### 예시 스키마
```json
{
  "pharmacy_id": 123,
  "visit_id": 456,
  "responses": {
    "online_usage": ["HMP몰", "새로망"],
    "main_products": "전문의약품",
    "urgent_needs": "고혈압 치료제",
    "marketing_concerns": ["SNS 광고", "지역 홍보물"],
    "feedback": "매우 좋음"
  },
  "submitted_at": "2025-10-27T10:30:00Z"
}
```

### 4.6 통계 및 대시보드

#### 집계 쿼리
- **실시간 통계**: COUNT, SUM 등 집계 함수
- **기간별 통계**: GROUP BY 날짜
- **전환율 계산**: (회원가입 수 / 방문 수) * 100

#### 성능 최적화
- 인덱스 설정 (날짜, 사용자 ID 등)
- 뷰(View) 또는 Materialized View 활용
- 캐싱 (Redis, 애플리케이션 레벨)

## 5. 보안 고려사항

### 5.1 인증 보안
- 비밀번호 해싱 (BCrypt, 최소 10 rounds)
- JWT 토큰 만료 시간 설정 (Access: 1h, Refresh: 7d)
- HTTPS 필수 사용

### 5.2 입력 검증
- Frontend: 클라이언트 측 검증 (즉각적인 피드백)
- Backend: 서버 측 검증 (보안 강화)
- SQL Injection 방지 (JPA Parameterized Query)
- XSS 방지 (입력 sanitization)

### 5.3 파일 업로드 보안
- 파일 크기 제한 (예: 10MB)
- 허용된 파일 타입만 업로드 (이미지: jpg, png, gif)
- 파일명 난독화 (UUID 사용)
- 바이러스 스캔 (선택사항)

### 5.4 API 보안
- Rate Limiting (요청 빈도 제한)
- CORS 설정 (허용된 오리진만)
- API 키 관리 (환경 변수)

## 6. 확장성 및 성능

### 6.1 수평 확장
- Stateless API 설계 (세션 없음, JWT 사용)
- 로드 밸런서 배치
- 데이터베이스 Read Replica (읽기 부하 분산)

### 6.2 캐싱 전략
- **브라우저 캐싱**: 정적 자원 (이미지, CSS, JS)
- **CDN**: Next.js Static Assets
- **Redis**:
  - 세션 데이터 (선택사항)
  - 리더보드 캐싱
  - 자주 조회되는 통계 데이터

### 6.3 데이터베이스 최적화
- 인덱스 전략
  - Primary Key, Foreign Key
  - 검색 조건 컬럼 (날짜, 상태 등)
  - 복합 인덱스 (다중 조건 검색)
- 쿼리 최적화
  - N+1 문제 해결 (Eager Loading, Join Fetch)
  - Pagination (Offset/Limit)
- 파티셔닝 (데이터 증가 시)

## 7. 개발 및 배포 프로세스

### 7.1 개발 환경 설정

#### Backend 개발 환경
```bash
# Java 21 설치
# Gradle 설치
# PostgreSQL 13.1+ 설치 및 DB 생성
# application-dev.yml 설정

# 프로젝트 실행
./gradlew bootRun
```

#### Frontend 개발 환경
```bash
# Node.js 18+ 설치
# npm/yarn 설치

# 의존성 설치
npm install

# 개발 서버 실행
npm run dev
```

### 7.2 빌드 및 배포

#### Production Build
```bash
# Backend
./gradlew clean build -x test

# Frontend
npm run build
```

#### Docker 배포 (참고용 예시)
> **참고**: 배포 환경은 아직 미확정(TBD) 상태입니다.

```yaml
# docker-compose.yml
version: '3.8'
services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: picofriends
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/picofriends
    depends_on:
      - postgres

  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      API_URL: http://backend:8080
    depends_on:
      - backend

volumes:
  postgres_data:
```

### 7.3 CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Build Backend
        run: |
          cd backend
          ./gradlew clean build

      - name: Build Frontend
        run: |
          cd frontend
          npm install
          npm run build

      - name: Deploy to Server
        # Deploy commands...
```

## 8. 모니터링 및 로깅

### 8.1 Application Monitoring
- **Spring Boot Actuator**: Health Check, Metrics
- **Logging**: Logback (INFO, ERROR 레벨)
- **로그 파일**: 일별 로테이션

### 8.2 에러 추적
- **Frontend**: Console Logging, Error Boundary
- **Backend**: Exception Handling, Custom Error Responses

### 8.3 성능 모니터링
- API 응답 시간
- 데이터베이스 쿼리 성능
- 메모리 사용량

## 9. 향후 고려사항

### 9.1 기능 확장
- 모바일 앱 (React Native, Flutter)
- 실시간 알림 (WebSocket, Firebase Cloud Messaging)
- 다국어 지원 (i18n)
- 데이터 분석 대시보드 (AI/ML 인사이트)

### 9.2 기술 개선
- Microservices Architecture (서비스 분리)
- Event-Driven Architecture (Kafka, RabbitMQ)
- GraphQL API (REST 대체)
- Serverless Functions (일부 기능)

