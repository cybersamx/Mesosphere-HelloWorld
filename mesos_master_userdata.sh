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

apt-get install -y mesosphere

### Configure Zookeeper ###

# Define the master nodes.
cat > /etc/mesos/zk << EOF
${zookeeper_master_ip_addresses}/mesos
EOF

echo "${zookeeper_config_ip_addresses}" \
| awk '{gsub(/\\n/,"\n")}1' >> /etc/zookeeper/conf/zoo.cfg

# Configure unique zookeeper ID.
cat > /etc/zookeeper/conf/myid << EOF
${zookeeper_id}
EOF

### Configure Mesos ###

cat > /etc/mesos-master/quorum << EOF
${quorum}
EOF

cat > /etc/mesos-master/ip << EOF
${ip_address}
EOF

cp /etc/mesos-master/ip /etc/mesos-master/hostname

### Configure Marathon ###

mkdir -p /etc/marathon/conf
cp /etc/mesos-master/ip /etc/marathon/conf/hostname

cp /etc/mesos/zk /etc/marathon/conf/master

cat > /etc/marathon/conf/zk << EOF
${zookeeper_master_ip_addresses}/marathon
EOF

### Autostart services ###

# Mesos-master
if [ ! -f /etc/init.d/mesos-master ]; then
  ln -s /lib/init/upstart-job /etc/init.d/mesos-master
fi
update-rc.d mesos-master defaults
service mesos-master start

# Marathon
if [ ! -f /etc/init.d/marathon ]; then
  ln -s /lib/init/upstart-job /etc/init.d/marathon
fi
update-rc.d marathon defaults
service marathon start

# Mesos-slave
update-rc.d mesos-slave remove
service mesos-slave stop
echo "manual" > /etc/init/mesos-slave.override
