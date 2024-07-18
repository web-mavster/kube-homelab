resource "ssh_resource" "install_k3s" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "echo Hola"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# Note: Removed waiting for k3s server to be ready

resource "ssh_resource" "uninstall_k3s" {
  for_each    = { for server in var.servers : server.host => server }
  host        = each.value.host
  when        = "destroy"
  user        = each.value.user
  commands    = ["bash -c 'echo hi;'"]
  private_key = file(each.value.private_key)
}
