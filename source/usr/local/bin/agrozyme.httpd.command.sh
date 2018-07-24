#!/bin/bash
set -euxo pipefail
docker-core.sh
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
