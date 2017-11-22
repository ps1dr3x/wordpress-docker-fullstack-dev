# wordpress-docker-fullstack-dev
Full Docker Compose development stack for Wordpress

### **Services**:

**wordpress-dev**
- Custom image with:
    - Debian (base image)
    - Apache (SSL and optional http auth)
    - PHP7
    - Xdebug
    - PHPunit
    - WordPress
    - WP-CLI
- Container name: wordpress-dev


**mariadb-dev**
- MariaDB official image
- Container name: mariadb-dev

**phpmyadmin-dev**
- phpMyAdmin official image
- Container name: phpmyadmin-dev

------

### **Instructions**:

 - Set ENVs in .env file:
    - MYSQL_ROOT_PASSWORD
    - MYSQL_USER
    - MYSQL_PASSWORD
    - MYSQL_DATABASE
    - Eventually enable http auth by setting HTTP_AUTH_ENABLED (to 'true'), HTTP_AUTH_USER and HTTP_AUTH_PASSWORD
    - Eventually change WORDPRESS_VERSION, WORDPRESS_SHA1, WPCLI_VERSION, PHPUNIT_VERSION and XDEBUG_PORT
 - Set DB_NAME, DB_USER, DB_PASSWORD and random Authentication Unique Keys (https://api.wordpress.org/secret-key/1.1/salt/) in wp-config.php
 - `sudo docker-compose up`

Wordpress will be available on localhost

phpMyAdmin will be available on localhost:8090

All the wordpress directory in the container's volume will be locally binded at ./wordpress

------