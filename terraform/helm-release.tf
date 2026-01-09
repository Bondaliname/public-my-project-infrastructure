resource "helm_release" "traefik" {
  name             = "traefik"
  repository       = "https://traefik.github.io/charts"
  chart            = "traefik"
  namespace        = "traefik"
  create_namespace = true
  version          = "32.1.1"

  values = [
    <<EOF
service:
  type: LoadBalancer

ingressClass:
  enabled: true
  isDefaultClass: true

ports:
  web:
    port: 8000
    expose:
      enabled: true

  websecure:
    port: 8443
    expose:
      enabled: true
    tls:
      enabled: false

securityContext:
  capabilities:
    drop:
      - ALL
  runAsNonRoot: true
  runAsUser: 65532

additionalArguments:
  - "--providers.kubernetesingress"
  - "--providers.kubernetescrd"
  - "--ping=true"
  - "--metrics.prometheus=true"

logs:
  general:
    level: INFO
  access:
    enabled: true

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi
EOF
  ]

  depends_on = [module.aks]
}

data "external" "traefik_ip" {
  program    = ["bash", "-c", "echo \"{\\\"ip\\\": \\\"$(kubectl get svc traefik -n traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}')\\\"}\""]
  depends_on = [null_resource.wait_for_traefik_ip]
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "65.0.0"

  values = [
    <<EOF
prometheus:
  prometheusSpec:
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelectorNilUsesHelmValues: false

    retention: 7d

    storageSpec:
      volumeClaimTemplate:
        spec:
          storageClassName: managed-csi
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 5Gi

    resources:
      requests:
        cpu: 100m
        memory: 256Mi
      limits:
        cpu: 500m
        memory: 1Gi

alertmanager:
  enabled: true

  alertmanagerSpec:
    storage:
      volumeClaimTemplate:
        spec:
          storageClassName: managed-csi
          accessModes: ["ReadWriteOnce"]
          resources:
            requests:
              storage: 2Gi

    resources:
      requests:
        cpu: 50m
        memory: 128Mi
      limits:
        cpu: 200m
        memory: 256Mi

grafana:
  enabled: false
EOF
  ]

  depends_on = [module.aks]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = "monitoring"
  version    = "8.0.0"

  values = [
    <<EOF
adminPassword: ${var.grafana_admin_password}

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus-kube-prometheus-prometheus.monitoring:9090
        access: proxy
        isDefault: true

dashboardProviders:
  dashboardproviders.yaml:
    apiVersion: 1
    providers:
      - name: 'default'
        orgId: 1
        folder: ''
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/default

dashboards:
  default:
    kubernetes:
      gnetId: 7249
      revision: 1
      datasource: Prometheus
    node-exporter:
      gnetId: 1860
      revision: 31
      datasource: Prometheus

ingress:
  enabled: true
  ingressClassName: traefik
  hosts:
    - grafana.${data.external.traefik_ip.result["ip"]}.nip.io
  path: /
  pathType: Prefix

persistence:
  enabled: true
  storageClassName: managed-csi
  size: 5Gi

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

securityContext:
  runAsNonRoot: true
  runAsUser: 472
  fsGroup: 472

grafana.ini:
  auth.anonymous:
    enabled: false
  users:
    allow_sign_up: false
EOF
  ]

  depends_on = [helm_release.kube_prometheus_stack, helm_release.traefik]
}
