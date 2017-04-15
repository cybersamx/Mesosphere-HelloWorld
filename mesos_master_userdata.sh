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

# Configure the IP addresses in the master zookeeper cluster.
cat > /etc/mesos/zk << EOF
${zookeeper_ip_addresses}
EOF

echo "${zookeeper_config_ip_addresses}" \
| awk '{gsub(/\\n/,"\n")}1' >> /etc/zookeeper/conf/zoo.cfg

# Configure unique zookeeper ID.
cat > /etc/zookeeper/conf/myid << EOF
${zookeeper_id}
EOF