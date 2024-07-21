resource "helm_release" "app_data_minio" {
  name       = "homelab-app-data-minio"
  chart      = "./molecules/cluster/resources/lib/helm-chart-openebs-persistence"
  namespace  = "homelab"
  wait = false

  values = [
    <<EOF
    storage: 2Gi
    storageClassName: openebs-hostpath
    pv:
      enabled: true
      name: pv-homelab-app-data-minio
      path: /mnt/disk/app-data/minio
      accessModes:
        - ReadWriteMany
      nodeAffinity:
        required:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/hostname
              operator: In
              values:
              - raspberrypi
    pvc:
      enabled: true
      name: pvc-homelab-app-data-minio
    EOF
  ]

   lifecycle {
     prevent_destroy = true
   }
}
