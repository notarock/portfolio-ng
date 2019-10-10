FROM nginx:1.17.4-alpine


ENV VERSION 0.58.3
RUN apk add --no-cache git openssl py-pygments curl \
	&& curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_Linux-64bit.tar.gz | tar -xz \	
	&& mv hugo /usr/bin/hugo \
	&& apk del curl

WORKDIR /app

COPY . .

RUN cd site && hugo -d /usr/share/nginx/html

