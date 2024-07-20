output "kubeconfigs" {
  sensitive = false
  value = data.remote_file.kubeconfig["192.168.1.2"].content
}

resource "local_file" "private_key" {
    content  = data.remote_file.kubeconfig["192.168.1.2"].content
    # PATH IN THE LOCAL MACHINE
    filename = "./config/kubeconfig"
}