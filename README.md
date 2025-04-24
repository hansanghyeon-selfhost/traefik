# traefik

## 사용법

```bash
make init
make start
```

## 적용하기

`traefik.yaml` 수정

```yaml
networks:
  traefik_proxy:
    external: true

services:
  __CHANGE_ME__:
    networks:
      - default
      - traefik_proxy
    labels:
      # traefik
      - traefik.enable=true
      - traefik.http.routers.${SERVICE}.entrypoints=web,webs
      - traefik.http.routers.${SERVICE}.rule=Host(`${DOMAIN}`)
      - traefik.http.services.${SERVICE}.loadbalancer.server.port=${APP_PORT}
      # - traefik.http.routers.${SERVICE}.service=${SERVICE}
      # - traefik.http.routers.${SERVICE}.middlewares=http2https@file
      # - traefik.http.routers.${SERVICE}.tls.certresolver=leresolver
```

## 레시피

### http redirect https

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

### multiple domain

```yaml
  labels:
      - traefik.enable=true
      # A DOMAIN
      - traefik.http.routers.${SERVICE}-A.rule=Host(`${DOMAIN}`)
      - traefik.http.routers.${SERVICE}-A.entrypoints=webs
      - traefik.http.routers.${SERVICE}-A.service=${SERVICE}-A
      - traefik.http.services.${SERVICE}-A.loadbalancer.server.port=${APP_PORT}
      # B DOMAIN
      - traefik.http.routers.${SERVICE}-B.rule=Host(`${DOMAIN}`)
      - traefik.http.routers.${SERVICE}-B.entrypoints=webs
      - traefik.http.routers.${SERVICE}-B.service=${SERVICE}-B
      - traefik.http.services.${SERVICE}-B.loadbalancer.server.port=${APP_PORT}
```


### local port 맵핑하는 방법

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

  services:
    example:
      loadBalancer:
        servers:
          - url: http://192.168.1.34:3000
        passHostHeader: true
```

### 커스텀 상태페이지

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


### Swarm

using: docker swarm

다른점 deploy에서 lables를 정의함

```yaml
networks:
  traefik_proxy:
    driver: overlay
    name: traefik_proxy
```

위 처럼 docker-compose의 기본 네트워크를 `overlay`로 구성해줘야한다 (require)

또한 traefik.yaml에서 설정파일안에서 docker provider를 사용하는 해당 사용하는 설정을 아래와 같이 network 이름일 동일해야함

```yaml
providers:
  docker:
    watch: true
    endpoint: unix:///var/run/docker.sock
    exposedByDefault: false
    network: traefik_proxy
    # swarm 모드 추가
    swarmMode: true
    swarmModeRefreshSeconds: 5
```

### synology

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

## internal, reinternal 진입점추가

- internal - https로 리다이렉트가 자동적으로 이루어지지 않은 internal 진입점이다.
- reinternal - https로 리다리렉트가 자동적으러 이루어지는 internal 진입점이다.

reinternal 진입점을 제일 많이사용하고 internal 도메인의 경우 404페이지에서 디버깅을 할 수 있도록 whoami를 에러페이지로 표시하도록 설정하였다.
