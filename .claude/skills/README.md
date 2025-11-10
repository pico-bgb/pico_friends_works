# Claude Code Skills - PICOFriends 프로젝트

PICOFriends 프로젝트를 위한 **5개의 프로젝트 전용 Claude Skills** 모음입니다.

## 📋 목차

- [개요](#개요)
- [스킬 목록](#스킬-목록)
- [글로벌 스킬](#글로벌-스킬)
- [사용 방법](#사용-방법)
- [설정](#설정)
- [예제](#예제)

---

## 개요

이 스킬들은 PICOFriends 프로젝트에 **특화된** 문서 관리 및 워크플로우 자동화 스킬입니다.

범용적으로 사용 가능한 Atlassian 통합, Git 커밋, 릴리스 관리 스킬은 **글로벌 스킬** (`~/.claude/skills/`)로 분리되어 있습니다.

### 프로젝트 구조

```
/Users/bgb/Dev/Repo/pico_friends_works   # 문서 프로젝트 (현재 저장소)
/Users/bgb/Dev/Repo/pico_friends_be      # 백엔드 (Spring Boot)
/Users/bgb/Dev/Repo/pico_friends_fe      # 프론트엔드 (Next.js)
```

### 스킬 구성

**로컬 스킬 (5개)** - PICOFriends 전용:
- 📄 **문서 관리** (2개): PPT ↔ Markdown 변환, 명세서 작성
- 📘 **Confluence 통합** (1개): PICOFriends 문서 배포
- 🔄 **워크플로우 자동화** (2개): 개발/문서 워크플로우

**글로벌 스킬** - 범용 (6개, `~/.claude/skills/`):
- 🤖 **atlassian-project-manager** (Agent)
- 🤖 **pico-git-commit** (Agent)
- 🖥️ **screen-dev** (PF-17 패턴 기반 화면 자동 개발)
- 📝 **work-log**
- 📋 **changelog**
- 🚀 **release-notes**

---

## 스킬 목록

### 📄 문서 관리 스킬

#### [docs-sync](docs-sync/)
문서 버전 간 차이점 확인 및 docs_new/ 디렉토리 업데이트

**사용 예시:**
```
화면설계서 PPT와 마크다운 문서 동기화해줘
```
- 화면설계서 PPT와 마크다운 문서 비교
- API 명세서와 백엔드 코드 일치 여부 확인
- 불일치 사항 리포트 생성

---

#### [spec-helper](spec-helper/)
API 명세서, DB 스키마, 화면 명세서 작성 지원

**사용 예시:**
```
AuthController의 API 명세서 작성해줘
```
- 백엔드 컨트롤러에서 자동으로 API 명세 추출
- JPA Entity에서 DB 스키마 문서 생성
- 프론트엔드 페이지에서 화면 명세 생성

---

### 📘 Confluence 통합 스킬

#### [spec-to-confluence](spec-to-confluence/)
PICOFriends 명세서를 Confluence에 자동 발행

**사용 예시:**
```
API 명세서를 Confluence에 업로드해줘
```
- OpenAPI/Swagger → Confluence 테이블
- DB ERD → Confluence 다이어그램
- 화면설계서 슬라이드 업로드
- 공통 컴포넌트 카탈로그 생성

---

### 🔄 워크플로우 자동화 스킬

#### [workflow-docs](workflow-docs/)
PICOFriends 문서 작업의 전체 워크플로우 자동화

**사용 예시:**
```
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

---

#### [workflow-dev](workflow-dev/)
PICOFriends 개발 작업의 전체 워크플로우 자동화

**사용 예시:**
```
PF-44 작업 시작
```

**워크플로우:**
```
Jira 이슈 → Git 브랜치 → 코드 작성 → 테스트 → PR 생성 → Jira 업데이트 → Confluence 로그
```

**자동 실행 항목:**
- Jira 이슈 조회 및 상태 변경 (atlassian-project-manager 사용)
- Git 브랜치 생성 (feature/PF-XX)
- 테스트 실행 (타입/린트/단위)
- Git 커밋 (pico-git-commit Agent 사용)
- PR 생성 (템플릿 사용)
- Jira PR 링크 추가
- Confluence 개발 로그 작성

---

## 글로벌 스킬

다음 스킬들은 `~/.claude/skills/`에 있으며, **모든 프로젝트에서 사용 가능**합니다:

### 🤖 Agent 스킬 (자동 실행)

#### atlassian-project-manager
Jira 이슈 및 Confluence 페이지 통합 관리

**자동 실행 조건:**
- Jira 이슈 번호 감지 (예: `PF-123`, `PROJ-456`)
- Jira 링크 공유
- Confluence 페이지 링크 공유
- Atlassian 관련 작업 요청 시

**주요 기능:**
- Jira 이슈 조회/생성/업데이트 (MCP 도구 활용)
- Confluence 페이지 읽기/수정 (MCP 도구 활용)
- 이슈-문서 간 연결 관리
- 워크플로우 상태 전환

---

#### pico-git-commit
Gitflow + Jira Smart Commit 통합 커밋 관리

**자동 실행 조건:**
- Staged 파일이 존재할 때
- "커밋", "commit" 키워드 감지 시
- 사용자가 커밋 준비 완료를 알릴 때

**주요 기능:**
- Gitflow 브랜치 인식 (feature/hotfix/bugfix)
- Jira 이슈 키 자동 추출
- Conventional Commits 타입 자동 결정
- Jira Smart Commit 통합 (`#done`, `#comment`)

**커밋 메시지 예시:**
```bash
PF-33 feat: 로그인 컴포넌트 구현 #done
PF-45 fix: Storybook router 설정 오류 수정 #comment useRouter mock 추가
```

---

### 📝 유틸리티 스킬

#### work-log
AI 작업 로그를 Obsidian Daily_AI에 생성

**사용 예시:**
```
작업 로그 남겨줘
```
- 세션 분석 및 작업 요약
- 사용한 도구 및 파일 작업 내역 추출
- Obsidian Areas/Daily_AI에 자동 저장

---

#### changelog
Git 커밋 로그 기반 CHANGELOG.md 자동 생성

**사용 예시:**
```
최근 1개월 변경사항으로 CHANGELOG 업데이트
```
- Conventional Commits 분류
- Jira 이슈 자동 연결

---

#### release-notes
Jira와 Git 기반 릴리스 노트 자동 생성

**사용 예시:**
```
v1.5.0 릴리스 노트 생성
```
- Jira Fix Version 이슈 수집
- Git 커밋 로그 분석
- Keep a Changelog 형식
- Confluence/GitHub Releases 발행

---

#### screen-dev
PF-17 검증된 패턴으로 신규 관리자 화면 자동 개발

**위치**: `~/.claude/skills/screen-dev/`

**사용 예시:**
```
PF-42 약국 관리 화면 개발해줘
```

**자동 실행 조건:**
- Jira 이슈 번호(PF-XX)와 "화면", "페이지", "개발" 키워드가 함께 언급될 때

**개발 7단계 워크플로우:**
1. Jira 이슈/화면설계서/API 명세서 분석
2. TypeScript 타입 + MSW 핸들러 생성
3. React Query 훅 생성 (CRUD 작업)
4. Storybook 컴포넌트 개발 (List + Form, 18+ stories)
5. 실제 페이지 통합 (역할별 권한 제어)
6. Playwright 테스트 작성 (Smoke + Comprehensive)
7. 대시보드 메뉴 추가

**생성되는 파일 (10개):**
- `src/types/{domain}.ts`
- `src/mocks/handlers/{domain}.ts`
- `src/hooks/use{Domain}s.ts`
- `src/components/{domain}/{Domain}List.tsx` + `.stories.tsx`
- `src/components/{domain}/{Domain}Form.tsx` + `.stories.tsx`
- `src/app/(admin)/{domains}/page.tsx`
- `tests/{domain}-management-smoke.spec.ts`
- `tests/{domain}-management.spec.ts`

**특징:**
- ✅ PF-17 검증된 패턴 재사용 (100% 테스트 통과)
- ✅ API 응답 unwrapping 자동 적용
- ✅ 역할별 권한 제어 (ADMIN/VIEWER)
- ✅ CSV Export 기능 포함
- ✅ 서버 사이드 페이지네이션
- ✅ TypeScript strict mode 준수

**적용 프로젝트:**
- PICOFriends Frontend (`/Users/bgb/Dev/Repo/pico_friends_fe`)
- 또는 유사한 Next.js + React Query 프로젝트

---

## 사용 방법

### 기본 사용법

**로컬 스킬 (프로젝트 전용):**
- 명시적으로 호출할 필요 없이 대화형으로 사용
- 예: "화면설계서 동기화해줘" → Claude가 자동으로 `docs-sync` 사용

**글로벌 스킬 (범용):**
- Agent 스킬: 자동 실행 (사용자 명령 불필요)
  - 예: "PF-42 상태 확인해줘" → `atlassian-project-manager` 자동 실행
  - 예: "커밋해줘" → `pico-git-commit` 자동 실행
- 유틸리티 스킬: 명시적 호출
  - 예: "작업 로그 남겨줘" → `work-log` 실행
  - 예: "CHANGELOG 업데이트해줘" → `changelog` 실행

### 스킬 조합 사용

여러 스킬을 연결하여 복잡한 워크플로우 구현:

```
1. 개발 시작 (workflow-dev)
   → atlassian-project-manager: Jira 이슈 조회
   → Git 브랜치 생성

2. 코드 작성

3. 커밋 (pico-git-commit)
   → 자동으로 Jira Smart Commit 적용

4. 문서 업데이트 (spec-helper)
   → API 명세서 자동 생성

5. Confluence 배포 (spec-to-confluence)
   → atlassian-project-manager: Confluence 업로드

6. 작업 로그 (work-log)
   → Obsidian에 작업 기록
```

---

## 설정

### Atlassian 통합

**Jira 프로젝트 정보:**
- **프로젝트 키**: PF (PICOFriends), AD (Admin)
- **Issue Types**: Epic, Story, Task, Bug, Subtask
- **Workflows**: To Do → In Progress → Done
- **보드**: [PF Board](https://picoinnov.atlassian.net/jira/software/projects/PF/boards/5/timeline)

**Confluence Space 정보:**
- **Space Key**: PICO
- **Space Name**: PICOFriends

---

## 예제

### 예제 1: 새 기능 개발 전체 프로세스

```
User: PF-44 아이콘 버튼 컴포넌트 개발 시작

Claude: (workflow-dev 자동 실행)
1. ✅ PF-44 이슈 조회 (atlassian-project-manager)
2. ✅ Git 브랜치 생성 (feature/PF-44-icon-button)
3. ✅ Jira 상태 변경 (To Do → In Progress)
4. 📝 개발 가이드 제시

[코드 작성 완료 후]

User: 완료했어, 커밋해줘

Claude: (pico-git-commit 자동 실행)
✅ 커밋 완료: "PF-44 feat: 아이콘 버튼 컴포넌트 추가 #done"

User: API 명세서 업데이트하고 Confluence에 올려줘

Claude: (spec-helper + spec-to-confluence 실행)
1. ✅ API 명세서 자동 생성
2. ✅ Confluence 업로드 (atlassian-project-manager)
```

### 예제 2: 화면설계서 업데이트

```
User: 화면설계서 v1.6 업데이트했어. PPT와 문서 동기화해줘

Claude: (docs-sync 실행)
1. ✅ 화면설계서 PPT 분석 (251105_v1.6.pptx)
2. ✅ 마크다운 문서 비교
3. ⚠️ 불일치 3건 발견
   - PF-030: 버튼 색상 변경
   - PF-042: 새 화면 추가
   - CC-MODAL: Props 업데이트
4. ✅ 문서 자동 업데이트

User: Confluence에도 올려줘

Claude: (spec-to-confluence 실행)
✅ 4개 페이지 업데이트 완료
```

---

## 트러블슈팅

### MCP 서버 연결 실패

**증상**: `Error: MCP server not available`

**해결**:
1. Atlassian MCP 서버 설정 확인
2. 인증 토큰 갱신
3. Claude Code 재시작

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

1. `.claude/skills/` 디렉토리에 스킬 폴더 추가
2. `SKILL.md` 파일 작성
3. 이 README에 스킬 설명 추가
4. 테스트 후 Git에 커밋

---

## 문의

- **Jira 프로젝트**: [PF (PICOFriends)](https://picoinnov.atlassian.net/browse/PF)
- **Confluence Space**: PICO
- **Git Repository**: `/Users/bgb/Dev/Repo/pico_friends_works`

---

**Last Updated**: 2025-11-06
**Version**: 2.0.0 (최적화 버전)
