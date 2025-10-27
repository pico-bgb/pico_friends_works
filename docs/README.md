# PICOFriends 개발 명세서

## 프로젝트 개요
PICOFriends는 대학 간 네트워킹 및 업무 분배를 위한 플랫폼으로, 37개 학교를 지원하는 Mobile Web 애플리케이션입니다.

- **버전**: Ver 1.1
- **Frontend**: Next.js
- **Backend**: Spring Boot
- **Database**: MySQL/PostgreSQL

## 문서 구조

### 1. [프로젝트 개요](./01_프로젝트개요.md)
- 프로젝트 정보 및 목적
- 지원 대학 목록 (37개)
- 주요 기능 개요
- 기술 스택

### 2. [프론트엔드 명세서](./02_프론트엔드명세서.md)
- Next.js 기반 프론트엔드 아키텍처
- 프로젝트 구조 및 파일 구성
- 화면별 상세 명세
  - 로그인/회원가입
  - 배정된 업무 관리
  - 약국 관리
  - 업무 분배
  - 공지사항
  - 백오피스 (관리자)
- 공통 컴포넌트 설계
- 상태 관리 및 API 연동
- 라우팅 및 미들웨어

### 3. [백엔드 명세서](./03_백엔드명세서.md)
- Spring Boot 기반 백엔드 아키텍처
- 프로젝트 구조 및 패키지 구성
- Entity 설계 (7개 테이블)
  - User (사용자)
  - Pharmacy (약국)
  - Work (업무)
  - WorkAssignment (업무 배정)
  - Notice (공지사항)
  - VisitRecord (방문 기록)
  - RegistrationRecord (회원가입 기록)
- Controller, Service, Repository 설계
- Security 설정 (JWT 인증)
- Exception 처리
- 대학교 Enum 관리

### 4. [데이터베이스 명세서](./04_데이터베이스명세서.md)
- 데이터베이스 정보 (MySQL/PostgreSQL)
- ERD (Entity Relationship Diagram)
- 테이블 상세 설계
  - 컬럼 정의
  - 인덱스
  - 외래키
  - 제약 조건
- 초기 데이터 (Seed Data)
- 데이터베이스 생성 스크립트
- 주요 쿼리 예시
  - 랭킹 조회 (일간/주간)
  - 대시보드 통계
  - 업무 배정 현황
  - 전환율 계산
- 백업 및 복구 전략
- 성능 최적화 권장사항
- 보안 고려사항

### 5. [API 명세서](./05_API명세서.md)
- RESTful API 설계
- Base URL 및 인증 (JWT)
- 공통 응답 형식
- API 엔드포인트 (42개)
  - 인증 API (4개)
  - 사용자 관리 API (5개)
  - 약국 관리 API (7개)
  - 업무 관리 API (9개)
  - 공지사항 API (6개)
  - 관리자 대시보드 API (3개)
- 에러 코드 정의
- 페이지네이션
- 필터링 및 검색
- Rate Limiting
- CORS 설정

## 주요 기능

### 사용자 기능
1. **인증**
   - 로그인 (이메일/비밀번호)
   - 회원가입 (관리자 승인 필요)

2. **업무 관리**
   - 배정된 업무 조회
   - 약국 방문 인증
   - 회원가입 인증
   - 설문조사 제출

3. **대시보드**
   - 방문/가입 통계
   - 랭킹 확인 (일간/주간)
   - 미이미지 조회

### 관리자 기능
1. **사용자 관리**
   - 사용자 승인/거부
   - 사용자 정보 관리
   - CSV 내보내기

2. **약국 관리**
   - 약국 CRUD
   - CSV 가져오기/내보내기
   - 약국 정보 수정

3. **업무 분배**
   - 업무 생성 및 배정
   - 진행 현황 모니터링
   - CSV 내보내기

4. **통계 및 리포트**
   - 전체 통계 대시보드
   - 그래프 시각화 (일/주/월)
   - 랭킹 관리

5. **공지사항 관리**
   - 공지사항 CRUD
   - 리치 텍스트 에디터
   - 이미지 업로드

## 개발 환경 설정

### Frontend (Next.js)
```bash
# 패키지 설치
npm install

# 개발 서버 실행
npm run dev

# 빌드
npm run build

# 프로덕션 실행
npm start
```

### Backend (Spring Boot)
```bash
# 빌드
./gradlew build

# 실행
./gradlew bootRun

# 테스트
./gradlew test
```

### Database
```bash
# MySQL 데이터베이스 생성
mysql -u root -p < docs/database_schema.sql

# 또는 PostgreSQL
psql -U postgres -d picofriends -f docs/database_schema.sql
```

## 환경 변수

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_BASE_URL=http://localhost:8080/api
NEXT_PUBLIC_APP_NAME=PICOFriends
```

### Backend (application.yml)
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/picofriends
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}

jwt:
  secret: ${JWT_SECRET}
  expiration: 86400000
```

## 배포

### Frontend (Vercel/Netlify)
```bash
npm run build
# Vercel CLI 또는 Netlify CLI로 배포
```

### Backend (Docker)
```bash
docker build -t picofriends-backend .
docker run -p 8080:8080 picofriends-backend
```

## API 문서
개발 서버 실행 후 Swagger UI 접속:
```
http://localhost:8080/swagger-ui.html
```

## 데이터베이스 마이그레이션
Flyway 또는 Liquibase를 사용하여 데이터베이스 버전 관리 권장

## 테스트
- **Frontend**: Jest + React Testing Library
- **Backend**: JUnit 5 + Mockito
- **E2E**: Cypress 또는 Playwright

## 보안 고려사항
1. JWT 토큰 기반 인증
2. 비밀번호 BCrypt 암호화
3. SQL Injection 방지 (Prepared Statement)
4. XSS 방지 (입력 검증)
5. CSRF 토큰 (Next.js 기본 지원)
6. HTTPS 사용 (프로덕션)
7. Rate Limiting
8. CORS 설정

## 성능 최적화
1. 데이터베이스 인덱스 최적화
2. 쿼리 최적화 (N+1 문제 해결)
3. Redis 캐싱 (랭킹, 통계)
4. CDN 사용 (정적 파일)
5. 이미지 최적화 (Next.js Image)
6. 코드 스플리팅
7. Lazy Loading

## 모니터링 및 로깅
- **Backend**: SLF4J + Logback
- **Frontend**: Sentry 또는 LogRocket
- **Infrastructure**: Prometheus + Grafana

## 버전 관리
- Git Flow 전략 사용
- Semantic Versioning (v1.0.0)

## 문의
프로젝트 관련 문의사항은 이슈 트래커를 통해 등록해주세요.

---

**Last Updated**: 2025-10-20
**Version**: 1.1
