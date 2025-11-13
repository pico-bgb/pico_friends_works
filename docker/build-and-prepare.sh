#!/bin/bash

# ==============================================================================
# PICOFriends - 로컬 빌드 및 배포 파일 준비 스크립트
# ==============================================================================
# 이 스크립트는 로컬에서 실행되며, BE + FE를 빌드하고 배포 파일을 준비합니다.
# ==============================================================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 프로젝트 경로 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKS_DIR="$(dirname "$SCRIPT_DIR")"
BE_DIR="/Users/bgb/Dev/Repo/pico_friends_be"
FE_DIR="/Users/bgb/Dev/Repo/pico_friends_fe"

# 배포 준비 디렉토리
DEPLOY_DIR="$SCRIPT_DIR/deploy"

# 함수: 로그 출력
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 함수: 진행 단계 출력
print_step() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN} $1${NC}"
    echo -e "${GREEN}========================================${NC}"
}

# 시작
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  PICOFriends 빌드 및 배포 준비        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Step 1: 환경 체크
print_step "Step 1/8: 환경 체크"

# BE 프로젝트 확인
if [ ! -d "$BE_DIR" ]; then
    log_error "Backend 프로젝트를 찾을 수 없습니다: $BE_DIR"
    exit 1
fi
log_info "Backend 프로젝트: $BE_DIR"

# FE 프로젝트 확인
if [ ! -d "$FE_DIR" ]; then
    log_error "Frontend 프로젝트를 찾을 수 없습니다: $FE_DIR"
    exit 1
fi
log_info "Frontend 프로젝트: $FE_DIR"

# Java 확인
if ! command -v java &> /dev/null; then
    log_error "Java가 설치되어 있지 않습니다."
    exit 1
fi
log_info "Java 버전: $(java -version 2>&1 | head -n 1)"

# Node.js 확인
if ! command -v node &> /dev/null; then
    log_error "Node.js가 설치되어 있지 않습니다."
    exit 1
fi
log_info "Node.js 버전: $(node --version)"

log_success "환경 체크 완료"

# Step 2: 배포 디렉토리 준비
print_step "Step 2/8: 배포 디렉토리 준비"

# 기존 deploy 디렉토리 삭제 및 재생성
if [ -d "$DEPLOY_DIR" ]; then
    log_warn "기존 배포 디렉토리 삭제 중..."
    if ! rm -rf "$DEPLOY_DIR" 2>/dev/null; then
        log_error "배포 디렉토리 삭제 실패 (권한 문제)"
        log_error "다음 명령어를 실행하여 수동으로 삭제하세요:"
        echo ""
        echo "  sudo rm -rf $DEPLOY_DIR"
        echo ""
        exit 1
    fi
fi

mkdir -p "$DEPLOY_DIR/spring-app"
mkdir -p "$DEPLOY_DIR/nextjs-app"
mkdir -p "$DEPLOY_DIR/storybook-app"

log_success "배포 디렉토리 생성: $DEPLOY_DIR"

# Step 3: Backend 빌드
print_step "Step 3/8: Backend 빌드"

cd "$BE_DIR"
log_info "Gradle 빌드 시작..."

if [ -f "./gradlew" ]; then
    ./gradlew clean bootJar
else
    log_error "gradlew 파일을 찾을 수 없습니다."
    exit 1
fi

# JAR 파일 찾기
JAR_FILE=$(find build/libs -name "*.jar" -type f | grep -v "plain" | head -n 1)

if [ -z "$JAR_FILE" ]; then
    log_error "빌드된 JAR 파일을 찾을 수 없습니다."
    exit 1
fi

JAR_SIZE=$(du -h "$JAR_FILE" | cut -f1)
log_success "Backend 빌드 완료: $JAR_FILE ($JAR_SIZE)"

# Step 4: Backend 파일 복사
print_step "Step 4/8: Backend 파일 복사"

# JAR 파일 복사
cp "$JAR_FILE" "$DEPLOY_DIR/spring-app/app.jar"
log_info "app.jar 복사 완료"

# Dockerfile 복사
cp "$SCRIPT_DIR/spring-app/Dockerfile" "$DEPLOY_DIR/spring-app/"
log_info "Dockerfile 복사 완료"

log_success "Backend 파일 준비 완료"

# Step 5: Frontend 빌드
print_step "Step 5/8: Frontend 빌드"

cd "$FE_DIR"
log_info "npm 빌드 시작..."

# npm 의존성 설치 (필요 시)
if [ ! -d "node_modules" ]; then
    log_info "의존성 설치 중..."
    npm ci
