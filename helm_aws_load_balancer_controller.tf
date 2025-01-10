resource "helm_release" "alb_ingress_controller" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  namespace        = "kube-system"
  create_namespace = true

  set {
    name  = "clusterName"
    value = var.project_name
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_lb_controller.arn
  }

  set {
    name  = "region"
    value = var.region
  }


  set {
    name  = "vpcId"
    value = data.aws_ssm_parameter.vpc.value

  }

  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter,
    aws_eks_fargate_profile.karpenter,
    aws_eks_fargate_profile.kube_system,
  ]
}