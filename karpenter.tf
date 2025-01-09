resource "kubectl_manifest" "ec2_node_class" {
  count = length(var.karpenter_capacity)
  yaml_body = templatefile("${path.module}/files/karpenter/ec2_node_class.yml", {
    NAME              = var.karpenter_capacity[count.index].name
    INSTANCE_PROFILE  = aws_iam_instance_profile.nodes.name
    AMI_ID            = data.aws_ssm_parameter.karpenter_ami[count.index].value
    AMI_FAMILY        = var.karpenter_capacity[count.index].ami_family
    SECURITY_GROUP_ID = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
    SUBNETS           = data.aws_ssm_parameter.pod_subnets[*].value
  })
}


resource "kubectl_manifest" "nodepool" {
  count = length(var.karpenter_capacity)
  yaml_body = templatefile("${path.module}/files/karpenter/nodepool.yml", {
    NAME               = var.karpenter_capacity[count.index].name
    WORKLOAD           = var.karpenter_capacity[count.index].workload
    INSTANCE_FAMILY    = var.karpenter_capacity[count.index].instance_family
    INSTANCE_SIZES     = var.karpenter_capacity[count.index].instance_sizes
    CAPACITY_TYPE      = var.karpenter_capacity[count.index].capacity_type
    AVAILABILITY_ZONES = var.karpenter_capacity[count.index].availability_zones
  })
}