FROM debian:latest
MAINTAINER Michele Federici (@ps1dr3x) <michele@federici.tech>

# Args and env vars
ARG HTTP_AUTH_ENABLED
ARG HTTP_AUTH_USER
ARG HTTP_AUTH_PASSWORD
ARG WORDPRESS_VERSION
ARG WORDPRESS_SHA1
ARG XDEBUG_PORT
ARG WPCLI_VERSION
ARG PHPUNIT_VERSION
ENV WORDPRESS_VERSION ${WORDPRESS_VERSION}
ENV WORDPRESS_SHA1 ${WORDPRESS_SHA1}
ENV XDEBUG_PORT ${XDEBUG_PORT}

# Working dir
WORKDIR /var/www/html

# Repository update, installation of needed/common packages, cleanup
RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get -y install curl net-tools ssl-cert nano vim tmux dos2unix less apache2 apache2-utils libapache2-mod-php php php-mysql php-xdebug php-curl php-mbstring unzip composer mariadb-client && \
    apt-get clean && \
    rm -rf index.html /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Apache sites conf
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Http auth
RUN if [ "${HTTP_AUTH_ENABLED}" = "true" ]; then \
      htpasswd -bc /etc/apache2/.htpasswd ${HTTP_AUTH_USER} ${HTTP_AUTH_PASSWORD} && \
      echo "=> Http auth enabled"; \
    else \
      sed -i 's/AuthType/#AuthType/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/AuthName/#AuthName/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/AuthUserFile/#AuthUserFile/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/Require/#Require/g' /etc/apache2/sites-available/000-default.conf && \
      echo "=> Http auth not enabled"; \
    fi

# WordPress Configs
RUN mkdir wordpress && \
    mkdir tmp
COPY wp-config.php tmp/wp-config.php

# WordPress CLI
RUN curl -L "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar" > /usr/bin/wp && \
  chmod +x /usr/bin/wp

# PHPUnit
RUN curl -L "https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar" > /usr/bin/phpunit && \
  chmod +x /usr/bin/phpunit

# Xdebug port
EXPOSE ${XDEBUG_PORT}

# Config/Run scripts
COPY install.sh install.sh
COPY configure.sh configure.sh
COPY run.sh run.sh
RUN chmod 755 install.sh configure.sh run.sh
# Convert text files with DOS or Mac line endings to Unix line endings
RUN dos2unix install.sh configure.sh run.sh

# Let's go
CMD ["./run.sh"]
