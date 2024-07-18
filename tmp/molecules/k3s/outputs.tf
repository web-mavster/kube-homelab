output "kubeconfigs" {
  sensitive = true
  value = data.remote_file.kubeconfig["192.168.1.2"].content
}

resource "local_file" "private_key" {
    // root output kubeconfig
    content  = data.remote_file.kubeconfig["192.168.1.2"].content
    filename = "../../config/kubeconfig"
}