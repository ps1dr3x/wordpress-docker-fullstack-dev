#!/bin/bash

# apache
if [ ! -f apache_configured ]; then
  echo "=> Apache is not configured yet, configuring Apache ..."
  echo "=> Setting ServerName"
  echo "ServerName localhost" >> /etc/apache2/conf-available/fqdn.conf
  a2enconf fqdn
  a2enmod rewrite
  a2enmod ssl
  a2enmod http2
  a2ensite 000-default
  a2ensite default-ssl
  touch apache_configured
else
  echo "=> Apache is already configured"
fi

# xdebug
if [ ! -f xdebug_configured ]; then
  echo "=> Xdebug is not configured yet, configuring Xdebug ..."
  echo "xdebug.remote_enable=1" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_port=$XDEBUG_PORT" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_autostart=true" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_handler=dbgp" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_connect_back=1" >> /etc/php/7.0/mods-available/xdebug.ini
  touch xdebug_configured
else
  echo "=> Xdebug is already configured"
fi

# openssl
if [ ! -f openssl_configured ]; then
  echo "=> Openssl is not configured yet, configuring Openssl ..."
  echo "openssl.cafile=\"/etc/ssl/certs/ssl-cert-snakeoil.pem\"" >> /etc/php/7.0/apache2/php.ini
  touch openssl_configured
else
  echo "=> Openssl is already configured"
fi

# wordpress
if [ ! -f wordpress_configured ]; then
  echo "=> WordPress is not configured yet, configuring WordPress ..."
  mv tmp/wp-config.php wordpress/wp-config.php
  touch wordpress_configured
else
  echo "=> WordPress is already configured"
fi

# url rewrites
if [ ! -e wordpress/.htaccess ]; then
  echo "=> .htaccess file does not exists, creating ..."
  cat > wordpress/.htaccess <<EOF
  # BEGIN WordPress
  <IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteCond %{HTTPS} off
  RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
  RewriteBase /
  RewriteRule ^index\.php$ - [L]
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule . /index.php [L]
  </IfModule>
  # END WordPress
EOF
  chown www-data:www-data wordpress/.htaccess -v
else
  echo "=> .htaccess file already exists"
fi
