resource "aws_eks_node_group" "main" {

  cluster_name    = aws_eks_cluster.main.id
  node_group_name = aws_eks_cluster.main.id

  node_role_arn = aws_iam_role.eks_nodes_role.arn

  instance_types = var.nodes_instance_sizes

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  capacity_type = "SPOT"

  labels = {
    "capacity/os"   = "AMAZON_LINUX"
    "capacity/arch" = "x86_64"
    "capacity/type" = "SPOT"
  }

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }

  depends_on = [
    aws_eks_access_entry.nodes
  ]

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]
  }

  timeouts {
    create = "1h"
    update = "2h"
    delete = "2h"
  }

}