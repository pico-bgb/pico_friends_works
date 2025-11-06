# PICOFriends - Docker 개발 환경

이 디렉토리는 PICOFriends 프로젝트의 로컬 개발 환경을 위한 Docker 설정을 포함합니다.

## 📂 파일 구성

- **docker-compose.yml**: Redis 컨테이너 설정
- **DOCKER_SETUP.md**: 상세 사용 가이드

## 🚀 빠른 시작

```bash
# 이 디렉토리로 이동
cd /Users/bgb/Dev/Repo/pico_friends_works/docker

# Docker 컨테이너 시작
docker-compose up -d

# 상태 확인
docker-compose ps
```

## 📖 자세한 내용

상세한 사용법은 [DOCKER_SETUP.md](./DOCKER_SETUP.md)를 참조하세요.

## 🐳 포함된 서비스

- **Redis 7.2**: JWT 토큰 캐시 (Port: 6379)
- **PostgreSQL**: 원격 개발 서버 사용 (`110.165.17.206:5432`)

## 🔗 관련 문서

- [프로젝트 가이드](../CLAUDE.md)
- [Backend 가이드](../../pico_friends_be/CLAUDE.md)
- [Frontend 가이드](../../pico_friends_fe/CLAUDE.md)

---

**Last Updated**: 2025-11-06
