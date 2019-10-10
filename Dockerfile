FROM nginx:1.17.4-alpine

ENV VERSION 0.58.3
RUN apk add --no-cache git openssl py-pygments curl
RUN curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz | tar -xz
RUN mv hugo /usr/bin/hugo
RUN apk del curl

COPY . /app

RUN cd /app/site && hugo 

COPY /app/site/public /usr/share/nginx/html

