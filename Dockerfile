FROM php:8.3-apache

# Installer dépendances système + extensions PHP utiles
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
    && docker-php-ext-install pdo pdo_mysql intl zip \
    && rm -rf /var/lib/apt/lists/*

# Activer mod_rewrite pour Symfony
RUN a2enmod rewrite

# Installer Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copier le projet Symfony
WORKDIR /var/www/html
COPY . .

# Installer les dépendances Symfony (mode prod)
RUN composer install --no-dev --optimize-autoloader

# Donner les droits d'accès aux dossiers var/cache et var/log
RUN chown -R www-data:www-data /var/www/html/var

EXPOSE 80