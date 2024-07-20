terraform {
  required_version = ">=v1.9.2"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }

  }

  backend "http" { }
}

provider "time" {}


# # ENABLE host with the IP NORMAL (DHCP) and DISABLE if the STATIC IP is set
# Configure raspberry (System & Network) 
# module "configure-system" {
#     source = "./molecules/cluster/configuration/configure-rpi"
#     servers = var.servers
# }

# Start of the modules
module "update-system" {
    source = "./molecules/cluster/configuration/update"
    servers = var.servers
}

module "install-kubernetes" {
    source = "./molecules/cluster/configuration/microk8s"
    servers = var.servers
}

module "install-apps" {
    source = "./molecules/cluster/resources"
    base = var.base
    namespaces = var.namespaces
    per_environment_configuration = var.per_environment_configuration
    databases = var.databases
    cluster = var.cluster
    ingresses = var.ingresses
    externals = var.externals
}