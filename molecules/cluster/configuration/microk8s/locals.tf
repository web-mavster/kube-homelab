locals {
  microk8s = coalesce({
    package = "microk8s",
    flags = "--classic "
  }, var.microk8s)
  servers = {for server in var.servers : server.ip_static => server}
}