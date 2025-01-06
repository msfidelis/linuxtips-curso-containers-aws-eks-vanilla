resource "helm_release" "cluster_autoscaler" {

  repository = "https://kubernetes.github.io/autoscaler"

  chart = "cluster-autoscaler"
  name  = "aws-cluster-autoscaler"

  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "replicaCount"
    value = 1
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = true
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.autoscaler.arn
  }

  set {
    name  = "autoscalingGroups[0].name"
    value = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name
  }

  set {
    name  = "autoscalingGroups[0].maxSize"
    value = lookup(var.auto_scale_options, "max")
  }

  set {
    name  = "autoscalingGroups[0].minSize"
    value = lookup(var.auto_scale_options, "min")
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
  ]
}