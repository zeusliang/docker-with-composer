FROM php:7.2.11-apache-stretch

# add pkg sources
COPY $PWD/sources.list /etc/apt/sources.list

# set php.ini
COPY php.ini /usr/local/etc/php

# config apache vhosts
COPY mapp.conf /etc/apache2/sites-enabled/

RUN mv /etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf.bk && \ 
    ln -s /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/ 

ENV PHP_TOOLS \
    git  \
    zip \
    unzip \   
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libmemcached-dev \
    zlib1g-dev 

RUN apt-get update && apt-get install -y \
    $PHP_TOOLS \
    --no-install-recommends && rm -r /var/lib/apt/lists/* && \
    docker-php-source extract && \
    docker-php-ext-configure pdo_mysql --with-pdo-mysql=mysqlnd && \
    docker-php-ext-configure gd  --with-gd \
    --with-freetype-dir \
    --with-jpeg-dir \
    --with-png-dir \
    --with-zlib-dir && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-enable gd pdo_mysql && \
    docker-php-source delete && \
    curl -O  https://pecl.php.net/get/redis-4.1.1.tgz && \
    curl -O  https://pecl.php.net/get/memcached-3.0.4.tgz && \
    tar xf redis-4.1.1.tgz && tar xf memcached-3.0.4.tgz && \
    cd redis-4.1.1 && \
    phpize && ./configure && make && make install && \
    cd ../memcached-3.0.4 && \
    phpize && \
    ./configure && make && make install && \
    docker-php-ext-enable redis memcached && \
    curl -O  https://getcomposer.org/download/1.7.2/composer.phar && \
    mv composer.phar /usr/bin/composer && \
    chmod +x /usr/bin/composer && \
    rm -rf /var/www/html/memcached-3.0.4 /var/www/html/redis-4.1.1
