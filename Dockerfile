FROM marklee77/baseimage-cloud:latest
MAINTAINER Genc Tato <genc.tato@irisa.fr> and Mark Stillwell <mark@stillwell.me>

# install dependencies
ENV DEBIAN_FRONTEND noninteractive
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
        sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

# prepare working directory
RUN mkdir -p /var/cache/docker/workdirs && \
    git clone -b harness https://gitlab.harness-project.eu/gtato/conpaas.git \
        /var/cache/docker/workdirs/conpaas
WORKDIR /var/cache/docker/workdirs/conpaas

# FIXME: really should allow for proper certificates
RUN openssl req -newkey rsa:2048 -x509 -nodes -days 365 -subj "/CN=conpaas" \
      -out /usr/local/share/ca-certificates/conpaas.crt \
      -keyout /etc/ssl/private/conpaas.key && \
    update-ca-certificates && \
    sed -i "s/ssl-cert-snakeoil/conpaas/g" /etc/apache2/sites-available/default-ssl

# install conpaas 
RUN bash mkdist.sh 1.5.0 && \
    tar -xaf cpsdirector-*.tar.gz && \
    tar -xaf cpsfrontend-*.tar.gz && \
    easy_install --always-unzip cpslib-*.tar.gz cpsclient-*.tar.gz && \
    cp -r cpsfrontend-*/www/* /var/www/html/ && \
    rm /var/www/html/index.html && \
    cp /var/www/html/config-example.php /var/www/html/config.php && \
    cd cpsdirector-1.5.0 && echo 'localhost' | make install && cd .. && \
    mv /etc/apache2/sites-available/conpaas-director \
       /etc/apache2/sites-available/conpaas-director.conf && \
    sed -i 'N; s/\ *\<Order deny,allow\>\n\ *\<Allow from all\>/        Require all granted/g' /etc/apache2/sites-available/conpaas-director.conf && \
    cp cpsfrontend-*/conf/main.ini /etc/cpsdirector/main.ini && \
    sed -i "s/^\(logfile\s*=\s*\).*$/logfile = \/var\/log\/apache2\/cpsfrontend-error.log/" /etc/cpsdirector/main.ini && \
    cp cpsfrontend-*/conf/welcome.txt /etc/cpsdirector/welcome.txt && \
    a2ensite conpaas-director.conf && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    rm -rf *.tar.gz cpsfrontend* cpsdirector*

COPY ./scripts/startconpaas.sh /etc/my_init.d/10-conpaas
RUN chmod 755 /etc/my_init.d/10-conpaas

VOLUME [ '/etc/apache2', '/etc/cpsdirector', '/var/www/html', \
         '/var/log/apache2' ]

EXPOSE 80 443
