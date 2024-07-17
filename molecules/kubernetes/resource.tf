resource "ssh_resource" "install_dependencies" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo apt -y install iptables apt-transport-https gnupg2 software-properties-common apt-transport-https ca-certificates curl vim git"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}
resource "ssh_resource" "uninstall_dependencies" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo apt -y remove iptables apt-transport-https gnupg2 software-properties-common apt-transport-https ca-certificates curl vim git"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}


resource "ssh_resource" "disable_swap" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo swapoff -a"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

resource "ssh_resource" "enable_swap" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo swapon -a"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

resource "ssh_resource" "disable_firewall" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo ufw disable"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

resource "ssh_resource" "enable_firewall" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo ufw enable"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

resource "ssh_resource" "update_alternatives" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "update-alternatives --set iptables /usr/sbin/iptables-legacy",
    "update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

resource "ssh_resource" "restore_alternatives" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "update-alternatives --auto iptables",
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

# Enable kernel modules
resource "ssh_resource" "enable_kernel_modules" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo modprobe br_netfilter",
    "sudo modprobe overlay",
    "sudo modprobe nf_conntrack",
    "sudo modprobe xt_conntrack",
    "sudo modprobe xt_nat",
    "sudo modprobe xt_addrtype",
    "sudo modprobe iptable_filter",
    "sudo modprobe iptable_nat",
    "sudo modprobe nf_nat",
    "sudo modprobe nf_conntrack_ipv4",
    "sudo modprobe nf_conntrack_ipv6",
    "sudo modprobe nf_nat_ipv4",
    "sudo modprobe nf_nat_ipv6",
    "sudo modprobe nf_conntrack_netlink",
    "sudo modprobe nf_defrag_ipv4",
    "sudo modprobe nf_defrag_ipv6",
    "sudo modprobe nf_tables",
    "sudo modprobe nf_tables_inet",
    "sudo modprobe nf_tables_ipv4",
    "sudo modprobe nf_tables_ipv6",
    "sudo modprobe nfnetlink",
    "sudo modprobe nfnetlink_queue",
    "sudo modprobe nfnetlink_log",
    "sudo modprobe nfnetlink_cthelper",
    "sudo modprobe nfnetlink_cttimeout",
    "sudo modprobe nf_conntrack_netlink"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# Disable kernel modules
resource "ssh_resource" "disable_kernel_modules" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo modprobe -r br_netfilter",
    "sudo modprobe -r overlay",
    "sudo modprobe -r nf_conntrack",
    "sudo modprobe -r xt_conntrack",
    "sudo modprobe -r xt_nat",
    "sudo modprobe -r xt_addrtype",
    "sudo modprobe -r iptable_filter",
    "sudo modprobe -r iptable_nat",
    "sudo modprobe -r nf_nat",
    "sudo modprobe -r nf_conntrack_ipv4",
    "sudo modprobe -r nf_conntrack_ipv6",
    "sudo modprobe -r nf_nat_ipv4",
    "sudo modprobe -r nf_nat_ipv6",
    "sudo modprobe -r nf_conntrack_netlink",
    "sudo modprobe -r nf_defrag_ipv4",
    "sudo modprobe -r nf_defrag_ipv6",
    "sudo modprobe -r nf_tables",
    "sudo modprobe -r nf_tables_inet",
    "sudo modprobe -r nf_tables_ipv4",
    "sudo modprobe -r nf_tables_ipv6",
    "sudo modprobe -r nfnetlink",
    "sudo modprobe -r nfnetlink_queue",
    "sudo modprobe -r nfnetlink_log",
    "sudo modprobe -r nfnetlink_cthelper",
    "sudo modprobe -r nfnetlink_cttimeout",
    "sudo modprobe -r nf_conntrack_netlink"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}

# kernel boot
resource "ssh_resource" "kernel_boot" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak",
    "sudo echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf",
    "sudo echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.conf",
    "sudo echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",
    "sudo echo 'net.ipv6.conf.all.forwarding = 1' >> /etc/sysctl.conf",
    "sudo sysctl -p",
    "sudo cp /boot/firmware/cmdline.txt /boot/firmware/cmdline.txt.bak",
    "sudo sed -i 's/$/ cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1/' /boot/firmware/cmdline.txt"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
}

# kernel boot restore
resource "ssh_resource" "kernel_boot_restore" {
  for_each = local.servers
  host     = each.value.host
  user     = each.value.user
  commands = [
    "sudo cp /etc/sysctl.conf.bak /etc/sysctl.conf",
    "sudo rm /etc/sysctl.conf.bak",
    "sudo cp /boot/firmware/cmdline.txt.bak /boot/firmware/cmdline.txt",
    "sudo rm /boot/firmware/cmdline.txt.bak"
  ]
  private_key = file(each.value.private_key)
  timeout = "10m"
  when = "destroy"
}
