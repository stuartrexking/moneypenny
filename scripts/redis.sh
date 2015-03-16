#!/usr/bin/env bash

set -e

add-apt-repository ppa:chris-lea/redis-server
apt-get update
apt-get install redis-server
