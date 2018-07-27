#!/bin/bash
set -euo pipefail

function main() {
  agrozyme.alpine.function.sh change_core
  rm -f /run/apache2/httpd.pid
  exec httpd -DFOREGROUND
}

main "$@"
