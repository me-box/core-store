ARG ZEST_FROM=test
FROM ${ZEST_FROM}

USER root
WORKDIR /app/zest/
COPY run.sh /app/zest/run.sh

LABEL databox.type="store"

CMD ["/app/zest/run.sh"]