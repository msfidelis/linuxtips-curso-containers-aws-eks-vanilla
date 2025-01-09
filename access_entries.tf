resource "aws_eks_access_entry" "nodes" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.eks_nodes_role.arn
  type          = "EC2_LINUX"
}

resource "aws_eks_access_entry" "fargate" {
  cluster_name  = aws_eks_cluster.main.id
  principal_arn = aws_iam_role.fargate.arn
  type          = "FARGATE_LINUX"
}