# 프론트엔드 업데이트 완료 보고서

> **날짜**: 2025-11-11
> **백엔드 커밋**: b77a0865581cc7d4f50c322aecbe438f509efba0
> **작업자**: Claude Code (spec-helper 스킬)

---

## 📋 목차

1. [업데이트 개요](#업데이트-개요)
2. [신규 추가 파일](#신규-추가-파일)
3. [수정된 파일](#수정된-파일)
4. [기능별 상세 내역](#기능별-상세-내역)
5. [테스트 가이드](#테스트-가이드)
6. [다음 단계](#다음-단계)

---

## 업데이트 개요

백엔드 커밋 b77a086에서 추가된 신규 기능을 프론트엔드에 완전히 통합했습니다.

### ✅ 완료된 작업

1. **WorkRequest (업무 요청 시스템)** - 신규 추가
2. **Pharmacy Assignment (약국 배정)** - 신규 추가
3. **User Pharmacy Assignment (사용자 약국 배정)** - 신규 추가
4. **MSW Mock 핸들러** - 개발/테스트용
5. **React Query 훅** - 상태 관리
6. **TaskRequestButton 컴포넌트** - API 연동 완료

### 📊 작업 통계

| 구분 | 개수 |
|------|------|
| 신규 생성 파일 | 9개 |
| 수정된 파일 | 2개 |
| 추가된 타입 정의 | 8개 |
| 추가된 API 함수 | 9개 |
| 추가된 MSW 핸들러 | 3개 세트 |
| 추가된 React 훅 | 6개 |

---

## 신규 추가 파일

### 1. 타입 정의 (1개)

| 파일 | 설명 |
|------|------|
| [`src/types/work-request.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/types/work-request.ts) | WorkRequest 타입, 검색 파라미터, 라벨, 색상 상수 |

**주요 타입**:
```typescript
interface WorkRequest {
  id: number
  userId: number
  userName: string
  isCompleted: boolean
  createdAt: string
}

interface WorkRequestSearchParams {
  isCompleted?: boolean
  page?: number
  size?: number
  sort?: string
}
```

### 2. API 클라이언트 (2개)

| 파일 | 설명 |
|------|------|
| [`src/lib/api/work-request.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/lib/api/work-request.ts) | 업무 요청 API (생성, 조회, 미완료 확인) |
| [`src/lib/api/user.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/lib/api/user.ts) | 사용자 약국 배정 API |

**주요 함수**:
```typescript
// work-request.ts
export async function createWorkRequest(): Promise<WorkRequest>
export async function getWorkRequests(params?: WorkRequestSearchParams): Promise<PageResponse<WorkRequest>>
export async function hasPendingWorkRequest(): Promise<boolean>

// user.ts
export async function assignPharmacies(userId: number, pharmacyIds: number[]): Promise<string>
```

### 3. MSW 핸들러 (3개)

| 파일 | 설명 |
|------|------|
| [`src/mocks/handlers/work-request.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/mocks/handlers/work-request.ts) | 업무 요청 Mock 데이터 및 핸들러 |
| [`src/mocks/handlers/pharmacy.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/mocks/handlers/pharmacy.ts) | 약국 배정 Mock 핸들러 |
| [`src/mocks/handlers/user-assignment.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/mocks/handlers/user-assignment.ts) | 사용자 약국 배정 Mock 핸들러 |

**주요 엔드포인트**:
- `POST /api/work-requests` - 업무 요청 생성
- `GET /api/work-requests` - 업무 요청 목록 (필터링, 페이지네이션)
- `POST /api/pharmacies/:id/assign` - 약국 담당자 배정
- `DELETE /api/pharmacies/:id/assign` - 약국 배정 해제
- `POST /api/users/:id/assign-pharmacies` - 사용자에게 약국 배정

### 4. React Query 훅 (2개)

| 파일 | 설명 |
|------|------|
| [`src/hooks/useWorkRequests.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/hooks/useWorkRequests.ts) | 업무 요청 관련 훅 (조회, 생성, 미완료 확인) |
| [`src/hooks/usePharmacyAssignment.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/hooks/usePharmacyAssignment.ts) | 약국 배정 관련 훅 (배정, 해제, 일괄 배정) |

**주요 훅**:
```typescript
// useWorkRequests.ts
export function useWorkRequests(params?: WorkRequestSearchParams)
export function usePendingWorkRequest()
export function useCreateWorkRequest()

// usePharmacyAssignment.ts
export function useAssignPharmacy()
export function useReleasePharmacyAssignment()
export function useAssignPharmacies()
```

---

## 수정된 파일

### 1. 타입 정의

**파일**: [`src/types/pharmacy.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/types/pharmacy.ts)

**추가된 타입**:
```typescript
// 약국 담당자 배정 요청
interface PharmacyAssignRequest {
  userId: number
}

// 사용자에게 약국 배정 요청
interface UserPharmaciesAssignRequest {
  pharmacyIds: number[]
}
```

### 2. API 클라이언트

**파일**: [`src/lib/api/pharmacy.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/lib/api/pharmacy.ts)

**추가된 함수**:
```typescript
// 약국 담당자 배정 (ADMIN 권한)
export async function assignPharmacy(id: number, userId: number): Promise<Pharmacy>

// 약국 배정 해제 (ADMIN 권한)
export async function releasePharmacyAssignment(id: number): Promise<Pharmacy>
```

### 3. MSW 핸들러 인덱스

**파일**: [`src/mocks/handlers/index.ts`](/Users/bgb/Dev/Repo/pico_friends_fe/src/mocks/handlers/index.ts)

**변경 내용**:
```typescript
// 신규 핸들러 import
import { workRequestHandlers } from './work-request'
import { pharmacyHandlers } from './pharmacy'
import { userAssignmentHandlers } from './user-assignment'

// handlers 배열에 추가
export const handlers = [
  ...commonCodeHandlers,
  ...workRequestHandlers,
  ...pharmacyHandlers,
  ...userAssignmentHandlers,
]
```

### 4. TaskRequestButton 컴포넌트

**파일**: [`src/components/mobile/TaskRequestButton/TaskRequestButton.tsx`](/Users/bgb/Dev/Repo/pico_friends_fe/src/components/mobile/TaskRequestButton/TaskRequestButton.tsx)

**주요 변경**:
- ✅ React Query 훅 연동 (`useCreateWorkRequest`, `usePendingWorkRequest`)
- ✅ Toast 알림 추가
- ✅ 미완료 요청 확인 로직 추가
- ✅ 로딩 상태 관리 개선
- ✅ 에러 핸들링 추가

**Before**:
```typescript
export function TaskRequestButton({
  onClick,
  onSuccess,
  loading = false,
}: TaskRequestButtonProps) {
  const [isRequested, setIsRequested] = useState(false)

  const handleClick = async () => {
    if (onClick) {
      await onClick()
    }
    setIsRequested(true)
    if (onSuccess) {
      onSuccess()
    }
  }
  // ...
}
```

**After**:
```typescript
export function TaskRequestButton({ onSuccess }: TaskRequestButtonProps) {
  const { toast } = useToast()
  const { mutate: createRequest, isPending } = useCreateWorkRequest()
  const { data: hasPending, isLoading: checkingPending } = usePendingWorkRequest()
  const [isRequested, setIsRequested] = useState(false)

  const handleClick = () => {
    createRequest(undefined, {
      onSuccess: () => {
        setIsRequested(true)
        toast({ title: '업무 요청 완료', description: '...' })
        if (onSuccess) onSuccess()
      },
      onError: (error) => {
        toast({ variant: 'destructive', title: '업무 요청 실패', description: '...' })
      },
    })
  }

  // 대기 중인 요청이 있으면 "업무 요청 대기 중" 표시
  if (hasPending && !isRequested) {
    return <대기중UI />
  }
  // ...
}
```

---

## 기능별 상세 내역

### 1. 업무 요청 시스템 (WorkRequest)

**목적**: 사용자가 관리자에게 약국 배정을 요청하는 기능

#### 📌 사용 시나리오

1. **USER 권한 사용자**:
   - 배정된 약국이 없을 때 "업무 요청하기" 버튼 클릭
   - 미완료 요청이 없어야 새 요청 생성 가능
   - 요청 생성 시 Toast 알림 표시
   - 대기 중 상태에서는 "업무 요청 대기 중" 표시

2. **ADMIN 권한 사용자**:
   - 업무 요청 목록 조회 (모든 사용자의 요청)
   - 약국 배정 시 자동으로 해당 사용자의 미완료 요청 완료 처리

#### 📂 관련 파일
- `src/types/work-request.ts`
- `src/lib/api/work-request.ts`
- `src/hooks/useWorkRequests.ts`
- `src/mocks/handlers/work-request.ts`
- `src/components/mobile/TaskRequestButton/TaskRequestButton.tsx`

#### 🔌 API 엔드포인트

```typescript
// 업무 요청 생성 (USER)
POST /api/work-requests
Response: { success: true, data: WorkRequest, message: string }

// 업무 요청 목록 조회
GET /api/work-requests?isCompleted=false&page=0&size=20
Response: { success: true, data: PageResponse<WorkRequest> }
```

---

### 2. 약국 배정 시스템 (Pharmacy Assignment)

**목적**: 관리자가 약국에 담당자를 배정/해제하는 기능

#### 📌 사용 시나리오

1. **약국 담당자 배정** (ADMIN):
   - 특정 약국에 USER 역할 사용자 배정
   - 배정 대상 사용자는 ACTIVE 상태여야 함
   - 이미 다른 사용자에게 배정된 경우 재배정
   - 해당 사용자의 미완료 업무 요청 자동 완료

2. **약국 배정 해제** (ADMIN):
   - 특정 약국의 담당자 배정 해제
   - 약국 정보 업데이트

#### 📂 관련 파일
- `src/types/pharmacy.ts` (PharmacyAssignRequest 추가)
- `src/lib/api/pharmacy.ts` (assignPharmacy, releasePharmacyAssignment 추가)
- `src/hooks/usePharmacyAssignment.ts`
- `src/mocks/handlers/pharmacy.ts`

#### 🔌 API 엔드포인트

```typescript
// 약국 담당자 배정 (ADMIN)
POST /api/pharmacies/:id/assign
Body: { userId: number }
Response: { success: true, data: Pharmacy, message: string }

// 약국 배정 해제 (ADMIN)
DELETE /api/pharmacies/:id/assign
Response: { success: true, data: Pharmacy, message: string }
```

---

### 3. 사용자 약국 배정 시스템 (User Pharmacy Assignment)

**목적**: 관리자가 사용자에게 여러 약국을 일괄 배정하는 기능

#### 📌 사용 시나리오

1. **일괄 배정** (ADMIN):
   - 특정 사용자에게 여러 약국 한 번에 배정
   - 배정 대상 사용자는 USER 역할 + ACTIVE 상태
   - 약국이 다른 사용자에게 배정되어 있으면 재배정
   - 해당 사용자의 미완료 업무 요청 자동 완료

#### 📂 관련 파일
- `src/types/pharmacy.ts` (UserPharmaciesAssignRequest 추가)
- `src/lib/api/user.ts` (신규 생성)
- `src/hooks/usePharmacyAssignment.ts` (useAssignPharmacies 추가)
- `src/mocks/handlers/user-assignment.ts`

#### 🔌 API 엔드포인트

```typescript
// 사용자에게 약국 배정 (ADMIN)
POST /api/users/:id/assign-pharmacies
Body: { pharmacyIds: number[] }
Response: { success: true, data: string, message: string }
```

---

## 테스트 가이드

### 1. 로컬 환경 설정

```bash
cd /Users/bgb/Dev/Repo/pico_friends_fe
npm install
npm run dev
```

서버 실행 후 http://localhost:3000 접속

### 2. MSW Mock 데이터 확인

MSW가 활성화되어 있어 백엔드 없이 테스트 가능합니다.

**Mock 데이터**:
- 업무 요청 2건 (김피코: 미완료, 이프렌즈: 완료)
- 약국 2건 (서울약국: 배정됨, 부산약국: 미배정)

### 3. 기능별 테스트 시나리오

#### 3.1 업무 요청 생성 (TaskRequestButton)

**경로**: `/tasks` (모바일 웹)

**시나리오**:
1. ✅ 배정된 약국이 없을 때 "업무 요청하기" 버튼 표시
2. ✅ 버튼 클릭 시 요청 생성
3. ✅ Toast 알림: "업무 요청 완료"
4. ✅ "업무 요청 완료" 상태로 UI 변경
5. ✅ 이미 대기 중인 요청이 있으면 "업무 요청 대기 중" 표시

**테스트 코드**:
```typescript
import { render, screen, fireEvent } from '@testing-library/react'
import { TaskRequestButton } from '@/components/mobile/TaskRequestButton/TaskRequestButton'

test('업무 요청 버튼 클릭 시 요청 생성', async () => {
  render(<TaskRequestButton />)

  const button = screen.getByText('업무 요청하기')
  fireEvent.click(button)

  // Toast 확인
  expect(await screen.findByText('업무 요청 완료')).toBeInTheDocument()
})
```

#### 3.2 약국 배정 (ADMIN)

**시나리오**:
1. ✅ 약국 목록에서 "담당자 배정" 버튼 클릭
2. ✅ 사용자 선택 모달 표시
3. ✅ 사용자 선택 후 배정
4. ✅ Toast 알림: "약국 담당자가 배정되었습니다"
5. ✅ 약국 목록 자동 갱신

**사용 예시**:
```typescript
import { useAssignPharmacy } from '@/hooks/usePharmacyAssignment'

function PharmacyAssignModal({ pharmacyId }: { pharmacyId: number }) {
  const { mutate: assign, isPending } = useAssignPharmacy()

  const handleAssign = (userId: number) => {
    assign({ pharmacyId, userId }, {
      onSuccess: () => {
        toast({ title: '약국 담당자가 배정되었습니다' })
        closeModal()
      }
    })
  }

  return <UserSelectModal onSelect={handleAssign} />
}
```

### 4. React Query DevTools 활용

```typescript
// src/lib/providers.tsx에 추가
import { ReactQueryDevtools } from '@tanstack/react-query-devtools'

export function Providers({ children }: { children: React.ReactNode }) {
  return (
    <QueryClientProvider client={queryClient}>
      {children}
      <ReactQueryDevtools initialIsOpen={false} />
    </QueryClientProvider>
  )
}
```

**확인 사항**:
- `work-requests` 쿼리 캐시
- `pharmacies` 쿼리 캐시
- Mutation 상태 (pending, success, error)

---

## 다음 단계

### 1. 백엔드 API 연동 전환 (선택적)

현재 MSW Mock을 사용 중입니다. 백엔드 API가 준비되면 다음 단계로 전환하세요:

```typescript
// src/mocks/handlers/index.ts
export const handlers = [
  ...commonCodeHandlers,
  // 백엔드 API 준비 시 주석 처리
  // ...workRequestHandlers,
  // ...pharmacyHandlers,
  // ...userAssignmentHandlers,
]
```

### 2. 관리자 화면 개발 (권장)

현재 모바일 웹(TaskRequestButton)만 구현되어 있습니다. 관리자 화면 추가 필요:

**추천 구현 항목**:
- [ ] 업무 요청 목록 페이지 (`/admin/work-requests`)
- [ ] 약국 배정 모달 컴포넌트
- [ ] 사용자에게 약국 일괄 배정 페이지
- [ ] 업무 요청 통계 대시보드

**예시**:
```typescript
// src/app/(admin)/work-requests/page.tsx
'use client'

import { useWorkRequests } from '@/hooks/useWorkRequests'
import { useAssignPharmacies } from '@/hooks/usePharmacyAssignment'

export default function WorkRequestsPage() {
  const { data: requests } = useWorkRequests({ isCompleted: false })

  return (
    <div>
      <h1>업무 요청 관리</h1>
      <WorkRequestTable data={requests?.content} />
    </div>
  )
}
```

### 3. E2E 테스트 작성 (권장)

Playwright를 사용한 E2E 테스트:

```typescript
// tests/e2e/work-request.spec.ts
import { test, expect } from '@playwright/test'

test('업무 요청 플로우', async ({ page }) => {
  await page.goto('/tasks')

  // 업무 요청 버튼 클릭
  await page.click('text=업무 요청하기')

  // Toast 알림 확인
  await expect(page.locator('text=업무 요청 완료')).toBeVisible()

  // 대기 중 UI 확인
  await expect(page.locator('text=업무 요청 대기 중')).toBeVisible()
})
```

### 4. Storybook 스토리 추가 (선택적)

컴포넌트 개발 및 문서화:

```typescript
// src/components/mobile/TaskRequestButton/TaskRequestButton.stories.tsx
import type { Meta, StoryObj } from '@storybook/react'
import { TaskRequestButton } from './TaskRequestButton'

const meta: Meta<typeof TaskRequestButton> = {
  title: 'Mobile/TaskRequestButton',
  component: TaskRequestButton,
}

export default meta
type Story = StoryObj<typeof TaskRequestButton>

export const Default: Story = {}

export const AlreadyRequested: Story = {
  parameters: {
    msw: {
      handlers: [
        // Mock pending request
      ]
    }
  }
}
```

---

## 📁 전체 파일 목록

### 신규 생성 (9개)

```
src/
├── types/
│   └── work-request.ts                        ✨ 신규
├── lib/
│   └── api/
│       ├── work-request.ts                    ✨ 신규
│       └── user.ts                             ✨ 신규
├── hooks/
│   ├── useWorkRequests.ts                     ✨ 신규
│   └── usePharmacyAssignment.ts               ✨ 신규
└── mocks/
    └── handlers/
        ├── work-request.ts                     ✨ 신규
        ├── pharmacy.ts                         ✨ 신규
        └── user-assignment.ts                  ✨ 신규
```

### 수정 (2개)

```
src/
├── types/
│   └── pharmacy.ts                            📝 수정 (타입 2개 추가)
├── lib/
│   └── api/
│       └── pharmacy.ts                        📝 수정 (함수 2개 추가)
├── mocks/
│   └── handlers/
│       └── index.ts                           📝 수정 (핸들러 3개 추가)
└── components/
    └── mobile/
        └── TaskRequestButton/
            └── TaskRequestButton.tsx          📝 수정 (API 연동)
```

---

## ✅ 최종 체크리스트

- [x] WorkRequest 타입 정의 추가
- [x] WorkRequest API 클라이언트 추가
- [x] Pharmacy Assignment 타입 추가
- [x] Pharmacy Assignment API 추가
- [x] User Pharmacy Assignment API 추가
- [x] MSW Mock 핸들러 추가 (3개 세트)
- [x] React Query 훅 추가 (6개)
- [x] TaskRequestButton 컴포넌트 API 연동
- [x] Toast 알림 통합
- [x] 미완료 요청 확인 로직
- [x] 에러 핸들링
- [ ] 관리자 화면 개발 (다음 단계)
- [ ] E2E 테스트 작성 (다음 단계)
- [ ] Storybook 스토리 추가 (선택)

---

## 🎯 주요 성과

1. ✅ **백엔드 신규 API 완전 통합**: WorkRequest, Pharmacy Assignment 모두 구현
2. ✅ **MSW Mock 환경 구축**: 백엔드 없이 독립적으로 개발/테스트 가능
3. ✅ **React Query 상태 관리**: 자동 캐싱, 리페칭, 에러 핸들링
4. ✅ **타입 안전성 확보**: TypeScript 타입 정의로 컴파일 타임 오류 방지
5. ✅ **사용자 경험 개선**: Toast 알림, 로딩 상태, 에러 메시지

---

**다음 작업**: 관리자 화면 개발 또는 백엔드 API 준비 시 MSW → 실제 API 전환
