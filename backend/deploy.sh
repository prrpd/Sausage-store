#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf back.service /etc/systemd/system/back.service
sudo cp -rf sausage-store-backend /etc/default/sausage-store-backend
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
             -alias yandex-$RANDOM \
             -cacerts \
             -storepass ${KEYSTORE_PASS} \
             -noprompt

#Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload
#Перезапускаем сервис сосисочной
sudo systemctl restart back.service