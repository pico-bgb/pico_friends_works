# Jira 보드 조회 및 관리 스킬

Jira 보드(Scrum/Kanban)의 이슈를 조회하고 관리합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. 보드 현황 조회

**JQL 쿼리:**
```jql
project = PF AND sprint IN openSprints() ORDER BY rank
```

**보드 뷰:**
```markdown
# PICOFriends 보드 (Sprint 1)

## 📊 Sprint 요약
- **Sprint**: Sprint 1 (2025-10-21 ~ 2025-11-03)
- **남은 일수**: 3일
- **Story Points**: 38/40 완료 (95%)

---

## 📋 To Do (3개, 5 SP)

### PF-44: 아이콘 버튼 컴포넌트
- **담당자**: (미할당)
- **Story Points**: 3
- **라벨**: frontend, component, phase-3
- **생성일**: 2025-10-28

### PF-50: 설문조사 화면 구현
- **담당자**: Bob Johnson
- **Story Points**: 2
- **라벨**: frontend, survey
- **생성일**: 2025-10-29

### PF-51: 버그 수정 - 로딩 스피너 안 보임
- **담당자**: Jane Smith
- **Priority**: High
- **라벨**: bug, frontend
- **생성일**: 2025-10-30

---

## 🚧 In Progress (4개, 15 SP)

### PF-39: 검색/필터 컴포넌트
- **담당자**: John Doe
- **Story Points**: 5
- **진행률**: 70%
- **라벨**: frontend, component, phase-2
- **시작일**: 2025-10-25
- **코멘트**: "날짜 필터 구현 완료, 텍스트 검색 작업 중"

### PF-42: CSV 처리 컴포넌트
- **담당자**: Jane Smith
- **Story Points**: 5
- **진행률**: 30%
- **라벨**: frontend, component, phase-2
- **시작일**: 2025-10-28
- **블로커**: Papa Parse 라이브러리 이슈

### PF-43: 리치 에디터 컴포넌트
- **담당자**: Bob Johnson
- **Story Points**: 3
- **진행률**: 50%
- **라벨**: frontend, component, phase-3
- **시작일**: 2025-10-27

### PF-48: API 토큰 만료 버그
- **담당자**: John Doe
- **Priority**: Critical
- **Story Points**: 2
- **라벨**: bug, backend
- **시작일**: 2025-10-29

---

## ✅ Done (18개, 38 SP)

### 최근 완료 (최근 3일)

#### PF-35: 기본 UI 컴포넌트
- **담당자**: John Doe
- **Story Points**: 5
- **완료일**: 2025-10-30
- **소요 시간**: 3일

#### PF-36: 모달 컴포넌트
- **담당자**: Bob Johnson
- **Story Points**: 3
- **완료일**: 2025-10-29
- **소요 시간**: 2일

#### PF-37: 폼 컴포넌트
- **담당자**: Jane Smith
- **Story Points**: 5
- **완료일**: 2025-10-28
- **소요 시간**: 3일

---

## 📈 Sprint 진행률

\`\`\`
Story Points
40 |████████████████████░░ 95%
   +----------------------
   | Done  | Progress | To Do
   | 38 SP |   15 SP  |  5 SP
\`\`\`

## ⚠️ 주의사항

{warning}
**Sprint 종료까지 3일 남았습니다!**
- PF-42 (CSV 컴포넌트)의 진행률이 30%로 낮습니다
- PF-44 (아이콘 버튼)가 아직 미착수입니다
- PF-48 (토큰 만료 버그)이 Critical 우선순위입니다
{warning}
```

### 2. 백로그 관리

**백로그 조회 (JQL):**
```jql
project = PF AND sprint IS EMPTY AND status = "To Do" ORDER BY rank
```

**백로그 우선순위 조정:**
```markdown
# 백로그 (25개 이슈)

## 우선순위 변경

### High Priority로 상향
- PF-52: 로그인 세션 타임아웃 개선
  - **이유**: 보안 이슈
  - **권장 Sprint**: Sprint 2

### Medium Priority로 하향
- PF-53: 다크 모드 지원
  - **이유**: 우선순위 낮음
  - **권장 Sprint**: Sprint 3 이후

## Sprint 2 후보 (15개, 60 SP)

### Must Have (8개, 32 SP)
1. PF-52: 로그인 세션 타임아웃 개선 (5 SP)
2. PF-54: 약국 상세 화면 (8 SP)
3. PF-55: 방문 인증 화면 (8 SP)
...

### Should Have (5개, 20 SP)
1. PF-58: 알림 기능 (5 SP)
2. PF-59: 필터 저장 기능 (3 SP)
...

### Could Have (2개, 8 SP)
1. PF-62: 다크 모드 지원 (5 SP)
2. PF-63: 키보드 단축키 (3 SP)
```

### 3. 이슈 상태 트랜지션

**가능한 트랜지션 조회:**
```markdown
# PF-44 트랜지션 옵션

현재 상태: **To Do**

## 가능한 트랜지션:
1. **In Progress** - 작업 시작
2. **Done** - 바로 완료 (비권장)
3. **Blocked** - 블로커 발생
4. **Won't Do** - 작업 취소
```

