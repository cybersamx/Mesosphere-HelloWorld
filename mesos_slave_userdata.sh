#!/bin/bash

# Add Mesosphere repository

apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/$DISTRO $CODENAME main" | tee /etc/apt/sources.list.d/mesosphere.list

# Add the Java repository

add-apt-repository -y ppa:webupd8team/java

# Update the package manager

apt-get update -y

# Get packages

# Slient option for Java install
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
apt-get install -y oracle-java8-installer

apt-get install -y mesos

### Configure Zookeeper ###

# Define the master nodes.
cat > /etc/mesos/zk << EOF
${zookeeper_master_ip_addresses}/mesos
EOF

### Configure Mesos ###

cat > /etc/mesos-slave/ip << EOF
${ip_address}
EOF

cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

### Autostart services ###

# Mesos-slave
if [ ! -f /etc/init.d/mesos-slave ]; then
  ln -s /lib/init/upstart-job /etc/init.d/mesos-slave
fi
update-rc.d mesos-slave defaults
service mesos-slave start

# Zookeeper
update-rc.d zookeeper remove
service zookeeper stop
echo "manual" > /etc/init/zookeeper.override

# Mesos-master
update-rc.d mesos-master remove
service mesos-master stop
echo "manual" > /etc/init/mesos-master.override

