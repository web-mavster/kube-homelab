terraform {
  required_version = ">=v1.9.2"

  required_providers {
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
  }
}

resource "ssh_resource" "ssh_excecutor" {
  for_each = local.servers
  host     = each.value.ip_static
  user     = each.value.user
  commands = local.commands
  private_key = file(each.value.private_key)
  timeout = local.timeout
  retry_delay = "10s"
  when = local.is_destroy
  # if local.file_data is not null, then add the file {} block
  dynamic "file" {
    for_each = local.file_data != null ? [local.file_data] : []
    content {
      content     = file.value.content
      destination = file.value.destination
      permissions = file.value.permissions
    }
  }

  
}


