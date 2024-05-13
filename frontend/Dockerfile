FROM node:16.20.0-alpine3.18 as builder
ARG VERSION=${VERSION}
WORKDIR /usr/src/app
COPY ./e2e ./e2e
COPY ./src ./src
COPY *.json ./
RUN npm install \
    && npm run build

# шаг релиза
FROM nginx:stable-alpine3.17-slim
ARG VERSION=${VERSION}
WORKDIR /app
COPY --from=builder /usr/src/app/dist/frontend ./frontend/
COPY default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]