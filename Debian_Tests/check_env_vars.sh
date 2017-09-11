#!/usr/bin/env bash

# Ensure TEST_DATABASE_ENGINE is set
if ! [ -n "$TEST_DATABASE_ENGINE" ]; then
    echo "You must set TEST_DATABASE_ENGINE environment variable"
    exit 1
fi

# Ensure TEST_DATABASE_ENGINE value
case "$TEST_DATABASE_ENGINE" in
    postgresql|mysql|sqlite) ;;
    *) echo "TEST_DATABASE_ENGINE environment variable must be one of these: \
postgresql, mysql, sqlite" ; exit 1 ;;
esac
