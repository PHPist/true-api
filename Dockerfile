FROM php:7.4-apache
#registry.7detalei.ru/common/docker-images/sail:7.4

COPY . /tmp

# Крипто-ПРО
RUN cd /tmp \
    && tar xvzf linux-amd64_deb.tgz \
    && chmod 777 -R linux-amd64_deb/ \
    &&  linux-amd64_deb/install.sh \
    && /opt/cprocsp/sbin/amd64/cpconfig -license -set 5050C-R0000-01B53-WGA38-773A5 \
    &&  apt update && apt install -y wget libboost-all-dev patch software-properties-common gpg libxml2-dev sqlite3 libsqlite3-dev \
#    && wget https://www.cryptopro.ru/sites/default/files/public/faq/csp/csp5devel.tgz \
    && tar xvzf csp5devel.tgz \
    && dpkg -i csp5devel/lsb-cprocsp-devel_5.0.11863-5_all.deb

# Установка libphpcades
RUN  mkdir /tmp/cades \
#    && wget https://www.cryptopro.ru/sites/default/files/products/cades/current_release_2_0/cades-linux-amd64.tar.gz -O /tmp/cades/cades-linux-amd64.tar.gz \
#    && cd /tmp/cades \
    && cd /tmp \
    && tar xvzf cades-linux-amd64.tar.gz \
    && dpkg -i cades-linux-amd64/cprocsp-pki-cades-64_2.0.14892-1_amd64.deb \
    && dpkg -i cades-linux-amd64/cprocsp-pki-phpcades_2.0.14892-1_all.deb

RUN cp /tmp/contrib/php7_support.patch /opt/cprocsp/src/phpcades/ \
    && cd /opt/cprocsp/src/phpcades/ \
    && patch <php7_support.patch

RUN mkdir /php && cd /tmp \
    && tar xvzf php-7.4.0.tar.gz \
    && cd /tmp/php-7.4.0 \
    && ./configure \
    && cp -r /tmp/php-7.4.0/main /php \
    && cp -r /tmp/php-7.4.0/Zend /php \
    && cp -r /tmp/php-7.4.0/TSRM /php \
    && cd /opt/cprocsp/src/phpcades \
    && eval `/opt/cprocsp/src/doxygen/CSP/../setenv.sh --64`; make -f Makefile.unix \
    && ln -s /opt/cprocsp/src/phpcades/libphpcades.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/ \
    && echo "extension=libphpcades.so" >> /usr/local/etc/php/conf.d/docker-php-ext-sodium.ini

# Установка серта
RUN cp -r /tmp/cert_kostin.cer /var/opt/cprocsp/keys/kostin.cer \
    && /opt/cprocsp/bin/amd64/csptestf -absorb -certs
