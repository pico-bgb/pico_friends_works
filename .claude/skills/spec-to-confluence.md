# 명세서 Confluence 발행 스킬

API 명세서, DB 스키마, 화면설계서를 Confluence에 자동 발행합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. OpenAPI/Swagger → Confluence

**백엔드 Swagger 파싱:**
- Swagger UI 접속: `http://localhost:8080/swagger-ui.html`
- OpenAPI JSON 다운로드: `http://localhost:8080/v3/api-docs`
- 또는 Spring 컨트롤러 코드 직접 분석

**Confluence 테이블 형식으로 변환:**
```markdown
## API 엔드포인트 목록

|| Method || Endpoint || Description || Auth || Status ||
| POST | /api/auth/login | 로그인 | Public | ✅ Implemented |
| POST | /api/auth/logout | 로그아웃 | Required | ✅ Implemented |
| GET | /api/members/me | 내 정보 조회 | Required | ✅ Implemented |
| POST | /api/pharmacies | 약국 등록 | ROLE_USER | ✅ Implemented |
| GET | /api/reports | 리포트 목록 | ROLE_USER | 🚧 In Progress |
```

**상세 API 명세:**
```markdown
## POST /api/auth/login

### 설명
사용자 로그인 API. 아이디/비밀번호로 인증하고 JWT 토큰을 발급합니다.

### Request

#### Headers
{panel:borderStyle=solid|borderColor=#ccc|titleBGColor=#F7D6C1|bgColor=#FFFFCE}
| Name | Type | Required | Description |
|------|------|----------|-------------|
| Content-Type | String | Yes | application/json |
{panel}

#### Body
{code:language=json}
{
  "username": "user01",
  "password": "password123"
}
{code}

### Response

#### Success (200 OK)
{code:language=json}
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "expiresIn": 3600
}
{code}

#### Error (401 Unauthorized)
{code:language=json}
{
  "error": "INVALID_CREDENTIALS",
  "message": "아이디 또는 비밀번호가 일치하지 않습니다"
}
{code}

### 비고
{info}
Access Token은 1시간, Refresh Token은 7일 유효합니다.
{info}
```

### 2. 데이터베이스 스키마 → Confluence

**ERD 다이어그램 (Mermaid → Confluence):**

Mermaid ERD를 이미지로 렌더링하거나 Confluence 다이어그램 매크로 사용:

```markdown
{mermaid}
erDiagram
    USER ||--o{ PHARMACY : owns
    USER ||--o{ REPORT : writes
    PHARMACY ||--o{ REPORT : has

    USER {
        bigint id PK
        varchar username UK
        varchar email UK
        varchar password
        varchar role
        timestamp created_at
    }

    PHARMACY {
        bigint id PK
        bigint owner_id FK
        varchar name
        varchar address
        varchar phone
        timestamp created_at
    }

    REPORT {
        bigint id PK
        bigint member_id FK
        bigint pharmacy_id FK
        jsonb answers
        varchar visit_status
        timestamp visit_date
    }
{mermaid}
```

**테이블 상세 명세:**
```markdown
## t_user (사용자)

### 개요
시스템의 모든 사용자 정보를 저장하는 테이블입니다.

### 컬럼

|| Column || Type || Null || Key || Default || Description ||
| id | bigint | NO | PRI | auto_increment | 사용자 ID |
| username | varchar(50) | NO | UNI | - | 사용자명 (로그인 ID) |
| email | varchar(100) | NO | UNI | - | 이메일 주소 |
| password | varchar(255) | NO | - | - | 비밀번호 (BCrypt) |
| role | varchar(20) | NO | - | 'ROLE_USER' | 권한 (ROLE_USER/ADMIN) |
| created_at | timestamp | NO | - | CURRENT_TIMESTAMP | 생성일시 |
| updated_at | timestamp | NO | - | CURRENT_TIMESTAMP | 수정일시 |

### 인덱스

{panel:title=인덱스 목록|borderStyle=solid}
* PRIMARY KEY (id)
* UNIQUE KEY uk_username (username)
* UNIQUE KEY uk_email (email)
* INDEX idx_role (role)
{panel}

### 외래키

{panel:title=외래키 제약조건|borderStyle=solid}
(없음)
{panel}

### 트리거

{panel:title=트리거 목록|borderStyle=solid}
* trg_update_timestamp: updated_at 자동 업데이트
{panel}

### 비고

{note}
password는 BCrypt 10 rounds로 암호화되어 저장됩니다.
{note}

{warning}
username과 email은 대소문자 구분 없이 고유해야 합니다.
{warning}
```

