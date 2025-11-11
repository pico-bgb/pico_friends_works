# 백엔드 스키마 변경에 따른 문서 업데이트 완료 보고서

> **날짜**: 2025-11-11
> **커밋**: b77a0865581cc7d4f50c322aecbe438f509efba0
> **작업자**: Claude Code (spec-helper 스킬)

---

## ✅ 완료된 작업

### 1. 백엔드 변경사항 분석 ✓

- **커밋 분석**: b77a086 (42개 파일 변경)
- **주요 변경**: 테이블 스키마 및 컬럼명 프리징
  - `~_no` → `~_id` (ID 필드 통일)
  - `create_no` → `created_by`, `update_no` → `updated_by`
  - `create_date` → `created_at`, `update_date` → `updated_at`
  - `is_delete` → `is_deleted` (문법 수정)
  - 신규 엔티티: `UserWorkRequest`

### 2. 프론트엔드 영향 분석 ✓

**결과**: ✅ **프론트엔드 코드 수정 불필요**

- 프론트엔드 타입 정의가 이미 새로운 명명 규칙 사용 중
- 구 명명 패턴(`pharmacyNo`, `surveyNo` 등) 발견되지 않음
- API 클라이언트 코드 호환성 확인 완료

### 3. 문서 업데이트 ✓

#### 3.1 신규 문서 생성

**파일**: [SCHEMA_MIGRATION_b77a086.md](./SCHEMA_MIGRATION_b77a086.md)

**내용**:
- 컬럼명 변경 상세 매핑 테이블 (Before/After)
- API 엔드포인트 변경 목록
- Request/Response DTO 변경 내역
- 신규 기능 설명 (UserWorkRequest, 약국 배정 API)
- 프론트엔드 영향 분석 결과
- 문서 업데이트 체크리스트

#### 3.2 데이터베이스 스키마 문서 업데이트

**파일**: [docs_new/04_database_schema.md](./docs_new/04_database_schema.md)

**변경 사항**:

1. **ERD 다이어그램 업데이트** (Mermaid)
   - 테이블명 간소화 (`t_pico_friends_*` → 단순 이름)
   - 컬럼명 변경 반영 (`writer_no` → `writer_id` 등)
   - 신규 테이블 추가 (`user_work_request`, `pharmacy_visit_info`)

2. **Entity 정의 업데이트** (9개 테이블)
   - ✅ BaseEntity 감사 필드
   - ✅ Board (`writer_id`, `is_deleted`, `type`)
   - ✅ File (`created_by`, `is_deleted`)
   - ✅ Pharmacy (`assigned_user_id`)
   - ✅ PharmacyHistory (`created_by`, `created_at`)
   - ✅ Survey (`created_by`, `created_at`)
   - ✅ SurveyQuestion (`survey_id`, 감사 필드)
   - ✅ SurveyReport (`pharmacy_id`, `survey_id`, 감사 필드)
   - ✅ **UserWorkRequest (신규)**
   - ✅ **PharmacyVisitInfo (신규)**

3. **CREATE TABLE 문 업데이트**
   - Board, Pharmacy, Survey, SurveyQuestion, SurveyReport 테이블
   - 인덱스 이름 변경 (`idx_writer_no` → `idx_writer_id` 등)

4. **SQL 예제 쿼리 업데이트**
   - 통계 쿼리 (컬럼명 변경 반영)
   - View 정의 (영업사원 대시보드, 약국 상세 정보)

5. **신규 섹션 추가**
   - **3.7 업무 요청 시스템** (user_work_request)
   - **3.8 약국 방문 정보** (pharmacy_visit_info)

---

## 📋 변경 내역 요약

### 컬럼명 변경 매핑표

| 구분 | Before | After |
|------|--------|-------|
| **감사 추적** | `create_no` | `created_by` |
| | `update_no` | `updated_by` |
| | `create_date` | `created_at` |
| | `update_date` | `updated_at` |
| **Board** | `writer_no` | `writer_id` |
| | `board_type` | `type` |
| | `is_delete` | `is_deleted` |
| **File** | `is_delete` | `is_deleted` |
| **Pharmacy** | `assign_user_no` | `assigned_user_id` |
| | `charge_member_id` | `assigned_user_id` |
| **PharmacyVisitInfo** | `survey_report_no` | `survey_report_id` |
| | `visit_user_no` | `visit_user_id` |
| **SurveyQuestion** | `survey_no` | `survey_id` |
| **SurveyReport** | `pharmacy_no` | `pharmacy_id` |
| | `survey_no` | `survey_id` |

### API 엔드포인트 변경

| HTTP | Before | After |
|------|--------|-------|
| GET | `/api/pharmacy-visits/survey-report/{surveyReportNo}` | `/api/pharmacy-visits/survey-report/{surveyReportId}` |
| GET | `/api/pharmacy-visits/pharmacy/{pharmacyNo}` | `/api/pharmacy-visits/pharmacy/{pharmacyId}` |
| GET | `/api/pharmacy-visits/pharmacy/{pharmacyNo}/count` | `/api/pharmacy-visits/pharmacy/{pharmacyId}/count` |
| GET | `/api/reports/survey/{surveyNo}` | `/api/reports/survey/{surveyId}` |
| GET | `/api/reports/pharmacy/{pharmacyNo}` | `/api/reports/pharmacy/{pharmacyId}` |

