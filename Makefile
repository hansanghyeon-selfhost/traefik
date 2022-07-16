include .env
export

certs:
	cd ./traefik/certs && rm -r *.pem
	cd ./traefik/certs && mkcert -key-file localhost.pem -cert-file localhost.pem librespeed.local
	mkcert -install