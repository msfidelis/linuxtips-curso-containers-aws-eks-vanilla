resource "aws_eks_fargate_profile" "kube_system" {
  cluster_name         = aws_eks_cluster.main.name
  fargate_profile_name = "kube-system"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value

  selector {
    namespace = "kube-system"
  }
}

resource "aws_eks_fargate_profile" "karpenter" {
  cluster_name         = aws_eks_cluster.main.name
  fargate_profile_name = "karpenter"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value

  selector {
    namespace = "karpenter"
  }
}