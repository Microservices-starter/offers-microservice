FROM maven:3.8.5-jdk-11 as builder
WORKDIR /app
COPY . .
RUN mvn clean package -Dmaven.test.skip=true

FROM tomcat:9.0.62-jdk16-temurin-focal
WORKDIR webapps
COPY --from=builder /app/target/offers-0.0.1-SNAPSHOT.jar .
RUN rm -rf ROOT && mv offers-0.0.1-SNAPSHOT.jar offers.jar