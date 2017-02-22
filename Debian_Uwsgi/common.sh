#!/usr/bin/env bash

# Default values
# TODO: Voir avec Damien si c'est le comportement souhaité
PULL=${PULL:=1}

# If PULL is set, change repository HEAD
if [ "$PULL" = 1 ]; then
    echo "Upgrade Tracim code"
    cd /tracim && git pull origin master
fi

# Create config.ini file if no exist
if [ ! -f /etc/tracim/config.ini ]; then
    CONFIG_FILE_IS_NEW=1
    cp /tracim/tracim/development.ini.base /etc/tracim/config.ini
fi
ln -sf /etc/tracim/config.ini /tracim/tracim/config.ini

# Create wsgidav.conf file if no exist
if [ ! -f /etc/tracim/wsgidav.conf ]; then
    cp /tracim/tracim/wsgidav.conf.sample /etc/tracim/wsgidav.conf
fi
ln -sf /etc/tracim/wsgidav.conf /tracim/tracim/wsgidav.conf
