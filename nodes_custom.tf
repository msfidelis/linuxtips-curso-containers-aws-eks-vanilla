resource "aws_launch_template" "custom" {

  name = var.project_name

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 50
      volume_type = "gp3"
    }
  }

  ebs_optimized = true

  monitoring {
    enabled = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = format("%s-custom", var.project_name)
    }
  }

  user_data = base64encode(templatefile("${path.module}/files/user-data/user-data.tpl", {
    CLUSTER_NAME                     = aws_eks_cluster.main.id
    KUBERNETES_ENDPOINT              = aws_eks_cluster.main.endpoint
    KUBERNETES_CERTIFICATE_AUTHORITY = aws_eks_cluster.main.certificate_authority.0.data
  }))
}

resource "aws_eks_node_group" "custom" {

  cluster_name    = aws_eks_cluster.main.id
  node_group_name = format("%s-custom", aws_eks_cluster.main.id)

  node_role_arn = aws_iam_role.eks_nodes_role.arn

  instance_types = var.nodes_instance_sizes

  subnet_ids = data.aws_ssm_parameter.pod_subnets[*].value

  launch_template {
    id      = aws_launch_template.custom.id
    version = aws_launch_template.custom.latest_version
  }

  scaling_config {
    desired_size = lookup(var.auto_scale_options, "desired")
    max_size     = lookup(var.auto_scale_options, "max")
    min_size     = lookup(var.auto_scale_options, "min")
  }

  capacity_type = "ON_DEMAND"

  labels = {
    "capacity/os"   = "AMAZON_LINUX"
    "capacity/arch" = "x86_64"
    "capacity/type" = "ON_DEMAND"
  }

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "owned"
  }

  depends_on = [
    # kubernetes_config_map.aws-auth
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