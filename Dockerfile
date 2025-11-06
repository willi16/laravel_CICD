#image de base
FROM php:8.4

#definir le repertoire de travail
WORKDIR /project

#copier le projet laravel dans le repertoire de travail
COPY app . 

#installer php et ces extensions
RUN apt update && apt-get install -y\
	 zip\
	 libfreetype-dev\
	 libjpeg62-turbo-dev\
	 libpng-dev\
	 libpq-dev\
 && docker-php-ext-install bcmath pdo  pdo_pgsql pgsql\
 && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
# && php -r "if (hash_file('sha384', 'composer-setup.php') === 'ed0feb545ba87161262f2d45a633e34f591ebb3381f2e0063c345ebea4d228dd0043083717770234ec00c5a9f9593792') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
 && php composer-setup.php \
 && php -r "unlink('composer-setup.php');" \
 && mv composer.phar /usr/local/bin/composer \
 && composer install
#exposition du port 
EXPOSE 8000

RUN adduser www \
 && usermod -aG www www
    


#Generate key and migration
RUN chmod u+x /project/entrypoint.sh \
 && php artisan key:generate 

RUN chown -R www:www /project \
 && chmod -R 755 /project/storage
 
USER www

#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["sleep"," 10000000000000000000000000000000"]
#commande pour démarer le projet

ENTRYPOINT ["php", "artisan", "serve","--host","0.0.0.0"]


