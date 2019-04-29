#
# Builder container
#
FROM debian:buster as builder

ENV LANG C.UTF-8

## Prepare environment to build fpm packages
RUN apt-get update \
    && apt-get install -y wget ca-certificates make ruby-dev gcc git leiningen \
    && rm -rf /var/lib/apt/lists/*

RUN gem install fpm

WORKDIR /usr/app/zk-web
RUN git clone --depth=1 https://github.com/qiuxiafei/zk-web .

RUN lein uberjar

# Clean up
WORKDIR /usr/app/zk-web/target
RUN mv *-standalone.jar app.jar

#
# Runtime container
#
FROM azul/zulu-openjdk-alpine:11-jre 

# Run as user app:app
RUN addgroup -g 2222 app && adduser -D -G app -s /bin/bash -u 2222 app

# Switch to user app
USER app
WORKDIR /app
COPY conf/ ./conf
COPY --from=builder /usr/app/zk-web/target/app.jar /app/app.jar

ENTRYPOINT ["java","-jar","/app/app.jar"]
