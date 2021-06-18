FROM php:7.4-apache

RUN apt-get update 
RUN apt-get install --no-install-recommends -y \
    git \
    libzmq3-dev \
    libicu-dev \
    libzip-dev \
    cron \
    supervisor \
    mariadb-client \
    zip \
    unzip

RUN \
    # pull php-zmq extension -- the PECL version does not compile...
    git clone git://github.com/mkoppanen/php-zmq.git \
    && cd php-zmq \
    && phpize && ./configure \
    && make \
    && make install \
    && cd .. \
    && rm -fr php-zmq \
    # configure/enable extensions
    && docker-php-ext-enable zmq \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure pdo_mysql \
    && docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure zip \
    && docker-php-ext-install zip

# install node and yarn
RUN \
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn

RUN rm /etc/apache2/sites-available/*.conf

COPY config/apache/super-potato.conf /etc/apache2/sites-available/00-super-potato.conf
COPY config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY scripts/run.sh /container/scripts/run.sh
COPY config/cron/super-potato /etc/cron.d/super-potato
RUN chmod 500 /container/scripts/run.sh \
    && mkdir -p /container/io \
    && mkfifo /container/io/stdout \
    && mkfifo /container/io/stderr \
    && chown www-data:www-data /container/io/stdout /container/io/stderr

RUN a2ensite 00-super-potato && a2enmod proxy && a2enmod rewrite && a2enmod headers && a2enmod proxy_wstunnel

RUN \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv composer.phar /usr/local/bin/composer

COPY ./super-potato /var/www/html/super-potato

RUN chown -R www-data:www-data /var/www

WORKDIR /var/www/html/super-potato

# set up composer
USER www-data
RUN composer install --no-dev
RUN yarn install --frozen-lock && yarn prod

USER root
CMD ["/container/scripts/run.sh"]
