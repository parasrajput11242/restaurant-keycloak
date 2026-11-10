# ---- Stage 1: pre-build Keycloak so startup is fast and uses less RAM ----
FROM quay.io/keycloak/keycloak:26.7.2 AS builder
ENV KC_DB=postgres
RUN /opt/keycloak/bin/kc.sh build

# ---- Stage 2: runtime image ----
FROM quay.io/keycloak/keycloak:26.7.2
COPY --from=builder /opt/keycloak/ /opt/keycloak/
# Realm is imported on first boot only (skipped if it already exists in the DB)
COPY restaurant-review-realm.json /opt/keycloak/data/import/restaurant-review-realm.json

ENV KC_DB=postgres
ENV KC_HTTP_ENABLED=true
ENV KC_PROXY_HEADERS=xforwarded
ENV KC_HTTP_PORT=10000
# Keep the JVM inside the container's memory limit
ENV JAVA_OPTS_KC_HEAP="-XX:MaxRAMPercentage=65 -XX:InitialRAMPercentage=50"

EXPOSE 10000
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm"]
