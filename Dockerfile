FROM agrozyme/alpine:3.8
COPY rootfs /
RUN set +e -uxo pipefail && lua /usr/local/bin/build/httpd.lua
WORKDIR /var/www
EXPOSE 80
CMD ["/usr/local/bin/httpd.lua"]
