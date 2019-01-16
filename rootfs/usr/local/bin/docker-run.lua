#!/usr/bin/lua

local function main()
  local core = require("docker-core")
  core.update_user()
  core.clear_path("/run/apache2")
  core.chown("/var/www/cgi-bin", "/var/www/html")
  core.run("httpd -DFOREGROUND")
end

main()
