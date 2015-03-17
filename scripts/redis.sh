#!/usr/bin/env bash

set -e

apt-get install -y tcl8.5

wget -O /tmp/redis-stable.tar.gz http://download.redis.io/redis-stable.tar.gz
tar xvzf /tmp/redis-stable.tar.gz -C /tmp
(cd /tmp/redis-stable; make; make test; make install)

mkdir /etc/redis
mkdir -p /var/redis/6379
cp /tmp/redis-stable/utils/redis_init_script /etc/init.d/redis_6379
cp /tmp/redis-stable/redis.conf /etc/redis/6379.conf

sed "s/daemonize no/daemonize yes/" -i /etc/redis/6379.conf
sed "s/pidfile \/var\/run\/redis.pid/pidfile \/var\/run\/redis_6379.pid/" -i /etc/redis/6379.conf
sed "s/logfile \"\"/logfile \/var\/log\/redis_6379.log/" -i /etc/redis/6379.conf
sed "s/dir .\//dir \/var\/redis\/6379/" -i /etc/redis/6379.conf

update-rc.d redis_6379 defaults
