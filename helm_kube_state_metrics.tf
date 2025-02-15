resource "helm_release" "kube_state_metrics" {
  name             = "kube-state-metrics"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-state-metrics"
  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "apiService.create"
    value = "true"
  }

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
    name  = "metricLabelsAllowlist[0]"
    value = "nodes=[*]"
  }

  set {
    name  = "metricAnnotationsAllowList[0]"
    value = "nodes=[*]"
  }

  depends_on = [
    aws_eks_cluster.main
  ]
}