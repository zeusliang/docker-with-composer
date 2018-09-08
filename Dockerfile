FROM php:7.2.8-apache

# add pkg sources
COPY $PWD/sources.list /etc/apt/sources.list

# update and install git
RUN set -e && \
    apt-get -y update && \
    apt-get -y install git && \
    apt-get -y install zip unzip


COPY php.ini /usr/local/etc/php

# load rewrite mod
RUN ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/sites-enable/rewrite.load

# install composer and cunstome
RUN set -e && \
    cd /var/www/html && \
    curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com && \
    composer create-project --prefer-dist laravel/laravel laravel && \
    composer create-project --prefer-dist topthink/think tp5 && \
    composer create-project --prefer-dist yiisoft/yii2-app-basic basic && \
    chown -R www-data tp5 && chgrp -R www-data tp5 && \
    chmod -R 775 tp5 && \
    chown -R www-data laravel && chgrp -R www-data laravel && \
    chmod -R 775 laravel && \
    chmown -R www-data basic && chgrp -R www-data basic && \
    chmod -R 775 basic


# install php extend
RUN set -e && \
    docker-php-source extract && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-enable pdo_mysql && \
    docker-php-source delete

# install gd
RUN apt-get -y install libjpeg-dev libpng-dev libfreetype6-dev && \
    docker-php-source extract \
    && docker-php-ext-configure gd  --with-gd \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd \
    && docker-php-source delete
