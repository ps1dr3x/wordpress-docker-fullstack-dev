#!/bin/bash

# WordPress
if [ ! -f wordpress_installed ]; then
  echo "=> WordPress is not installed yet, installing WordPress ..."
  curl -o wordpress.tar.gz -fSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" && \
  echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - && \
  tar -xzf wordpress.tar.gz -C wordpress --strip-components=1 && \
  rm wordpress.tar.gz && \
  chown -R www-data:www-data ./
  touch wordpress_installed
else
  echo "=> WordPress is already installed"
fi
