#! /bin/bash
#Если свалится одна из команд, рухнет и весь скрипт
set -xe
#Перезаливаем дескриптор сервиса на ВМ для деплоя
sudo cp -rf front.service /etc/systemd/system/front.service
sudo rm -rf /opt/sausage-store/static/*||true
#Переносим артефакт в нужную папку
curl -u ${NEXUS_REPO_USER}:${NEXUS_REPO_PASS} -o front.tar.gz ${NEXUS_REPO_URL}/repository/${NEXUS_REPO_FRONTEND_NAME}/${VERSION}/sausage-store-${VERSION}.tar.gz
sudo tar -xvzf front.tar.gz
sudo mv -f frontend/* /opt/sausage-store/static/||true #"<...>||true" говорит, если команда обвалится — продолжай
sudo chown -R frontend:frontend /opt/sausage-store/static/
#Обновляем конфиг systemd с помощью рестарта
sudo systemctl daemon-reload
#Перезапускаем сервис сосисочной
sudo systemctl restart front.service