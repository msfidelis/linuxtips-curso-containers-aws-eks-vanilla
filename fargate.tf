resource "aws_eks_fargate_profile" "chip" {
  cluster_name         = aws_eks_cluster.main.name
  fargate_profile_name = "chip"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value

  selector {
    namespace = "chip"
  }
}