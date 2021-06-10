FROM caddy:2.4.1-builder-alpine AS builder
RUN xcaddy build --with github.com/ueffel/caddy-brotli

FROM caddy:2.4.1-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

ARG DOCKER_GEN_VERSION="0.7.4"
ARG FOREGO_VERSION="0.16.1"


ENV CADDYPATH="/etc/caddy"
ENV DOCKER_HOST="unix:///tmp/docker.sock"

RUN apk update && apk upgrade \
    && apk add --no-cache bash openssh-client git \
    && apk add --no-cache --virtual .build-dependencies curl wget tar \
    && wget --quiet "https://github.com/jwilder/forego/releases/download/v${FOREGO_VERSION}/forego" \
    && mv ./forego /usr/bin/forego \
    && chmod u+x /usr/bin/forego \
    && wget --quiet "https://github.com/jwilder/docker-gen/releases/download/${DOCKER_GEN_VERSION}/docker-gen-alpine-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz" \
    && tar -C /usr/bin -xvzf "docker-gen-alpine-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz" \
    && rm "docker-gen-alpine-linux-amd64-${DOCKER_GEN_VERSION}.tar.gz" \
    && apk del .build-dependencies

EXPOSE 80 443 2015
VOLUME /etc/caddy

COPY . /code
COPY ./docker-gen/templates/Caddyfile.tmpl /code/docker-gen/templates/Caddyfile.bkp
WORKDIR /code


ENTRYPOINT ["sh", "/code/docker-entrypoint.sh"]
CMD ["/usr/bin/forego", "start", "-r"]