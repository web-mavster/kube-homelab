locals {
  servers = {for server in var.servers : server.host => server}
  servers_tmp = {for server in var.servers : server.ip_static => server}
  commands = var.commands
  is_destroy = var.is_destroy == true ? "destroy" : "create"
  file_data = var.file_data != {} ? var.file_data : null
}
