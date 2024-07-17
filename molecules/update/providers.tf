terraform {
  required_version = ">=v1.9.2"

  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }

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

provider "ssh" {}
provider "time" {}
provider "remote" {}
