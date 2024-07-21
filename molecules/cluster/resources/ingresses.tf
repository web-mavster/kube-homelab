resource "helm_release" "ingresses" {
  for_each     = {for app in var.ingresses : app.name => app if fileexists("./molecules/cluster/resources/config/ingresses/${app.name}.tftpl")}
  name       = "${each.value.name}-ingress"
  chart      = "./molecules/cluster/resources/lib/helm-chart-homelab-ingress"
  namespace  = each.value.namespace

  values = ["${templatefile("./molecules/cluster/resources/config/ingresses/${each.value.name}.tftpl", { hosts = var.cluster.hosts })}"]

  depends_on = [
    helm_release.external_apps
  ]
}
