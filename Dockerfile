FROM debian:latest
LABEL authors="Michele Federici (@ps1dr3x) <michele@federici.tech>, Giovanni Contino (@micene09) <giovanni.contino09@gmail.com>"

# Args and env vars
ARG HTTP_AUTH_ENABLED
ARG HTTP_AUTH_USER
ARG HTTP_AUTH_PASSWORD
ARG WORDPRESS_VERSION
ARG WORDPRESS_SHA1
ARG XDEBUG_PORT
ARG WPCLI_VERSION
ARG WPCLI_SHA1
ARG PHPUNIT_VERSION
ARG PHPUNIT_SHA1
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
COPY configs/000-default.conf /etc/apache2/sites-available/000-default.conf
COPY configs/default-ssl.conf /etc/apache2/sites-available/default-ssl.conf

# Http auth
RUN if [ "${HTTP_AUTH_ENABLED}" = "true" ]; then \
      htpasswd -bc /etc/apache2/.htpasswd ${HTTP_AUTH_USER} ${HTTP_AUTH_PASSWORD} && \
      echo "=> Http auth enabled"; \
    else \
      sed -i 's/AuthName/#AuthName/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/AuthType/#AuthType/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/AuthUserFile/#AuthUserFile/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/Require/#Require/g' /etc/apache2/sites-available/000-default.conf && \
      sed -i 's/AuthName/#AuthName/g' /etc/apache2/sites-available/default-ssl.conf && \
      sed -i 's/AuthType/#AuthType/g' /etc/apache2/sites-available/default-ssl.conf && \
      sed -i 's/AuthUserFile/#AuthUserFile/g' /etc/apache2/sites-available/default-ssl.conf && \
      sed -i 's/Require/#Require/g' /etc/apache2/sites-available/default-ssl.conf && \
      echo "=> Http auth not enabled"; \
    fi

# WordPress Configs
RUN mkdir wordpress && \
    mkdir tmp
COPY configs/wp-config.php tmp/wp-config.php

# WordPress CLI
RUN curl -L "https://github.com/wp-cli/wp-cli/releases/download/v${WPCLI_VERSION}/wp-cli-${WPCLI_VERSION}.phar" > /usr/bin/wp && \
  echo $WPCLI_SHA1 /usr/bin/wp | sha1sum -c - && \
  chmod +x /usr/bin/wp

# PHPUnit
RUN curl -L "https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar" > /usr/bin/phpunit && \
  echo $PHPUNIT_SHA1 /usr/bin/phpunit | sha1sum -c - && \
  chmod +x /usr/bin/phpunit

# Xdebug port
EXPOSE $XDEBUG_PORT

# Config/Run scripts
COPY scripts/install.sh install.sh
COPY scripts/configure.sh configure.sh
COPY scripts/run.sh run.sh
# Permissions and line endings conversion (compatibility)
RUN chmod 755 install.sh configure.sh run.sh && \
  dos2unix install.sh configure.sh run.sh

# Let's go
CMD ["./run.sh"]
