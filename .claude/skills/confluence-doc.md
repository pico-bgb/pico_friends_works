# Confluence 문서 생성/업데이트 스킬

로컬 마크다운 문서를 Confluence 페이지로 변환하여 업로드합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. Confluence Space 확인

**Space 조회:**
- PICOFriends 프로젝트 Space 확인
- Space Key 및 Space ID 획득
- 접근 권한 확인

**Space 구조:**
```
PICOFriends Space (PICO)
├── 📄 프로젝트 개요
├── 📁 화면설계서
│   ├── 피코프렌즈 (현장요원)
│   └── 관리자 페이지
├── 📁 기술 문서
│   ├── API 명세서
│   ├── 데이터베이스 스키마
│   └── 아키텍처
├── 📁 공통 컴포넌트
│   ├── Phase 1
│   ├── Phase 2
│   └── Phase 3
└── 📁 개발 가이드
```

### 2. 마크다운 → Confluence 변환

**지원되는 마크다운 문법:**

| 마크다운 | Confluence |
|---------|------------|
| `# H1` | h1. Heading |
| `**bold**` | *bold* |
| `*italic*` | _italic_ |
| `` `code` `` | {{code}} |
| \`\`\`code block\`\`\` | {code}...{code} |
| `[link](url)` | [link\|url] |
| `![image](url)` | !image.png! |
| `- list` | * list |
| `1. list` | # list |
| `> quote` | {quote}...{quote} |
| `| table |` | \|\| header \|\| |

**코드 블록 변환:**
```markdown
# 마크다운
\`\`\`typescript
const hello = "world";
\`\`\`

# Confluence Storage Format
{code:language=typescript}
const hello = "world";
{code}
```

**테이블 변환:**
```markdown
# 마크다운
| Column 1 | Column 2 |
|----------|----------|
| Value 1  | Value 2  |

# Confluence
|| Column 1 || Column 2 ||
| Value 1 | Value 2 |
```

### 3. 이미지 처리

**로컬 이미지 업로드:**
- 마크다운에서 이미지 경로 추출
- 로컬 파일 읽기
- Confluence 페이지에 첨부파일로 업로드
- 이미지 참조 업데이트

**화면설계서 슬라이드:**
```markdown
# 로컬: docs_new/01_screen_picofriends.md
![PF-010 로그인](../피코프렌즈_v1.5/PF-010_로그인.png)

# Confluence 업로드 후
!PF-010_로그인.png|width=800!
```

### 4. 페이지 생성/업데이트

**새 페이지 생성:**
```json
{
  "spaceId": "123456",
  "title": "API 명세서",
  "body": "...",
  "parentId": "789012",  // 부모 페이지 ID (선택)
  "isPrivate": false
}
```

**기존 페이지 업데이트:**
```json
{
  "pageId": "345678",
  "title": "API 명세서 (업데이트)",
  "body": "...",
  "versionMessage": "docs_new/05_api_specification.md 동기화"
}
```

### 5. 페이지 계층 구조 유지

**docs_new/ 디렉토리 구조:**
```
docs_new/
├── README.md                       → 프로젝트 개요 (루트)
├── 00_common_components.md         → 공통 컴포넌트 (루트 하위)
├── 01_screen_picofriends.md        → 피코프렌즈 화면 (루트 하위)
├── 02_screen_admin.md              → 관리자 화면 (루트 하위)
├── 03_technical_architecture.md    → 기술 아키텍처 (루트 하위)
├── 04_database_schema.md           → DB 스키마 (기술 문서 하위)
└── 05_api_specification.md         → API 명세 (기술 문서 하위)
```

**Confluence 페이지 트리:**
```
프로젝트 개요 (README.md)
├── 공통 컴포넌트 명세 (00_common_components.md)
├── 피코프렌즈 화면설계서 (01_screen_picofriends.md)
├── 관리자 화면설계서 (02_screen_admin.md)
└── 기술 문서 (03_technical_architecture.md)
    ├── 데이터베이스 스키마 (04_database_schema.md)
    └── API 명세서 (05_api_specification.md)
```

### 6. 메타데이터 및 라벨

**페이지 라벨 추가:**
- `version-1.5`: 화면설계서 버전
- `phase-1`, `phase-2`, `phase-3`: 개발 단계
- `frontend`, `backend`, `documentation`: 카테고리
- `api`, `database`, `component`: 유형

**페이지 속성:**
- 작성자: 현재 Atlassian 사용자
- 마지막 수정: 로컬 파일 수정 일시
- 버전 메시지: Git 커밋 메시지

### 7. 일괄 업로드

**docs_new/ 전체 동기화:**
```markdown
## 업로드 계획

1. README.md → "프로젝트 개요" (루트)
2. 00_common_components.md → "공통 컴포넌트 명세"
3. 01_screen_picofriends.md → "피코프렌즈 화면설계서"
   - 이미지 20개 첨부
4. 02_screen_admin.md → "관리자 화면설계서"
   - 이미지 15개 첨부
5. 03_technical_architecture.md → "기술 아키텍처"
6. 04_database_schema.md → "데이터베이스 스키마" (03의 하위)
   - Mermaid ERD → Confluence 다이어그램
7. 05_api_specification.md → "API 명세서" (03의 하위)

## 예상 소요 시간: 약 5분
```

### 8. 변경사항 추적

**페이지 버전 히스토리:**
```markdown
## 버전 히스토리

### v4 (2025-10-30)
- 변경: API 명세서 엔드포인트 3개 추가
- 커밋: cd62826
- 작성자: John Doe

### v3 (2025-10-27)
- 변경: DB 스키마 테이블 2개 추가
- 커밋: 0ddc22e
- 작성자: John Doe

### v2 (2025-10-21)
- 변경: 화면설계서 v1.3 반영
- 커밋: 31cb732
- 작성자: Jane Smith
```

**변경 알림:**
- Confluence Space 구독자에게 이메일 알림
- 페이지 상단에 "최근 업데이트" 배너 표시

## 사용 예시

- "docs_new/05_api_specification.md를 Confluence에 업로드"
- "docs_new/ 전체를 Confluence Space PICO에 동기화"
- "README.md를 프로젝트 개요 페이지로 업데이트"
- "화면설계서 이미지와 함께 Confluence에 발행"
- "공통 컴포넌트 명세를 Confluence Live Doc으로 생성"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `getConfluenceSpaces`: Space 목록 조회
- `getPagesInConfluenceSpace`: Space 내 페이지 조회
- `getConfluencePage`: 특정 페이지 조회
- `createConfluencePage`: 페이지 생성
- `updateConfluencePage`: 페이지 업데이트
- `searchConfluenceUsingCql`: CQL로 페이지 검색

**Confluence 마크다운 라이브러리:**
- Storage Format (XML 기반)
- Markdown → Storage Format 변환기 사용
