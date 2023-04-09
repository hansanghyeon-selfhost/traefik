## makefile

```bash
make net
```

traefik이 사용할 traefik_proxy 네트워크를 만들어준다.

```bash
make synology
```

synology에서 80, 443 포트를 사용하고있을때 기본 포트를 변경한다.

```bash
make cert
```

let's encry를 사용하지 않고 로컬 cert 파일을 만들기

## post

home lab에서 traefik을 구성하면서 쓴 글

https://hyeon.pro/dev/tag/traefik

using: docker compose

가장 기본적으로 사용하는 docker-compose

```yaml
version: "3.8"

########################### SERVICES
services:
  traefik:
    image: traefik:v2.4
    container_name: DO__traefik
    restart: unless-stopped
    ports:
      - target: 80
        published: 80
        protocol: tcp
        mode: host
      - target: 443
        published: 443
        protocol: tcp
        mode: host
      - target: 8080
        published: 8080
        protocol: tcp
        mode: host
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - ./traefik/rules:/rules
      - ./traefik/acme:/acme
      - ./traefik/traefik.yaml:/etc/traefik/traefik.yaml
    labels:
      - traefik.enable=true
      ## HTTP Routers
      - traefik.http.routers.svc__traefik.rule=Host(`traefik.${DOMAINNAME}`)
      - traefik.http.routers.svc__traefik.entrypoints=web
      # - traefik.http.routers.svc__traefik.entrypoints=websecure
      # - traefik.http.routers.svc__traefik.tls.certresolver=leresolver
      ## Service
      - traefik.http.services.svc__traefik.loadbalancer.server.port=8080
```

## Traefik hub (experimental)

여러곳에서 사용중인 traefik을 관리하기 용이해졌다.


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

자세한 내용은 [traefik swarm 모드 설정 | 개발자 상현에 하루하루](https://hyeon.pro/dev/traefik-swarm-mode-set/) 참고

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
        - websecure
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
