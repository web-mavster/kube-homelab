terraform {
  required_version = ">=v1.9.2"

  required_providers {
    time = {
      source  = "hashicorp/time"
      version = "0.11.2"
    }

    remote = {
      source  = "tenstad/remote"
      version = "0.1.3"
    }
  }

  backend "http" { }
}

provider "time" {}
provider "remote" {}


## ENABLE host with the IP NORMAL (DHCP) and DISABLE if the STATIC IP is set
# Configure raspberry (System & Network) 
# module "configure-system" {
#     source = "./molecules/configure-rpi"
#     servers = var.servers
# }

# Start of the modules
module "update-system" {
    source = "./molecules/update"
    servers = var.servers
}