### 3. 화면설계서 → Confluence

**화면 목록 (인덱스 페이지):**
```markdown
## 피코프렌즈 화면 목록 (현장요원용)

### 인증
|| 화면 ID || 화면명 || 경로 || 권한 || 상태 || 담당자 ||
| PF-010 | 로그인 | /login | Public | ✅ Done | John |
| PF-020 | 회원가입 | /signup | Public | ✅ Done | Jane |

### 메인
|| 화면 ID || 화면명 || 경로 || 권한 || 상태 || 담당자 ||
| PF-030 | 업무 목록 | /tasks | ROLE_USER | 🚧 Progress | John |
| PF-040 | 방문 인증 | /tasks/:id/visit | ROLE_USER | 📋 To Do | - |
| PF-041 | 설문조사 | /tasks/:id/survey | ROLE_USER | 📋 To Do | - |

### 내 활동
|| 화면 ID || 화면명 || 경로 || 권한 || 상태 || 담당자 ||
| PF-042 | 활동 내역 | /reports | ROLE_USER | 📋 To Do | - |
| PF-043 | 리더보드 | /leaderboard | ROLE_USER | 📋 To Do | - |
```

**화면 상세 (슬라이드 이미지 포함):**
```markdown
## PF-010: 로그인 화면

### 화면 정보

{panel:title=기본 정보|borderStyle=solid|titleBGColor=#E6F2FF}
* **화면 ID**: PF-010
* **화면명**: 로그인
* **경로**: /login
* **권한**: Public (인증 불필요)
* **상위 화면**: (루트)
* **상태**: ✅ Done
* **담당자**: John Doe
* **Jira**: [PF-33](https://picoinnov.atlassian.net/browse/PF-33)
{panel}

### 화면 미리보기

!PF-010_로그인.png|width=800,border=true!

### UI 컴포넌트

{panel:title=사용된 컴포넌트|borderStyle=solid}
* [[CC-LOGIN|공통 컴포넌트#CC-LOGIN]] - 로그인 폼
* [[CC-INPUT|공통 컴포넌트#CC-INPUT]] - 아이디/비밀번호 입력
* [[CC-BUTTON|공통 컴포넌트#CC-BUTTON]] - 로그인 버튼
* [[CC-TOAST|공통 컴포넌트#CC-TOAST]] - 에러 메시지 표시
{panel}

### 화면 흐름

{code:language=mermaid}
graph TD
    A[로그인 페이지 진입] --> B{로그인 시도}
    B --> C[유효성 검증]
    C --> D{검증 성공?}
    D -->|Yes| E[API 호출: POST /api/auth/login]
    D -->|No| F[에러 토스트 표시]
    E --> G{인증 성공?}
    G -->|Yes| H[토큰 저장]
    H --> I[/tasks 페이지로 리다이렉트]
    G -->|No| F
    F --> B
{code}

### API 연동

{info:title=API 엔드포인트}
* **Endpoint**: POST /api/auth/login
* **Request**: \{ username, password \}
* **Response**: \{ accessToken, refreshToken \}
* **상세**: [[API 명세서#POST-login|API 명세서]]
{info}

### 상태 관리

{panel:title=Zustand Store|borderStyle=solid}
* **Store**: useAuthStore
* **State**: user, accessToken, refreshToken, isAuthenticated
* **Actions**: login(), logout(), refreshToken()
{panel}

### 비고

{tip}
자동 로그인 체크박스를 선택하면 Refresh Token을 LocalStorage에 저장합니다.
{tip}

{warning}
비밀번호는 최소 8자 이상이어야 합니다.
{warning}
```

