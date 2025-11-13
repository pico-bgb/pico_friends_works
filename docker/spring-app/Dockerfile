# Java 21 JRE로 가볍고 안정적인 런타임 환경
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# app.jar 복사
COPY app.jar .

# 포트 노출
EXPOSE 7070

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]

