FROM agrozyme/alpine:3.8

COPY docker-command.sh /usr/local/bin/

RUN set -x \
  && chmod +x /usr/local/bin/docker-command.sh \
  && addgroup -g 82 -S www-data \
  && adduser -u 82 -D -S -G www-data www-data \
  && apk add --no-cache apache2 apache2-proxy apache2-http2 \
  && mkdir -p /run/apache2 /usr/local/etc/apache2 \
  && mv /var/www/localhost /var/www/html \
  && chown -R www-data:www-data /var/www/html \
  && ln -sf /proc/self/fd/1 /var/log/apache2/access.log \
  && ln -sf /proc/self/fd/2 /var/log/apache2/error.log \
  && sed -ri \
  -e 's!^#LoadModule mpm_event_module !LoadModule mpm_event_module !' \
  -e 's!^LoadModule mpm_prefork_module !#LoadModule mpm_prefork_module !' \
  -e 's!^#LoadModule slotmem_shm_module !LoadModule slotmem_shm_module !' \
  -e 's!^User apache!User www-data!' \
  -e 's!^Group apache!Group www-data!' \
  -e 's!/var/www/localhost/htdocs!/var/www/html!g' \
  -e '/^#ServerName/a ServerName 127.0.0.1' \
  -e '$ a IncludeOptional /usr/local/etc/apache2/*.conf' \
  /etc/apache2/httpd.conf

WORKDIR /var/www
EXPOSE 80
CMD ["docker-command.sh"]