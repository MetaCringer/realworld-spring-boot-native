FROM debian:12.6 as builder
ARG JAVA_VERSION=22.3.2.r17-nik

SHELL [ "/bin/bash", "-c" ]
COPY . /app
WORKDIR /app
RUN apt update && apt install -y curl zip && \
curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
curl -s "https://get.sdkman.io" | bash && \
source "/root/.sdkman/bin/sdkman-init.sh" && \
sdk install java $JAVA_VERSION && \
sdk use java $JAVA_VERSION && \
apt update && \
apt-get install -y nodejs build-essential && \
npm install npx newman@6.1.0 && \
./gradlew build 
# && \
#./gradlew nativeCompile --debug --stacktrace -Dorg.gradle.jvmargs="-Xmx8000m"
# RUN dnf install -y zip gcc gcc-toolset-13-gcc-c++ libstdc++-static zlib-devel


# Integration tests
# RUN source "/root/.sdkman/bin/sdkman-init.sh" && \
# sdk use java $JAVA_VERSION && \
# java -agentlib:native-image-agent=config-output-dir=./aot/META-INF/native-image/,experimental-class-define-support -Dspring.aot.enabled=true -jar ./build/libs/realworld.jar & \
# sleep 60 && \
# ./api/run-api-tests.sh && \
# kill $!

# RUN source "/root/.sdkman/bin/sdkman-init.sh" && \
# sdk use java $JAVA_VERSION && \
# ./gradlew nativeCompile


FROM debian:12.6
RUN apt update && apt install -y postgresql-client openjdk-17-jdk



#USER 1001:1001
#COPY --from=builder --chown=1001:1001 /app/build/native/nativeCompile/realworld /app/
COPY --from=builder /app/build/libs/realworld.jar /app/
WORKDIR /app
ENTRYPOINT ["java", "-jar", "/app/realworld.jar"]