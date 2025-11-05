# Confluence 양방향 동기화 스킬

Confluence 페이지와 로컬 문서를 양방향으로 동기화합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. 동기화 매핑 관리

**매핑 파일: `.claude/confluence-mapping.json`**
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
    },
    {
      "localPath": "docs_new/05_api_specification.md",
      "confluencePageId": "345678",
      "lastSync": "2025-10-29T10:30:00Z",
      "syncDirection": "local-to-confluence"
    }
  ]
}
```

**동기화 방향:**
- `bidirectional`: 양방향 (충돌 감지 필요)
- `local-to-confluence`: 로컬 우선 (Confluence 읽기 전용)
- `confluence-to-local`: Confluence 우선 (로컬 자동 업데이트)

### 2. 변경사항 감지

#### 로컬 변경사항

**Git 기반 감지:**
```bash
# 마지막 동기화 이후 변경된 파일
git diff --name-only <last-sync-commit> HEAD -- docs_new/
```

**파일 시스템 기반:**
```bash
# 파일 수정 시간 비교
stat -c %Y docs_new/05_api_specification.md
```

#### Confluence 변경사항

**페이지 버전 확인:**
```json
{
  "pageId": "345678",
  "version": {
    "number": 5,
    "when": "2025-10-30T14:30:00Z",
    "by": {
      "displayName": "Jane Smith"
    }
  }
}
```

**변경 내용 비교:**
- 마지막 동기화 버전과 현재 버전 비교
- Confluence 페이지 히스토리 조회
- Diff 생성

### 3. Confluence → 로컬 (Pull)

**변경사항 다운로드:**
```markdown
## Pull 대상

1. **API 명세서** (05_api_specification.md)
   - Confluence 버전: v5 (2025-10-30 14:30)
   - 로컬 버전: v4 (2025-10-29 10:30)
   - 변경자: Jane Smith
   - 변경 내용:
     - 엔드포인트 3개 추가
     - 응답 스키마 수정

2. **데이터베이스 스키마** (04_database_schema.md)
   - Confluence 버전: v3 (2025-10-30 11:00)
   - 로컬 버전: v3 (동일)
   - 변경 없음
```

**Confluence Storage Format → Markdown 변환:**
```markdown
# Confluence
{code:language=typescript}
interface User {
  id: number;
}
{code}

# Markdown
\`\`\`typescript
interface User {
  id: number;
}
\`\`\`
```

**로컬 파일 업데이트:**
1. 백업 생성: `docs_new/05_api_specification.md.backup`
2. 새 내용으로 파일 덮어쓰기
3. Git 커밋: `docs: Confluence에서 API 명세서 동기화 (v5)`

### 4. 로컬 → Confluence (Push)

**변경사항 업로드:**
```markdown
## Push 대상

1. **공통 컴포넌트 명세** (00_common_components.md)
   - 로컬 버전: 2025-10-30 15:00
   - Confluence 버전: 2025-10-27 09:00
   - 변경 내용:
     - CC-ICON-BUTTON 컴포넌트 추가
     - CC-MODAL props 수정

2. **화면설계서** (01_screen_picofriends.md)
   - 로컬 버전: 2025-10-30 13:00
   - Confluence 버전: 2025-10-30 13:00 (동일)
   - 변경 없음
```

**Markdown → Confluence 업로드:**
1. 마크다운 파싱 및 변환
2. 이미지 파일 첨부
3. Confluence API로 페이지 업데이트
4. 버전 메시지: Git 커밋 메시지 사용

### 5. 충돌 감지 및 해결

**충돌 시나리오:**
```markdown
## 충돌 감지: docs_new/05_api_specification.md

### Confluence (v5, 2025-10-30 14:30, Jane Smith)
\`\`\`diff
+ POST /api/reports/bulk - 대량 리포트 제출
+ GET /api/statistics/team - 팀 통계
\`\`\`

### 로컬 (2025-10-30 15:00, Git commit abc123, John Doe)
\`\`\`diff
+ POST /api/reports/export - 리포트 내보내기
+ DELETE /api/reports/{id} - 리포트 삭제
\`\`\`

### 충돌 타입: 동시 수정 (Concurrent Modification)
```

**해결 전략:**

