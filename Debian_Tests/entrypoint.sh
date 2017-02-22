#!/usr/bin/env bash

# Default values
FETCH=${FETCH:=1}

# Check environment variables
/bin/bash /tracim/check_env_vars.sh
if [ ! "$?" = 0 ]; then
    exit 1
fi

# Execute common tasks
/bin/bash /tracim/common.sh
if [ ! "$?" = 0 ]; then
    exit 1
fi

# If CHECKOUT is set, change repository HEAD
if [ -n "$CHECKOUT" ]; then
    cd /tracim && git checkout ${CHECKOUT}
    echo "CHECKOUT set to $CHECKOUT"
fi

# tracim test.ini need a development.ini
cp /tracim/tracim/config.ini /tracim/tracim/development.ini

# PostgreSQL case
if [ "$TEST_DATABASE_ENGINE" = postgresql ] ; then
    service postgresql start
    su - postgres -s /bin/bash -c "psql -c \"CREATE DATABASE tracim;\""
    su - postgres -s /bin/bash -c "psql -c \"ALTER USER postgres WITH PASSWORD 'dummy';\""
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = postgresql:\/\/postgres:dummy@127.0.0.1:5432\/tracim?client_encoding=utf8/" /tracim/tracim/test.ini
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = postgresql:\/\/postgres:dummy@127.0.0.1:5432\/tracim?client_encoding=utf8/" /tracim/tracim/development.ini
fi

# MySQL case
if [ "$TEST_DATABASE_ENGINE" = mysql ] ; then
    service mysql start
    mysql -e 'CREATE DATABASE tracim;'
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = mysql+oursql:\/\/root@localhost\/tracim/" /tracim/tracim/test.ini
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = mysql+oursql:\/\/root@localhost\/tracim/" /tracim/tracim/development.ini
fi

# SQLite case
if [ "$TEST_DATABASE_ENGINE" = sqlite ] ; then
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = sqlite:\/\/\/tracim.sqlite/" /tracim/tracim/test.ini
    sed -i "s/\(sqlalchemy.url *= *\).*/\sqlalchemy.url = sqlite:\/\/\/tracim.sqlite/" /tracim/tracim/development.ini
fi

# Run tests
cd /tracim/tracim && nosetests -c /tracim/tracim/test.ini -v
