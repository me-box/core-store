ARG ZEST_FROM=test
FROM ${ZEST_FROM}

USER root
COPY /run.sh /run.sh
WORKDIR /app/zest/

LABEL databox.type="store"

ENTRYPOINT ["/run.sh"]