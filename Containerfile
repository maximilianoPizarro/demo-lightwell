# Contingency / Tekton image for Lightwell demo WAR
# Build stage: Red Hat UBI OpenJDK
# Runtime: WildFly (JBoss family) — swap to registry.redhat.io EAP when pull secret available
ARG JAVA_IMAGE=registry.access.redhat.com/ubi9/openjdk-17:1.21
ARG RUNTIME_IMAGE=quay.io/wildfly/wildfly:27.0.1.Final-jdk17

FROM ${JAVA_IMAGE} AS build
USER root
WORKDIR /build
COPY app/pom.xml app/settings-lightwell-direct.xml.template ./
COPY app/src ./src
# When building in CI, settings.xml is mounted/copied with credentials.
# Offline-friendly: settings may be provided as /tmp/settings.xml
COPY app/pom.xml /tmp/pom.xml
RUN microdnf install -y maven || (dnf install -y maven) || true
# Placeholder build path when settings provided at /tmp/settings.xml by CI
COPY app /build/app
WORKDIR /build/app
# Default: resolve from Central for servlet-api; Lightwell deps need settings at build time
ARG MAVEN_SETTINGS=/tmp/settings.xml
RUN if [ -f "${MAVEN_SETTINGS}" ]; then \
      mvn -B -s "${MAVEN_SETTINGS}" -DskipTests package; \
    else \
      echo "WARN: no settings.xml — build may fail for Lightwell deps"; \
      mvn -B -DskipTests package || true; \
    fi

FROM ${RUNTIME_IMAGE}
USER root
COPY --from=build /build/app/target/demo-lightwell.war /opt/jboss/wildfly/standalone/deployments/ROOT.war
# Enable management console on 0.0.0.0 for demo Route
RUN /opt/jboss/wildfly/bin/add-user.sh -u admin -p 'Admin#123' -g ManagementRealm || true \
 && sed -i 's/127.0.0.1:9990/0.0.0.0:9990/g' /opt/jboss/wildfly/standalone/configuration/standalone.xml || true \
 && sed -i 's/jboss.bind.address.management:127.0.0.1/jboss.bind.address.management:0.0.0.0/g' /opt/jboss/wildfly/standalone/configuration/standalone.xml || true
USER jboss
EXPOSE 8080 9990
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]
