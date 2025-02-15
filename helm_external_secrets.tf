resource "helm_release" "external_secrets" {
  namespace        = "external-secrets"
  create_namespace = true

  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"

  set {
    name = "installCRDs"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_eks_pod_identity_association.external_secrets
  ]

}