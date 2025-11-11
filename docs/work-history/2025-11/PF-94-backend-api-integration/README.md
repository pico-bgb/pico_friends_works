# PF-94: 백엔드 신규 API 통합 (WorkRequest, Pharmacy Assignment)

**작업 기간**: 2025-11-11
**작업자**: Claude Code (screen-dev, spec-helper 스킬)
**관련 커밋**:
- Backend: b77a0865581cc7d4f50c322aecbe438f509efba0
- Frontend: 92d6040

## 작업 개요

백엔드 커밋 b77a086에서 추가된 테이블 스키마 변경 및 신규 API를 프론트엔드에 통합하는 작업.

### 주요 변경사항

#### 1. 백엔드 스키마 변경 (b77a086)
- 컬럼명 표준화: `create_no` → `created_by`, `update_no` → `updated_by`
- 날짜 필드: `create_date` → `created_at`, `update_date` → `updated_at`
- 삭제 플래그: `is_delete` → `is_deleted`

#### 2. 신규 API 추가
- **WorkRequest API**: 사용자가 관리자에게 약국 배정 요청
  - `POST /api/work-requests` - 업무 요청 생성
  - `GET /api/work-requests` - 업무 요청 목록 조회
  - `GET /api/work-requests/pending` - 미완료 요청 확인

- **Pharmacy Assignment API**: 관리자가 약국 담당자 배정
  - `POST /api/pharmacies/{id}/assign` - 약국 배정
  - `DELETE /api/pharmacies/{id}/assign` - 약국 배정 해제

- **User Pharmacy Assignment API**: 사용자에게 다수 약국 배정
  - `POST /api/users/{id}/assign-pharmacies` - 약국 일괄 배정

#### 3. 프론트엔드 통합 (92d6040)

**신규 파일 (8개)**:
- `src/types/work-request.ts` - WorkRequest 타입 정의
- `src/lib/api/work-request.ts` - WorkRequest API 클라이언트
- `src/lib/api/user.ts` - User Pharmacy Assignment API
- `src/hooks/useWorkRequests.ts` - React Query 훅 (WorkRequest)
- `src/hooks/usePharmacyAssignment.ts` - React Query 훅 (Pharmacy Assignment)
- `src/mocks/handlers/work-request.ts` - MSW Mock 핸들러
- `src/mocks/handlers/pharmacy.ts` - MSW Mock 핸들러
- `src/mocks/handlers/user-assignment.ts` - MSW Mock 핸들러

**수정 파일 (4개)**:
- `src/components/mobile/TaskRequestButton/TaskRequestButton.tsx` - API 연동
- `src/lib/api/pharmacy.ts` - Pharmacy Assignment API 추가
- `src/types/pharmacy.ts` - 요청 타입 추가
- `src/mocks/handlers/index.ts` - 핸들러 통합

## 관련 문서

- [SCHEMA_MIGRATION_b77a086.md](./SCHEMA_MIGRATION_b77a086.md) - 스키마 마이그레이션 가이드
- [FRONTEND_UPDATES.md](./FRONTEND_UPDATES.md) - 프론트엔드 업데이트 상세 내역
- [UPDATE_SUMMARY.md](./UPDATE_SUMMARY.md) - 작업 완료 요약

## Jira 링크

[PF-94: [FE] 백엔드 신규 API 통합 (WorkRequest, Pharmacy Assignment)](https://picoinnov.atlassian.net/browse/PF-94)

## Git 커밋

### Backend (pico_friends_be)
```
b77a0865581cc7d4f50c322aecbe438f509efba0
테이블 스키마 및 컬럼명 프리징

- 42 files changed
- 컬럼명 표준화 (created_by, updated_by, created_at, updated_at)
- WorkRequest, PharmacyVisitInfo 엔티티 추가
- WorkRequestController, API 추가
```

### Frontend (pico_friends_fe)
```
92d6040
PF-94 feat: 백엔드 신규 API 통합 (WorkRequest, Pharmacy Assignment)

- 12 files changed (8 new, 4 modified)
- 585 insertions, 15 deletions
- React Query 훅, MSW Mock 핸들러
- TaskRequestButton 컴포넌트 API 연동
```

## 기술 스택

- **Frontend**: Next.js 15.1.6, React 19, TypeScript, TanStack Query, MSW
- **Backend**: Spring Boot 3.3.5, Java 21, JPA, PostgreSQL
- **State Management**: Zustand, React Query
- **API Mocking**: MSW (Mock Service Worker)

## 테스트 시나리오

### 1. WorkRequest 생성
1. 모바일 웹에서 "업무 요청" 버튼 클릭
2. Toast 알림 확인: "업무 요청 완료"
3. 버튼 상태 변경: "대기 중"

### 2. Pharmacy Assignment (관리자)
1. 관리자 웹에서 약국 목록 조회
2. 약국 선택 → 담당자 배정
3. 자동으로 WorkRequest 완료 처리

### 3. 캐시 무효화 확인
- 약국 배정 시 `pharmacies`, `work-requests`, `users` 쿼리 자동 refetch

## 다음 단계

1. **관리자 UI 개발** (선택):
   - WorkRequest 목록 조회 화면
   - 약국 배정 인터페이스

2. **E2E 테스트 작성** (선택):
   - Playwright 테스트 시나리오 추가

3. **Storybook 스토리 추가** (선택):
   - TaskRequestButton 컴포넌트 스토리

## 참고사항

- MSW 핸들러는 로컬 개발용이며, 백엔드 API 구현 후 제거 예정
- 프론트엔드는 이미 올바른 필드명(createdAt, updatedAt) 사용 중 → 스키마 변경 영향 없음
- React Query 자동 캐시 무효화로 데이터 일관성 보장

---

**작성일**: 2025-11-11
**문서 버전**: 1.0.0
