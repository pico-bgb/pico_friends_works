# Claude Code Skills - PICOFriends 프로젝트

PICOFriends 프로젝트를 위한 **15개의 Custom Claude Skills** 모음입니다.

## 📋 목차

- [개요](#개요)
- [스킬 목록](#스킬-목록)
- [사용 방법](#사용-방법)
- [Atlassian 통합](#atlassian-통합)
- [설정](#설정)
- [예제](#예제)

---

## 개요

이 스킬들은 PICOFriends 프로젝트의 문서 관리, Jira 이슈 관리, Confluence 문서 동기화, Git 워크플로우를 자동화합니다.

**새롭게 추가된 Agent 스킬** 🤖:
- **atlassian-project-manager**: Jira/Confluence 자동 감지 및 처리
- **pico-git-commit**: Gitflow + Jira Smart Commit 통합

### 프로젝트 구조

```
/mnt/c/Dev/Document/Project/PICOFriends  # 문서 프로젝트
/mnt/c/Dev/repo/pico_friends_be           # 백엔드 (Spring Boot)
/mnt/c/Dev/REpo/pico_friends_fe           # 프론트엔드 (Next.js)
```

### 기능 카테고리

- **문서 관리** (3개): 로컬 마크다운 문서 동기화 및 검증
- **Atlassian 통합** (6개): Jira 이슈 및 Confluence 페이지 관리 (+ 자동 Agent)
- **Confluence 통합** (4개): Confluence 페이지 동기화 및 발행
- **워크플로우 자동화** (2개 + 1개 Agent): 문서/개발 작업의 전체 프로세스 자동화

**총 15개 스킬**: 13개 일반 스킬 + 2개 자동 실행 Agent 🤖

---

## 스킬 목록

### 📄 문서 관리 스킬

#### [/docs-sync](docs-sync.md)
문서 버전 간 차이점 확인 및 docs_new/ 디렉토리 업데이트

**사용 예시:**
```
/docs-sync
```
- 화면설계서 PPT와 마크다운 문서 비교
- API 명세서와 백엔드 코드 일치 여부 확인
- 불일치 사항 리포트 생성

---

#### [/spec-helper](spec-helper.md)
API 명세서, DB 스키마, 화면 명세서 작성 지원

**사용 예시:**
```
/spec-helper
AuthController의 API 명세서 작성해줘
```
- 백엔드 컨트롤러에서 자동으로 API 명세 추출
- JPA Entity에서 DB 스키마 문서 생성
- 프론트엔드 페이지에서 화면 명세 생성

---

#### [/changelog](changelog.md)
Git 커밋 로그 기반 CHANGELOG.md 자동 생성

**사용 예시:**
```
/changelog
최근 1개월 변경사항으로 CHANGELOG 업데이트
```
- Conventional Commits 분류
- Jira 이슈 자동 연결
- 화면설계서 버전별 비교

---

### 🔷 Jira 통합 스킬

#### [/jira-sync](jira-sync.md)
로컬 문서와 Jira 이슈 양방향 동기화

**사용 예시:**
```
/jira-sync
Jira 이슈와 로컬 문서 동기화
```
- Jira 이슈 상태를 문서에 반영
- Git 커밋에서 이슈 번호 추출
- 충돌 감지 및 해결

---

#### [/jira-create](jira-create.md)
문서/코드 기반 Jira 이슈 자동 생성

**사용 예시:**
```
/jira-create
docs_new/00_common_components.md에서 이슈 생성
```
- Epic 하위에 Subtask 일괄 생성
- 문서에서 요구사항 추출
- 버그 리포트 자동 생성

---

#### [/jira-report](jira-report.md)
Jira 이슈 데이터 분석 및 리포트 생성

**사용 예시:**
```
/jira-report
Sprint 1 진행률 리포트 생성
```
- Sprint/Epic별 진행률
- 팀 생산성 리포트
- 버그 분석 리포트
- 릴리즈 준비 리포트

---

#### [/jira-board](jira-board.md)
Jira 보드(Scrum/Kanban) 조회 및 관리

**사용 예시:**
```
/jira-board
PF 프로젝트 보드 현황 보여줘
```
- 보드 현황 조회 (To Do/In Progress/Done)
- 이슈 상태 트랜지션
- 백로그 우선순위 조정
- Sprint 생성 및 이슈 할당

---

#### [atlassian-project-manager](atlassian-project-manager.md) 🤖
**자동 실행 Agent**: Jira 이슈 및 Confluence 페이지 통합 관리

**자동 실행 조건:**
- Jira 이슈 번호 감지 (예: `PF-123`, `PROJ-456`)
- Jira 링크 공유 (예: `https://company.atlassian.net/browse/PF-123`)
- Confluence 페이지 링크 공유
- Atlassian 관련 작업 요청 시

**사용 예시:**
```
# 사용자가 명시적으로 호출할 필요 없음 (자동 실행)
사용자: "PF-42 이슈 상태 확인해줘"
→ Claude가 자동으로 Agent 실행하여 Jira MCP 도구로 이슈 조회

사용자: "이 Confluence 페이지 요약해줘 [링크]"
→ Claude가 자동으로 Agent 실행하여 Confluence MCP 도구로 페이지 읽기
```

**주요 기능:**
- Jira 이슈 조회/생성/업데이트 (MCP 도구 활용)
- Confluence 페이지 읽기/수정 (MCP 도구 활용)
- 이슈-문서 간 연결 관리
- 워크플로우 상태 전환
- 전문적인 프로젝트 관리 컨텍스트 제공

---

### 📘 Confluence 통합 스킬

#### [/confluence-doc](confluence-doc.md)
로컬 마크다운 문서를 Confluence 페이지로 변환/업로드

**사용 예시:**
```
/confluence-doc
docs_new/05_api_specification.md를 Confluence에 업로드
```
- 마크다운 → Confluence Storage Format 변환
- 이미지 첨부파일 자동 업로드
- 페이지 계층 구조 유지

---

#### [/confluence-sync](confluence-sync.md)
Confluence 페이지와 로컬 문서 양방향 동기화

**사용 예시:**
```
/confluence-sync
Confluence와 로컬 문서 양방향 동기화
```
- Confluence 변경사항 Pull
- 로컬 변경사항 Push
- 충돌 감지 및 3-way 병합

---

#### [/spec-to-confluence](spec-to-confluence.md)
명세서를 Confluence에 자동 발행

**사용 예시:**
```
/spec-to-confluence
Swagger API를 Confluence 테이블로 발행
```
- OpenAPI/Swagger → Confluence 테이블
- DB ERD → Confluence 다이어그램
- 화면설계서 슬라이드 업로드
- 공통 컴포넌트 카탈로그 생성

---

#### [/release-notes](release-notes.md)
Jira와 Git 기반 릴리즈 노트 자동 생성

**사용 예시:**
```
/release-notes
v1.5.0 릴리즈 노트 생성
```
- Jira Fix Version 이슈 수집
- Git 커밋 로그 분석
- Keep a Changelog 형식
- Confluence/GitHub Releases 발행

---

### 🔄 워크플로우 자동화 스킬

#### [/workflow-docs](workflow-docs.md)
문서 작업의 전체 워크플로우 자동화

**사용 예시:**
```
/workflow-docs
화면설계서 v1.6 업데이트 워크플로우 실행
```

**워크플로우:**
```
문서 수정 → Git 커밋 → Confluence 동기화 → Jira 코멘트 → 팀 알림
```

**자동 실행 항목:**
- docs_new/ 변경 감지
- Git 커밋 메시지 생성
- Confluence 페이지 업데이트
- 관련 Jira 이슈에 코멘트 추가
- 팀 이메일/Slack 알림

---

#### [/workflow-dev](workflow-dev.md)
개발 작업의 전체 워크플로우 자동화

**사용 예시:**
```
/workflow-dev
PF-44 작업 시작
```

**워크플로우:**
```
Jira 이슈 → Git 브랜치 → 코드 작성 → 테스트 → PR 생성 → Jira 업데이트 → Confluence 로그
```

**자동 실행 항목:**
- Jira 이슈 조회 및 상태 변경
- Git 브랜치 생성 (feature/PF-XX)
- 테스트 실행 (타입/린트/단위)
- Git 커밋 (Conventional Commits)
- PR 생성 (템플릿 사용)
- Jira PR 링크 추가
- Confluence 개발 로그 작성

---

#### [pico-git-commit](pico-git-commit.md) 🤖
**자동 실행 Agent**: Gitflow + Jira Smart Commit 통합 커밋 관리

**자동 실행 조건:**
- Staged 파일이 존재할 때
- "커밋", "commit" 키워드 감지 시
- `git add` 명령 실행 후
- 사용자가 커밋 준비 완료를 알릴 때

**사용 예시:**
```
# 사용자가 명시적으로 호출할 필요 없음 (자동 실행)
사용자: "로그인 기능 구현 완료했어, 커밋해줘"
→ Claude가 자동으로 Agent 실행

Agent 자동 실행 과정:
1. git status로 Staged 파일 확인
2. 현재 브랜치명에서 Jira 이슈 키 추출 (예: feature/PF-33-login → PF-33)
3. git diff --cached로 변경 내용 분석
4. Conventional Commits 타입 결정 (feat, fix, docs, etc.)
5. Jira Smart Commit 문법 적용 (#done, #comment)
6. 커밋 메시지 생성 및 사용자 승인 요청
   예: "PF-33 feat: 로그인 컴포넌트 구현 #done"
7. 승인 후 git commit 실행
```

**주요 기능:**
- **Gitflow 브랜치 인식**: feature/hotfix/bugfix 브랜치 패턴 자동 감지
- **Jira 이슈 키 자동 추출**: 브랜치명 또는 최근 커밋에서 이슈 번호 파싱
- **Conventional Commits**: feat, fix, docs, refactor 등 표준 타입 자동 결정
- **Jira Smart Commit 통합**:
  - `#comment`: 상세 설명 추가
  - `#done`, `#in-progress`, `#todo`: 이슈 상태 자동 전환
- **다국어 지원**: 한국어/영어 커밋 메시지 자동 생성
- **커밋 품질 검증**: Atomic commits 권장, 명확한 설명 강제

**Jira Smart Commit 예시:**
```bash
# 기본 기능 추가
PF-33 feat: 로그인 컴포넌트 구현

# 버그 수정 + 코멘트
PF-45 fix: Storybook router 설정 오류 수정 #comment useRouter mock 추가로 테스트 환경 안정화

# 작업 완료 + 상태 전환
PF-52 feat: 약국 방문 통계 대시보드 추가 #done

# 작업 시작 표시
PF-60 feat: GraphQL 스키마 정의 #in-progress
```

---

## 사용 방법

### 기본 사용법

1. **스킬 호출**
   ```
   /skill-name
   ```

2. **스킬 + 명령**
   ```
   /skill-name
   구체적인 작업 내용 입력
   ```

3. **대화형**
   ```
   User: docs_new/05_api_specification.md 수정했어
   Claude: /spec-helper를 사용하여 변경사항을 분석하고 Confluence에 동기화할까요?
   ```

### 스킬 조합 사용

여러 스킬을 연결하여 복잡한 워크플로우 구현:

```
1. /jira-create (이슈 생성)
2. /workflow-dev (개발 시작)
3. /confluence-doc (문서 업데이트)
4. /jira-sync (완료 동기화)
```

---

## Atlassian 통합

### 필수 설정

**Atlassian MCP Server 설정:**

이 스킬들은 `atlassian-project-manager` agent를 사용합니다. MCP 서버 설정이 필요합니다.

### Jira 프로젝트 정보

- **프로젝트 키**: PF (PICOFriends), AD (Admin)
- **Issue Types**: Epic, Story, Task, Bug, Subtask
- **Workflows**: To Do → In Progress → Done
- **Sprints**: 2주 단위

### Confluence Space 정보

- **Space Key**: PICO
- **Space Name**: PICOFriends
- **페이지 구조**:
  ```
  프로젝트 개요 (README)
  ├── 공통 컴포넌트 명세
  ├── 피코프렌즈 화면설계서
  ├── 관리자 화면설계서
  └── 기술 문서
      ├── API 명세서
      └── 데이터베이스 스키마
  ```

---

## 설정

### 1. Confluence 매핑 설정

**파일: `.claude/confluence-mapping.json`**
```json
{
  "spaceKey": "PICO",
  "spaceId": "123456",
  "mappings": [
    {
      "localPath": "docs_new/README.md",
      "confluencePageId": "789012",
      "lastSync": "2025-10-30T15:00:00Z",
      "syncDirection": "bidirectional"
    }
  ]
}
```

### 2. 워크플로우 설정

**파일: `.claude/workflow-docs.json`**
```json
{
  "autoSync": {
    "enabled": true,
    "trigger": "git-commit"
  },
  "confluence": {
    "spaceKey": "PICO",
    "notifyOnUpdate": true
  },
  "jira": {
    "addComments": true,
    "updateLinkedIssues": true
  }
}
```

**파일: `.claude/workflow-dev.json`**
```json
{
  "git": {
    "branchPrefix": {
      "feature": "feature/",
      "bugfix": "fix/",
      "hotfix": "hotfix/"
    },
    "commitConvention": "conventional-commits"
  },
  "jira": {
    "autoTransition": true,
    "addPRLink": true
  },
  "pr": {
    "autoAssignReviewers": true,
    "defaultReviewers": ["tech-lead", "senior-dev"]
  }
}
```

---

## 예제

### 예제 1: 화면설계서 업데이트 전체 프로세스

```
User: 화면설계서 v1.6 업데이트 완료했어. 전체 프로세스 자동화해줘.

Claude: /workflow-docs 실행

1. ✅ docs_new/ 변경사항 감지 (4개 파일)
2. ✅ Git 커밋 생성 (abc123def)
3. ✅ Confluence 동기화 (4개 페이지 업데이트)
4. ✅ Jira 이슈 코멘트 추가 (PF-44, PF-52, PF-54, PF-55)
5. ✅ 팀 알림 발송 (5명)

완료! 화면설계서 v1.6 업데이트가 모든 시스템에 반영되었습니다.
```

### 예제 2: 새 기능 개발 시작

```
User: PF-44 아이콘 버튼 컴포넌트 개발 시작

Claude: /workflow-dev 실행

1. ✅ PF-44 이슈 조회 (3 SP, Phase 3)
2. ✅ Git 브랜치 생성 (feature/PF-44-icon-button-component)
3. ✅ Jira 상태 변경 (To Do → In Progress)
4. 📝 개발 가이드 제시:
   - 컴포넌트 구조
   - Props 인터페이스
   - 체크리스트

준비 완료! PF-44 개발을 시작하세요.
```

### 예제 3: 개발 완료 및 PR 생성

```
User: PF-44 개발 완료. PR 생성해줘

Claude: /workflow-dev 계속

1. ✅ 테스트 실행 (타입/린트/단위 모두 통과)
2. ✅ Git 커밋 (def456ghi)
3. ✅ PR #123 생성
4. ✅ Jira PR 링크 추가
5. ✅ Confluence 개발 로그 작성

완료! PR #123가 생성되고 리뷰어에게 알림이 발송되었습니다.
```

### 예제 4: Sprint 진행률 리포트

```
User: Sprint 1 진행률 리포트 생성해줘

Claude: /jira-report 실행

# Sprint 1 진행률 리포트

## 요약
- 총 이슈: 25개
- 완료: 15개 (60%)
- 진행 중: 7개 (28%)
- 미착수: 3개 (12%)

## Epic별 분류
### PF-3: FE 공통 컴포넌트 개발
- 완료: 6개 (60%)
- 진행 중: 3개 (30%)
- 미착수: 1개 (10%)

## 위험 요소
⚠️ PF-44 미착수, PF-42 진행률 30%

Confluence에 리포트를 발행할까요?
```

### 예제 5: 릴리즈 노트 생성

```
User: v1.5.0 릴리즈 노트 생성

Claude: /release-notes 실행

1. ✅ Jira Fix Version 이슈 조회 (33개)
2. ✅ Git 커밋 로그 분석 (v1.4.0..v1.5.0)
3. ✅ 카테고리별 분류 (Features/Bugs/Docs)
4. ✅ 릴리즈 노트 생성 (RELEASE_NOTES_v1.5.0.md)

릴리즈 노트가 생성되었습니다.
Confluence와 GitHub Releases에 발행할까요?
```

---

## 트러블슈팅

### Confluence 동기화 실패

**증상**: `Error: Page not found`

**해결**:
1. `.claude/confluence-mapping.json` 확인
2. Confluence Page ID 업데이트
3. Space 접근 권한 확인

### Jira 이슈 조회 실패

**증상**: `Error: Issue not found`

**해결**:
1. Jira Cloud ID 확인 (`getAccessibleAtlassianResources`)
2. 프로젝트 키(PF, AD) 확인
3. 이슈 번호 오타 확인

### Git 브랜치 충돌

**증상**: `fatal: A branch named 'feature/PF-XX' already exists`

**해결**:
```bash
git branch -d feature/PF-XX
# 또는
git checkout feature/PF-XX
```

---

## 기여

새로운 스킬 추가 또는 기존 스킬 개선 시:

1. `.claude/skills/` 디렉토리에 마크다운 파일 추가
2. 이 README에 스킬 설명 추가
3. 테스트 후 팀원에게 공유

---

## 문의

- **Jira 프로젝트**: [PF (PICOFriends)](https://picoinnov.atlassian.net/browse/PF)
- **Confluence Space**: [PICO](https://picoinnov.atlassian.net/wiki/spaces/PICO)
- **Git Repository**: `/mnt/c/Dev/Document/Project/PICOFriends`

---

**Last Updated**: 2025-10-30
**Version**: 1.0.0
