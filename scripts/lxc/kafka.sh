#!/usr/bin/env bash

set -e

sudo sed "s/#LXC_DHCP_CONFILE=\/etc\/lxc\/dnsmasq.conf/LXC_DHCP_CONFILE=\/etc\/lxc\/dnsmasq.conf/" -i /etc/default/lxc-net

cat <<EOF > /tmp/dnsmasq.conf
dhcp-host=zookeeper,10.0.3.100
dhcp-host=kafka1,10.0.3.101
dhcp-host=kafka2,10.0.3.102
dhcp-host=kafka3,10.0.3.103
EOF
sudo cp /tmp/dnsmasq.conf /etc/lxc/dnsmasq.conf
sudo service lxc-net restart
sleep 5

#Create and start the Zookeeper container
lxc-create -t download -n zookeeper -- -d ubuntu -r trusty -a amd64
lxc-start -n zookeeper -d

#Wait for stuff to start
sleep 5

#Install dependencies
lxc-attach -n zookeeper -- apt-get update
lxc-attach -n zookeeper -- apt-get install -y wget

#Install jdk
lxc-attach -n zookeeper -- mkdir -p /usr/lib/jvm/
lxc-attach -n zookeeper -- wget -O /tmp/jdk-7u51-linux-x64.tar.gz --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz"
lxc-attach -n zookeeper -- tar -xvf /tmp/jdk-7u51-linux-x64.tar.gz -C /usr/lib/jvm/
lxc-attach -n zookeeper -- update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_51/bin/java 1
lxc-attach -n zookeeper -- update-alternatives --set java /usr/lib/jvm/jdk1.7.0_51/bin/java

#Install Zookeeper
lxc-attach -n zookeeper -- mkdir -p /usr/lib/zookeeper
lxc-attach -n zookeeper -- wget -O /tmp/zookeeper-3.4.6.tar.gz "http://apache.mirror.serversaustralia.com.au/zookeeper/stable/zookeeper-3.4.6.tar.gz"
lxc-attach -n zookeeper -- tar -xvf /tmp/zookeeper-3.4.6.tar.gz -C /usr/lib/zookeeper

lxc-attach -n zookeeper -- sh -ec "echo 'tickTime=2000\ndataDir=/var/lib/zookeeper\nclientPort=2181' >> /usr/lib/zookeeper/zookeeper-3.4.6/conf/zoo.cfg"
lxc-stop -n zookeeper

#Create and start the Kafka container
lxc-create -t download -n kafka1 -- -d ubuntu -r trusty -a amd64
lxc-start -n kafka1 -d

#Wait for stuff to start
sleep 5

#Install dependencies
lxc-attach -n kafka1 -- apt-get update
lxc-attach -n kafka1 -- apt-get install -y wget

#Install jdk
lxc-attach -n kafka1 -- mkdir -p /usr/lib/jvm/
lxc-attach -n kafka1 -- wget -O /tmp/jdk-7u51-linux-x64.tar.gz --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/7u51-b13/jdk-7u51-linux-x64.tar.gz"
lxc-attach -n kafka1 -- tar -xvf /tmp/jdk-7u51-linux-x64.tar.gz -C /usr/lib/jvm/
lxc-attach -n kafka1 -- update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_51/bin/java 1
lxc-attach -n kafka1 -- update-alternatives --set java /usr/lib/jvm/jdk1.7.0_51/bin/java

#Install Kafka
lxc-attach -n kafka1 -- mkdir -p /usr/lib/kafka/
lxc-attach -n kafka1 -- wget -O /tmp/kafka_2.11-0.8.2.1.tgz "https://archive.apache.org/dist/kafka/0.8.2.1/kafka_2.11-0.8.2.1.tgz"
lxc-attach -n kafka1 -- tar -xvf /tmp/kafka_2.11-0.8.2.1.tgz -C /usr/lib/kafka/
lxc-attach -n kafka1 -- sed 's/broker.id=0/broker.id=1/' -i /usr/lib/kafka/kafka_2.11-0.8.2.1/config/server.properties
lxc-attach -n kafka1 -- sed 's/zookeeper.connect=localhost:2181/zookeeper.connect=10.0.3.100:2181/' -i /usr/lib/kafka/kafka_2.11-0.8.2.1/config/server.properties

lxc-stop -n kafka1

#Clone container for multiple brokers
lxc-clone kafka1 kafka2
lxc-clone kafka1 kafka3

#Configure broker 2
lxc-start -n kafka2 -d
sleep 5
lxc-attach -n kafka2 -- sed 's/broker.id=1/broker.id=2/' -i /usr/lib/kafka/kafka_2.11-0.8.2.1/config/server.properties
lxc-stop -n kafka2

#Configure broker 3
lxc-start -n kafka3 -d
sleep 5
lxc-attach -n kafka3 -- sed 's/broker.id=1/broker.id=3/' -i /usr/lib/kafka/kafka_2.11-0.8.2.1/config/server.properties
lxc-stop -n kafka3
