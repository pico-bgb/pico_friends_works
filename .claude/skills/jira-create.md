# Jira 이슈 생성 스킬

문서나 코드 변경사항을 기반으로 Jira 이슈를 생성합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. 이슈 타입 선택

**지원되는 이슈 타입:**
- **Epic**: 대규모 기능 (예: PF-3 - FE 공통 컴포넌트 개발)
- **Story**: 사용자 스토리 (예: 로그인 기능 구현)
- **Task**: 작업 (예: API 문서 작성)
- **Bug**: 버그 (예: 로그인 실패 시 에러 메시지 미표시)
- **Subtask**: 하위 작업 (예: CC-LOGIN 컴포넌트 개발)

**프로젝트 및 이슈 타입 조회:**
- `getVisibleJiraProjects`: PF, AD 프로젝트 목록
- `getJiraProjectIssueTypesMetadata`: 프로젝트별 사용 가능한 이슈 타입
- `getJiraIssueTypeMetaWithFields`: 이슈 타입별 필수 필드

### 2. 문서에서 요구사항 추출

**대상 문서:**
- 화면설계서: `docs_new/01_screen_picofriends.md`, `docs_new/02_screen_admin.md`
- 공통 컴포넌트: `docs_new/00_common_components.md`
- API 명세서: `docs_new/05_api_specification.md`
- DB 스키마: `docs_new/04_database_schema.md`

**추출 정보:**
```markdown
## 추출된 요구사항

### 화면: PF-010 로그인 (docs_new/01_screen_picofriends.md)

**요약**: 사용자 로그인 화면 구현

**상세 설명**:
- 아이디/비밀번호 입력
- 로그인 버튼 클릭 시 JWT 토큰 발급
- 자동 로그인 체크박스
- 회원가입 링크

**사용 컴포넌트**:
- CC-LOGIN
- CC-INPUT
- CC-BUTTON

**API 연동**:
- POST /api/auth/login

**수락 기준**:
- [ ] 유효성 검증 통과
- [ ] JWT 토큰 저장
- [ ] /tasks 페이지로 리다이렉트
```

### 3. 이슈 정보 구성

**필수 필드:**
```json
{
  "projectKey": "PF",
  "issueTypeName": "Story",
  "summary": "[PF-010] 로그인 화면 구현",
  "description": "사용자가 아이디/비밀번호로 로그인하는 화면을 구현합니다.\n\n## 요구사항\n- 아이디/비밀번호 입력 필드\n- 로그인 버튼\n- 자동 로그인 체크박스\n- 회원가입 링크\n\n## 사용 컴포넌트\n- CC-LOGIN\n- CC-INPUT\n- CC-BUTTON\n\n## API 연동\n- POST /api/auth/login\n\n## 수락 기준\n- [ ] 유효성 검증 통과\n- [ ] JWT 토큰 저장\n- [ ] /tasks 페이지로 리다이렉트",
  "assignee_account_id": "user-account-id"
}
```

**선택 필드:**
- `parent`: Epic 이슈 키 (Subtask인 경우)
- `additional_fields`:
  - `labels`: ["frontend", "authentication", "phase-1"]
  - `priority`: { "name": "High" }
  - `components`: [{ "name": "Web Frontend" }]
  - `customfield_xxxxx`: Epic Link, Story Points 등

### 4. 일괄 이슈 생성

**시나리오: 공통 컴포넌트 Epic 생성**
```markdown
## Epic: PF-3 - FE 공통 컴포넌트 개발

### Subtasks (Phase 1):
1. PF-33: 인증 컴포넌트 (CC-LOGIN, CC-SIGNUP)
2. PF-34: 레이아웃 컴포넌트 (CC-HEADER-MOBILE, CC-HEADER-ADMIN)
3. PF-35: 기본 UI 컴포넌트 (CC-BUTTON, CC-BADGE, CC-LOADING, CC-TOAST)
4. PF-36: 모달 컴포넌트 (CC-MODAL, CC-CONFIRM-MODAL)

### Subtasks (Phase 2):
5. PF-37: 폼 컴포넌트 (CC-INPUT, CC-SELECT)
6. PF-38: 테이블/리스트 컴포넌트 (CC-DATA-TABLE, CC-CARD-LIST, CC-PAGINATION)
...
```

**생성 프로세스:**
1. Epic 생성 (PF-3)
2. Subtask 생성 (PF-33 ~ PF-44)
3. Epic Link 설정
4. 라벨 및 컴포넌트 할당
5. 초기 상태: "To Do"

### 5. 코드 변경사항에서 이슈 생성

**버그 리포트 자동 생성:**
```markdown
## 감지된 문제

### 파일: /mnt/c/Dev/REpo/pico_friends_fe/src/components/auth/LoginForm.tsx

**문제**: 로그인 실패 시 에러 메시지가 표시되지 않음

**스택 트레이스**:
```
TypeError: Cannot read property 'message' of undefined
  at LoginForm.tsx:45
```

**재현 단계**:
1. 잘못된 비밀번호 입력
2. 로그인 버튼 클릭
3. 에러 토스트 미표시

**예상 동작**: 에러 토스트에 "로그인 실패: 비밀번호가 일치하지 않습니다" 표시

**환경**:
- Next.js 14.2.0
- Browser: Chrome 120
```

**Jira 이슈 생성:**
```json
{
  "projectKey": "PF",
  "issueTypeName": "Bug",
  "summary": "로그인 실패 시 에러 메시지 미표시",
  "description": "...",
  "additional_fields": {
    "priority": { "name": "High" },
    "labels": ["frontend", "bug", "authentication"],
    "components": [{ "name": "Web Frontend" }]
  }
}
```

### 6. 이슈 생성 후 후속 작업

**생성 완료 리포트:**
```markdown
# 이슈 생성 완료

## 생성된 이슈
1. **PF-45**: 로그인 실패 시 에러 메시지 미표시
   - 타입: Bug
   - 우선순위: High
   - 담당자: (미할당)
   - 링크: https://picoinnov.atlassian.net/browse/PF-45

## 다음 단계
1. [ ] 담당자 지정
2. [ ] Sprint에 추가
3. [ ] Git 브랜치 생성: `git checkout -b fix/PF-45-login-error-message`
4. [ ] 이슈 상태를 "In Progress"로 변경
```

**로컬 문서 업데이트:**
- 생성된 이슈 번호를 관련 문서에 추가
- TODO 리스트에 이슈 링크 추가

## 사용 예시

- "docs_new/00_common_components.md에서 이슈 생성"
- "PF-3 Epic 하위에 10개 Subtask 일괄 생성"
- "로그인 버그 리포트를 Jira 이슈로 생성"
- "API 명세서 작성 Task 이슈 생성"
- "PF-010 화면 구현 Story 생성"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `getVisibleJiraProjects`: 프로젝트 조회 (create 권한)
- `getJiraProjectIssueTypesMetadata`: 이슈 타입 조회
- `getJiraIssueTypeMetaWithFields`: 필드 메타데이터 조회
- `createJiraIssue`: 이슈 생성
- `atlassianUserInfo`: 현재 사용자 정보
- `lookupJiraAccountId`: 담당자 계정 ID 조회
