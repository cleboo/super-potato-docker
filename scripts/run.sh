#!/bin/bash

if [ ! -f config/.env ]; then
  2>&1 echo "ERROR: .env file not found"
  exit 1
fi

source config/.env

echo "waiiting for database" 

while ! mysqladmin ping -h"$DATABASE_HOST" --silent; do
    sleep 1
done

cron -f &

if [ "$SUPER_POTATO_UPGRADE_DB" == true ]; then
  (cd /var/www/html/super-potato; bin/cake migrations migrate) || exit 1
fi 

tail -f /container/io/stdout &
2>&1 tail -f /container/io/stderr &

/usr/bin/supervisord