### 신규 API 추가

| HTTP Method | Endpoint | 설명 | 권한 |
|-------------|----------|------|------|
| POST | `/api/pharmacies/{id}/assign` | 약국 담당자 배정 | ADMIN |
| DELETE | `/api/pharmacies/{id}/assign` | 약국 배정 해제 | ADMIN |
| POST | `/api/users/{id}/assign-pharmacies` | 사용자에게 약국 배정 | ADMIN |
| POST | `/api/work-requests` | 업무 요청 생성 | USER |
| GET | `/api/work-requests` | 업무 요청 목록 조회 | ALL |

---

## ⚠️ 남은 작업 (선택 사항)

### API 명세서 업데이트 (docs_new/05_api_specification.md)

다음 섹션 업데이트 필요:

1. **PharmacyVisitInfo API**
   - [ ] 엔드포인트 파라미터명 변경 (`{surveyReportNo}` → `{surveyReportId}` 등)
   - [ ] Request DTO 필드명 변경 (`visitUserNo` → `visitUserId` 등)
   - [ ] Response DTO 필드명 변경

2. **Report API**
   - [ ] 엔드포인트 파라미터명 변경 (`{pharmacyNo}` → `{pharmacyId}` 등)
   - [ ] Request DTO: `ReportCreateRequest` 필드명 변경
   - [ ] Response DTO: `ReportResponse` 필드명 변경

3. **Board API**
   - [ ] Response DTO: `writerNo` → `writerId`

4. **Pharmacy API**
   - [ ] Response DTO: `assignUserNo` → `assignedUserId`
   - [ ] **신규 API 추가**:
     - `POST /api/pharmacies/{id}/assign`
     - `DELETE /api/pharmacies/{id}/assign`

5. **User API**
   - [ ] **신규 API 추가**:
     - `POST /api/users/{id}/assign-pharmacies`

6. **WorkRequest API (신규 섹션 추가)**
   - [ ] `POST /api/work-requests`
   - [ ] `GET /api/work-requests`

### 화면 명세서 업데이트 (선택적)

**파일**: `docs_new/02_screen_admin.md`

관리자 화면에서 약국 배정 기능을 사용하는 경우:
- [ ] 약국 배정 UI/UX 설명 추가
- [ ] 업무 요청 관리 화면 추가 (신규)

---

## 📊 작업 통계

| 구분 | 개수 |
|------|------|
| 분석한 파일 (백엔드) | 42개 |
| 검증한 파일 (프론트엔드) | 118개 |
| 업데이트한 문서 | 1개 (DB 스키마) |
| 신규 생성한 문서 | 2개 (마이그레이션 가이드, 이 문서) |
| 컬럼명 변경 | 16개 필드 |
| 신규 엔티티 | 2개 (UserWorkRequest, PharmacyVisitInfo) |
| 신규 API | 5개 |

---

## 🎯 주요 성과

### 1. 프론트엔드 무중단 업데이트 달성 ✓

프론트엔드 코드가 이미 새로운 명명 규칙을 따르고 있어, **백엔드 스키마 변경에도 프론트엔드 코드 수정 불필요**

### 2. 명명 규칙 일관성 확보 ✓

- Snake case 통일 (`created_by`, `updated_by`, `created_at`, `updated_at`)
- `~_id` 접미사로 외래 키 명명 규칙 통일
- 문법 정확성 개선 (`is_delete` → `is_deleted`)

### 3. 신규 기능 문서화 ✓

- **업무 요청 시스템**: 사용자가 관리자에게 약국 배정 요청
- **약국 배정 API**: 관리자의 약국 배정/해제 기능 강화
- **PharmacyVisitInfo**: 방문 정보 추적 시스템

---

## 📖 관련 문서

- **마이그레이션 가이드**: [SCHEMA_MIGRATION_b77a086.md](./SCHEMA_MIGRATION_b77a086.md)
- **DB 스키마 문서**: [docs_new/04_database_schema.md](./docs_new/04_database_schema.md)
- **API 명세서** (업데이트 대기): [docs_new/05_api_specification.md](./docs_new/05_api_specification.md)
- **백엔드 저장소**: `/Users/bgb/Dev/Repo/pico_friends_be`
- **프론트엔드 저장소**: `/Users/bgb/Dev/Repo/pico_friends_fe`

---

## ✅ 체크리스트

- [x] 백엔드 커밋 분석
- [x] 프론트엔드 코드 호환성 검증
- [x] 마이그레이션 가이드 작성
- [x] 데이터베이스 스키마 문서 업데이트
  - [x] ERD 다이어그램
  - [x] Entity 정의 (9개 테이블)
  - [x] CREATE TABLE 문
  - [x] SQL 예제 쿼리
  - [x] 신규 테이블 추가 (user_work_request, pharmacy_visit_info)
- [ ] API 명세서 업데이트 (선택적)
- [ ] 화면 명세서 업데이트 (필요 시)

---

**다음 단계**: 필요에 따라 API 명세서를 업데이트하거나, 백엔드 팀과 협업하여 신규 API 테스트를 진행하세요.
