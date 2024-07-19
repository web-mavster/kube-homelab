module "update_dependenes" {
    source = "../shared/connection"
    servers = var.servers
    commands = [
        # "sudo apt-get update -y",
        # "sudo apt-get upgrade -y",
        # "sudo apt-get dist-upgrade -y",
        # "sudo apt-get autoremove -y",
        # "sudo apt-get autoclean -y",
        "sudo apt-get clean -y"
    ]
    is_destroy = false
}