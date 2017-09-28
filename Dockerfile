FROM ocaml/opam:alpine

# add the code
ADD src src
RUN sudo chown -R opam:nogroup src

# add the build script
ADD build.sh .

# setup ocaml and compile
RUN sudo apk add alpine-sdk m4 perl gmp-dev \
&& opam install -y reason lwt tls cohttp \
&& sudo chmod +x build.sh && sync \
&& ./build.sh \
&& rm -rf /home/opam/src \
&& rm -rf /home/opam/.opam \
&& rm -rf /home/opam/opam-repository

# move to leaner image with zest binaries
FROM jptmoore/zest

USER root
WORKDIR /app/zest/

COPY --from=0 /home/opam/ .

