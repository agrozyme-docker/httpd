#!/usr/bin/lua
local core = require("docker-core")

local function update_http2(target, items)
  core.append_file(target, "Protocols h2 h2c http/1.1 \n")
end

local function update_proxy(target, items)
  local pcre = items.pcre
  local text = core.read_file(target)
  text = pcre.gsub(text, [[^[#\s]*(LoadModule[\s]+.*)$]], "# %1", nil, "im")
  core.write_file(target, text)
end

local function update_httpd(target, items)
  local pcre = items.pcre
  local text = core.read_file(target)
  text = pcre.gsub(text, [[^#LoadModule[\s]+negotiation_module[\s]+.*$]], "", nil, "im")
  text = pcre.gsub(text, [[^[#\s]*(LoadModule[\s]+.*)$]], "# %1", nil, "im")
  text =
    pcre.gsub(
    text,
    [[^[#\s]*(LoadModule)[\s]+(mpm_event|authz_core|mime|negotiation|unixd)(_module[\s]+.*)$]],
    "%1 %2%3",
    nil,
    "im"
  )
  text = pcre.gsub(text, [[^[#\s]*(User|Group)[\s]+.*$]], "%1 core", nil, "im")
  text = pcre.gsub(text, [[^[#\s]*(ServerName)[\s]+[.:\w]+$]], "%1 127.0.0.1", nil, "im")
  text = pcre.gsub(text, [[([\s]+"/var/www/)localhost/htdocs(/?")]], "%1html%2", nil, "im")
  text = pcre.gsub(text, [[([\s]+"/var/www/)localhost/(cgi-bin/?")]], "%1%2", nil, "im")
  core.write_file(target, text)
  core.append_file(target, "IncludeOptional /usr/local/etc/apache2/*.conf \n")
end

local function replace_setting()
  local requires = {pcre = "rex_pcre"}
  local updates = {
    ["/etc/apache2/httpd.conf"] = update_httpd,
    ["/etc/apache2/conf.d/http2.conf"] = update_http2,
    ["/etc/apache2/conf.d/proxy.conf"] = update_proxy
  }
  core.replace_files(requires, updates)
end

local function main()
  -- core.run("apk add --no-cache lua-rex-pcre")
  core.run("apk add --no-cache apache2 apache2-proxy apache2-http2")
  core.run("mkdir -p /usr/local/etc/apache2")
  core.run("mv /var/www/localhost/* /var/www/")
  core.run("mv /var/www/htdocs /var/www/html")
  core.run("rm -rf /var/www/localhost")
  core.link_log("/var/log/apache2/access.log", "/var/log/apache2/error.log")
  replace_setting()
end

main()
