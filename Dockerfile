# FROM alpine:3.10 as build
FROM node:8.16.0-stretch as build

ENV HUGO_VERSION 0.55.6
ENV HUGO_BINARY hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
# ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz

WORKDIR /app
RUN set -x && \
    wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
    tar xzf ${HUGO_BINARY} && \
    rm -r ${HUGO_BINARY} && \
    mv hugo /usr/bin

COPY ./ /site

WORKDIR /site
# Change from runningit.se to localhost
# RUN cat config.toml|head -5 |sed 's/https:\/\/runningit.se/localhost/g' > config.toml

RUN git submodule update --init --recursive
# RUN npm install
# RUN npm run build
RUN hugo -t hugo-coder -d public

FROM nginx:alpine

COPY nginx_default.conf /etc/nginx/conf.d/default.conf

COPY --from=build /site/public /usr/share/nginx/html/

WORKDIR /usr/share/nginx/html/

