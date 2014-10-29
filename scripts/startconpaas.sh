#!/bin/sh
: ${DIRECTOR_URL:="https://localhost:5555"}
: ${USERNAME:="test"}
: ${PASSWORD:="password"}
: ${EMAIL:="test@email"}

sed -i "/^const DIRECTOR_URL =/s%=.*$%= ${DIRECTOR_URL}%" /var/www/html/config.php
service apache2 start
cpsadduser.py ${EMAIL} ${USERNAME} ${PASSWORD}
cpsclient.py credentials ${DIRECTOR_URL} ${USERNAME} ${PASSWORD}
