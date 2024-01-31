FROM redhat/ubi8 as builder
ARG JAVA_VERSION=22.3.2.r17-nik

COPY . /app
WORKDIR /app
RUN dnf install -y zip gcc gcc-toolset-13-gcc-c++ libstdc++-static zlib-devel && \
curl -s "https://get.sdkman.io" | bash && \
source "/root/.sdkman/bin/sdkman-init.sh" && \
sdk install java $JAVA_VERSION && \
sdk use java $JAVA_VERSION && \
java -version && \
dnf module install -y nodejs:20/common && \
npm install npx newman@6.1.0 && \
./gradlew build


# Integration tests
RUN source "/root/.sdkman/bin/sdkman-init.sh" && \
sdk use java $JAVA_VERSION && \
java -agentlib:native-image-agent=config-output-dir=./aot/META-INF/native-image/,experimental-class-define-support -Dspring.aot.enabled=true -jar ./build/libs/realworld.jar & \
sleep 60 && \
./api/run-api-tests.sh && \
kill $!

RUN source "/root/.sdkman/bin/sdkman-init.sh" && \
sdk use java $JAVA_VERSION && \
./gradlew nativeCompile


FROM redhat/ubi8
RUN dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
dnf install -y postgresql15 java-11-openjdk && \
curl https://dlcdn.apache.org/kafka/3.6.1/kafka_2.13-3.6.1.tgz -o kafka.tgz && \
tar -xzf kafka.tgz

#USER 1001:1001
#COPY --from=builder --chown=1001:1001 /app/build/native/nativeCompile/realworld /app/
COPY --from=builder /app/build/native/nativeCompile/realworld /app/
WORKDIR /app
ENTRYPOINT ["/app/realworld"]