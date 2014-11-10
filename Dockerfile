FROM marklee77/debian-cloudimage:latest
MAINTAINER Mark Stillwell <mark@stillwell.me>

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
        python \
        python-dev \
        python-httplib2 \
        python-pip \
        python-pycurl \
        python-setuptools \
        python-simplejson \
        sqlite3 && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN pip install argcomplete

# prepare working directory
RUN mkdir -p /var/cache/docker/workdirs && \
    git clone -b harness https://gitlab.harness-project.eu/gtato/conpaas.git \
        /var/cache/docker/workdirs/conpaas
WORKDIR /var/cache/docker/workdirs/conpaas

# install conpaas 
RUN bash mkdist.sh 1.5.0 && \
    tar -xaf cpsdirector-*.tar.gz && \
    tar -xaf cpsfrontend-*.tar.gz && \
    easy_install --always-unzip cpslib-*.tar.gz cpsclient-*.tar.gz && \
    cp -r cpsfrontend-*/www/* /var/www/ && \
    rm /var/www/index.html && \
    cp /var/www/config-example.php /var/www/config.php && \
    cd cpsdirector-1.5.0 && echo 'localhost' | make install && cd .. && \
    sed -i 'N; s/\ *\<Order deny,allow\>\n\ *\<Allow from all\>/        Require all granted/g' /etc/apache2/sites-available/conpaas-director && \
    cp cpsfrontend-*/conf/main.ini /etc/cpsdirector/main.ini && \
    sed -i "s/^\(logfile\s*=\s*\).*$/logfile = \/var\/log\/apache2\/cpsfrontend-error.log/" /etc/cpsdirector/main.ini && \
    cp cpsfrontend-*/conf/welcome.txt /etc/cpsdirector/welcome.txt && \
    a2ensite conpaas-director && \
    a2enmod ssl && \
    a2ensite default-ssl && \
    rm -rf *.tar.gz cpsfrontend* cpsdirector*

# create startup scripts
ADD conpaas.sh /etc/my_init.d/10-conpaas
RUN chmod 0755 /etc/my_init.d/10-conpaas

# data volumes
VOLUME [ "/etc/apache2", "/etc/cpsdirector", "/var/log/apache2" ]

# interface ports
EXPOSE 22 80 443 5555
