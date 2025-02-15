resource "aws_eks_cluster" "main" {
  name    = var.project_name
  version = var.k8s_version

  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = data.aws_ssm_parameter.private_subnets[*].value
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.main.arn
    }
    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]

  // Auto mode
  bootstrap_self_managed_addons = false

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  compute_config {
    enabled = true
    node_pools = [ "general-purpose", "system"]
    node_role_arn = aws_iam_role.eks_nodes_role.arn
  }

  zonal_shift_config {
    enabled = true
  }

  tags = {
    "kubernetes.io/cluster/${var.project_name}" = "shared"
  }

}