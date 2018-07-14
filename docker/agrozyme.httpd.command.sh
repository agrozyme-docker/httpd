#!/bin/sh
set -ex
rm -f /run/apache2/httpd.pid
exec httpd -DFOREGROUND