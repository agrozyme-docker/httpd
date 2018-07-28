#!/bin/bash
set -euo pipefail

function main() {
  agrozyme.alpine.function.sh change_core
  chown -R core:core /run/apache2 /var/www/html /var/www/cgi-bin
  rm -f /run/apache2/httpd.pid
  exec httpd -DFOREGROUND
}

main "$@"
