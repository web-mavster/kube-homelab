resource "ssh_resource" "update_dependencies" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo apt update -y",
    "sudo apt full-upgrade -y",
    "sudo apt clean -y"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# Enable eth0 and disable wlan0
resource "ssh_resource" "enable_eth0_disable_wlan0" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo ip link set eth0 up",
    "sudo ip link set wlan0 down"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# Disable eth0 and enable wlan0
resource "ssh_resource" "disable_eth0_enable_wlan0" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo ip link set eth0 down",
    "sudo ip link set wlan0 up"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

# /etc/dhcpcd.conf
resource "ssh_resource" "set_static_ip_dhcpcd" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak",
    "echo 'interface eth0' | sudo tee -a /etc/dhcpcd.conf",
    "echo 'static ip_address=$(hostname -I | awk '{print $1}')/24' | sudo tee -a /etc/dhcpcd.conf",
    "echo 'static routers=$(ip route | awk '/default/ { print $3 }' | sort | uniq | head -n 1)' | sudo tee -a /etc/dhcpcd.conf",
    "echo 'static domain_name_servers=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}')' | sudo tee -a /etc/dhcpcd.conf"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# Restart dhcpcd service
resource "ssh_resource" "restart_dhcpcd" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo mv /etc/dhcpcd.conf.bak /etc/dhcpcd.conf",
    "sudo rm -rf /etc/dhcpcd.conf.bak",
    "sudo systemctl daemon-reload",
    "sudo systemctl restart dhcpcd"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

resource "ssh_resource" "set_static_ip" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  file {
    content  = <<-EOT
      network:
        version: 2
        renderer: networkd
        wifis:
          renderer: networkd
          wlan0:
            access-points:
              NAZGUL_REY_PLUS:
                password: 02f94c39b9132a19d4c7375860e9010aeaa0f31beddc905ff89964a513f3d998
            dhcp4: true
            optional: true
        ethernets:
          eth0:
            addresses:
              - IP_ADDRESS/24
            gateway4: IP_GATEWAY
            nameservers:
              addresses:
                - DNS1
            optional: true
            dhcp4: false
      EOT
    destination = "/etc/netplan/01-netcfg.yaml"
    permissions = "0644"
  }
  commands = [
    "sudo set -i 's/IP_ADDRESS/'$(hostname -I | awk '{print $1}')'/g' /etc/netplan/01-netcfg.yaml",
    "sudo set -i 's/IP_GATEWAY/'$(ip route | awk '/default/ { print $3 }' | sort | uniq | head -n 1)'/g' /etc/netplan/01-netcfg.yaml",
    "sudo set -i 's/DNS1/'$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}')'/g' /etc/netplan/01-netcfg.yaml",
    "sudo netplan --debug try",
    "sudo netplan --debug generate",
    "sudo netplan --debug apply",
  ]
}

resource "ssh_resource" "set_dhcp_ip" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  file {
    content  = <<-EOT
      network:
        version: 2
        renderer: networkd
        wifis:
          renderer: networkd
          wlan0:
            access-points:
              NAZGUL_REY_PLUS:
                password: 02f94c39b9132a19d4c7375860e9010aeaa0f31beddc905ff89964a513f3d998
            dhcp4: true
            optional: true
        ethernets:
          eth0:
            dhcp4: true
            optional: true
      EOT
    destination = "/etc/netplan/01-netcfg.yaml"
    permissions = "0644"
  }
  commands = [
    "sudo netplan --debug try",
    "sudo netplan --debug generate",
    "sudo netplan --debug apply",
  ]
  when = "destroy"
}