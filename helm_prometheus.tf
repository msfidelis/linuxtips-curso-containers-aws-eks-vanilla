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


resource "kubectl_manifest" "grafana_host" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: prometheus
  annotations:
spec:
  ingressClassName: nginx
  rules:
    - host: ${var.grafana_host}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: prometheus-grafana
                port:
                  number: 80
YAML
  depends_on = [
    helm_release.prometheus,
    helm_release.nginx_controller
  ]

}