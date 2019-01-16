FROM agrozyme/alpine:3.8
COPY rootfs /
RUN set +e -uxo pipefail && chmod +x /usr/local/bin/* && /usr/local/bin/docker-build.lua
WORKDIR /var/www
EXPOSE 80
CMD ["/usr/local/bin/httpd.lua"]
