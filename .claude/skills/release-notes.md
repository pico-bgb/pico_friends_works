# 릴리즈 노트 자동 생성 스킬

Jira 이슈와 Git 커밋을 기반으로 릴리즈 노트를 생성합니다.

**이 스킬은 atlassian-project-manager agent를 사용합니다.**

## 작업 수행

### 1. 릴리즈 버전 정보 수집

**Jira Fix Version:**
```jql
project = PF AND fixVersion = "v1.5.0" AND status = Done
```

**Git 태그 및 커밋:**
```bash
# 이전 릴리즈와 현재 사이의 커밋
git log v1.4.0..v1.5.0 --oneline --no-merges

# 또는 날짜 기반
git log --since="2025-10-15" --until="2025-10-30" --oneline
```

### 2. 이슈 분류

**카테고리별 분류:**

1. **✨ Features (새로운 기능)**
   - Jira 이슈 타입: Story, Epic
   - Git 커밋: `feat:` prefix

2. **🐛 Bug Fixes (버그 수정)**
   - Jira 이슈 타입: Bug
   - Git 커밋: `fix:` prefix

3. **⚡ Performance (성능 개선)**
   - Jira 라벨: `performance`
   - Git 커밋: `perf:` prefix

4. **♻️ Refactoring (리팩토링)**
   - Git 커밋: `refactor:` prefix

5. **📝 Documentation (문서)**
   - Jira 이슈 타입: Task (문서 관련)
   - Git 커밋: `docs:` prefix

6. **🔧 Chore (기타 변경)**
   - Git 커밋: `chore:`, `build:`, `ci:` prefix

7. **💥 Breaking Changes (호환성 변경)**
   - Jira 라벨: `breaking-change`
   - Git 커밋: `BREAKING CHANGE:` 포함

### 3. 릴리즈 노트 생성

**형식 (Keep a Changelog 스타일):**

