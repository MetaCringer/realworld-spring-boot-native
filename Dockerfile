FROM redhat/ubi8

RUN dnf install -y zip gcc && \
curl -s "https://get.sdkman.io" | bash && \
source "/root/.sdkman/bin/sdkman-init.sh" && \
sdk install java 22.3.2.r17-nik && \
sdk use java 22.3.2.r17-nik && \
dnf module install -y nodejs:20/common

#USER 1001:1001
#COPY --chown=1001:1001 . /app
COPY . /app
WORKDIR /app
RUN npm install npx newman@6.1.0

RUN ./gradlew build

# Integration tests
RUN java -agentlib:native-image-agent=config-output-dir=./aot/META-INF/native-image/,experimental-class-define-support -Dspring.aot.enabled=true -jar ./build/libs/realworld.jar & \
sleep 60 && \
./api/run-api-tests.sh && \
kill $!

# ./gradlew nativeCompile

#RUN ./gradlew build
#ENTRYPOINT ["/app/entrypoint.sh"]