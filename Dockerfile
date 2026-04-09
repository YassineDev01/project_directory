FROM php:8.3-apache
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
 && docker-php-ext-install pdo pdo_mysql intl zip \
 && rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/var
EXPOSE 80