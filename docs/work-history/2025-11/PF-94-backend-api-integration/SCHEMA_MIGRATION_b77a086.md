# 백엔드 스키마 변경사항 (Commit b77a086)

> **날짜**: 2025-11-11
> **커밋**: b77a0865581cc7d4f50c322aecbe438f509efba0
> **작성자**: jsw <swjeong@picoinnov.com>
> **제목**: chore: 테이블 스키마 및 컬럼명 프리징

---

## 📋 목차

1. [변경 개요](#변경-개요)
2. [컬럼명 변경 상세](#컬럼명-변경-상세)
3. [API 엔드포인트 변경](#api-엔드포인트-변경)
4. [신규 기능 추가](#신규-기능-추가)
5. [프론트엔드 영향 분석](#프론트엔드-영향-분석)
6. [문서 업데이트 필요 사항](#문서-업데이트-필요-사항)

---

## 변경 개요

### 목적
- 데이터베이스 컬럼명을 **snake_case**로 통일
- `~_no` 접미사를 `~_id`로 변경하여 명명 규칙 일관성 확보
- `is_delete` → `is_deleted` 문법 정확성 개선

### 영향 범위
- ✅ **백엔드**: 42개 파일 변경 (Entity, Repository, Service, Controller, DTO)
- ✅ **프론트엔드**: **영향 없음** (이미 새로운 명명 규칙 사용 중)
- ⚠️ **문서**: 업데이트 필요 (DB 스키마, API 명세서)

---

## 컬럼명 변경 상세

### 1. 기본 감사 필드 (BaseEntity)

모든 엔티티에 적용되는 기본 감사 필드가 변경되었습니다.

| 엔티티 | 구 컬럼명 | 신 컬럼명 | 비고 |
|--------|----------|----------|------|
| **BaseEntity** | `create_no` | `created_by` | 생성자 ID |
| **BaseEntity** | `create_date` | `created_at` | 생성 일시 |
| **BaseEntity** | `update_no` | `updated_by` | 수정자 ID |
| **BaseEntity** | `update_date` | `updated_at` | 수정 일시 |

**영향 엔티티**: `Board`, `Pharmacy`, `PharmacyVisitInfo`, `SurveyQuestion`, `SurveyReport`, `UserWorkRequest`

---

### 2. Board (게시판)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `writer_no` | `writer_id` | INTEGER | 작성자 ID |
| `is_delete` | `is_deleted` | BOOLEAN | 삭제 여부 (문법 수정) |

**메서드 변경**:
- `isOwnedBy(Integer userNo)` → `isOwnedBy(Integer userId)`

---

### 3. File (파일)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `create_no` | `created_by` | INTEGER | 생성자 ID (BaseEntity와 별도) |
| `is_delete` | `is_deleted` | BOOLEAN | 삭제 여부 |

**참고**: File은 `BaseEntity`를 상속받지 않으며, `created_by`와 `created_at`만 존재 (update 필드 없음)

---

### 4. Pharmacy (약국)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `assign_user_no` | `assigned_user_id` | INTEGER | 담당 사용자 ID |

**메서드 변경**:
- `isOwnedBy(Integer userNo)` → `isOwnedBy(Integer userId)`

**Repository 변경**:
```java
// OLD
Optional<Pharmacy> findByIdAndAssignUserNo(Integer id, Integer assignUserNo);
List<Pharmacy> findByAssignUserNo(Integer assignUserNo);
long countByAssignUserNo(Integer assignUserNo);

// NEW
Optional<Pharmacy> findByIdAndAssignedUserId(Integer id, Integer assignedUserId);
List<Pharmacy> findByAssignedUserId(Integer assignedUserId);
long countByAssignedUserId(Integer assignedUserId);
```

---

### 5. PharmacyVisitInfo (약국 방문 정보)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `survey_report_no` | `survey_report_id` | INTEGER | 설문 응답 ID (Nullable) |
| `visit_user_no` | `visit_user_id` | INTEGER | 방문 담당자 ID |

**메서드 변경**:
- `markAsVisited(Integer surveyReportNo)` → `markAsVisited(Integer surveyReportId)`
- `isVisitedBy(Integer userId)` 파라미터명 변경

**Repository 변경**:
```java
// OLD
List<PharmacyVisitInfo> findByVisitUserNo(Integer visitUserNo);
Optional<PharmacyVisitInfo> findBySurveyReportNo(Integer surveyReportNo);
long countBySurveyReportPharmacyNo(Integer pharmacyNo);

// NEW
List<PharmacyVisitInfo> findByVisitUserId(Integer visitUserId);
Optional<PharmacyVisitInfo> findBySurveyReportId(Integer surveyReportId);
long countBySurveyReportPharmacyId(Integer pharmacyId);
```

---

### 6. Survey (설문지)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `create_no` | `created_by` | INTEGER | 생성자 ID (BaseEntity 미상속) |

---

### 7. SurveyQuestion (설문 질문)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `survey_no` | `survey_id` | INTEGER | 설문지 ID |

**Repository 변경**:
```java
// OLD
List<SurveyQuestion> findBySurveyNoAndIsActiveTrueOrderByDisplayOrder(Integer surveyNo);

// NEW
List<SurveyQuestion> findBySurveyIdAndIsActiveTrueOrderByDisplayOrder(Integer surveyId);
```

---

### 8. SurveyReport (설문 응답)

| 구 컬럼명 | 신 컬럼명 | 타입 | 비고 |
|----------|----------|------|------|
| `pharmacy_no` | `pharmacy_id` | INTEGER | 약국 ID |
| `survey_no` | `survey_id` | INTEGER | 설문지 ID |

**메서드 변경**:
- `isCreatedBy(Integer userId)` 내부 로직: `getCreateNo()` → `getCreatedBy()`

**Repository 변경**:
```java
// OLD
List<SurveyReport> findBySurveyNo(Integer surveyNo);
List<SurveyReport> findByPharmacyNo(Integer pharmacyNo);

// NEW
List<SurveyReport> findBySurveyId(Integer surveyId);
List<SurveyReport> findByPharmacyId(Integer pharmacyId);
```

---

### 9. UserWorkRequest (신규 엔티티)

**새로 추가된 엔티티** - 업무 요청 시스템

| 컬럼명 | 타입 | Nullable | 설명 |
|--------|------|----------|------|
| `id` | INTEGER | NO | PK (Auto Increment) |
| `user_id` | INTEGER | NO | 요청 사용자 ID |
| `is_completed` | BOOLEAN | NO | 완료 여부 (기본값: false) |
| `created_by` | INTEGER | NO | 생성자 (BaseEntity) |
| `created_at` | TIMESTAMP | NO | 생성 일시 |
| `updated_by` | INTEGER | NO | 수정자 |
| `updated_at` | TIMESTAMP | NO | 수정 일시 |

---

## API 엔드포인트 변경

### 1. PharmacyVisitInfoController

| 구 엔드포인트 | 신 엔드포인트 | HTTP Method |
|--------------|--------------|-------------|
| `GET /api/pharmacy-visits/survey-report/{surveyReportNo}` | `GET /api/pharmacy-visits/survey-report/{surveyReportId}` | GET |
| `GET /api/pharmacy-visits/pharmacy/{pharmacyNo}` | `GET /api/pharmacy-visits/pharmacy/{pharmacyId}` | GET |
| `GET /api/pharmacy-visits/pharmacy/{pharmacyNo}/count` | `GET /api/pharmacy-visits/pharmacy/{pharmacyId}/count` | GET |

---

### 2. ReportController

| 구 엔드포인트 | 신 엔드포인트 | HTTP Method |
|--------------|--------------|-------------|
| `GET /api/reports/survey/{surveyNo}` | `GET /api/reports/survey/{surveyId}` | GET |
| `GET /api/reports/pharmacy/{pharmacyNo}` | `GET /api/reports/pharmacy/{pharmacyId}` | GET |

---

### 3. PharmacyController (신규 추가)

| 엔드포인트 | HTTP Method | 설명 | 권한 |
|-----------|-------------|------|------|
| `POST /api/pharmacies/{id}/assign` | POST | 약국 담당자 배정 | ADMIN |
| `DELETE /api/pharmacies/{id}/assign` | DELETE | 약국 배정 해제 | ADMIN |

**Request Body (PharmacyAssignRequest)**:
```json
{
  "userId": 123
}
```

---

### 4. UserController (신규 추가)

| 엔드포인트 | HTTP Method | 설명 | 권한 |
|-----------|-------------|------|------|
| `POST /api/users/{id}/assign-pharmacies` | POST | 사용자에게 약국 배정 | ADMIN |

**Request Body (UserPharmaciesAssignRequest)**:
```json
{
  "pharmacyIds": [1, 2, 3, 4, 5]
}
```

---

### 5. WorkRequestController (신규 추가)

| 엔드포인트 | HTTP Method | 설명 | 권한 |
|-----------|-------------|------|------|
| `POST /api/work-requests` | POST | 업무 요청 생성 | USER |
| `GET /api/work-requests` | GET | 업무 요청 목록 조회 | ALL |

**Query Parameters (GET)**:
- `isCompleted` (Boolean, Optional): 완료 상태 필터
  - `true`: 완료된 요청만
  - `false`: 미완료 요청만
  - 미지정: 전체 요청
- `page`, `size`, `sort` (Pageable)

**조회 범위**:
- **USER**: 본인의 요청만 조회
- **ADMIN/VIEWER**: 모든 요청 조회

---

## Request/Response DTO 변경

### 1. PharmacyVisitAssignRequest

```java
// OLD
public record PharmacyVisitAssignRequest(
    Integer visitUserNo,
    String description
) {}

// NEW
public record PharmacyVisitAssignRequest(
    Integer visitUserId,
    String description
) {}
```

---

### 2. PharmacyVisitCompleteRequest

```java
// OLD
public record PharmacyVisitCompleteRequest(
    Integer surveyReportNo,
    String description
) {}

// NEW
public record PharmacyVisitCompleteRequest(
    Integer surveyReportId,
    String description
) {}
```

---

### 3. ReportCreateRequest

```java
// OLD
public record ReportCreateRequest(
    Integer pharmacyNo,
    Integer surveyNo,
    Map<String, Object> answers
) {}

// NEW
public record ReportCreateRequest(
    Integer pharmacyId,
    Integer surveyId,
    Map<String, Object> answers
) {}
```

---

### 4. BoardResponse

```java
// OLD
public record BoardResponse(
    Integer id,
    Integer writerNo,
    String writerName,
    ...
) {}

// NEW
public record BoardResponse(
    Integer id,
    Integer writerId,
    String writerName,
    ...
) {}
```

---

### 5. PharmacyResponse

```java
// OLD
assignUserNo → assignedUserId
```

---

### 6. PharmacyVisitInfoResponse

```java
// OLD
visitUserNo → visitUserId
surveyReportNo → surveyReportId
```

---

### 7. ReportResponse

```java
// OLD
pharmacyNo → pharmacyId
surveyNo → surveyId
```

---

### 8. 신규 DTO

#### PharmacyAssignRequest
```java
public record PharmacyAssignRequest(
    Integer userId
) {}
```

#### UserPharmaciesAssignRequest
```java
public record UserPharmaciesAssignRequest(
    List<Integer> pharmacyIds
) {}
```

#### WorkRequestResponse
```java
public record WorkRequestResponse(
    Integer id,
    Integer userId,
    String userName,
    Boolean isCompleted,
    LocalDateTime createdAt
) {}
```

---

## 신규 기능 추가

### 1. 업무 요청 시스템 (UserWorkRequest)

**목적**: 사용자가 관리자에게 약국 배정을 요청하는 기능

**엔티티**: `UserWorkRequest`
- `user_id`: 요청한 사용자
- `is_completed`: 요청 완료 여부 (배정 승인/거부 시 true)

**API**:
- `POST /api/work-requests`: 요청 생성
- `GET /api/work-requests`: 요청 목록 조회 (권한별 필터링)

**비즈니스 로직**:
- 사용자는 미완료 요청이 없을 때만 새 요청 생성 가능
- 관리자가 약국 배정/해제 시 자동으로 요청 완료 처리

---

### 2. 약국 배정 API 강화

#### PharmacyController
- `POST /api/pharmacies/{id}/assign`: 특정 약국에 사용자 배정
- `DELETE /api/pharmacies/{id}/assign`: 약국 배정 해제

#### UserController
- `POST /api/users/{id}/assign-pharmacies`: 사용자에게 여러 약국 일괄 배정

**배정 조건**:
1. 배정 대상 사용자는 `USER` 역할이어야 함
2. 배정 대상 사용자는 `ACTIVE` 상태여야 함
3. 약국이 이미 다른 사용자에게 배정되어 있으면 **재배정** 처리
4. 미완료 업무 요청이 있으면 **자동 완료** 처리

---

## 프론트엔드 영향 분석

### ✅ 영향 없음

프론트엔드 코드 전수 조사 결과, 이미 새로운 명명 규칙을 사용 중입니다.

```bash
# 검색 결과: 구 명명 패턴 발견되지 않음
grep -r "assignUserNo|visitUserNo|surveyReportNo|pharmacyNo|surveyNo|writerNo|createNo|updateNo" src/
# → No matches found
```

**프론트엔드 타입 정의 예시** (이미 올바름):
```typescript
// src/types/pharmacy.ts
export interface Pharmacy {
  id: number
  businessNumber: string
  name: string
  address: string
  telNumber: string
  chargeMember?: {  // ← 백엔드 assignedUserId에 매핑
    id: number
    name: string
    email?: string
  }
  isVisited: boolean
  reportCount?: number
  createdAt: string
  updatedAt?: string
}
```

### 필요한 작업

프론트엔드 코드 수정은 **불필요**하지만, 다음 작업이 필요할 수 있습니다:

1. **MSW Mock 데이터 검증**: Mock 응답이 새로운 필드명 사용 확인
2. **API 클라이언트 검토**: `/pharmacy/{pharmacyNo}` → `/pharmacy/{pharmacyId}` 엔드포인트 변경 반영
3. **신규 API 연동**:
   - `POST /api/pharmacies/{id}/assign` (약국 배정)
   - `POST /api/users/{id}/assign-pharmacies` (사용자에게 약국 배정)
   - `POST /api/work-requests` (업무 요청 생성)
   - `GET /api/work-requests` (업무 요청 목록)

---

## 문서 업데이트 필요 사항

### 1. 데이터베이스 스키마 문서

**파일**: `docs_new/04_database_schema.md`

**업데이트 필요 항목**:
- [ ] ERD 다이어그램 (컬럼명 변경)
- [ ] BaseEntity 감사 필드 설명 (`create_no` → `created_by` 등)
- [ ] Board 엔티티 (`writer_no` → `writer_id`, `is_delete` → `is_deleted`)
- [ ] File 엔티티 (`create_no` → `created_by`, `is_delete` → `is_deleted`)
- [ ] Pharmacy 엔티티 (`assign_user_no` → `assigned_user_id`)
- [ ] PharmacyVisitInfo 엔티티 (`survey_report_no` → `survey_report_id`, `visit_user_no` → `visit_user_id`)
- [ ] Survey 엔티티 (`create_no` → `created_by`)
- [ ] SurveyQuestion 엔티티 (`survey_no` → `survey_id`)
- [ ] SurveyReport 엔티티 (`pharmacy_no` → `pharmacy_id`, `survey_no` → `survey_id`)
- [ ] **UserWorkRequest 엔티티 추가** (신규)
- [ ] CREATE TABLE 문 수정
- [ ] 인덱스 이름 업데이트 (`idx_writer_no` → `idx_writer_id` 등)
- [ ] SQL 예제 쿼리 수정 (`create_no` → `created_by` 등)

---

### 2. API 명세서

**파일**: `docs_new/05_api_specification.md`

**업데이트 필요 항목**:
- [ ] PharmacyVisitInfo API 엔드포인트 변경
  - [ ] `GET /pharmacy-visits/survey-report/{surveyReportNo}` → `{surveyReportId}`
  - [ ] `GET /pharmacy-visits/pharmacy/{pharmacyNo}` → `{pharmacyId}`
  - [ ] `GET /pharmacy-visits/pharmacy/{pharmacyNo}/count` → `{pharmacyId}/count`
- [ ] Report API 엔드포인트 변경
  - [ ] `GET /reports/survey/{surveyNo}` → `{surveyId}`
  - [ ] `GET /reports/pharmacy/{pharmacyNo}` → `{pharmacyId}`
- [ ] Request DTO 필드명 변경
  - [ ] `PharmacyVisitAssignRequest.visitUserNo` → `visitUserId`
  - [ ] `PharmacyVisitCompleteRequest.surveyReportNo` → `surveyReportId`
  - [ ] `ReportCreateRequest.pharmacyNo` → `pharmacyId`, `surveyNo` → `surveyId`
- [ ] Response DTO 필드명 변경
  - [ ] `BoardResponse.writerNo` → `writerId`
  - [ ] `PharmacyResponse.assignUserNo` → `assignedUserId`
  - [ ] `PharmacyVisitInfoResponse.visitUserNo` → `visitUserId`, `surveyReportNo` → `surveyReportId`
  - [ ] `ReportResponse.pharmacyNo` → `pharmacyId`, `surveyNo` → `surveyId`
- [ ] **신규 API 추가**
  - [ ] `POST /api/pharmacies/{id}/assign` (약국 담당자 배정)
  - [ ] `DELETE /api/pharmacies/{id}/assign` (약국 배정 해제)
  - [ ] `POST /api/users/{id}/assign-pharmacies` (사용자에게 약국 배정)
  - [ ] `POST /api/work-requests` (업무 요청 생성)
  - [ ] `GET /api/work-requests` (업무 요청 목록)

---

### 3. 화면 명세서 (필요 시)

**파일**: `docs_new/02_screen_admin.md`

관리자 화면에서 약국 배정 기능을 사용하는 경우, 다음 업데이트 필요:
- [ ] 약국 배정 UI/UX 설명
- [ ] 업무 요청 관리 화면 (신규)

---

## 변경 이력

| 날짜 | 작성자 | 변경 내용 |
|------|--------|----------|
| 2025-11-11 | jsw | 테이블 스키마 및 컬럼명 프리징 (커밋 b77a086) |
| 2025-11-11 | Claude | 변경사항 분석 및 문서화 |

---

## 참고 자료

- **백엔드 저장소**: `/Users/bgb/Dev/Repo/pico_friends_be`
- **프론트엔드 저장소**: `/Users/bgb/Dev/Repo/pico_friends_fe`
- **커밋 상세**: `git show b77a0865581cc7d4f50c322aecbe438f509efba0`
- **영향 받은 파일**: 42개 파일 (Entity 9개, Repository 10개, Service 6개, Controller 5개, DTO 12개)