```markdown
# Release Notes - v1.5.0

**Release Date**: 2025-10-30
**Release Type**: Minor Release
**Jira Fix Version**: [v1.5.0](https://picoinnov.atlassian.net/projects/PF?selectedItem=com.atlassian.jira.jira-projects-plugin:release-page&status=released)

---

## 📋 목차

- [🎉 주요 기능](#주요-기능)
- [✨ 새로운 기능](#새로운-기능)
- [🐛 버그 수정](#버그-수정)
- [⚡ 성능 개선](#성능-개선)
- [📝 문서 업데이트](#문서-업데이트)
- [💥 Breaking Changes](#breaking-changes)
- [🔄 마이그레이션 가이드](#마이그레이션-가이드)
- [📦 Dependencies](#dependencies)
- [👥 Contributors](#contributors)

---

## 🎉 주요 기능

이번 릴리즈에서는 **공통 컴포넌트 18개**를 추가하고, **리더보드 기능**을 새롭게 도입했습니다.

### 하이라이트

1. **공통 컴포넌트 Phase 1 완료** 🎨
   - CC-LOGIN, CC-SIGNUP, CC-HEADER-MOBILE 등 8개 컴포넌트
   - Storybook 문서화 완료
   - 단위 테스트 커버리지 85%

2. **리더보드 기능** 🏆
   - 실시간 방문 순위 조회
   - 팀별/개인별 통계
   - 애니메이션 효과

3. **CSV 일괄 업로드** 📊
   - 약국 정보 대량 등록
   - 유효성 검증 및 에러 리포트
   - 진행률 표시

---

## ✨ 새로운 기능

### 피코프렌즈 (현장 요원용)

#### 인증 시스템
- **[PF-33]** 로그인/회원가입 컴포넌트 구현 [@johndoe]
  - JWT 토큰 기반 인증
  - 자동 로그인 옵션
  - 소셜 로그인 준비 (구글, 카카오)

#### 공통 컴포넌트
- **[PF-34]** 모바일/관리자 헤더 컴포넌트 [@janedoe]
  - 반응형 디자인
  - 햄버거 메뉴
  - 알림 배지

- **[PF-35]** 기본 UI 컴포넌트 (버튼, 뱃지, 로딩, 토스트) [@johndoe]
  - 8가지 버튼 variants
  - 5가지 뱃지 colors
  - 스켈레톤 로딩 UI

- **[PF-36]** 모달 컴포넌트 (모달, 확인 모달) [@bobjohnson]
  - 접근성 개선 (키보드 트랩, ESC 닫기)
  - 애니메이션 효과
  - 중첩 모달 지원

#### 리더보드
- **[PF-43]** 리더보드 화면 구현 [@janedoe]
  - 실시간 순위 업데이트
  - 팀별/개인별 필터
  - 월간/주간 통계

### 관리자 페이지

#### 약국 관리
- **[AD-20]** CSV 일괄 업로드 기능 [@bobjohnson]
  - Papa Parse 라이브러리 사용
  - 실시간 진행률 표시
  - 에러 행 다운로드

#### 통계
- **[AD-50]** 통계 대시보드 [@johndoe]
  - Recharts 차트 시각화
  - 약국별/요원별 통계
  - 엑셀 내보내기

---

## 🐛 버그 수정

### 인증
- **[PF-45]** 로그인 실패 시 에러 메시지 미표시 문제 수정 [@johndoe]
  - Axios error response 핸들링 개선
  - Toast 컴포넌트 연동

### UI/UX
- **[PF-46]** 모달 닫기 버튼 클릭 시 폼 제출되는 버그 수정 [@janedoe]
  - 버튼 type을 `type="button"`으로 명시

- **[PF-47]** 모바일 헤더 메뉴 클릭 시 닫히지 않는 문제 수정 [@bobjohnson]
  - useOutsideClick 훅 추가

### API 연동
- **[PF-48]** 토큰 만료 시 무한 루프 문제 수정 [@johndoe]
  - Axios interceptor 로직 개선
  - Refresh token 재시도 횟수 제한

---

## ⚡ 성능 개선

- **로그인 응답 시간 50% 단축** (1.2s → 0.6s)
  - Redis 캐싱 적용
  - DB 인덱스 최적화

- **공통 컴포넌트 번들 크기 30% 감소**
  - Tree-shaking 최적화
  - Lazy loading 적용

- **리더보드 렌더링 성능 개선**
  - React.memo 적용
  - 가상 스크롤 (react-window)

---

## 📝 문서 업데이트

- **API 명세서 v3.0**
  - 엔드포인트 15개 추가
  - 요청/응답 예시 보강

- **DB 스키마 v2.5**
  - 테이블 5개 추가
  - ERD 다이어그램 업데이트

- **공통 컴포넌트 명세 v4.0**
  - 컴포넌트 20개 상세 스펙
  - Storybook 링크 추가

- **화면설계서 v1.5**
  - 화면 35개 최신화
  - 슬라이드 이미지 추가

---

## 💥 Breaking Changes

### API 변경

#### 1. `/api/tasks` 엔드포인트 페이지네이션 필수화

**Before (v1.4.0):**
```typescript
GET /api/tasks
// 모든 약국 목록 반환 (최대 1000개)
```

**After (v1.5.0):**
```typescript
GET /api/tasks?page=0&size=20&sort=createdAt,desc
// 페이지네이션 파라미터 필수
```

**마이그레이션:**
```typescript
// AS-IS
const { data } = await axios.get('/api/tasks');

// TO-BE
const { data } = await axios.get('/api/tasks', {
  params: { page: 0, size: 20, sort: 'createdAt,desc' }
});
```

#### 2. `/api/reports` 응답 형식 변경

**Before:**
```json
{
  "data": [...]
}
```

**After:**
```json
{
  "content": [...],
  "pageable": {...},
  "totalElements": 100
}
```

### 데이터베이스 스키마 변경

#### 1. `t_pico_friends_report.answers` 컬럼 타입 변경

**Before:** `TEXT`
**After:** `JSONB`

**마이그레이션 SQL:**
```sql
ALTER TABLE t_pico_friends_report
ALTER COLUMN answers TYPE JSONB USING answers::JSONB;