**1. 자동 병합 (Auto-merge)**
- 서로 다른 섹션 수정 → 자동 병합 가능
- Git 3-way merge 알고리즘 사용

**2. 수동 병합 (Manual Merge)**
```markdown
## 병합 에디터

### Base (마지막 동기화 버전)
\`\`\`markdown
## API 엔드포인트
...
\`\`\`

### Confluence (원격 변경)
\`\`\`markdown
## API 엔드포인트
+ POST /api/reports/bulk
+ GET /api/statistics/team
...
\`\`\`

### Local (로컬 변경)
\`\`\`markdown
## API 엔드포인트
+ POST /api/reports/export
+ DELETE /api/reports/{id}
...
\`\`\`

### 병합 결과 (사용자 선택)
- [ ] Confluence 우선 (로컬 변경사항 폐기)
- [ ] 로컬 우선 (Confluence 변경사항 덮어쓰기)
- [x] 수동 병합 (두 변경사항 모두 포함)

\`\`\`markdown
## API 엔드포인트
+ POST /api/reports/bulk
+ POST /api/reports/export
+ GET /api/statistics/team
+ DELETE /api/reports/{id}
...
\`\`\`
```

**3. 충돌 회피 (Conflict Avoidance)**
- Confluence 페이지에 "동기화 중..." 라벨 추가
- 동기화 중 다른 사용자의 수정 방지
- 동기화 완료 후 라벨 제거

### 6. 동기화 상태 추적

**동기화 로그: `.claude/confluence-sync.log`**
```log
[2025-10-30 15:00:00] SYNC START
[2025-10-30 15:00:05] PULL docs_new/05_api_specification.md (Confluence v5 → Local)
[2025-10-30 15:00:10] CONFLICT docs_new/05_api_specification.md
[2025-10-30 15:01:30] MERGE MANUAL (User selected manual merge)
[2025-10-30 15:01:35] PUSH docs_new/00_common_components.md (Local → Confluence v6)
[2025-10-30 15:01:40] SYNC COMPLETE (2 files synced, 1 conflict resolved)
```

**동기화 요약 리포트:**
```markdown
# Confluence 동기화 리포트

## 📊 요약
- 동기화 시작: 2025-10-30 15:00:00
- 동기화 완료: 2025-10-30 15:01:40
- 소요 시간: 1분 40초

## ⬇️ Pull (Confluence → 로컬)
1. ✅ 05_api_specification.md (v5)
2. ⏭️ 04_database_schema.md (변경 없음)

## ⬆️ Push (로컬 → Confluence)
1. ✅ 00_common_components.md → v6
2. ⏭️ 01_screen_picofriends.md (변경 없음)

## ⚠️ 충돌
1. ✅ 05_api_specification.md (수동 병합 완료)

## 📝 다음 동기화
- 예정: 2025-10-31 10:00 (자동)
- 또는 수동: `/confluence-sync` 실행
```

### 7. 자동 동기화 스케줄

**Cron 스타일 스케줄:**
```json
{
  "autoSync": {
    "enabled": true,
    "schedule": "0 10,14,17 * * 1-5",
    "timezone": "Asia/Seoul",
    "conflictResolution": "manual",
    "notifyOnConflict": true
  }
}
```

**동기화 트리거:**
- 정기 스케줄 (매일 10시, 14시, 17시)
- Git 커밋 후 (git hook)
- 파일 변경 감지 (file watcher)
- 수동 실행 (`/confluence-sync`)

## 사용 예시

- "Confluence와 로컬 문서 양방향 동기화"
- "API 명세서 Confluence 변경사항 Pull"
- "공통 컴포넌트 명세 로컬 변경사항 Push"
- "동기화 충돌 해결"
- "docs_new/ 전체 동기화 (자동 병합)"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `getConfluencePage`: 페이지 조회 (버전 확인)
- `updateConfluencePage`: 페이지 업데이트
- `searchConfluenceUsingCql`: CQL로 페이지 검색
  - 예: `space = PICO AND lastModified >= '2025-10-30'`

**Git 통합:**
- 로컬 변경사항은 Git 커밋으로 추적
- Confluence 변경사항도 Git에 반영 (자동 커밋)
- 병합 충돌은 Git merge 도구 활용
