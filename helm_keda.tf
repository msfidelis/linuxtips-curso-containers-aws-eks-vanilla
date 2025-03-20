resource "helm_release" "keda" {

  version = var.keda_version

  name             = "keda"
  chart            = "keda"
  repository       = "https://kedacore.github.io/charts"
  namespace        = "keda"
  create_namespace = true

  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter,
    helm_release.keda
  ]
}