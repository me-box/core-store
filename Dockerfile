FROM jptmoore/zest:v0.0.8

USER root
WORKDIR /app/zest/

LABEL databox.type="store"
COPY . /

ENTRYPOINT ["/run.sh"]