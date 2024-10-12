# traefik

```bash
make init
make start
```

## 적용하기

`traefik.yaml` 수정

```yaml
    labels:
      - traefik.enable=true
      ## HTTP Routers
      - traefik.http.routers.${SERVICE}.entrypoints=webs
      - traefik.http.routers.${SERVICE}.rule=Host(`${DOMAIN}`)
      - traefik.http.services.${SERVICE}.loadbalancer.server.port=3000
      - traefik.http.routers.${SERVICE}.tls.certresolver=leresolver
```

## http redirect https

설정에 기본값으로 http를 https로 리다이렉트하도록 설정

```diff
 entryPoints:
   web:
     address: :80
-    # Redirect
-    http:
-      redirections:
-        entryPoint:
-          to: webs
-          scheme: https
-          permanent: true
   webs:
     address: :443
```

`traefik/rules/http2https.yaml` 생성

```yaml
http:
  middlewares:
    http2https:
      redirectScheme:
        scheme: https
        permanent: true
```

http로 오면 https로 리다이렉트되는 미들웨어 적용하기.

```yaml
  labels:
      - traefik.enable=true
      ## HTTP Routers
      - traefik.http.routers.${SERVICE}-http.rule=Host(`${DOMAIN}`)
      - traefik.http.routers.${SERVICE}-http.entrypoints=web
      - traefik.http.routers.${SERVICE}-http.middlewares=http2https
      ## HTTPS Routers
      - traefik.http.routers.${SERVICE}.rule=Host(`${DOMAIN}`)
      - traefik.http.routers.${SERVICE}.entrypoints=webs
      - traefik.http.routers.${SERVICE}.tls.certresolver=leresolver
      - traefik.http.services.${SERVICE}.loadbalancer.server.port=
```

## local port 맵핑하는 방법

rules 폴더에 추가하면된다. `rules/test.yaml`

```yaml
################################################################
# local port
# custom url: https://example.local/
################################################################

http:
  routers:
    example:
      entryPoints:
        - webs
      service: hanaonethecar
      rule: Host(`example.local`)
      tls:
        certResolver: leresolver

  services:
    example:
      loadBalancer:
        servers:
          - url: http://192.168.1.34:3000
        passHostHeader: true
```

## 커스텀 상태페이지

docker-compose 구성에 nginx를 추가해서 nginx에서 커스텀 상태페이지를 추가할 수 있다.

```yaml
  middlewares:
    local-hxan-net-error:
      errors:
        status:
          - "400-499"
          - "500-599"
        service: "custom-status-page"
        query: "/505.html" # << 쿼리해서 가져올 페이지
```


## Swarm

using: docker swarm

다른점 deploy에서 lables를 정의함

```yaml
networks:
  proxy-main:
    driver: overlay
    name: proxy-main
```

위 처럼 docker-compose의 기본 네트워크를 `overlay`로 구성해줘야한다 (require)

또한 traefik.yaml에서 설정파일안에서 docker provider를 사용하는 해당 사용하는 설정을 아래와 같이 network 이름일 동일해야함

```yaml
providers:
  docker:
    watch: true
    endpoint: unix:///var/run/docker.sock
    exposedbydefault: false
    swarmMode: true
    network: proxy-main
    swarmModeRefreshSeconds: 5
```

## synology

synology 내부에서 사용한다하면 기본적으로 nginx 또는 apache때문에 80, 443포트를 사용하지 못해서 `docker-compose up` 할 수 없다.

```sh
sed -i "s/\( *listen .*\)81/\180/" /usr/syno/share/nginx/*.mustache
sed -i "s/\( *listen .*\)80/\181/" /usr/syno/share/nginx/*.mustache
sed -i "s/\( *listen .*\)444/\1443/" /usr/syno/share/nginx/*.mustache
sed -i "s/\( *listen .*\)443/\1444/" /usr/syno/share/nginx/*.mustache
```

이런식으로 바꿔주자.

- 80 -> 81
- 443 -> 444
