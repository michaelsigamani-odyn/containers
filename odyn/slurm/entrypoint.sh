#!/bin/bash
set -e

# Fix sackd hostname resolution at runtime (hosts is writable at container start)
grep -q "slurm-controller.slurm" /etc/hosts || \
    echo "127.0.0.1 slurm-controller.slurm" >> /etc/hosts

# Bootstrap MariaDB if first run
if [ ! -d /var/lib/mysql/slurm_acct_db ]; then
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql > /dev/null 2>&1
    mysqld_safe --skip-networking &
    sleep 3
    mysql < /docker-entrypoint-initdb.d/init-db.sql
    mysqladmin shutdown
fi

exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf
