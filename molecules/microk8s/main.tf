module "install_microk8s" {
    source = "../shared/connection"
    servers = var.servers
    timeout = "10m"
    commands = [
        "sudo snap install ${local.microk8s.package} ${local.microk8s.flags}",
        "sudo mkdir ~/.kube || true",
        "sudo usermod -a -G microk8s $USER",
        "sudo chown -f -R $USER ~/.kube",
        "newgrp microk8s",
        "touch ~/.bash_aliases || true",
        "echo 'alias kubectl=\"microk8s kubectl\"' >> ~/.bash_aliases",
        "echo 'alias helm=\"microk8s helm\"' >> ~/.bash_aliases",
        "source ~/.bash_aliases",
        "microk8s config > ~/.kube/kubeconfig",
    ]
    is_destroy = false
}
