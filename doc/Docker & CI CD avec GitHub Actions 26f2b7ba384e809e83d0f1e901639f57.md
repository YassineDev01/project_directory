# Docker & CI/CD avec GitHub Actions

---

## Création d'un projet Symfony

```bash

composer create-project symfony/skeleton:"7.3.x" my_project_directory
cd my_project_directory

```

### Ajout du Mailer

```bash
composer require symfony/mailer

```

Configurer `.env` :

```
MAILER_DSN=smtp://localhost:1025

```

Configurer `.en.test` :

```
MAILER_DSN=smtp://localhost:1025

```

MailController.php

```php
#[Route('/send-mail', name: 'send_mail')]   
public function sendMail(MailerInterface $mailer): Response   
{       
$email = (new Email())           
			->from('demo@example.com')           
			->to('test@exemple.com')           
			->subject('Bonjour depuis Symfony !')           
			->text('Ceci est un email de test.');
			->html('<h2>Bonjour</h2>')
        $mailer->send($email);
        return new Response("Email envoyé !");   
}
```

MailTest

```php
class MailTest extends WebTestCase
{     
public function testMailEnvoi(): void   
{       
				$client = static::createClient();       
				$client->request('GET', '/send-mail');
        $this->assertResponseIsSuccessful();       
				$this->assertEmailCount(1);    
}}
```

### Mailhog / Mailpit pour tester les mails

`compose.yml`

```yaml
services:
    mailer:
        image: axllent/mailpit
        ports:
            - "1025:1025"
            - "8025:8025"
```

- `http://localhost:8025` → interface pour voir les mails.
- `localhost:1025` → port SMTP où Symfony envoie les emails.

### Dockerfile

`Dockerfile`

```docker
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

```

---

## CI : Intégration Continue avec GitHub Actions

### Définition

L’**Intégration Continue (CI)** est une pratique de développement où **chaque modification du code est automatiquement testée et validée**.

L’objectif est de détecter rapidement les erreurs, avant qu’elles ne s’accumulent.

### Pourquoi la CI ?

- Chaque fois qu’un développeur pousse du code, GitHub va :
    - Installer les dépendances.
    - Préparer la base de données.
    - Lancer les tests.

Cela garantit que **chaque commit est testé automatiquement**.

### Fichier `.github/workflows/ci-cd.yml`

```yaml
jobs:
    build-and-test:
        runs-on: ubuntu-latest
        services:
            mysql:
                image: mysql:8.0
                env:
                    MYSQL_ROOT_PASSWORD: root
                    MYSQL_DATABASE: test
                    MYSQL_USER: test
                    MYSQL_PASSWORD: test
                ports: ["3306:3306"]
            mailhog:
                image: mailhog/mailhog
                ports: ["1025:1025", "8025:8025"]

        steps:
            - uses: actions/checkout@v4
            - uses: shivammathur/setup-php@v2
              with:
                  php-version: "8.3"
                  extensions: pdo_mysql, intl

            - run: composer install --no-interaction --prefer-dist

            - name: Run tests
              env:
                  DATABASE_URL: "mysql://test:test@127.0.0.1:3306/test"
                  MAILER_DSN: "smtp://localhost:1025"
              run: php bin/phpunit --testdox
```

---

## CD : Déploiement Continu avec Docker Hub

### Définition

Le **CD** est la suite logique du CI.

Une fois les tests validés, l’application est automatiquement **préparée pour la production**.

### Ajout du job CD dans GitHub Actions

```yaml
docker-build-push:
    runs-on: ubuntu-latest
    needs: build-and-test
    steps:
        - uses: actions/checkout@v4
        - uses: docker/login-action@v3
          with:
              username: ${{ secrets.DOCKERHUB_USERNAME }}
              password: ${{ secrets.DOCKERHUB_TOKEN }}
        - uses: docker/build-push-action@v5
          with:
              context: .
              push: true
              tags: |
                  tonpseudo/mailer:latest
                  tonpseudo/mailer:${{ github.sha }}
```

---

## **Configuration des variables d’accès Docker Hub & GitHub**

### Création d’un repository sur Docker Hub

1. Se connecter sur Docker Hub
2. Dans le menu principal → sélectionner **Repositories**.
3. Cliquer sur **Create Repository**.
4. Remplir le formulaire :
    1. **Repository name** : `mailer` (exemple)
    2. **Visibility** : `Public` (ou `Private` si restreint)
    3. Valider avec **Create**.

### Génération d’un Access Token Docker Hub

1. Ouvrir **Account Settings** (paramètres du compte Docker Hub).
2. Aller dans l’onglet **Security**.
3. Section **Access Tokens** → cliquer sur **New Access Token**.
4. Donner un nom au token (par exemple : `github-actions`).
5. Cliquer sur **Generate**.
6. **Copier immédiatement le token généré** (il n’apparaîtra plus par la suite).

Ce token permet à GitHub Actions de se connecter à Docker Hub **en toute sécurité**.

### Ajout des secrets dans GitHub

1. Ouvrir le dépôt GitHub concerné.
2. Aller dans **Settings** (paramètres du dépôt).
3. Dans le menu gauche → **Secrets and variables > Actions**.
4. Cliquer sur **New repository secret**.
5. Ajouter les deux secrets suivants :
    - `DOCKERHUB_USERNAME` → identifiant Docker Hub
    - `DOCKERHUB_TOKEN` → valeur du token généré précédemment

Les secrets apparaissent maintenant dans la liste, accessibles uniquement par GitHub Actions.

---

### Simulation de production

- Même sans serveur dédié, vous pouvez montrer que votre app Symfony est **portable**.
- L’image Docker publiée sur **Docker Hub** peut être téléchargée partout et exécutée instantanément.
- Docker Hub joue ici le rôle de “production”.

---

<aside>
💡

- **Docker** : uniformise et simplifie l’exécution des applis.
- **CI (GitHub Actions)** : automatise les tests et sécurise le code.
- **CD (Docker Hub)** : rend les déploiements fiables et reproductibles.
- Résultat : un simple `git push` = tests + image prête à déployer
  </aside>

---

## Conclusion

Le CI/CD est un **pilier du DevOps** :

- CI/CD supprime les barrières entre **développeurs** et **ops**.
- Les développeurs n’ont plus besoin d’envoyer des fichiers par FTP.
- Les ops n’ont plus besoin de réinstaller manuellement les serveurs.
- Tout est **automatisé, versionné, reproductible**.
- Tout est **automatisé, versionné, reproductible**.
