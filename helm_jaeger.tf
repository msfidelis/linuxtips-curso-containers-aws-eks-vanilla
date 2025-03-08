resource "helm_release" "jaeger" {
  name             = "jaeger"
  repository       = "https://jaegertracing.github.io/helm-charts"
  chart            = "jaeger"
  namespace        = "tracing"
  create_namespace = true

  set {
    name  = "allInOne.enabled"
    value = "true"
  }

  set {
    name  = "storage.type"
    value = "memory"
  }


  set {
    name  = "agent.enabled"
    value = "false"
  }

  set {
    name  = "collector.enabled"
    value = "false"
  }

  set {
    name  = "query.enabled"
    value = "false"
  }

  set {
    name  = "provisionDataStore.cassandra"
    value = "false"
  }

  set {
    name  = "provisionDataStore.kafka"
    value = "false"
  }

  set {
    name  = "provisionDataStore.elasticsearch"
    value = "false"
  }

  set {
    name  = "collector.service.zipkin.port"
    value = "9411"
  }

  depends_on = [
    aws_eks_cluster.main,
    helm_release.istiod
  ]
}

resource "kubectl_manifest" "jaeger_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: jaeger-query
  namespace: tracing
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "${var.jaeger_host}"
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]

}

resource "kubectl_manifest" "jaeger_virtual_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: jaeger-query
  namespace: tracing
spec:
  hosts:
  - "${var.jaeger_host}"
  gateways:
  - jaeger-query
  http:
  - route:
    - destination:
        host: jaeger-query
        port:
          number: 16686 
YAML

  depends_on = [
    helm_release.jaeger,
    helm_release.istio_ingress
  ]

}