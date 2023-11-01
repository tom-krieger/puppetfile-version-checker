#!/bin/bash

. /etc/apache2/envvars

sed -i "s/#dbuser#/${DBUSER}/" /opt/whiskey-api/config.yaml
sed -i "s/#dbpass#/${DBPASS}/" /opt/whiskey-api/config.yaml
sed -i "s/#dbhost#/${DBHOST}/" /opt/whiskey-api/config.yaml
sed -i "s/#dbport#/${DBPORT}/" /opt/whiskey-api/config.yaml
sed -i "s/#dbname#/${DBNAME}/" /opt/whiskey-api/config.yaml
sed -i "s/#whiskybaseurl#/${WHISKYBASEURL}/" /opt/whiskey-api/config.yaml
sed -i "s/#picsdir#/${PICSDIR}/" /opt/whiskey-api/config.yaml

apache2 -D FOREGROUND

exit 0
