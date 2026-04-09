FROM php:8.3-apache

# # Installer dépendances système et extensions PHP
# RUN apt-get update && apt-get install -y \
#     libicu-dev libzip-dev unzip git \
#  && docker-php-ext-install pdo pdo_mysql intl zip \
#  && rm -rf /var/lib/apt/lists/*

# # Activer mod_rewrite pour Symfony
# RUN a2enmod rewrite

# # Copier Composer
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# # Définir le répertoire de travail
# WORKDIR /var/www/html

# # Copier uniquement les fichiers nécessaires pour Composer (optimisation du cache)
# COPY composer.json composer.lock ./

# # Installer les dépendances PHP sans utiliser root
# RUN composer install --no-dev --optimize-autoloader --no-interaction 

# # Copier le reste du projet
# COPY . .

# # Permissions correctes pour Apache/Symfony
# RUN chown -R www-data:www-data /var/www/html/var /var/www/html/vendor

# # Exposer le port Apache
# EXPOSE 80

# FROM php:8.3-apache
RUN apt-get update && apt-get install -y \
    libicu-dev libzip-dev unzip git \
 && docker-php-ext-install pdo pdo_mysql intl zip \
 && rm -rf /var/lib/apt/lists/*
RUN a2enmod rewrite
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
COPY composer.json composer.lock ./
WORKDIR /var/www/html
COPY . .
RUN composer install --no-dev --optimize-autoloader
RUN chown -R www-data:www-data /var/www/html/var
EXPOSE 80