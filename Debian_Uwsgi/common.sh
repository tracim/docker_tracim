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

# Create tracim conf file if none exists
if [ ! -f /etc/tracim/config.ini ]; then
    CONFIG_FILE_IS_NEW=1
    cp /tracim/tracim/development.ini.base /etc/tracim/config.ini
    sed -i 's/\(8080$\)/80/' /etc/tracim/config.ini
    sed -i 's/\(depot_storage_dir *= *\).*/depot_storage_dir = \/var\/tracim\/depot/' /etc/tracim/config.ini
    sed -i "s/\(radicale.server.filesystem.folder *= *\).*/radicale.server.filesystem.folder = \/var\/tracim\/radicale/" /etc/tracim/config.ini
    SECRET=$(python -c "import uuid; print(str(uuid.uuid4()))")
    sed -i "s/\(cookie_secret *= *\).*/cookie_secret = $SECRET/" /etc/tracim/config.ini
    sed -i "s/\(beaker.session.secret *= *\).*/beaker.session.secret = $SECRET/" /etc/tracim/config.ini
    sed -i "s/\(beaker.session.validate_key *= *\).*/beaker.session.validate_key = $SECRET/" /etc/tracim/config.ini
    case "$DATABASE_TYPE" in
      mysql)
        sed -i "s/\(^sqlalchemy.url *= *\).*/\\sqlalchemy.url = $DATABASE_TYPE+pymysql:\/\/$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT\/$DATABASE_NAME$DATABASE_SUFFIX/" /etc/tracim/config.ini ;;
      postgresql)
        sed -i "s/\(^sqlalchemy.url *= *\).*/\\sqlalchemy.url = $DATABASE_TYPE:\/\/$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT\/$DATABASE_NAME$DATABASE_SUFFIX/" /etc/tracim/config.ini ;;
      sqlite)
        sed -i "s/\(^sqlalchemy.url *= *\).*/\\sqlalchemy.url = sqlite:\/\/\/\/var\/tracim\/tracim.db/" /etc/tracim/config.ini ;;
    esac
fi
ln -sf /etc/tracim/config.ini /tracim/tracim/config.ini

# Create nginx conf file if none exists
if [ ! -f /etc/tracim/nginx.conf ]; then
    cp /tracim/nginx.conf /etc/tracim/nginx.conf
fi
ln -s /etc/tracim/nginx.conf /etc/nginx/sites-available/tracim.conf
ln -s /etc/nginx/sites-available/tracim.conf /etc/nginx/sites-enabled/tracim.conf
rm /etc/nginx/sites-enabled/default

# Create uwsgi conf file if none exists
if [ ! -f /etc/tracim/uwsgi.ini ]; then
    cp /tracim/uwsgi.ini /etc/tracim/uwsgi.ini
fi
ln -s /etc/tracim/uwsgi.ini /etc/uwsgi/apps-available/tracim.ini
ln -s /etc/uwsgi/apps-available/tracim.ini /etc/uwsgi/apps-enabled/tracim.ini

# Create wsgidav.conf file if no exist
if [ ! -f /etc/tracim/wsgidav.conf ]; then
    cp /tracim/tracim/wsgidav.conf.sample /etc/tracim/wsgidav.conf
fi
ln -s /etc/tracim/wsgidav.conf /tracim/tracim/wsgidav.conf

# Create logs and assets directories
if [ ! -f /var/tracim/logs ]; then
    mkdir /var/tracim/logs -p
    chown root:www-data -R /var/tracim/logs
    chmod 775 -R /var/tracim/logs
fi
if [ ! -f /var/tracim/assets ]; then
    mkdir /var/tracim/assets -p
fi

# Configure tracim wsgi file
sed -i "s/\(^# import logging\)$/import logging\nimport logging.config/" /tracim/tracim/app.wsgi
sed -i "s/\(^# logging.config.fileConfig(APP_CONFIG)\)$/logging.config.fileConfig(APP_CONFIG)/" /tracim/tracim/app.wsgi
sed -i "s/\(^APP_CONFIG *= *\).*/APP_CONFIG = \"\/tracim\/tracim\/config.ini\"/" /tracim/tracim/app.wsgi
