ARG DOCKER_GEN_VERSION="0.8.4"
ARG FOREGO_VERSION="v0.17.0"

FROM golang:1.18.0 as gobuilder

FROM gobuilder as forego
ARG FOREGO_VERSION
RUN git clone https://github.com/nginx-proxy/forego/ \
   && cd /go/forego \
   && git -c advice.detachedHead=false checkout $FOREGO_VERSION \
   && go mod download \
   && CGO_ENABLED=0 GOOS=linux go build -o forego . \
   && go clean -cache \
   && mv forego /usr/local/bin/ \
   && cd - \
   && rm -rf /go/forego

FROM gobuilder as dockergen
ARG DOCKER_GEN_VERSION
RUN git clone https://github.com/nginx-proxy/docker-gen \
   && cd /go/docker-gen \
   && git -c advice.detachedHead=false checkout $DOCKER_GEN_VERSION \
   && go mod download \
   && CGO_ENABLED=0 GOOS=linux go build -ldflags "-X main.buildVersion=${DOCKER_GEN_VERSION}" ./cmd/docker-gen \
   && go clean -cache \
   && mv docker-gen /usr/local/bin/ \
   && cd - \
   && rm -rf /go/docker-gen

FROM caddy:2.5.2-builder-alpine AS builder
RUN xcaddy build --with github.com/ueffel/caddy-brotli

FROM builder as caddy
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
ENV CADDYPATH="/etc/caddy"
ENV DOCKER_HOST="unix:///tmp/docker.sock"

COPY --from=forego /usr/local/bin/forego /usr/local/bin/forego
COPY --from=dockergen /usr/local/bin/docker-gen /usr/local/bin/docker-gen

RUN apk --no-cache add bash

EXPOSE 80 443 2015
VOLUME /etc/caddy

COPY . /code
COPY ./docker-gen/templates/Caddyfile.tmpl /code/docker-gen/templates/Caddyfile.bkp
WORKDIR /code


ENTRYPOINT ["sh", "/code/docker-entrypoint.sh"]
CMD ["/usr/local/bin/forego", "start", "-r"]
