resource "ssh_resource" "update_dependencies" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo apt update -y; sudo apt full-upgrade -y; sudo apt clean -y"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}
