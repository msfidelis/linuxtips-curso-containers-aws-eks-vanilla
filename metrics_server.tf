resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  chart      = "metrics-server"
  namespace  = "kube-system"

  wait = false

  version = "7.2.16"

  set {
    name  = "nodeSelector.karpenter\\.sh/nodepool"
    value = "system"
  }

  set {
    name  = "tolerations[0].key"
    value = "CriticalAddonsOnly"
  }

  set {
    name  = "tolerations[0].operator"
    value = "Exists"
  } 

  set {
    name  = "apiService.create"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.main,
  ]
}