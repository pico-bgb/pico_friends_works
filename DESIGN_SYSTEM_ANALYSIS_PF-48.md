# PICOFriends 디자인 시스템 적용 현황 분석 리포트

**작성일**: 2025-11-11
**대상 Epic**: PF-48 (사용자 화면 Mobile Web)
**디자인 소스**: `/Users/bgb/Dev/Repo/pico_friends_design`

---

## 📋 목차

1. [개요](#개요)
2. [디자인 파일 분석](#디자인-파일-분석)
3. [현재 FE 구현 상태](#현재-fe-구현-상태)
4. [디자인-이슈 매핑](#디자인-이슈-매핑)
5. [디자인 시스템 차이점](#디자인-시스템-차이점)
6. [리팩토링 vs 신규 개발](#리팩토링-vs-신규-개발)
7. [작업 계획](#작업-계획)
8. [리스크 및 고려사항](#리스크-및-고려사항)

---

## 개요

PF-48 에픽 하위의 모바일 웹 화면들을 `/Users/bgb/Dev/Repo/pico_friends_design` 경로의 디자인 요소로 재개발하기 위한 전략 수립 문서입니다.

### 주요 발견사항

- ✅ **PF-65 (로그인/회원가입)**: 완료되었으나 **버튼 색상 불일치** (파란색 → 녹색으로 변경 필요)
- 🟡 **PF-70 (메인-약국목록)**: 75% 완료, 업무 요청 기능(PF-73)만 남음
- ❌ **PF-75 (방문 활동 플로우)**: 미착수, 가장 복잡한 기능 (12시간 예상)
- ❌ **PF-82 (마이페이지)**: 미착수 (6시간 예상)
- ✅ **PF-87 (공통 컴포넌트)**: 완료

### 핵심 문제

**Primary Button 색상 불일치**
- **디자인**: `#16A34A` (녹색)
- **현재 구현**: `#2563EB` (파란색)
- **영향 범위**: LoginForm, SignupForm, PharmacyCard 등

---

## 디자인 파일 분석

### 디자인 파일 목록 (총 9개 PNG + 15개 SVG)

#### PNG 디자인 파일

| 파일명 | 대응 화면 | Jira 이슈 | 상태 |
|--------|---------|----------|------|
| **00-로그인.png** | PF-010 | PF-65 | ✅ 완료 (색상 불일치) |
| **00-회원가입.png** | PF-010 | PF-65 | ✅ 완료 (색상 불일치) |
| **01-1-업무요청.png** | PF-020 | PF-70, PF-73 | 🟡 진행중 (업무요청 미완) |
| **01-2-대시보드.png** | PF-020 | PF-70 | 🟡 진행중 |
| **01-3-기간선택.png** | PF-020 | PF-70, PF-72 | ✅ 완료 |
| **01-4-방문사진등록.png** | PF-030 | PF-75, PF-76 | ❌ 미착수 |
| **01-5-방문기록.png** | PF-030 | PF-75, PF-78 | ❌ 미착수 |
| **02-공지사항.png** | PF-040 | PF-82, PF-84 | ❌ 미착수 |
| **03-마이페이지.png** | PF-040 | PF-82, PF-83 | ❌ 미착수 |

#### SVG 아이콘 파일 (15개)

위치: `/Users/bgb/Dev/Repo/pico_friends_design/icon-svg/`

| 아이콘 | 설명 | 용도 |
|--------|------|------|
| icon-01.svg | Plus (원형 테두리) | 업무 요청 버튼 |
| icon-02.svg | Navigation/Pointer | 방문 인증 (위치) |
| icon-03.svg | Check (원형 테두리) | 완료 상태 표시 |
| icon-04~15.svg | (기타 UI 아이콘) | 추가 UI 요소 |

**아이콘 스타일**: 흰색 선, 원형 테두리, 일관된 두께

---

## 현재 FE 구현 상태

### PF-48 에픽 하위 이슈 현황

| 이슈 | 화면 | 상태 | 완료된 하위작업 | 진행률 |
|------|------|------|----------------|--------|
| **PF-65** | 로그인/회원가입 | ✅ 완료 | 4/4 | 100% |
| **PF-70** | 메인-약국목록 | 🟡 진행중 | 3/4 | 75% |
| **PF-75** | 방문 활동 플로우 | ❌ 미착수 | 0/6 | 0% |
| **PF-82** | 마이페이지 | ❌ 미착수 | 0/4 | 0% |
| **PF-87** | 공통 컴포넌트 | ✅ 완료 | 4/4 | 100% |

### 완료된 컴포넌트

#### 인증 컴포넌트 (PF-65)

1. **LoginForm** - `/src/components/auth/LoginForm/LoginForm.tsx`
   - React Hook Form + Zod 검증
   - JWT 기반 자동 리다이렉트
   - ⚠️ 버튼 색상: 파란색 → **녹색으로 변경 필요**

2. **SignupForm** - `/src/components/auth/SignupForm/SignupForm.tsx`
   - 37개 약학대학 Select
   - ⚠️ 버튼 색상: 파란색 → **녹색으로 변경 필요**

#### 공통 컴포넌트 (PF-87)

1. **NoticeRollingBanner** - 공지사항 롤링 배너 ✅
2. **ChatFloatingButton** - 카카오톡 스타일 플로팅 버튼 ✅
3. **HeaderMobile** - 모바일 헤더 ✅
4. **MobileLayout** - 모바일 레이아웃 ✅

#### 약국 목록 컴포넌트 (PF-70)

1. **PharmacyCard** - `/src/components/mobile/PharmacyCard/PharmacyCard.tsx`
   - ⚠️ "방문 인증" 버튼: 파란색 → **녹색으로 변경 필요**

2. **StatusFilter** - `/src/components/mobile/StatusFilter/StatusFilter.tsx`
   - ✅ 디자인과 일치

3. **PharmacyList** - `/src/components/mobile/PharmacyList/PharmacyList.tsx`
   - ✅ 무한 스크롤 구현

### 미구현 컴포넌트

#### 방문 활동 플로우 (PF-75) - 예상 10시간

- **PF-76**: CameraCapture - 사진 촬영 (4시간)
- **PF-78**: DynamicSurveyForm - 동적 설문 폼 (6시간)
- **PF-79**: VisitSubmitButton - 최종 제출 (포함)

#### 마이페이지 (PF-82) - 예상 6시간

- **PF-83**: LeaderboardCard - 순위 표시 (3시간)
- **PF-84**: NoticeDetailModal - 공지사항 상세 (2시간)
- **PF-85**: LogoutButton - 로그아웃 (1시간)

#### 업무 요청 (PF-73) - 예상 2시간

- **EmptyTaskState** - Empty State UI
- **TaskRequestButton** - 업무 배정 요청

---

## 디자인-이슈 매핑

| 디자인 파일 | 화면 ID | Jira 이슈 | 상태 | 우선순위 |
|------------|---------|----------|------|---------|
| 00-로그인.png | PF-010 | PF-65 | ✅ 완료 (색상 수정 필요) | P1 |
| 00-회원가입.png | PF-010 | PF-65 | ✅ 완료 (색상 수정 필요) | P1 |
| 01-1-업무요청.png | PF-020 | PF-73 | ❌ 미착수 | P2 |
| 01-2-대시보드.png | PF-020 | PF-70, PF-71 | ✅ 완료 | P1 |
| 01-3-기간선택.png | PF-020 | PF-72 | ✅ 완료 | P1 |
| 01-4-방문사진등록.png | PF-031 | PF-76 | ❌ 미착수 | P2 |
| 01-5-방문기록.png | PF-032 | PF-78 | ❌ 미착수 | P2 |
| 02-공지사항.png | PF-042 | PF-84 | ❌ 미착수 | P3 |
| 03-마이페이지.png | PF-041 | PF-83 | ❌ 미착수 | P3 |

---

## 디자인 시스템 차이점

### 컬러 팔레트 불일치

| 요소 | 디자인 시스템 | 현재 구현 | 상태 |
|------|-------------|----------|------|
| Primary Button | `#16A34A` (녹색) | `#2563EB` (파란색) | ❌ 불일치 |
| Background | `#F9FAFB` | `#F9FAFB` | ✅ 일치 |
| Text Primary | `#111827` | `#111827` | ✅ 일치 |
| Success | `#22C55E` | `#22C55E` | ✅ 일치 |
| Warning | `#F97316` | `#F97316` | ✅ 일치 |

### 해결 방법: 디자인 토큰 정의

**신규 파일 생성**: `/src/lib/design-tokens.ts`

```typescript
export const colors = {
  primary: {
    DEFAULT: '#16A34A',  // green-600
    hover: '#15803D',    // green-700
  },
  secondary: {
    DEFAULT: '#6B7280',  // gray-500
  },
  success: '#22C55E',    // green-500
  warning: '#F97316',    // orange-500
  danger: '#EF4444',     // red-500
}
```

**Tailwind 설정 업데이트**: `tailwind.config.ts`

```typescript
import { colors } from './src/lib/design-tokens'

export default {
  theme: {
    extend: {
      colors: {
        primary: colors.primary,
      }
    }
  }
}
```

---

## 리팩토링 vs 신규 개발

### 수정해야 할 컴포넌트 (기존 리팩토링)

| 컴포넌트 | 경로 | 수정 내용 | 복잡도 | 예상 시간 |
|---------|------|----------|--------|----------|
| LoginForm | `auth/LoginForm/LoginForm.tsx` | 버튼 색상 녹색 변경 | 🟢 Low | 10분 |
| SignupForm | `auth/SignupForm/SignupForm.tsx` | 버튼 색상 녹색 변경 | 🟢 Low | 10분 |
| PharmacyCard | `mobile/PharmacyCard/PharmacyCard.tsx` | 버튼 색상 녹색 변경 | 🟢 Low | 10분 |
| Button (전역) | `ui/button.tsx` | Primary variant 수정 | 🟡 Medium | 20분 |

**총 예상 시간**: 50분

### 새로 만들어야 할 컴포넌트 (신규 개발)

| 컴포넌트 | 경로 | 기능 | 복잡도 | 예상 시간 |
|---------|------|------|--------|----------|
| CameraCapture | `mobile/CameraCapture/` | 카메라 촬영 (`getUserMedia`) | 🔴 High | 4시간 |
| DynamicSurveyForm | `mobile/DynamicSurveyForm/` | 동적 설문 폼 | 🔴 High | 6시간 |
| VisitSubmitButton | `mobile/VisitSubmitButton/` | 최종 제출 | 🟢 Low | 1시간 |
| LeaderboardCard | `mobile/LeaderboardCard/` | 순위 표시 | 🟡 Medium | 3시간 |
| NoticeDetailModal | `mobile/NoticeDetailModal/` | 공지사항 상세 | 🟢 Low | 2시간 |
| EmptyTaskState | `mobile/EmptyTaskState/` | Empty State | 🟢 Low | 1시간 |

**총 예상 시간**: 17시간

---

## 작업 계획

### Phase 1: 디자인 토큰 정의 (1시간)

**목표**: 디자인 시스템 일관성 확보

1. `/src/lib/design-tokens.ts` 생성
2. `tailwind.config.ts` 업데이트
3. 기존 컴포넌트 색상 일괄 수정 (`bg-blue-600` → `bg-primary`)
4. Storybook 업데이트

**관련 이슈**: -

---

### Phase 2: 기존 컴포넌트 리팩토링 (1시간)

**목표**: 디자인과 코드 일치

1. LoginForm 버튼 색상 수정
2. SignupForm 버튼 색상 수정
3. PharmacyCard 버튼 색상 수정
4. 전역 Button 컴포넌트 Primary variant 수정

**관련 이슈**: PF-65, PF-70

---

### Phase 3: 업무 요청 기능 완료 (2시간)

**목표**: PF-70 100% 완료

1. EmptyTaskState 컴포넌트 개발
2. TaskRequestButton 통합
3. `/src/app/(mobile)/tasks/page.tsx` 업데이트

**관련 이슈**: PF-73

**디자인 참조**: `01-1-업무요청.png`

---

### Phase 4: 방문 활동 플로우 (10시간)

**목표**: PF-75 완료

#### 4.1 CameraCapture (4시간)

- `getUserMedia` API 사용
- 갤러리 접근 차단 (capture="environment")
- 사진 프리뷰 및 재촬영
- 파일 업로드 (Base64 or FormData)

**디자인 참조**: `01-4-방문사진등록.png`

#### 4.2 DynamicSurveyForm (6시간)

- 관리자 설정 설문 폼 렌더링
- 다양한 입력 타입 (text, textarea, checkbox, radio)
- React Hook Form + Zod 검증
- JSONB 응답 포맷

**디자인 참조**: `01-5-방문기록.png`

#### 4.3 플로우 통합 및 테스트

- VisitSubmitButton
- 중복 제출 방지
- 로딩 상태 표시

**관련 이슈**: PF-75, PF-76, PF-78, PF-79

---

### Phase 5: 마이페이지 (6시간)

**목표**: PF-82 완료

#### 5.1 LeaderboardCard (3시간)

- 개인 통계 표시 (오늘/누적)
- 1~10위 순위 테이블
- 순위 변동 아이콘 (▲, ▼, -, NEW)
- 닉네임 마스킹 (이메일 3글자 + ***)

**디자인 참조**: `03-마이페이지.png`

#### 5.2 NoticeDetailModal (2시간)

- 공지사항 제목, 내용, 작성일
- 관리자 지정 이미지 배너
- TipTap 에디터로 렌더링 (HTML)

**디자인 참조**: `02-공지사항.png`

#### 5.3 LogoutButton (1시간)

- Zustand 상태 초기화
- JWT 토큰 삭제
- 로그인 화면으로 리다이렉트

**관련 이슈**: PF-82, PF-83, PF-84, PF-85

---

### 총 예상 시간: 20시간 (약 2.5일)

---

## 리스크 및 고려사항

### 기술적 리스크

| 리스크 | 영향도 | 해결 방안 |
|--------|--------|----------|
| **브라우저 호환성** (카메라 API) | 🔴 High | `getUserMedia` 폴리필, 대체 UI 제공 |
| **동적 설문 렌더링** | 🟡 Medium | JSON 스키마 검증, 오류 처리 강화 |
| **색상 변경 영향 범위** | 🟢 Low | 디자인 토큰 사용, 점진적 롤아웃 |

### 일정 리스크

- **PF-75 (방문 활동)**: 가장 복잡한 기능 (10시간 예상)
- **DynamicSurveyForm**: 요구사항이 유동적일 수 있음
- **Backend 의존성**: API가 준비되지 않은 경우 MSW 모킹 필요

### 디자인 불일치 리스크

- 디자인 파일이 최신 버전(v1.6)인지 확인 필요
- 일부 디자인 요소가 누락되거나 변경되었을 가능성
- 디자이너와의 주기적인 리뷰 필요

---

## 우선순위 제안

### 긴급 (1주 내)

1. ✅ 디자인 토큰 정의 및 색상 일괄 수정 (2시간)
2. ✅ 업무 요청 기능 완료 (PF-73, 2시간)

### 중요 (2주 내)

3. 방문 활동 플로우 개발 (PF-75, 10시간)
   - CameraCapture
   - DynamicSurveyForm

### 보통 (3주 내)

4. 마이페이지 개발 (PF-82, 6시간)
   - LeaderboardCard
   - NoticeDetailModal

---

## design-system-refactor 스킬 활용 전략

### 시나리오 1: 디자인 토큰 정의

```
"디자인 시스템 컬러 팔레트를 /src/lib/design-tokens.ts에 정의해줘.
Primary는 녹색(#16A34A), Success는 녹색(#22C55E), Warning은 주황색(#F97316)이야."
```

### 시나리오 2: 기존 컴포넌트 일괄 수정

```
"LoginForm, SignupForm, PharmacyCard의 버튼 색상을 디자인 토큰 기반으로 수정해줘."
```

### 시나리오 3: 신규 컴포넌트 개발

```
"디자인 파일 01-4-방문사진등록.png를 참고해서 CameraCapture 컴포넌트를 만들어줘."
```

---

## screen-dev 스킬 활용 가능성

**screen-dev 스킬**: PF-17 패턴 기반 신규 화면 자동 개발 (7단계 워크플로우)

### 적용 가능한 이슈

1. **PF-75 (방문 활동 플로우)**
   - TypeScript 타입 자동 생성
   - MSW 핸들러 자동 생성
   - React Query 훅 자동 생성
   - Storybook 컴포넌트 자동 생성
   - 실제 페이지 자동 생성
   - Playwright 테스트 자동 생성
   - ⚠️ GPS 수집 기능은 제외됨 (PF-77 취소)

2. **PF-82 (마이페이지)**
   - 동일한 7단계 워크플로우 적용

### 사용 예시

```
"PF-75 방문 활동 플로우 화면 개발해줘.
디자인 파일: /Users/bgb/Dev/Repo/pico_friends_design/design/01-4-방문사진등록.png
주의: GPS 위치 수집 기능은 제외"
```

---

## 다음 단계

1. ✅ 이 리포트를 팀과 공유
2. 🔄 디자인 파일 최신 버전 확인 (v1.6)
3. 🔄 Backend API 개발 상태 확인
4. 🔄 디자인 토큰 정의 작업 시작
5. 🔄 PF-73 (업무 요청) 개발 착수

---

**작성자**: Claude Code
**리포트 버전**: 1.0
**관련 Epic**: PF-48
**마지막 업데이트**: 2025-11-11
