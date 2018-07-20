#!/bin/bash
set -euxo pipefail
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND
