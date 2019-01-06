FROM tokaido/php72:stable
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" \
      php7.2-fpm \
      php-pear \
      python \
      python-pip \
    && pip install crudini \
    && pip install awscli  \
    && chsh -s /bin/bash fpm \        
    && mkdir -p /tokaido/logs/fpm \
    && chmod 770 /tokaido/logs/fpm \
    && chown -R tok:web /tokaido/logs/fpm \        
    && mkdir -p /var/log/php7 \
    && chmod 770 /var/log/php7 \
    && chown -R tok:web /var/log/php7 \
    && chown tok:web /run/php/ \   
    && chsh -s /usr/sbin/nologin fpm  \
    && curl -s https://getcomposer.org/installer > composer-setup.php && php composer-setup.php && mv composer.phar /usr/local/bin/composer && rm composer-setup.php  \
    && su - tok -c "/usr/local/bin/composer global require \"hirak/prestissimo\""  \
    && su - tok -c "/usr/local/bin/composer global require \"drush/drush\""  \
    && wget -O /tmp/drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar \
    && mv /tmp/drush.phar /usr/local/bin/drush \
    && chmod a+x /usr/local/bin/drush \
    && curl -sLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/2.1.2/yq_linux_amd64 \
	  && echo "af1340121fdd4c7e8ec61b5fdd2237b40205563c6cc174e6bdab89de18fc5b97 /usr/local/bin/yq" | sha256sum -c \
	  && chmod 777 /usr/local/bin/yq

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY config/php.ini /etc/php/7.2/fpm/php.ini
COPY config/www.conf /etc/php/7.2/fpm/pool.d/www.conf 

RUN chown tok:web /usr/local/bin/entrypoint.sh \
    && chown tok:web /etc/php/7.2/fpm/ -R \
    && chmod 770 /usr/local/bin/entrypoint.sh

EXPOSE 9000
USER tok
WORKDIR /tokaido
VOLUME /tokaido/site
CMD ["/usr/local/bin/entrypoint.sh"]