fi

# Next.js 빌드 (환경변수 설정)
NEXT_PUBLIC_API_URL=http://110.165.17.206:7070 npm run build

if [ ! -d ".next/standalone" ]; then
    log_error "Frontend 빌드 실패: .next/standalone 디렉토리를 찾을 수 없습니다."
    log_error "next.config.ts에서 output: 'standalone' 설정을 확인하세요."
    exit 1
fi

log_success "Frontend 빌드 완료"

# Step 6: Frontend 파일 복사
print_step "Step 6/8: Frontend 파일 복사"

# .next 디렉토리 구조 생성
mkdir -p "$DEPLOY_DIR/nextjs-app/.next"

# .next/standalone 전체 복사 (디렉토리 포함)
cp -r .next/standalone "$DEPLOY_DIR/nextjs-app/.next/"
log_info ".next/standalone 복사 완료"

# .next/static 복사
cp -r .next/static "$DEPLOY_DIR/nextjs-app/.next/"
log_info ".next/static 복사 완료"

# public 복사
if [ -d "public" ]; then
    cp -r public "$DEPLOY_DIR/nextjs-app/"
    log_info "public 복사 완료"
fi

# Dockerfile 복사
cp "$SCRIPT_DIR/nextjs-app/Dockerfile" "$DEPLOY_DIR/nextjs-app/"
log_info "Dockerfile 복사 완료"

log_success "Frontend 파일 준비 완료"

# Step 7: Storybook 빌드 및 복사
print_step "Step 7/8: Storybook 빌드 및 복사"

cd "$FE_DIR"
log_info "Storybook 빌드 시작..."

# Storybook 빌드
npm run build-storybook

if [ ! -d "storybook-static" ]; then
    log_error "Storybook 빌드 실패: storybook-static 디렉토리를 찾을 수 없습니다."
    exit 1
fi

# Storybook 파일 복사
cp -r storybook-static "$DEPLOY_DIR/storybook-app/"
log_info "storybook-static 복사 완료"

# Dockerfile 복사
cp "$SCRIPT_DIR/Dockerfile.storybook" "$DEPLOY_DIR/storybook-app/Dockerfile"
log_info "Dockerfile 복사 완료"

log_success "Storybook 파일 준비 완료"

# Step 8: Docker 설정 파일 복사
print_step "Step 8/8: Docker 설정 파일 복사"

# docker-compose.yml 복사
cp "$SCRIPT_DIR/docker-compose.yml" "$DEPLOY_DIR/"
log_info "docker-compose.yml 복사 완료"

# .env 복사
if [ -f "$SCRIPT_DIR/.env" ]; then
    cp "$SCRIPT_DIR/.env" "$DEPLOY_DIR/"
    log_warn ".env 파일이 복사되었습니다. 서버에서 실제 값으로 변경하세요!"
else
    log_warn ".env 파일이 없습니다. 서버에서 직접 생성하세요."
fi

log_success "Docker 설정 파일 준비 완료"

# 완료
echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  빌드 및 배포 준비 완료!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# 배포 디렉토리 내용 확인
echo -e "${BLUE}배포 준비 디렉토리: $DEPLOY_DIR${NC}"
echo ""
tree -L 2 "$DEPLOY_DIR" 2>/dev/null || find "$DEPLOY_DIR" -maxdepth 2 -type f -o -type d

echo ""
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}  다음 단계: 서버에 배포${NC}"
echo -e "${YELLOW}═══════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}1. 배포 파일을 서버로 전송:${NC}"
echo "   cd $DEPLOY_DIR"
echo "   scp -r * root@110.165.17.206:/srv/apps/pico_friends/"
echo ""
echo -e "${GREEN}2. 서버에서 Docker 실행:${NC}"
echo "   ssh root@110.165.17.206"
echo "   cd /srv/apps/pico_friends"
echo "   vi .env  # DB_PASSWORD, JWT_SECRET 설정"
echo "   docker-compose down"
echo "   docker-compose build --no-cache"
echo "   docker-compose up -d"
echo ""
echo -e "${GREEN}3. 배포 확인:${NC}"
echo "   docker-compose ps"
echo "   curl http://110.165.17.206:7070/actuator/health"
echo "   curl http://110.165.17.206:3001/api/health"
echo ""
echo -e "${GREEN}4. 서비스 접속:${NC}"
echo "   Frontend:  http://110.165.17.206:3001"
echo "   Backend:   http://110.165.17.206:7070"
echo "   Storybook: http://110.165.17.206:6006"
echo ""
