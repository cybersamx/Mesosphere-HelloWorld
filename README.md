# Mesosphere

My attempt to turn [DigitalOcean tutorial](https://www.digitalocean.com/community/tutorials/how-to-configure-a-production-ready-mesosphere-cluster-on-ubuntu-14-04) on Mesosphere to a Terraform template that I can use to automate a Mesosphere cluster.

## Setup

1. Make a copy of `config.json.example` and rename it to `config.json`.
1. Enter the name of the SSH key name you will associate with the EC2 instances.
1. Run the Python script to generate a `terraform.tfvars`

  ```sh
  $ python setup.py
  ```
  
1. Run terraform to set up the cluster

  ```sh
  $ terraform apply
  ```
  
  