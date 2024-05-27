FROM python:latest
ADD app /app
WORKDIR /app
RUN wget -O  YandexInternalRootCA.crt https://storage.yandexcloud.net/cloud-certs/CA.pem \
    && cp YandexInternalRootCA.crt /usr/local/share/ca-certificates/rootCA.crt \
    && pip install -r requirements.txt
ENTRYPOINT ["python"]
CMD ["app.py"]
EXPOSE 8080