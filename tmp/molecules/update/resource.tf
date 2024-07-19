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

# Set 192.168.1.2 as ip static for hostname -I (ifconfig eth0)
resource "ssh_resource" "set_static_ip" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo ifconfig eth0 192.168.1.2 netmask 255.255.255.0"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# /etc/dhcpcd.conf
resource "ssh_resource" "set_static_ip_dhcpcd" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak",
    "echo 'interface eth0' | sudo tee -a /etc/dhcpcd.conf",
    "echo 'static ip_address=192.168.1.2/24' | sudo tee -a /etc/dhcpcd.conf",
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