CREATE INDEX idx_report_answers_gin ON t_pico_friends_report USING gin(answers);
```

---

## 🔄 마이그레이션 가이드

### 백엔드 (Spring Boot)

1. **환경 변수 업데이트**
```bash
# .env
JWT_SECRET=<새로운 256비트 키>
REDIS_HOST=localhost
REDIS_PORT=6379
```

2. **DB 마이그레이션 실행**
```bash
psql -U postgres -d pico_friends -f src/main/resources/db/migration/V3__update_report_answers.sql
```

3. **애플리케이션 재시작**
```bash
./gradlew bootRun
```

### 프론트엔드 (Next.js)

1. **의존성 업데이트**
```bash
npm install
```

2. **API 클라이언트 수정**
```typescript
// lib/api/tasks.ts
export const getTasks = async (params: TasksParams) => {
  const { data } = await apiClient.get<TasksResponse>('/tasks', { params });
  return data;
};
```

3. **환경 변수 확인**
```bash
# .env.local
NEXT_PUBLIC_API_URL=http://localhost:8080/api
```

4. **빌드 및 실행**
```bash
npm run build
npm start
```

---

## 📦 Dependencies

### 추가된 의존성

**Frontend:**
```json
{
  "react": "^19.0.0-rc",
  "recharts": "^2.10.0",
  "papaparse": "^5.4.1",
  "react-window": "^1.8.10"
}
```

**Backend:**
```gradle
implementation 'org.springframework.boot:spring-boot-starter-data-redis'
implementation 'com.querydsl:querydsl-jpa:5.0.0:jakarta'
```

### 업데이트된 의존성

- **Spring Boot**: 3.3.5 → 3.5.6
- **Next.js**: 14.0.0 → 14.2.0
- **PostgreSQL Driver**: 42.6.0 → 42.7.1

---

## 👥 Contributors

이번 릴리즈에 기여해주신 분들께 감사드립니다!

- [@johndoe](https://github.com/johndoe) - 12 commits, 15 issues
- [@janedoe](https://github.com/janedoe) - 10 commits, 10 issues
- [@bobjohnson](https://github.com/bobjohnson) - 8 commits, 8 issues

**Special Thanks** 🙏
- QA Team: 버그 리포트 및 테스트
- Design Team: UI/UX 디자인

---

## 📊 통계

- **총 커밋**: 45개
- **총 이슈**: 33개 (완료)
- **코드 변경**: +12,345 / -3,456 lines
- **테스트 커버리지**: 75% → 85%
- **빌드 시간**: 3분 → 2분

---

## 🔗 Links

- [Jira Release](https://picoinnov.atlassian.net/projects/PF/versions/10001)
- [GitHub Release](https://github.com/pico-innovation/pico-friends/releases/tag/v1.5.0)
- [Confluence Docs](https://picoinnov.atlassian.net/wiki/spaces/PICO/pages/123456/Release+v1.5.0)
- [API Docs](http://localhost:8080/swagger-ui.html)

---

**Full Changelog**: [v1.4.0...v1.5.0](https://github.com/pico-innovation/pico-friends/compare/v1.4.0...v1.5.0)
```

### 4. 다중 포맷 지원

**Markdown:** `CHANGELOG.md`, `RELEASE_NOTES_v1.5.0.md`
**Confluence:** Confluence 페이지로 발행
**GitHub Release:** GitHub Releases에 자동 생성
**Slack/이메일:** 요약본 발송

### 5. 자동 생성 트리거

- Git 태그 푸시 시 (`git tag v1.5.0 && git push --tags`)
- Jira Fix Version "Released" 상태 변경 시
- 수동 실행 (`/release-notes v1.5.0`)

## 사용 예시

- "v1.5.0 릴리즈 노트 생성"
- "최근 릴리즈와 현재의 변경사항으로 릴리즈 노트 작성"
- "v1.4.0부터 v1.5.0까지의 릴리즈 노트"
- "릴리즈 노트를 Confluence와 GitHub Releases에 발행"

## 참고

**atlassian-project-manager agent 도구 사용:**
- `searchJiraIssuesUsingJql`: Fix Version 이슈 조회
- `getJiraIssue`: 이슈 상세 정보
- `createConfluencePage`: Confluence에 릴리즈 노트 발행
