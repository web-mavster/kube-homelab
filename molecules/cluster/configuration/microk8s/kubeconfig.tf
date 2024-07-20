terraform {
  required_providers {
    remote = {
      source  = "tenstad/remote"
      version = "0.1.3"
    }
  }
}

data "remote_file" "kubeconfig" {
  for_each = local.servers
  conn {
    host        = each.value.ip_static
    user        = each.value.user
    private_key = file(each.value.private_key)
  }
  # PATH IN THE RASPBERRY
  path        = "/home/supermavster/.kube/kubeconfig"
  depends_on  = [
    module.install_microk8s
  ]
}
