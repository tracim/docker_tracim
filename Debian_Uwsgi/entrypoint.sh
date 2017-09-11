#!/usr/bin/env bash

# Default values
CONFIG_FILE_IS_NEW=0
export PYTHON_EGG_CACHE=/tmp 
set -e

# Check environment variables
/bin/bash /tracim/check_env_vars.sh
if [ ! "$?" = 0 ]; then
    exit 1
fi

rm -f /tmp/config.ini

# Execute common tasks
/bin/bash /tracim/common.sh
if [ ! "$?" = 0 ]; then
    exit 1
fi

# MySQL case
if [ "$DATABASE_TYPE" = mysql ] ; then
    # Ensure DATABASE_PORT is set
    if ! [ -n "$DATABASE_PORT" ]; then
        DATABASE_PORT=3306
    fi

    # Check if database must be init
    TEST_TABLE=$(mysql --host="$DATABASE_HOST" --user="$DATABASE_USER" --password="$DATABASE_PASSWORD" --database="$DATABASE_NAME" -s -N --execute="SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$DATABASE_NAME' AND table_name = 'content';")
    if [ ${TEST_TABLE} = 0 ] ; then
        INIT_DATABASE=true
    fi
fi

# PostgreSQL case
if [ "$DATABASE_TYPE" = postgresql ] ; then
    # Ensure DATABASE_PORT is set
    if ! [ -n "$DATABASE_PORT" ]; then
        DATABASE_PORT=5432
    fi
    DATABASE_SUFFIX="?client_encoding=utf8"

    # Check if database must be init
    TEST_TABLE=$(PGPASSWORD="$DATABASE_PASSWORD" psql -U ${DATABASE_USER} -h ${DATABASE_HOST} -d ${DATABASE_NAME} -t -c "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'content' );")
    if [ $TEST_TABLE = f ] ; then
        INIT_DATABASE=true
    fi
fi

# SQLite case
if [ "$DATABASE_TYPE" = sqlite ] ; then
    if [ ! -f /var/tracim/tracim.db ]; then
        INIT_DATABASE=true
    fi
fi


# Create file if tmp/config.ini exist
if [ -f "/tmp/config.ini" ]; then
    echo "IN"
    cp  /etc/tracim/config.ini /tmp/config.ini
    sed -i 's/\(depot_storage_dir *= *\).*/depot_storage_dir = \/var\/tracim\/depot/' /etc/tracim/config.ini
    sed -i "s/\(# radicale.server.filesystem.folder *= *\).*/radicale.server.filesystem.folder = \/var\/tracim\/radicale/" /etc/tracim/config.ini
    SECRET=$(python -c "import uuid; print(str(uuid.uuid4()))")
    sed -i "s/\(cookie_secret *= *\).*/cookie_secret = $SECRET/" /etc/tracim/config.ini
    sed -i "s/\(beaker.session.secret *= *\).*/beaker.session.secret = $SECRET/" /etc/tracim/config.ini
    sed -i "s/\(beaker.session.validate_key *= *\).*/beaker.session.validate_key = $SECRET/" /etc/tracim/config.ini
fi

# Update sqlalchemy.url config
if ! [ "$DATABASE_TYPE" = sqlite ] ; then
    sed -i "s/\(sqlalchemy.url *= *\).*/\\sqlalchemy.url = $DATABASE_TYPE:\/\/$DATABASE_USER:$DATABASE_PASSWORD@$DATABASE_HOST:$DATABASE_PORT\/$DATABASE_NAME$DATABASE_SUFFIX/" /etc/tracim/config.ini
else
    sed -i "s/\(sqlalchemy.url *= *\).*/\\sqlalchemy.url = sqlite:\/\/\/\/var\/tracim\/tracim.db/" /etc/tracim/config.ini
fi

# Start redis server (for async email sending if configured)
service redis-server start

# Initialize database if needed
if [ "$INIT_DATABASE" = true ] ; then
    cd /tracim/tracim/ && gearbox setup-app -c config.ini
fi

# Upgrade database
if [ "$PULL" = 1 ]; then
    echo "Upgrade Tracim database if required"
    cd /tracim/tracim/ && gearbox migrate upgrade
fi

service nginx start

ln -sf /var/log/uwsgi/app/tracim.log /var/tracim/logs/uwsgi.log
ln -sf /var/log/nginx/access.log /var/tracim/logs/nginx-access.log
ln -sf /var/log/nginx/error.log /var/tracim/logs/nginx-error.log
mkdir -p /var/run/uwsgi/app/tracim/
chown www-data:www-data -R /var/run/uwsgi
chown www-data:www-data -R /var/tracim

uwsgi -i /etc/uwsgi/apps-available/tracim.ini --uid www-data --gid www-data
