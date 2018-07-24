FROM agrozyme/alpine:3.8
COPY source /

RUN set -euxo pipefail \
  && chmod +x /usr/local/bin/*.sh \
  && apk add --no-cache apache2 apache2-proxy apache2-http2 \
  && mkdir -p /run/apache2 /usr/local/etc/apache2 \
  && mv /var/www/localhost /var/www/html \
  && chown -R core:core /var/www/html \
  && ln -sf /dev/stdout /var/log/apache2/access.log \
  && ln -sf /dev/stderr /var/log/apache2/error.log \
  && sed -ri -e '$ a Protocols h2 h2c http/1.1' /etc/apache2/conf.d/http2.conf \
  && sed -ri \
  -e 's!^#LoadModule mpm_event_module !LoadModule mpm_event_module !' \
  -e 's!^LoadModule mpm_prefork_module !#LoadModule mpm_prefork_module !' \
  -e 's!^#LoadModule slotmem_shm_module !LoadModule slotmem_shm_module !' \
  -e 's!^#LoadModule heartmonitor_module !LoadModule heartmonitor_module !' \
  -e 's!^User apache!User core!' \
  -e 's!^Group apache!Group core!' \
  -e 's!/var/www/localhost/htdocs!/var/www/html!g' \
  -e 's!/var/www/localhost!/var/www/html!g' \
  -e '/^#ServerName/a ServerName 127.0.0.1' \
  -e '$ a IncludeOptional /usr/local/etc/apache2/*.conf' \
  /etc/apache2/httpd.conf

WORKDIR /var/www
EXPOSE 80
CMD ["agrozyme.httpd.command.sh"]