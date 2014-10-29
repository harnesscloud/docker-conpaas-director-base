FROM phusion/baseimage:latest
MAINTAINER Genc Tato <genc.tato@irisa.fr> and Mark Stillwell <mark@stillwell.me>

# install dependencies
RUN apt-get update && \
    apt-get -y install \
        apache2 \
        build-essential \
        default-jdk \
        git \
        libapache2-mod-php5 \
        libapache2-mod-wsgi \
        libcurl4-openssl-dev \
        libffi-dev \
        php5-curl \
        python-dev \
        python-httplib2 \
        python-pip \
        python-setuptools \
        sqlite3 

# prepare working directory
RUN mkdir -p /var/cache/docker/workdirs && \
    git clone -b harness https://gitlab.harness-project.eu/gtato/conpaas.git \
        /var/cache/docker/workdirs/conpaas
WORKDIR /var/cache/docker/workdirs/conpaas

# install conpaas 
RUN bash mkdist.sh 1.5.0 && \
    easy_install --always-unzip cpslib-*.tar.gz cpsclient-*.tar.gz && \
    tar -xaf cpsdirector-*.tar.gz && \
    tar -xaf cpsfrontend-*.tar.gz && \
    cp -r cpsfrontend-*/www/* /var/www/html/ && \
    rm /var/www/html/index.html && \
    cp /var/www/html/config-example.php /var/www/html/config.php && \
    cp cpsfrontend-*/conf/main.ini /etc/cpsdirector/ && \
    cp cpsfrontend-*/conf/welcome.txt /etc/cpsdirector/ && \
    sed -i 'Listen 56788' /etc/apache2/sites-enabled/default-ssl.conf && \
    sed -i s/:443/:56788/g /etc/apache2/sites-enabled/default-ssl.conf && \
    a2ensite conpaas-director.conf && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    cd cpsdirector-1.5.0 && echo 'localhost' | make install && cd .. && \
    rm -rf *.tar.gz cpsfrontend* cpsdirector*

RUN sed 'N; s/\ *\<Order deny,allow\>\n\ *\<Allow from all\>/        Require all granted/g' /etc/apache2/sites-available/conpaas-director > /etc/apache2/sites-available/conpaas-director.conf

RUN sed -i "s/^\(const DIRECTOR_URL\s*=\s*\).*$/const DIRECTOR_URL = 'https:\/\/localhost:5555';/" /var/www/html/config.php
RUN sed -i "s/^\(logfile\s*=\s*\).*$/logfile = \/var\/log\/apache2\/cpsfrontend-error.log/" /etc/cpsdirector/main.ini

#RUN cpsadduser.py test@email test password
#RUN cpsclient.py credentials https://localhost:5555 test password


