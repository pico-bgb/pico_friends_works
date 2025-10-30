# 피코프렌즈 현장 활동 관리 시스템 개발 문서

## 프로젝트 개요

피코프렌즈 현장 활동 관리 시스템은 약국을 방문하여 설문조사 및 피코 서비스 가입을 유치하는 현장 요원(피코프렌즈)과 이를 관리하는 관리자를 위한 웹 기반 플랫폼입니다.

### 시스템 구성
- **Mobile Web**: 피코프렌즈용 모바일 웹 애플리케이션
- **Admin Web**: 관리자용 백오피스 웹 애플리케이션
- **Backend API**: RESTful API 서버
- **Database**: PostgreSQL

### 기술 스택
- **Frontend**: Next.js 14+ (React, TypeScript)
- **Backend**: Spring Boot 3.5.6 (Java 21)
- **Database**: PostgreSQL 13.1+
- **인증**: JWT (JSON Web Token)
- **빌드 도구**: Gradle

## 문서 구조

본 개발 문서는 다음과 같이 구성되어 있습니다:

### 1. [화면설계서 - 피코프렌즈 (사용자)](./01_screen_picofriends.md)
- 모바일 웹 화면 분석 (슬라이드 1-10)
- 주요 화면: 로그인, 회원가입, 배정된 업무, 방문 인증, 설문조사, 마이페이지
- 화면 ID: PF-010 ~ PF-043

### 2. [화면설계서 - 관리자](./02_screen_admin.md)
- 백오피스 웹 화면 분석 (슬라이드 11-26)
- 주요 화면: 대시보드, 사용자 관리, 약국 관리, 업무 분배, 계시판 관리, 통계
- 화면 ID: AD-010 ~ AD-074

### 3. [기술 아키텍처](./03_technical_architecture.md)
- 시스템 전체 아키텍처
- 계층별 설계 (Presentation, Application, Data Layer)
- 기술 스택 상세 설명
- 주요 기능별 기술 설계
- 보안, 확장성, 성능 고려사항
- 개발 및 배포 프로세스

### 4. [데이터베이스 스키마](./04_database_schema.md)
- ERD (Entity Relationship Diagram)
- 테이블 정의:
  - users (사용자)
  - pharmacies (약국)
  - tasks (업무 배정)
  - visits (방문 기록)
  - surveys (설문조사)
  - pharmacy_registrations (약국 회원가입)
  - notices (공지사항)
  - leaderboard_scores (리더보드 점수)
- 뷰(Views), 인덱스 전략
- 백업 및 복구 전략

### 5. [API 명세서](./05_api_specification.md)
- RESTful API 엔드포인트 전체 목록
- 인증 API (회원가입, 로그인, 토큰 갱신)
- 사용자 관리 API
- 약국 관리 API
- 업무 관리 API
- 방문 기록 API
- 설문조사 API
- 공지사항 API
- 통계 API
- 리더보드 API
- 에러 코드 및 Rate Limiting

### 6. [IA (Information Architecture)](./06_information_architecture.md)
- 시스템 정보 구조 및 화면 체계
- 피코프렌즈(사용자) IA:
  - 화면 ID 체계 (PF-010 ~ PF-043)
  - 로그인, 메인, 활동 기록, 마이페이지
  - 사용자 플로우 다이어그램
- 관리자 IA:
  - 화면 ID 체계 (AD-010 ~ AD-074)
  - 대시보드, 사용자 관리, 약국 관리, 업무 분배, 게시물 관리, 통계
  - 관리자 플로우 (Phase 1~4)
- 기능 명세 요약
- 비기능적 요구사항
- 개발 우선순위

## 주요 기능

### 피코프렌즈 기능 (Mobile Web)

#### 1. 인증
- 기존 시스템(t_user) 연동 회원가입 및 로그인
- 소속 대학교 선택 (공통 코드 관리)
- 관리자 승인 프로세스 (PENDING → ACTIVE)

#### 2. 담당 약국 관리
- 배정된 약국 목록 조회 (약국당 담당자 1명)
- 약국 정보 확인 (사업자번호, 주소, 연락처)
- 방문 완료 처리 (is_visited 플래그)

