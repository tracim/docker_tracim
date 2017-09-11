#!/usr/bin/env bash

# Default values
PULL=${PULL:=0}

# If PULL is set, change repository HEAD
if [ "$PULL" = 1 ]; then
    echo "Upgrade Tracim code"
    cd /tracim && git pull origin master
    cd /tracim/tracim && python3 setup.py develop
    cd /tracim pip3 install -r install/requirements.txt
    cd /tracim pip3 install -r install/requirements.postgresql.txt
    cd /tracim pip3 install -r install/requirements.mysql.txt
fi

# Create config.ini file if no exist
if [ ! -f /etc/tracim/config.ini ]; then
    CONFIG_FILE_IS_NEW=1
    cp /tracim/tracim/development.ini.base /etc/tracim/config.ini
    touch /tmp/config.ini
    echo FICHIER CREE
fi
ln -sf /etc/tracim/config.ini /tracim/tracim/config.ini

# Create wsgidav.conf file if no exist
if [ ! -f /etc/tracim/wsgidav.conf ]; then
    cp /tracim/tracim/wsgidav.conf.sample /etc/tracim/wsgidav.conf
fi
ln -sf /etc/tracim/wsgidav.conf /tracim/tracim/wsgidav.conf
