# Node.js 20 Alpine으로 가볍고 안정적인 런타임 환경
FROM node:20-alpine
WORKDIR /app

# standalone 빌드 결과물 복사
COPY .next/standalone ./
COPY .next/static ./.next/static
COPY public ./public

# 포트 노출
EXPOSE 3000

# 애플리케이션 실행
ENV NODE_ENV=production
ENV HOSTNAME=0.0.0.0
CMD ["node", "server.js"]
