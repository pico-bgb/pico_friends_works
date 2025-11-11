# 작업 문서 히스토리

> PICOFriends 프로젝트의 모든 작업 문서를 시간순으로 정리한 인덱스입니다.

## 📋 최근 작업

### 2025-11

#### PF-94: 백엔드 신규 API 통합 (WorkRequest, Pharmacy Assignment)
- **날짜**: 2025-11-11
- **유형**: Frontend Integration, Backend Schema Migration
- **주요 변경**:
  - 백엔드 스키마 변경 (컬럼명 표준화)
  - WorkRequest, Pharmacy Assignment API 추가
  - 프론트엔드 React Query 훅 및 MSW Mock 핸들러 구현
- **문서**: [📁 2025-11/PF-94-backend-api-integration](./2025-11/PF-94-backend-api-integration/)
  - [SCHEMA_MIGRATION_b77a086.md](./2025-11/PF-94-backend-api-integration/SCHEMA_MIGRATION_b77a086.md)
  - [FRONTEND_UPDATES.md](./2025-11/PF-94-backend-api-integration/FRONTEND_UPDATES.md)
  - [UPDATE_SUMMARY.md](./2025-11/PF-94-backend-api-integration/UPDATE_SUMMARY.md)
  - [README.md](./2025-11/PF-94-backend-api-integration/README.md)

---

## 📊 통계

- **총 작업 수**: 1개
- **문서 수**: 4개
- **커버 기간**: 2025-11 ~ 현재

---

## 📁 월별 아카이브

### 2025-11
- [PF-94: 백엔드 신규 API 통합](./2025-11/PF-94-backend-api-integration/)

---

## 🔍 검색 가이드

### 이슈 번호로 검색
```bash
# 특정 이슈의 작업 문서 찾기
find docs/work-history -type d -name "PF-94*"
```

### 날짜로 검색
```bash
# 특정 월의 작업 문서 찾기
ls docs/work-history/2025-11/
```

### 키워드로 검색
```bash
# 문서 내용에서 키워드 검색
grep -r "WorkRequest" docs/work-history/
```

---

## 📚 문서 유형

| 유형 | 설명 | 예시 파일명 |
|------|------|------------|
| **SCHEMA_MIGRATION** | DB 스키마 마이그레이션 가이드 | `SCHEMA_MIGRATION_*.md` |
| **FRONTEND_UPDATES** | 프론트엔드 업데이트 상세 내역 | `FRONTEND_UPDATES.md` |
| **UPDATE_SUMMARY** | 작업 완료 요약 보고서 | `UPDATE_SUMMARY.md` |
| **README** | 작업 개요 및 메타데이터 | `README.md` |

---

## 🔗 관련 링크

- **Jira 프로젝트**: [PF Board](https://picoinnov.atlassian.net/jira/software/projects/PF/boards/5/timeline)
- **Frontend 저장소**: [pico_friends_fe](https://github.com/picoinnov/pico_friends_fe)
- **Backend 저장소**: [pico_friends_be](https://github.com/picoinnov/pico_friends_be)

---

**마지막 업데이트**: 2025-11-11
**관리자**: Claude Code (work-doc-manager 스킬)