#### 3. 설문 리포트 작성
- 활성 설문지 조회 (버전 관리)
- 동적 설문 폼 (질문 마스터 기반)
- 다양한 응답 유형:
  - TEXT, TEXTAREA, NUMBER, PHONE, EMAIL
  - RADIO, CHECKBOX, SELECT, DATE
- JSONB 형식 답변 저장
- 리포트 임시저장 및 제출

#### 4. 설문 항목 (예시)
- 약국 기본 정보 (이름, 약사, 연락처)
- 온라인몰 이용 현황
- 주력 판매 상품군
- 마케팅/홍보 관련 고민
- 피코프렌즈 평가

#### 5. 마이페이지
- 통계 대시보드:
  - 총 담당 약국 수
  - 방문 완료 약국 수
  - 작성한 리포트 수
  - 방문율

### 관리자 기능 (Admin Web)

#### 1. 대시보드
- 전체 통계: 총 멤버 수, 총 약국 수, 총 리포트 수
- 방문 통계: 방문 완료/미완료 약국, 방문율
- 영업사원별 실적

#### 2. 멤버 관리
- 멤버 목록 조회 (페이지네이션, 검색, 필터링)
- 상태 필터: 승인 대기(PENDING), 활성(ACTIVE), 비활성(INACTIVE)
- 멤버 승인/거부 프로세스
- 멤버 정보 수정

#### 3. 약국 관리
- 약국 목록 조회 (담당자별, 방문 여부 필터)
- 약국 생성/수정/삭제 (CRUD)
- 담당자 배정 및 변경
- 약국 변경 이력 추적 (pharmacy_history)
- 약국별 리포트 이력 조회
- CSV Export/Import

#### 4. 게시판 관리
- 공지사항, FAQ, QNA 관리
- 게시글 작성/수정/삭제
- 리치 텍스트 에디터 지원
- 조회 수 추적
- 소프트 삭제

#### 5. 설문지 버전 관리
- 설문지 생성 및 버전 관리 (예: 1.0.0, 1.1.0)
- 질문 마스터 관리 (question_code 기준)
- 질문 유형별 설정 (config JSONB)
- 활성 설문지 전환 (1개만 활성화)

#### 6. 통계 및 분석
- 영업사원별 실적 통계
- 설문 응답 분석:
  - 라디오/체크박스 답변 분포
  - 숫자 답변 통계 (평균, 합계, 최소, 최대)
  - JSONB 기반 유연한 쿼리
- 기간별 통계
- CSV Export

## 개발 환경 설정

### 필수 요구사항

#### Backend
- Java 21
- Gradle 7+
- PostgreSQL 13.1+

#### Frontend
- Node.js 18+
- npm 9+ 또는 yarn 1.22+

### 로컬 개발 환경 구성

#### 1. 데이터베이스 설정

```bash
# PostgreSQL 설치 (Ubuntu 예시)
sudo apt update
sudo apt install postgresql postgresql-contrib

# 데이터베이스 생성
sudo -u postgres psql
CREATE DATABASE picofriends;
CREATE USER picofriends_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE picofriends TO picofriends_user;
```

#### 2. Backend 설정

```bash
# 프로젝트 클론
git clone https://github.com/yourorg/picofriends-backend.git
cd picofriends-backend

# application-dev.yml 설정
# src/main/resources/application-dev.yml 파일에 DB 연결 정보 입력

# 빌드 및 실행
./gradlew clean build
./gradlew bootRun --args='--spring.profiles.active=dev'
```

**application-dev.yml 예시:**
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/picofriends
    username: picofriends_user
    password: your_password
  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true

jwt:
  secret: your-jwt-secret-key-min-256-bits
  expiration: 3600000  # 1 hour
```

#### 3. Frontend 설정

```bash
# Mobile Web
git clone https://github.com/yourorg/picofriends-mobile-web.git
cd picofriends-mobile-web
npm install
npm run dev

