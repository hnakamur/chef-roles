override_attributes({
  :iptables => {
    :accept_lines => <<'EOS'
-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
EOS
  },
  :nginx => {
    :start_server => false,
    :default_server_configs => <<'EOS'
location / {
    root   /var/www/html/_default/htdocs;
    index  index.html index.htm;

    satisfy any;
    auth_basic_user_file /var/www/html/_default/.htpasswd;
    auth_basic "Authentication Required";
    include conf/allow_common_ip.conf;
    deny all;
}

include conf/nagios.conf;

#error_page  404              /404.html;

# redirect server error pages to the static page /50x.html
#
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root   /usr/share/nginx/html;
}
EOS
  }
})

run_list [
  "role[base]",
  "iptables",
  "fcgiwrap",
  "nginx",
  "php",
  "nagios",
  "nagios_plugins",
  "nagios_nrpe",
  "start-nginx"
]
