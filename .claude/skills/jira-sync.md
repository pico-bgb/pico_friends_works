# Jira 이슈 동기화 스킬

로컬 문서와 Jira 이슈를 양방향 동기화합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. Jira 이슈 조회

**프로젝트 정보 확인:**
- Jira Cloud ID 및 사용자 정보 조회
- PICOFriends 프로젝트 키 확인 (예: PF, AD)

**이슈 검색 (JQL):**
```jql
project = PF AND status IN ("To Do", "In Progress", "Done") ORDER BY updated DESC
```

**이슈 상세 정보 수집:**
- 이슈 키 (PF-33, PF-34 등)
- 제목, 설명, 상태, 담당자
- Epic 링크, 라벨, 컴포넌트
- 첨부파일, 코멘트
- 생성일, 수정일

### 2. 로컬 문서에서 이슈 추출

**문서 스캔:**
- `docs_new/` 디렉토리의 모든 마크다운 파일
- 이슈 번호 패턴 매칭: `PF-\d+`, `AD-\d+`
- 이슈 관련 정보 추출:
  - 화면 ID와 이슈 번호 매핑
  - 컴포넌트 ID와 이슈 번호 매핑

**Git 커밋 로그 분석:**
```bash
git log --all --oneline --grep="PF-" --grep="AD-"
```
- 커밋 메시지에서 이슈 번호 추출
- 커밋 날짜, 작성자, 변경 파일 수집

### 3. 양방향 동기화

#### Jira → 로컬 (Pull)

**이슈 정보 업데이트:**
```markdown
## 동기화 대상
- PF-33: 로그인/회원가입 컴포넌트
  - Jira 상태: Done
  - 로컬 문서: docs_new/00_common_components.md (CC-LOGIN, CC-SIGNUP)
  - 동기화 필요: 상태를 "✅ 완료"로 업데이트
```

**자동 업데이트 항목:**
- 이슈 상태 변경 → 문서에 체크박스/뱃지 업데이트
- 이슈 설명 변경 → 요구사항 섹션 업데이트
- 첨부파일 추가 → 로컬에 다운로드 및 링크 추가

#### 로컬 → Jira (Push)

**문서 변경사항 반영:**
```markdown
## 업데이트 대상
- docs_new/00_common_components.md 수정됨
  - CC-MODAL 스펙 추가
  - 관련 Jira 이슈: PF-36
  - 동기화: 이슈에 코멘트 추가 "문서 업데이트: CC-MODAL 스펙 추가"
```

**Git 커밋 연동:**
- 커밋 메시지에서 이슈 번호 추출
- Jira Smart Commit 형식 지원:
  - `PF-33 #comment 로그인 컴포넌트 구현 완료`
  - `PF-34 #time 2h #comment 헤더 컴포넌트 작업`
  - `PF-35 #done 버튼 컴포넌트 완료`

### 4. 충돌 감지 및 해결

**충돌 시나리오:**
1. Jira와 로컬 문서가 모두 수정됨
2. 이슈 상태가 불일치 (Jira: Done, 문서: In Progress)
3. 담당자 정보 불일치

**충돌 해결 전략:**
```markdown
## 충돌 감지: PF-33

### Jira (최종 수정: 2025-10-30 14:00)
- 상태: Done
- 담당자: John Doe
- 설명: "로그인 컴포넌트 완료"

### 로컬 문서 (최종 수정: 2025-10-30 15:00)
- 상태: In Progress
- 설명: "로그인 컴포넌트 - 소셜 로그인 추가 중"

### 권장 해결책
1. Jira 우선 (Jira 정보로 로컬 업데이트)
2. 로컬 우선 (로컬 정보로 Jira 업데이트)
3. 수동 병합 (사용자가 직접 선택)
```

### 5. 동기화 리포트

**동기화 요약:**
```markdown
# Jira 동기화 리포트

## 📊 통계
- 조회된 Jira 이슈: 25개
- 로컬 문서에서 발견된 이슈: 23개
- 동기화 성공: 20개
- 충돌 발생: 3개
- 새로운 이슈: 2개

## ✅ 동기화 완료
1. PF-33: 상태 업데이트 (In Progress → Done)
2. PF-34: 설명 동기화
3. PF-35: 첨부파일 다운로드

## ⚠️ 충돌 발생
1. PF-36: 상태 불일치
   - Jira: Done
   - 로컬: In Progress
   - 액션: Jira 우선 선택됨

## 🆕 새로운 이슈
1. PF-43: 리더보드 화면
   - Jira에만 존재
   - 액션: 로컬 문서에 추가 필요

## 📝 수동 검토 필요
- PF-40: 설명이 크게 변경됨 (사용자 확인 필요)
```

## 사용 예시

- "Jira 이슈와 로컬 문서 동기화"
- "PF 프로젝트의 최근 업데이트된 이슈 가져오기"
- "Git 커밋에서 Jira 이슈 추출하고 연결"
- "PF-33 이슈 정보를 문서에 반영"
- "로컬 문서 변경사항을 Jira에 코멘트로 추가"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `getJiraIssue`: 특정 이슈 조회
- `searchJiraIssuesUsingJql`: JQL로 이슈 검색
- `editJiraIssue`: 이슈 업데이트
- `addCommentToJiraIssue`: 코멘트 추가
- `getTransitionsForJiraIssue`: 상태 전환 조회
- `transitionJiraIssue`: 이슈 상태 변경
