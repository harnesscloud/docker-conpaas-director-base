FROM      contpaas/base:latest
MAINTAINER Genc Tato <genc.tato@irisa.fr>

WORKDIR /tmp
RUN git clone -b harness https://gitlab.harness-project.eu/gtato/conpaas.git
WORKDIR /tmp/conpaas
#the version can potentially be passed as argument
RUN bash mkdist.sh 1.5.0 

#install conpaas core and client
RUN easy_install --always-unzip cpslib-*.tar.gz cpsclient-*.tar.gz

RUN tar -xaf cpsdirector-*.tar.gz 
WORKDIR /tmp/conpaas/cpsdirector-1.5.0

RUN echo 'localhost' | make install
RUN sed 'N; s/\ *\<Order deny,allow\>\n\ *\<Allow from all\>/        Require all granted/g' /etc/apache2/sites-available/conpaas-director > /etc/apache2/sites-available/conpaas-director.conf
RUN a2ensite conpaas-director.conf
RUN a2enmod ssl && a2ensite default-ssl

WORKDIR /tmp/conpaas
RUN tar -xaf cpsfrontend-*.tar.gz
RUN cp -r cpsfrontend-*/www/* /var/www/html/
RUN rm /var/www/html/index.html
RUN cp cpsfrontend-*/conf/main.ini /etc/cpsdirector/
RUN cp cpsfrontend-*/conf/welcome.txt /etc/cpsdirector/
RUN cp /var/www/html/config-example.php /var/www/html/config.php
RUN sed -i "s/^\(const DIRECTOR_URL\s*=\s*\).*$/const DIRECTOR_URL = 'https:\/\/localhost:5555';/" /var/www/html/config.php
RUN sed -i "s/^\(logfile\s*=\s*\).*$/logfile = \/var\/log\/apache2\/cpsfrontend-error.log/" /etc/cpsdirector/main.ini
RUN rm -rf cpsfrontend*

sed -i 'Listen 56788' /etc/apache2/sites-enabled/default-ssl.conf
sed -i s/:443/:56788/g /etc/apache2/sites-enabled/default-ssl.conf

RUN service apache2 restart
RUN cpsadduser.py test@email test password
#RUN cpsclient.py credentials https://localhost:5555 test password

CMD ["/bin/bash"]

