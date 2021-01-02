FROM mediawiki:latest

RUN apt-get update && apt-get install -y \
    vim unzip libzip-dev

RUN docker-php-ext-install zip

# install PHP package manager "Compose"
# requires v1 instead of v2 for compatibility with SMW
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer --version=1.10.16
#RUN mv composer.phar /usr/local/bin/composer

# once Compose is installed, create a file the specifies the desired packages
# update mediawiki extensions via composer
RUN echo "{\n\"require\": {\n\"mediawiki/semantic-media-wiki\": \"~3.2\"\n}\n}" > /var/www/html/composer.local.json
# then run Composer to get the package
RUN composer update --no-dev


# alternatively, install semantic mediawiki without a file
#RUN php composer.phar require mediawiki/semantic-media-wiki "~3.2" --update-no-dev

#WORKDIR /var/www/html
#COPY LocalSettings.php .

#RUN echo "enableSemantics('localhost');" >> /var/www/html/LocalSettings.php

# problem: the following command depends on /var/www/html/db
# which is normally mounted from the host but isn't available during "docker build"
#RUN php /var/www/html/maintenance/update.php
