#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf back.service /etc/systemd/system/back.service
sudo rm -f /opt/sausage-store/bin/sausage-store.jar||true
#Переносим артефакт в нужную папку
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o sausage-store.jar ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_BACKEND_NAME}/com/yandex/practicum/devops/sausage-store/${VERSION}/sausage-store-${VERSION}.jar
sudo cp ./sausage-store.jar /opt/sausage-store/bin/sausage-store.jar||true #"<...>||true" говорит, если команда обвалится — продолжай
sudo chown -R backend:backend /opt/sausage-store/bin/

#postgres
sudo mkdir -p /home/backend/.postgresql && \
sudo wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O /home/backend/.postgresql/root.crt && \
sudo chmod 0600 /home/backend/.postgresql/root.crt
#mongo
sudo wget "https://storage.yandexcloud.net/cloud-certs/CA.pem" -O YandexInternalRootCA.crt
sudo keytool -importcert \
             -file YandexInternalRootCA.crt \
             -alias yandex \
             -cacerts \
             -storepass changeit \
             -noprompt

#setting env variable to env file
sudo bash -c "echo "PSQL_USER=${PSQL_USER}" > /etc/default/sausage-store-backend"
sudo bash -c "echo "PSQL_PASSWORD=${PSQL_PASSWORD}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "PSQL_HOST=${PSQL_HOST}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "PSQL_DBNAME=${PSQL_DBNAME}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "PSQL_PORT=${PSQL_PORT}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "SPRING_DATASOURCE_URL=${SPRING_DATASOURCE_URL}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "SPRING_DATASOURCE_USERNAME=${PSQL_USER}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "SPRING_DATASOURCE_PASSWORD=${PSQL_PASSWORD}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "MONGO_USER=${MONGO_USER}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "MONGO_PASSWORD=${MONGO_PASSWORD}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "MONGO_HOST=${MONGO_HOST}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "MONGO_DATABASE=${MONGO_DATABASE}" >> /etc/default/sausage-store-backend"
sudo bash -c "echo "SPRING_DATA_MONGODB_URI=${SPRING_DATA_MONGODB_URI}" >> /etc/default/sausage-store-backend"

#Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload
#Перезапускаем сервис сосисочной
sudo systemctl restart back.service