**트랜지션 실행:**
```markdown
# PF-44 상태 변경

## 변경 내용
- **From**: To Do
- **To**: In Progress
- **담당자**: John Doe로 할당
- **코멘트**: "아이콘 라이브러리 선정 완료, 개발 시작"

## 변경 완료
✅ PF-44가 "In Progress"로 변경되었습니다.
```

### 4. Sprint 생성 및 이슈 할당

**새 Sprint 생성:**
```markdown
# Sprint 2 생성

## Sprint 정보
- **이름**: Sprint 2
- **시작일**: 2025-11-04
- **종료일**: 2025-11-17 (2주)
- **목표**: 화면 구현 및 API 연동

## 할당된 이슈 (15개, 60 SP)
1. PF-52: 로그인 세션 타임아웃 개선 (5 SP) → John Doe
2. PF-54: 약국 상세 화면 (8 SP) → Jane Smith
3. PF-55: 방문 인증 화면 (8 SP) → Bob Johnson
...

## Sprint 생성 완료
✅ Sprint 2가 생성되고 15개 이슈가 할당되었습니다.
```

### 5. 이슈 신속 생성 (Quick Add)

**보드에서 바로 이슈 생성:**
```markdown
# 신속 이슈 생성

## 생성된 이슈
- **이슈 키**: PF-60
- **제목**: 버그 - 리더보드 정렬 오류
- **타입**: Bug
- **우선순위**: High
- **담당자**: John Doe
- **Sprint**: Sprint 1
- **상태**: To Do
- **설명**:
  > 리더보드에서 방문 수 기준 정렬이 내림차순이 아닌 오름차순으로 표시됩니다.
  >
  > 재현 단계:
  > 1. 리더보드 페이지 접속
  > 2. 기본 정렬 확인
  > 3. 1위가 가장 아래에 표시됨

## 다음 단계
- [ ] 담당자에게 알림 전송
- [ ] 상태를 "In Progress"로 변경
- [ ] 브랜치 생성: `git checkout -b fix/PF-60-leaderboard-sort`
```

### 6. 이슈 대량 작업

**여러 이슈 한 번에 처리:**
```markdown
# 대량 작업: Sprint 2로 이동

## 선택된 이슈 (5개)
- PF-52: 로그인 세션 타임아웃 개선
- PF-54: 약국 상세 화면
- PF-55: 방문 인증 화면
- PF-56: 설문조사 화면
- PF-57: 활동 내역 화면

## 작업 내용
- **Sprint 변경**: (백로그) → Sprint 2
- **담당자 할당**:
  - PF-52 → John Doe
  - PF-54, PF-55 → Jane Smith
  - PF-56, PF-57 → Bob Johnson

## 완료
✅ 5개 이슈가 Sprint 2로 이동되고 담당자가 할당되었습니다.
```

### 7. 보드 필터 및 검색

**필터 적용:**
```markdown
# 보드 필터

## 적용된 필터
- **담당자**: John Doe
- **라벨**: frontend, component
- **우선순위**: High, Critical

## 필터 결과 (3개 이슈)

### 🚧 In Progress (2개)
1. PF-39: 검색/필터 컴포넌트
2. PF-48: API 토큰 만료 버그

### 📋 To Do (1개)
1. PF-60: 리더보드 정렬 오류
```

### 8. 보드 리포트 (빠른 요약)

**일일 스탠드업용 리포트:**
```markdown
# Daily Standup Report (2025-10-30)

## 🎯 오늘의 목표
- PF-39 (검색/필터) 완료
- PF-42 (CSV) 50% 달성
- PF-48 (토큰 버그) 해결

## ✅ 어제 완료
- PF-35: 기본 UI 컴포넌트
- PF-36: 모달 컴포넌트 리뷰 완료

## 🚧 현재 진행 중
- PF-39: 검색/필터 (70% → 100% 목표)
- PF-42: CSV (30% → 50% 목표)
- PF-43: 리치 에디터 (50%)
- PF-48: 토큰 버그 (80%)

## 🚨 블로커
- PF-42: Papa Parse 라이브러리 타입 이슈
  - 해결 방안: 커스텀 타입 정의 파일 작성

## 📊 Sprint 진행률
- **완료**: 38/40 SP (95%)
- **남은 일수**: 3일
- **상태**: 🟢 On Track
```

## 사용 예시

- "PF 프로젝트 보드 현황 보여줘"
- "Sprint 1의 To Do 이슈 목록"
- "PF-44를 In Progress로 변경하고 John에게 할당"
- "Sprint 2 생성하고 백로그에서 15개 이슈 할당"
- "John Doe가 담당한 High Priority 이슈 조회"
- "일일 스탠드업 리포트 생성"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `searchJiraIssuesUsingJql`: 보드 이슈 조회
- `getJiraIssue`: 이슈 상세 정보
- `editJiraIssue`: 이슈 업데이트 (담당자, Sprint 등)
- `getTransitionsForJiraIssue`: 가능한 상태 전환 조회
- `transitionJiraIssue`: 이슈 상태 변경
- `createJiraIssue`: 신속 이슈 생성
