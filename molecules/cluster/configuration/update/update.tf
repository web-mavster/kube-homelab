module "update_dependenes" {
    source = "../shared/connection"
    servers = var.servers
    timeout = "30m"
    commands = [
        # "sudo apt-get update -y",
        # "sudo apt-get upgrade -y",
        # "sudo apt-get dist-upgrade -y",
        "sudo apt install net-tools iptables apt-transport-https gnupg2 software-properties-common apt-transport-https ca-certificates curl vim git -y",
        # "sudo apt-get autoremove -y",
        # "sudo apt-get autoclean -y",
        "sudo apt-get clean -y"
    ]
    is_destroy = false
}