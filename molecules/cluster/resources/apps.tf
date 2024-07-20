resource "helm_release" "external_apps" {
  for_each = { for external in var.externals : external.name => external }
  repository = each.value.repo
  name       = each.value.name
  chart      = each.value.name
  namespace  = each.value.namespace != null ? each.value.namespace : each.value.name
  create_namespace = true
  values = fileexists("./molecules/cluster/resources/config/externals/${each.value.name}/values.yaml") == true ? ["${file("./molecules/cluster/resources/config/externals/${each.value.name}/values.yaml")}"] : []
  timeout = 600
}

resource "helm_release" "external_ingresses" {
  for_each     = {for app in helm_release.external_apps : app.name => app if fileexists("./molecules/cluster/resources/config/externals/${app.name}/ingress.values.tftpl")}
  name       = "${each.value.name}-ingress"
  chart      = "./molecules/cluster/resources/lib/helm-chart-homelab-ingress"
  namespace  = each.value.namespace

  values = ["${templatefile("./molecules/cluster/resources/config/externals/${each.value.name}/ingress.values.tftpl", { hosts = var.cluster.hosts })}"]

  depends_on = [
    helm_release.external_apps
  ]
}
