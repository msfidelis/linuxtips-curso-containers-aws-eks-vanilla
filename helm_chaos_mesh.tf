resource "helm_release" "chaos_mesh" {
  name       = "chaos-mesh"
  namespace  = "chaos-mesh"
  chart      = "chaos-mesh"
  repository = "https://charts.chaos-mesh.org"

  version    = "2.7.2"

  create_namespace = true

  set {
    name  = "chaosDaemon.runtime"
    value = "containerd"
  }

  // ContainerD no Bottlerocket
  set {
    name  = "chaosDaemon.socketPath"
    value = "/run/containerd/containerd.sock"
  }


  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter,
  ]
}

resource "kubectl_manifest" "chaos_gateway" {

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: chaos-mesh-gateway
  namespace: chaos-mesh
spec:
  selector:
    istio: ingressgateway 
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - ${var.chaos_mesh_host}
YAML

  depends_on = [
    helm_release.chaos_mesh
  ]

}


resource "kubectl_manifest" "chaos_virtual_service" {

  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: chaos-mesh
  namespace: chaos-mesh
spec:
  hosts:
  - ${var.chaos_mesh_host}
  gateways:
  - chaos-mesh-gateway
  http:
  - match:
    - uri:
        prefix: /
    route:
    - destination:
        host: chaos-dashboard
        port:
          number: 2333
YAML

  depends_on = [
    helm_release.argo_rollouts
  ]

}