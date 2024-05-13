#! /bin/bash
set -xe
sudo docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} ${CI_REGISTRY}
sudo docker network create -d bridge sausage_network || true
sudo docker rm -f sausage-frontend || true
sudo docker run -d --name sausage-frontend \
     --network=sausage_network \
     -p 8080:80 \
     --restart=on-failure:10 \
     -v ${NGINX_CONF}:/etc/nginx/conf.d/default.conf \
     "${CI_REGISTRY_IMAGE}"/sausage-frontend:${VERSION}