### 4. 기술 아키텍처 → Confluence

**시스템 아키텍처 다이어그램:**
```markdown
## 시스템 아키텍처

{mermaid}
graph TB
    subgraph "Frontend"
        A[Next.js 14<br/>React 19]
        B[Zustand]
        C[React Query]
    end

    subgraph "Backend"
        D[Spring Boot 3.5.6<br/>Java 21]
        E[Spring Security<br/>JWT]
        F[QueryDSL]
    end

    subgraph "Data"
        G[PostgreSQL 13.1+]
        H[Redis]
    end

    A --> D
    B --> A
    C --> A
    D --> E
    D --> F
    F --> G
    E --> H
{mermaid}
```

### 5. 공통 컴포넌트 카탈로그

**컴포넌트 목록 (갤러리 형식):**
```markdown
## 공통 컴포넌트 카탈로그

### Phase 1 - 필수 컴포넌트

#### CC-LOGIN (로그인 폼)

!CC-LOGIN-preview.png|thumbnail,width=300!

{panel:title=컴포넌트 정보}
* **ID**: CC-LOGIN
* **Phase**: 1
* **Jira**: [PF-33](https://picoinnov.atlassian.net/browse/PF-33)
* **Status**: ✅ Done
* **Storybook**: [View Story](http://localhost:6006/?path=/story/pico-authentication-loginform)
{panel}

**Props**
|| Name || Type || Required || Default || Description ||
| onSubmit | Function | Yes | - | 로그인 콜백 |
| loading | Boolean | No | false | 로딩 상태 |
| errorMessage | String | No | - | 에러 메시지 |

**Usage**
{code:language=typescript}
<LoginForm
  onSubmit={handleLogin}
  loading={isLoading}
  errorMessage={error}
/>
{code}

---

#### CC-BUTTON (버튼)

!CC-BUTTON-preview.png|thumbnail,width=300!

{panel:title=컴포넌트 정보}
* **ID**: CC-BUTTON
* **Phase**: 1
* **Jira**: [PF-35](https://picoinnov.atlassian.net/browse/PF-35)
* **Status**: ✅ Done
{panel}

...
```

### 6. 자동 업데이트 및 버전 관리

**자동 업데이트 설정:**
```json
{
  "autoPublish": {
    "enabled": true,
    "triggers": [
      "git-commit",
      "swagger-update",
      "schema-migration"
    ],
    "pages": [
      {
        "source": "docs_new/05_api_specification.md",
        "confluencePageId": "123456",
        "format": "api-spec"
      },
      {
        "source": "http://localhost:8080/v3/api-docs",
        "confluencePageId": "123456",
        "format": "openapi"
      },
      {
        "source": "docs_new/04_database_schema.md",
        "confluencePageId": "789012",
        "format": "db-schema"
      }
    ]
  }
}
```

**버전 관리:**
- 각 발행마다 Confluence 페이지 버전 증가
- 버전 메시지에 변경 내용 기록
- 이전 버전 비교 링크 제공

## 사용 예시

- "Swagger API를 Confluence 테이블로 발행"
- "DB 스키마 ERD를 Confluence 다이어그램으로 변환"
- "화면설계서 슬라이드를 Confluence 페이지로 발행"
- "공통 컴포넌트 카탈로그를 Confluence 갤러리로 생성"
- "백엔드 컨트롤러를 분석하여 API 명세서 자동 발행"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `createConfluencePage`: 페이지 생성 (마크다운 변환 포함)
- `updateConfluencePage`: 페이지 업데이트
- `searchConfluenceUsingCql`: 기존 페이지 검색

**지원 형식:**
- OpenAPI/Swagger JSON
- Mermaid 다이어그램
- 마크다운 테이블
- 이미지 (PNG, JPEG)
- 코드 블록 (언어 하이라이팅)
