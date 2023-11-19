init:
	docker network create traefik_proxy

start:
	docker compose up -d
