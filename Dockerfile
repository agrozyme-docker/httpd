FROM agrozyme/alpine:3.8
COPY source /

RUN set -euxo pipefail \
  && chmod +x /usr/local/bin/*.sh \
  && apk add --no-cache apache2 apache2-proxy apache2-http2 \
  && mkdir -p /run/apache2 /usr/local/etc/apache2 \
  && mv /var/www/localhost/htdocs /var/www/html \
  && mv /var/www/localhost/cgi-bin /var/www/cgi-bin \
  && chown -R core:core /var/www/html /var/www/cgi-bin \
  && ln -sf /dev/stdout /var/log/apache2/access.log \
  && ln -sf /dev/stderr /var/log/apache2/error.log \
  && sed -ri -e '$ a Protocols h2 h2c http/1.1' /etc/apache2/conf.d/http2.conf \
  && sed -ri \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(.*)$/#\1 \2 /i' \
  /etc/apache2/conf.d/proxy.conf \
  && sed -ri \
  -e 's/^(#LoadModule)[[:space:]]+(negotiation_module)[[:space:]]+(.*)$//i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(.*)$/#\1 \2 /i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(mpm_event_module)[[:space:]]+(.*)$/\1 \2 \3 /i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(authz_core_module)[[:space:]]+(.*)$/\1 \2 \3 /i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(mime_module)[[:space:]]+(.*)$/\1 \2 \3 /i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(negotiation_module)[[:space:]]+(.*)$/\1 \2 \3 /i' \
  -e 's/^[#[:space:]]*(LoadModule)[[:space:]]+(unixd_module)[[:space:]]+(.*)$/\1 \2 \3 /i' \
  -e 's/^[#[:space:]]*(User)[[:space:]]+.*$/\1 core/i' \
  -e 's/^[#[:space:]]*(Group)[[:space:]]+.*$/\1 core/i' \
  -e 's/^[#[:space:]]*(ServerName)[[:space:]]+[0-9a-z.:]+$/\1 127.0.0.1 /i' \
  -e 's!/(www.example.com)/!/127.0.0.1/!i' \
  -e 's![[:space:]]+"(/var/www/localhost/htdocs)(/?)"! "/var/www/html\2"!i' \
  -e 's![[:space:]]+"(/var/www/localhost/cgi-bin)(/?)"! "/var/www/cgi-bin\2"!i' \
  -e '$ a IncludeOptional /usr/local/etc/apache2/*.conf' \
  /etc/apache2/httpd.conf

WORKDIR /var/www
EXPOSE 80
CMD ["agrozyme.httpd.command.sh"]
