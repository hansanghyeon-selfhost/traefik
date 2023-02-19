certs:
	cd ./traefik/certs && rm -r *.pem
	cd ./traefik/certs && mkcert -key-file localhost.pem -cert-file localhost.pem librespeed.local
	mkcert -install
	
synology:
	HTTP_PORT=80
	HTTP_PATCH_PORT=81
	HTTPS_PORT=443
	HTTPS_PATCH_PORT=444

	sed -i "s/^\( *listen .*\)$HTTP_PATCH_PORT/\1$HTTP_PORT/" /usr/syno/share/nginx/*.mustache
	sed -i "s/^\( *listen .*\)$HTTP_PORT/\1$HTTP_PATCH_PORT/" /usr/syno/share/nginx/*.mustache
	sed -i "s/^\( *listen .*\)$HTTPS_PATCH_PORT/\1$HTTPS_PORT/" /usr/syno/share/nginx/*.mustache
	sed -i "s/^\( *listen .*\)$HTTPS_PORT/\1$HTTPS_PATCH_PORT/" /usr/syno/share/nginx/*.mustache
