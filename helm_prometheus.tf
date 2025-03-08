resource "helm_release" "prometheus" {

  name             = "prometheus"
  chart            = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "prometheus"
  create_namespace = true

  version = "69.3.2"

  values = [
    "${file("./helm/prometheus/values.yml")}"
  ]

  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "grafana_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: grafana
  namespace: prometheus
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "${var.grafana_host}" 
YAML
}

resource "kubectl_manifest" "grafana_virtual_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  namespace: prometheus
spec:
  hosts:
  - "${var.grafana_host}"
  gateways:
  - grafana
  http:
  - route:
    - destination:
        host: prometheus-grafana
        port:
          number: 80 
YAML
}

# resource "kubectl_manifest" "grafana_host" {
#   yaml_body = <<YAML
# apiVersion: networking.k8s.io/v1
# kind: Ingress
# metadata:
#   name: grafana-ingress
#   namespace: prometheus
#   annotations:
# spec:
#   ingressClassName: nginx
#   rules:
#     - host: ${var.grafana_host}
#       http:
#         paths:
#           - path: /
#             pathType: Prefix
#             backend:
#               service:
#                 name: prometheus-grafana
#                 port:
#                   number: 80
# YAML
#   depends_on = [
#     helm_release.prometheus,
#     helm_release.nginx_controller
#   ]

# }