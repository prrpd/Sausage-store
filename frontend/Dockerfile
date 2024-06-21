FROM mirror.gcr.io/node:16.20.0-alpine3.18 as builder
WORKDIR /usr/src/app
COPY ./e2e ./e2e
COPY ./src ./src
COPY *.json ./
RUN npm install \
    && npm run build

# шаг релиза
FROM mirror.gcr.io/nginx:stable-alpine-slim
WORKDIR /app
COPY --from=builder /usr/src/app/dist/frontend /usr/share/nginx/html/