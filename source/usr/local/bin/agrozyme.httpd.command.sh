#!/bin/bash
set -euo pipefail
docker-core.sh
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
