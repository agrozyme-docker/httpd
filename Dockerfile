FROM agrozyme/alpine:3.8
COPY docker /docker/

RUN set -ex \
  && chmod +x /docker/*.sh \
  && apk add --no-cache apache2 apache2-proxy apache2-http2 \
  # && apk add --no-cache apache2 apache2-proxy \
  && mkdir -p /run/apache2 /usr/local/etc/apache2 \
  && mv /var/www/localhost /var/www/html \
  && chown -R nobody:nobody /var/www/html \
  && ln -sf /dev/stdout /var/log/apache2/access.log \
  && ln -sf /dev/stderr /var/log/apache2/error.log \
  # && sed -ri \
  # -e 's!/var/www/localhost/htdocs!/var/www/html!g' \
  # /etc/apache2/conf.d/ssl.conf \
  && sed -ri \
  -e '$ a Protocols h2 h2c http/1.1' \
  /etc/apache2/conf.d/http2.conf \
  && sed -ri \
  -e 's!^#LoadModule mpm_event_module !LoadModule mpm_event_module !' \
  -e 's!^LoadModule mpm_prefork_module !#LoadModule mpm_prefork_module !' \
  -e 's!^#LoadModule slotmem_shm_module !LoadModule slotmem_shm_module !' \
  -e 's!^#LoadModule heartmonitor_module !LoadModule heartmonitor_module !' \
  -e 's!^User apache!User nobody!' \
  -e 's!^Group apache!Group nobody!' \
  -e 's!/var/www/localhost/htdocs!/var/www/html!g' \
  -e 's!/var/www/localhost!/var/www/html!g' \
  -e '/^#ServerName/a ServerName 127.0.0.1' \
  -e '$ a IncludeOptional /usr/local/etc/apache2/*.conf' \
  /etc/apache2/httpd.conf

WORKDIR /var/www
EXPOSE 80
CMD ["/docker/agrozyme.httpd.command.sh"]