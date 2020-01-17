FROM node:latest AS builder

WORKDIR /opt/mx-puppet-slack
RUN adduser --disabled-password --gecos '' builder \
 && chown builder:builder . \
 && apk add git python2 build-base

USER builder

COPY package.json package-lock.json ./
RUN npm install

COPY tsconfig.json ./
COPY src/ ./src/
RUN npm run build


FROM node:alpine

VOLUME ["/data"]

RUN adduser -D -g '' bridge

WORKDIR /opt/mx-puppet-slack

COPY docker-run.sh ./
COPY --from=builder /opt/mx-puppet-slack/node_modules/ ./node_modules/
COPY --from=builder /opt/mx-puppet-slack/build/ ./build/

ENTRYPOINT ["./docker-run.sh"]
