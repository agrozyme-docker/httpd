#!/usr/bin/lua
local core = require("docker-core")

local function update_http2()
  core.append_file("/etc/apache2/conf.d/http2.conf", "Protocols h2 h2c http/1.1 \n")
end

local function update_proxy()
  local pcre = require("rex_pcre")
  local file = "/etc/apache2/conf.d/proxy.conf"
  local text = core.read_file(file)
  text = pcre.gsub(text, [[^[#\s]*(LoadModule[\s]+.*)$]], "# %1", nil, "im")
  core.write_file(file, text)
end

local function update_httpd()
  local pcre = require("rex_pcre")
  local file = "/etc/apache2/httpd.conf"
  local text = core.read_file(file)
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
  core.write_file(file, text)
  core.append_file(file, "IncludeOptional /usr/local/etc/apache2/*.conf \n")
end

local function replace_setting()
  if (core.has_modules("rex_pcre")) then
    update_http2()
    update_proxy()
    update_httpd()
  else
    core.replace_files("/etc/apache2/httpd.conf", "/etc/apache2/conf.d/http2.conf", "/etc/apache2/conf.d/proxy.conf")
  end
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
