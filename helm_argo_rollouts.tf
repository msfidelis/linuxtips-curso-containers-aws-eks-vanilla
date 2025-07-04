resource "helm_release" "argo_rollouts" {

  name       = "argo-rollouts"
  chart      = "argo-rollouts"
  repository = "https://argoproj.github.io/argo-helm"
  namespace  = "argo-rollouts"

  version = "2.34.1"

  create_namespace = true

  set {
    name  = "dashboard.enabled"
    value = true
  }

  set {
    name  = "controller.metrics.enabled"
    value = false
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = false
  }

  depends_on = [
    aws_eks_cluster.main,
  ]
}