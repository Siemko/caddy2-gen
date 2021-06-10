# Caddy 2 Gen

Heavily inspired by wemake-services' awesome [caddy-gen](https://github.com/wemake-services/caddy-gen).

[Docker Hub](https://hub.docker.com/repository/docker/siemko8/caddy2-gen)

---

## Configuration

Use `labels`.

The main idea is simple. Every labeled service exposes a `virtual.host` to be handled. Then, every container represents a single `reverse_proxy`'s `to` option to serve requests.

Options to configure:

- `virtual.host` domain name, don't pass `http://` or `https://`, you can separate them with space,
- `virtual.alias` domain alias, e.q. `www` prefix,
- `virtual.port` port exposed by container, e.g. `3000` for React apps in development,
- `virtual.tls-email` the email address to use for the ACME account managing the site's certificates,
- `virtual.host.directives` set custom Caddyfile directives for the host. These will be inlined into the site block.
- `virtual.host.import` include Caddyfile directives for the host from a file on the container's filesystem. See Caddy import.
- `virtual.proxy.matcher` have the reverse proxy only match certain paths.
- `virtual.proxy.lb_policy` specify load balancer policy, defaults to round_robin.
- `virtual.proxy.directives` include any reverse_proxy directives. These will be inlined into the reverse proxy block.
- `virtual.proxy.import` include any reverse_proxy directives from a file on the container's filesystem. See Caddy import.
- `virtual.auth.username` and
- `virtual.auth.password` together provide HTTP basic authentication.

Password should be a string `base64` encoded from `bcrypt` hash. You can use https://bcrypt-generator.com/ with default config and https://www.base64encode.org/.

## Backing up certificates

To backup certificates make a volume:

`./caddy-info:/data/caddy`
