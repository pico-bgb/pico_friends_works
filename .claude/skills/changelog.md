# 변경 이력 생성 스킬

Git 커밋 로그를 기반으로 CHANGELOG.md를 자동 생성하고, 화면설계서 버전별 변경사항을 추적합니다.

## 작업 수행

### 1. Git 커밋 로그 분석

**커밋 수집:**
```bash
git log --oneline --no-merges --since="2025-10-01"
```

**커밋 분류 (Conventional Commits):**
- `feat:` - 새로운 기능
- `fix:` - 버그 수정
- `docs:` - 문서 변경
- `style:` - 코드 스타일 변경 (포맷팅)
- `refactor:` - 리팩토링
- `test:` - 테스트 추가/수정
- `chore:` - 빌드/설정 변경
- `perf:` - 성능 개선

**Jira 이슈 연결:**
- 커밋 메시지에서 이슈 번호 추출 (PF-XXX, AD-XXX)
- Jira API로 이슈 정보 조회 (제목, 타입, 상태)

### 2. CHANGELOG.md 생성

**형식:**
```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- [PF-33] 로그인/회원가입 컴포넌트 (CC-LOGIN, CC-SIGNUP) (#123)
- [PF-34] 모바일/관리자 헤더 컴포넌트 (#124)

### Changed
- [PF-35] 버튼 컴포넌트 스타일 개선 (#125)

### Fixed
- [PF-36] 모달 닫기 버튼 버그 수정 (#126)

### Deprecated
- Legacy 인증 API (v1.0) - v2.0 마이그레이션 권장

### Removed
- 사용되지 않는 유틸리티 함수 제거

### Security
- JWT 토큰 검증 로직 강화

## [1.5.0] - 2025-10-30

### Added
- 화면설계서 v1.5 반영
- 공통 컴포넌트 20개 명세 추가

...

## [1.0.0] - 2025-10-15

- Initial release
```

### 3. 화면설계서 버전 비교

**버전 디렉토리:**
- `피코프렌즈_v1.2/`
- `피코프렌즈_v1.3/`
- `피코프렌즈_v1.4/`
- `피코프렌즈_v1.5/` (최신)

**변경사항 추적:**
```markdown
## 화면설계서 변경 이력

### v1.5 (2025-10-30)
**추가된 화면:**
- PF-043: 리더보드 화면
- AD-050: 통계 대시보드

**수정된 화면:**
- PF-010: 로그인 화면 - 소셜 로그인 버튼 추가
- PF-030: 업무 목록 - 필터 옵션 추가

**삭제된 화면:**
- (없음)

**UI 변경:**
- 공통 컴포넌트 명세 v4.0 반영
- 디자인 시스템 컬러 팔레트 업데이트

### v1.4 (2025-10-27)
...
```

### 4. 릴리즈 노트 생성

**특정 버전의 릴리즈 노트:**
```markdown
# Release Notes - v1.5.0

**Release Date**: 2025-10-30

## 🎉 주요 기능

### 피코프렌즈 (현장 요원용)
- **리더보드 기능** (PF-43): 실시간 방문 순위 조회
- **설문조사 개선**: JSONB 기반 유연한 응답 구조

### 관리자 페이지
- **통계 대시보드** (AD-50): 약국별/요원별 통계 시각화
- **일괄 업로드**: CSV 파일로 약국 정보 대량 등록

## 🐛 버그 수정
- 로그인 세션 만료 시 무한 루프 문제 수정
- 모바일 헤더 메뉴 클릭 오작동 수정

## 📚 문서 업데이트
- API 명세서 v3.0
- DB 스키마 v2.5
- 공통 컴포넌트 명세 v4.0

## 🔄 Breaking Changes
- **API 변경**: `GET /api/tasks` → 페이지네이션 필수 파라미터 추가
- **DB 스키마**: `t_pico_friends_report.answers` 타입 변경 (TEXT → JSONB)

## 📦 Dependencies
- Spring Boot 3.3.5 → 3.5.6
- Next.js 14.0.0 → 14.2.0
- React 18 → 19 (RC)

## 🚀 Migration Guide

### 백엔드
\`\`\`sql
-- JSONB 타입 마이그레이션
ALTER TABLE t_pico_friends_report
ALTER COLUMN answers TYPE JSONB USING answers::JSONB;
\`\`\`

### 프론트엔드
\`\`\`bash
npm install
npm run build
\`\`\`

## 📊 통계
- 총 커밋: 45개
- 새로운 기능: 8개
- 버그 수정: 12개
- 기여자: 3명
```

### 5. 리포지토리별 CHANGELOG

**다중 리포지토리 지원:**
- 문서: `/mnt/c/Dev/Document/Project/PICOFriends`
- 백엔드: `/mnt/c/Dev/repo/pico_friends_be`
- 프론트엔드: `/mnt/c/Dev/REpo/pico_friends_fe`

각 리포지토리의 `CHANGELOG.md` 동기화 및 통합 리포트 생성

## 사용 예시

- "최근 1개월 변경사항으로 CHANGELOG 업데이트"
- "v1.5.0 릴리즈 노트 생성"
- "화면설계서 v1.4와 v1.5 비교"
- "세 리포지토리의 변경사항 통합 리포트"
- "Jira 이슈 기반 CHANGELOG 생성"