# Admin Web
git clone https://github.com/yourorg/picofriends-admin-web.git
cd picofriends-admin-web
npm install
npm run dev
```

**.env.local 예시:**
```
NEXT_PUBLIC_API_URL=http://localhost:8080/api/v1
NEXT_PUBLIC_APP_NAME=PicoFriends
```

## Docker를 이용한 배포 (참고용 예시)

> **참고**: 배포 환경은 아직 미확정(TBD) 상태입니다. 아래는 참고용 예시입니다.

### Docker Compose

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:13
    environment:
      POSTGRES_DB: picofriends
      POSTGRES_USER: picofriends_user
      POSTGRES_PASSWORD: your_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://postgres:5432/picofriends
      SPRING_DATASOURCE_USERNAME: picofriends_user
      SPRING_DATASOURCE_PASSWORD: your_password
      JWT_SECRET: your-jwt-secret-key-min-256-bits
    depends_on:
      - postgres

  mobile-web:
    build: ./mobile-web
    ports:
      - "3000:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://backend:8080/api/v1
    depends_on:
      - backend

  admin-web:
    build: ./admin-web
    ports:
      - "3001:3000"
    environment:
      NEXT_PUBLIC_API_URL: http://backend:8080/api/v1
    depends_on:
      - backend

volumes:
  postgres_data:
```

### 실행

```bash
docker-compose up -d
```

## 프로젝트 구조

### Backend (Spring Boot)

```
backend/
├── src/
│   ├── main/
│   │   ├── java/com/pico/friends/
│   │   │   ├── config/              # 설정 클래스
│   │   │   ├── controller/          # REST Controllers
│   │   │   ├── service/             # 비즈니스 로직
│   │   │   ├── repository/          # 데이터 액세스
│   │   │   ├── domain/              # 엔티티 및 DTO
│   │   │   ├── security/            # 보안 관련
│   │   │   ├── exception/           # 예외 처리
│   │   │   └── util/                # 유틸리티
│   │   └── resources/
│   │       ├── application.yml
│   │       └── application-dev.yml
│   └── test/
├── build.gradle
└── Dockerfile
```

### Frontend (Next.js)

```
frontend/
├── app/
│   ├── (auth)/
│   │   ├── login/
│   │   └── register/
│   ├── (main)/
│   │   ├── tasks/
│   │   ├── visit/
│   │   ├── survey/
│   │   └── mypage/
│   ├── layout.tsx
│   └── page.tsx
├── components/
├── lib/
│   ├── api/                         # API 클라이언트
│   ├── hooks/                       # Custom Hooks
│   └── utils/                       # 유틸리티
├── public/
├── styles/
├── .env.local
├── next.config.js
├── package.json
└── Dockerfile
```

## 테스트

### Backend 테스트

```bash
# Unit Tests
./gradlew test

# Integration Tests
./gradlew integrationTest
```

### Frontend 테스트

```bash
# Unit Tests
npm test

# E2E Tests
npm run test:e2e
```

## 보안 고려사항

1. **인증/인가**: JWT 토큰 기반, HTTPS 필수
2. **비밀번호 암호화**: BCrypt (최소 10 rounds)
3. **SQL Injection 방지**: JPA Parameterized Query
4. **XSS 방지**: 입력값 Sanitization
5. **CSRF 방지**: CSRF 토큰 (필요시)
6. **파일 업로드 보안**: 파일 크기 제한, 타입 검증, 파일명 난독화
7. **Rate Limiting**: API 요청 빈도 제한
8. **환경 변수**: 민감 정보는 환경 변수로 관리

## 성능 최적화

1. **데이터베이스**: 인덱스 최적화, 쿼리 최적화, Connection Pooling
2. **캐싱**: Redis 활용 (리더보드, 통계 등)
3. **이미지 최적화**: 압축, 리사이징, CDN 활용
4. **페이지네이션**: 대량 데이터 조회 시 필수
5. **Lazy Loading**: 프론트엔드에서 이미지 지연 로딩

## 모니터링 및 로깅

1. **애플리케이션 모니터링**: Spring Boot Actuator
2. **로그 관리**: Logback (일별 로테이션)
3. **에러 추적**: Sentry (옵션)
4. **성능 모니터링**: API 응답 시간, DB 쿼리 성능

## 향후 개발 계획

### Phase 2
- 실시간 알림 (WebSocket, FCM)
- 모바일 앱 (React Native/Flutter)
- AI 기반 약국 추천

### Phase 3
- 다국어 지원 (i18n)
- 데이터 분석 대시보드 (BI 도구 연동)
- API Gateway 도입

### Phase 4
- Microservices Architecture
- Event-Driven Architecture (Kafka)
- GraphQL API

---

**문서 버전**: 1.0
**최종 수정일**: 2025-10-27

