# PICOFriends Docker 배포

> Backend + Frontend + Redis 통합 배포

## 📋 목차

- [빠른 시작](#-빠른-시작)
- [디렉토리 구조](#-디렉토리-구조)
- [배포 방법](#-배포-방법)
- [운영 명령어](#-운영-명령어)

---

## ⚡ 빠른 시작

### 1. 로컬에서 빌드 및 배포 파일 준비 (자동화)

```bash
cd /Users/bgb/Dev/Repo/pico_friends_works/docker

# 빌드 및 배포 파일 준비 (BE + FE 자동 빌드)
./build-and-prepare.sh
```

이 스크립트가 자동으로 수행하는 작업:
- ✅ Backend Gradle 빌드 (`./gradlew bootJar`)
- ✅ Frontend npm 빌드 (`npm run build`)
- ✅ 배포 파일 준비 (`deploy/` 디렉토리 생성)
- ✅ Docker 설정 복사

### 2. 서버에 전송

```bash
cd /Users/bgb/Dev/Repo/pico_friends_works/docker/deploy

# SFTP 또는 SCP로 전송
scp -r * root@110.165.17.206:/srv/apps/pico_friends/
```

### 3. 서버에서 배포

```bash
ssh root@110.165.17.206
cd /srv/apps/pico_friends

# .env 파일 수정 (최초 1회)
vi .env
# DB_PASSWORD=실제_비밀번호
# JWT_SECRET=실제_시크릿_키

# Docker 컨테이너 시작
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# 배포 확인
docker-compose ps
curl http://localhost:7070/actuator/health
curl http://localhost:3001/api/health
```

---

## 📁 디렉토리 구조

### 로컬 (이 저장소)

```
pico_friends_works/docker/
├── build-and-prepare.sh     # 🚀 자동 빌드 스크립트
├── docker-compose.yml        # Docker Compose 설정
├── .env                      # 환경변수 템플릿
├── .gitignore                # Git 제외 파일
├── README.md                 # 이 파일
├── spring-app/
│   └── Dockerfile            # Backend Dockerfile
├── nextjs-app/
│   └── Dockerfile            # Frontend Dockerfile
└── deploy/                   # 빌드 후 생성됨 (Git 제외)
    ├── docker-compose.yml
    ├── .env
    ├── spring-app/
    │   ├── Dockerfile
    │   └── app.jar           # ← 빌드 결과물
    └── nextjs-app/
        ├── Dockerfile
        ├── .next/            # ← 빌드 결과물
        └── public/
```

### 서버 (/srv/apps/pico_friends)

```
/srv/apps/pico_friends/
├── docker-compose.yml
├── .env                      # DB_PASSWORD, JWT_SECRET 설정
├── spring-app/
│   ├── Dockerfile
│   └── app.jar
└── nextjs-app/
    ├── Dockerfile
    ├── .next/
    └── public/
```

---

## 🔧 배포 방법

### 방법 1: 자동화 스크립트 사용 (권장) ⭐

```bash
# 1. 빌드 및 준비
cd /Users/bgb/Dev/Repo/pico_friends_works/docker
./build-and-prepare.sh

# 2. 서버 전송
cd deploy
scp -r * root@110.165.17.206:/srv/apps/pico_friends/

# 3. 서버에서 배포
ssh root@110.165.17.206
cd /srv/apps/pico_friends
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### 방법 2: 수동 빌드

**Backend**:
```bash
cd /Users/bgb/Dev/Repo/pico_friends_be
./gradlew clean bootJar

# app.jar 전송
scp build/libs/pico_friends_api-*.jar root@110.165.17.206:/srv/apps/pico_friends/spring-app/app.jar
```

**Frontend**:
```bash
cd /Users/bgb/Dev/Repo/pico_friends_fe
npm run build

# 빌드 결과물 압축 및 전송
tar czf nextjs-build.tar.gz .next public
scp nextjs-build.tar.gz root@110.165.17.206:/srv/apps/pico_friends/nextjs-app/

# 서버에서 압축 해제
ssh root@110.165.17.206
cd /srv/apps/pico_friends/nextjs-app
tar xzf nextjs-build.tar.gz
rm nextjs-build.tar.gz
```

**Docker 설정 (최초 1회)**:
```bash
cd /Users/bgb/Dev/Repo/pico_friends_works/docker

scp docker-compose.yml .env root@110.165.17.206:/srv/apps/pico_friends/
scp spring-app/Dockerfile root@110.165.17.206:/srv/apps/pico_friends/spring-app/
scp nextjs-app/Dockerfile root@110.165.17.206:/srv/apps/pico_friends/nextjs-app/
```

---

## 🛠️ 운영 명령어

### 컨테이너 관리

```bash
# 전체 재시작
docker-compose restart

# Backend만 재배포
docker-compose build --no-cache backend
docker-compose up -d --force-recreate backend

# Frontend만 재배포
docker-compose build --no-cache frontend
docker-compose up -d --force-recreate frontend

# 전체 중지 및 제거
docker-compose down
```

### 로그 확인

```bash
# 전체 로그
docker-compose logs -f

# 특정 서비스 로그
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f redis

# 마지막 100줄
docker-compose logs --tail=100 backend
```

### 상태 확인

```bash
# 컨테이너 상태
docker-compose ps

# Health Check
curl http://110.165.17.206:7070/actuator/health  # Backend
curl http://110.165.17.206:3001/api/health       # Frontend

# 리소스 사용량
docker stats pico-friends-api pico-friends-web pico-friends-redis
```

---

## 🔗 접속 정보

| 서비스 | URL |
|--------|-----|
| Frontend | http://110.165.17.206:3001 |
| Backend API | http://110.165.17.206:7070 |
| Swagger | http://110.165.17.206:7070/swagger-ui.html |
| Redis | 110.165.17.206:6379 (내부) |

---

## 📝 주요 특징

1. ✅ **자동화**: 한 번의 스크립트 실행으로 BE + FE 빌드
2. ✅ **간단**: Docker Compose로 전체 스택 관리
3. ✅ **일관성**: 모든 컨테이너 이름 `pico-friends-*` 통일
4. ✅ **분리**: 빌드(로컬) vs 배포(서버) 완전 분리

---

## 🔍 트러블슈팅

### 빌드 스크립트 실패

```bash
# 권한 문제
chmod +x build-and-prepare.sh

# 경로 문제 확인
# 스크립트 내부의 BE_DIR, FE_DIR 경로 확인
vi build-and-prepare.sh
```

### Frontend 빌드 실패

```bash
# next.config.ts에서 standalone 설정 확인
cd /Users/bgb/Dev/Repo/pico_friends_fe
cat next.config.ts | grep standalone
# output: "standalone" 있어야 함
```

### 서버 배포 실패

```bash
# 로그 확인
docker-compose logs -f backend frontend

# .env 파일 확인
cat .env
# DB_PASSWORD, JWT_SECRET 실제 값 확인
```

---

**Last Updated**: 2025-11-12
