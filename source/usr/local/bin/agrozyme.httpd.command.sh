#!/bin/bash
set -euo pipefail

function main() {
  agrozyme.alpine.function.sh change_core
  agrozyme.alpine.function.sh empty_folder /run/apache2
  chown -R core:core /var/www/cgi-bin /var/www/html
  exec httpd -DFOREGROUND
}

main "$@"
