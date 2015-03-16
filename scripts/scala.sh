#!/usr/bin/env bash

set -e

mkdir -p /usr/local/src/scala
wget -O /tmp/scala-2.11.6.tgz http://downloads.typesafe.com/scala/2.11.6/scala-2.11.6.tgz
tar -xvf /tmp/scala-2.11.6.tgz -C /usr/local/src/scala

cat <<EOF > /etc/profile.d/scala.sh
export SCALA_HOME=/usr/local/src/scala/scala-2.11.6
export PATH=$SCALA_HOME/bin:$PATH
EOF
