module "enable_eth0_disable_wlan0" {
  source  = "../shared/connection"
  servers = var.servers
  commands = [
    "sudo ip link set eth0 up",
    "sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak",
    "echo 'interface eth0' | sudo tee -a /etc/dhcpcd.conf",
    # Todo: Multiple Nodes
    "echo 'static ip_address=192.168.1.2/24' | sudo tee -a /etc/dhcpcd.conf",
    "router_ip=$(ip route | awk '/default/ { print $3 }' | sort | uniq | head -n 1); echo -e \"static routers=$router_ip\" | sudo tee -a /etc/dhcpcd.conf",
    "dns_ip=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}'); echo -e \"static domain_name_servers=$dns_ip\" | sudo tee -a /etc/dhcpcd.conf",
    "sudo systemctl daemon-reload"
  ]
  is_destroy = false
}

module "disable_eth0_enable_wlan0" {
  source  = "../shared/connection"
  servers = var.servers
  commands = [
    "sudo ip link set eth0 down",
    # "sudo ip link set wlan0 up"
    "sudo mv /etc/dhcpcd.conf.bak /etc/dhcpcd.conf",
    "sudo rm -rf /etc/dhcpcd.conf.bak",
    "sudo systemctl daemon-reload",
    # "sudo systemctl restart dhcpcd"
  ]
  is_destroy = true
}


module "configure_eth0_file" {
  source     = "../shared/connection"
  servers    = var.servers
  is_destroy = false
  file_data = {
    content     = "${file("./molecules/configure-rpi/dhcp-eth0.yaml")}"
    destination = "/tmp/temp-file.yaml"
    permissions = "0644"
  }
  commands = [
    "sudo mkdir -p /etc/netplan.bk",
    "sudo mv /etc/netplan/50-cloud-init.yaml /etc/netplan.bk/50-cloud-init.yaml",
    "sudo rm -rf /etc/netplan/*",
    "sudo mv /tmp/temp-file.yaml /etc/netplan/50-cloud-init.yaml",
    "sudo sed -i 's/IP_ADDRESS/192.168.1.2/g' /etc/netplan/50-cloud-init.yaml",
    "router_ip=$(ip route | awk '/default/ { print $3 }' | sort | uniq | head -n 1); sudo sed -i \"s/IP_GATEWAY/$router_ip/g\" /etc/netplan/50-cloud-init.yaml",
    "dns_ip=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}'); sudo sed -i \"s/DNS1/$dns_ip/g\" /etc/netplan/50-cloud-init.yaml",
    # "sudo netplan --debug try",
    # "sudo netplan --debug generate",
    "sudo netplan --debug apply",
    "sudo ip link set wlan0 down"
  ]
}

module "restore_eth0_file" {
  source     = "../shared/connection"
  servers    = var.servers
  is_destroy = true
  commands = [
    "sudo rm -rf /etc/netplan/*",
    "sudo mv /etc/netplan.bk/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml",
    "sudo rm -rf /etc/netplan.bk",
    # "sudo netplan --debug try",
    # "sudo netplan --debug generate",
    "sudo ip link set wlan0 up",
    "sudo netplan --debug apply",
  ]
}

