import json
from netaddr import IPNetwork
from collections import defaultdict

# Read JSON file.
with open('config.json') as input_file:
  config = json.load(input_file)

subnet = IPNetwork(config['subnet_cidr'])
master_ip_addresses = defaultdict()
slave_ip_addresses = defaultdict()
master_count = config['master_count']
slave_count = config['slave_count']

# The first 4 IP addresses of an AWS subnet are reserved.
# See http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Subnets.html
start = 4
master_node_index = 1
slave_node_index = 1
for i in range(start, master_count + start):
  ip_address = subnet[i]
  master_ip_addresses[master_node_index] = str(ip_address)
  master_node_index += 1

for i in range(1, slave_count + 1):
  ip_address = subnet[len(subnet)/2+i]
  slave_ip_addresses[slave_node_index] = str(ip_address)
  slave_node_index += 1

config['master_ip_addresses'] = master_ip_addresses
config['slave_ip_addresses'] = slave_ip_addresses
config['zookeeper_master_urls'] = 'zk://{0}'.format(','.join('{0}:2181'.format(ip) for ip in master_ip_addresses.values()))

zookeeper_config_ip_addresses = map(lambda x: 'server.{0}={1}:2888:3888'.format(x, master_ip_addresses[x]), master_ip_addresses)
config['zookeeper_config_ip_addresses'] = '\n'.join(zookeeper_config_ip_addresses)

# Generate Mesos config.

# Write the new config to the Terraform variable file.
with open('terraform.tfvars', 'w') as output_file:
  print(json.dump(config, output_file, indent=2))

