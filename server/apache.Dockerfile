FROM php:7.2-apache

USER root

ADD ./my-httpd.conf /etc/apache2/conf-available/
ADD ./web-project.conf /etc/apache2/sites-available/
ADD ./my-php.ini /usr/local/etc/php/

RUN curl https://drupalconsole.com/installer -L -o drupal.phar
RUN mv drupal.phar /usr/local/bin/drupal
RUN chmod +x /usr/local/bin/drupal

RUN pecl install xdebug-2.6.1 && docker-php-ext-enable xdebug

# install the PHP extensions we need
RUN apt-get update && apt-get install -y libpng12-dev libjpeg-dev libpq-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mbstring pdo pdo_mysql pdo_pgsql zip
RUN apt-get install -y vim
RUN apt-get install -y git

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=bin
RUN php -r "unlink('composer-setup.php');"

RUN echo 'zend_extension="/usr/local/lib/php/extensions/no-debug-non-zts-20151012/xdebug.so"' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_port=9000' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_enable=1' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.remote_connect_back=1' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.show_exception_trace = 0' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.collect_params = ?' >> /usr/local/etc/php/php.ini
RUN echo 'xdebug.max_nesting_level = 256' >> /usr/local/etc/php/php.ini

RUN echo 'sendmail_path = /usr/bin/env catchmail -f project@project.fr' >> /usr/local/etc/php/php.ini

EXPOSE 80