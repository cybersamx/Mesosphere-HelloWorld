# Mesosphere

My attempt to turn [DigitalOcean Mesos tutorial](https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04) to a Terraform template that I can use to automate a Mesos cluster.

## Setup

1. Make a copy of `config.json.example` and rename it to `config.json`.
1. Edit the file `config.json`. Enter the name of the SSH key name you will associate with the EC2 instances. Change other settings in the file as you see fit.
1. Run the Python script to generate a `terraform.tfvars` based on the settings in `config.json`.

   ```bash
   $ python setup.py
   ```
  
1. Run terraform to set up the cluster

   ```bash
   $ terraform apply
   ```
  
1. Read the output to get an IP address from one of the master nodes.

   To visit the Mesosphere console of your cluster go to:

   ```
   http://ip-address-of-a-master-node:5050
   ```

   To visit the Marathon console of your cluster go to:

   ```
   http://ip-address-of-a-master-node:8080
   ```

1. Don't forget to remove all resources when you are done playing with this project.

   ```bash
   $ terraform destroy
   ```

## References

* [Digital Ocean: How To Configure a Production-Ready Mesosphere Cluster on Ubuntu 14.04 ](ttps://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04)