# PICOFriends Backend - Docker 환경 설정 가이드

## 🐳 Docker 환경 구성

이 프로젝트는 로컬 개발을 위해 Docker Compose를 사용합니다.

### 포함된 서비스
- **Redis 7.2**: JWT 토큰 캐시 (Port: 6379)
- **PostgreSQL**: 원격 개발 서버 사용 (`110.165.17.206:5432`)
  - 필요 시 docker-compose.yml에서 주석 해제하여 로컬 PostgreSQL 사용 가능

---

## 🚀 빠른 시작

### 1. Docker 컨테이너 시작

```bash
# pico_friends_works/docker 디렉토리로 이동
cd /Users/bgb/Dev/Repo/pico_friends_works/docker

# 백그라운드에서 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f
```

### 2. 컨테이너 상태 확인

```bash
docker-compose ps
```

정상 실행 시:
```
NAME                   STATUS    PORTS
pico_friends_redis     Up        0.0.0.0:6379->6379/tcp
```

### 3. Spring Boot 애플리케이션 실행

```bash
# Backend 디렉토리로 이동
cd /Users/bgb/Dev/Repo/pico_friends_be

# Gradle로 실행
./gradlew bootRun --args='--spring.profiles.active=local'

# 또는 IDE에서 실행 (Run Configuration에 VM options 추가)
-Dspring.profiles.active=local
```

---

## 🔧 자주 사용하는 명령어

### 컨테이너 관리

```bash
# 시작
docker-compose up -d

# 정지
docker-compose stop

# 정지 + 컨테이너 삭제
docker-compose down

# 정지 + 컨테이너 + 볼륨 삭제 (DB 데이터도 삭제됨)
docker-compose down -v
```

### PostgreSQL 접속 (원격 개발 서버)

```bash
# 원격 개발 서버에 직접 접속 (권한 필요)
psql -h 110.165.17.206 -U pharmus_drug -d pharmus_drug
# Password: Vkadjtm123$

# 로컬 PostgreSQL 사용 시 (docker-compose.yml 주석 해제 후)
# docker-compose exec postgres psql -U pico_friends -d pico_friends_dev
```

### Redis 접속

```bash
# 컨테이너 내부 redis-cli 실행
docker-compose exec redis redis-cli

# 테스트
> PING
PONG
> KEYS *
```

### 로그 확인

```bash
# Redis 로그
docker-compose logs redis

# 실시간 로그 스트리밍
docker-compose logs -f redis
```

---

## 🗄️ 데이터베이스 관리

### 원격 개발 서버 사용 (기본)
- Spring Boot 실행 시 원격 DB(`110.165.17.206:5432`)에 자동 연결
- JPA `ddl-auto: validate` 설정으로 스키마 검증만 수행
- 스키마 변경은 Flyway/Liquibase 또는 DBA를 통해 진행

### 로컬 PostgreSQL 사용 (선택사항)
로컬 PostgreSQL이 필요한 경우 `docker-compose.yml`에서 주석을 해제하고:

```bash
# 1. docker-compose.yml에서 postgres 서비스 주석 해제
# 2. application-local.yml 수정
#    url: jdbc:postgresql://localhost:5432/pico_friends_dev
#    username: pico_friends
#    password: pico_friends_dev_2024

# 3. 컨테이너 시작
docker-compose up -d

# 4. 스키마 초기화 (필요시)
# Spring Boot 실행으로 자동 생성되거나 수동 SQL 실행
```

---

## ⚙️ 설정 정보

### PostgreSQL 접속 정보 (원격 개발 서버)
- **Host**: `110.165.17.206`
- **Port**: `5432`
- **Database**: `pharmus_drug`
- **Username**: `pharmus_drug`
- **Password**: `Vkadjtm123$`
- **JDBC URL**: `jdbc:postgresql://110.165.17.206:5432/pharmus_drug`

### Redis 접속 정보 (로컬 Docker)
- **Host**: `localhost`
- **Port**: `6379`
- **Password**: (없음)

---

## 🛠️ 트러블슈팅

### 1. 포트 충돌

**증상**: `Bind for 0.0.0.0:5432 failed: port is already allocated`

**해결**:
```bash
# 해당 포트를 사용 중인 프로세스 확인
lsof -i :5432
lsof -i :6379

# 프로세스 종료 또는 docker-compose.yml에서 포트 변경
# ports:
#   - "15432:5432"  # 예: 15432로 변경
```

### 2. 컨테이너가 계속 재시작됨

**증상**: `docker-compose ps`에서 STATUS가 `Restarting`

**해결**:
```bash
# 로그 확인
docker-compose logs postgres

# 볼륨 삭제 후 재시작
docker-compose down -v
docker-compose up -d
```

### 3. Spring Boot 연결 실패

**증상**: `org.postgresql.util.PSQLException: Connection refused`

**확인**:
```bash
# 1. 컨테이너 상태 확인
docker-compose ps

# 2. 헬스체크 확인
docker inspect pico_friends_postgres | grep -A 5 Health

# 3. PostgreSQL 직접 접속 테스트
docker-compose exec postgres psql -U pico_friends -d pico_friends_dev -c "SELECT 1;"
```

### 4. 데이터 초기화

**모든 데이터를 삭제하고 새로 시작**:
```bash
docker-compose down -v
docker-compose up -d
```

---

## 📦 볼륨 관리

Docker 볼륨에 데이터가 영구 저장됩니다:

```bash
# 볼륨 목록 확인
docker volume ls | grep pico_friends

# 볼륨 상세 정보
docker volume inspect pico_friends_be_postgres_data
docker volume inspect pico_friends_be_redis_data

# 볼륨 삭제 (주의: 데이터 삭제됨!)
docker-compose down -v
```

---

## 🔗 관련 파일

- [docker-compose.yml](./docker-compose.yml): Docker Compose 설정
- [application-local.yml](../../pico_friends_be/src/main/resources/application-local.yml): Spring Boot 로컬 설정
- [Backend CLAUDE.md](../../pico_friends_be/CLAUDE.md): 백엔드 전체 가이드
- [Project CLAUDE.md](../CLAUDE.md): 프로젝트 전체 가이드

---

## 💡 팁

### 개발 시 권장 워크플로우

1. **아침에 Docker 시작**
   ```bash
   docker-compose up -d
   ```

2. **Spring Boot 실행** (IDE 또는 CLI)
   ```bash
   ./gradlew bootRun
   ```

3. **작업 종료 시 Docker 정지** (선택사항)
   ```bash
   docker-compose stop  # 데이터 유지
   # 또는
   docker-compose down  # 컨테이너 삭제 (데이터 유지)
   ```

### 리소스 절약

Docker Desktop 메모리 사용량이 높다면:
- 사용하지 않을 때 `docker-compose stop`으로 정지
- Docker Desktop 설정에서 Memory/CPU 제한 설정

### 프로덕션 환경

이 Docker 설정은 **로컬 개발 전용**입니다.
프로덕션 환경은 별도 설정이 필요합니다.

---

**Last Updated**: 2025-11-06
