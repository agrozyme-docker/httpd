#!/bin/bash
set -euo pipefail

function main() {
  docker-core.sh change_core
  rm -f /run/apache2/httpd.pid
  exec httpd -DFOREGROUND
}

main "$@"
