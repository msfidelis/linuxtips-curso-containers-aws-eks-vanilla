resource "aws_efs_file_system" "prometheus" {
  creation_token   = format("%s-efs-prometheus", var.project_name)
  performance_mode = "generalPurpose"

  tags = {
    Name = format("%s-efs-prometheus", var.project_name)
  }
}

resource "aws_efs_mount_target" "prometheus" {
  count = length(data.aws_ssm_parameter.pod_subnets)


  file_system_id = aws_efs_file_system.prometheus.id
  subnet_id = data.aws_ssm_parameter.pod_subnets[count.index].value
  security_groups = [
    aws_security_group.efs.id
  ]
}

resource "kubectl_manifest" "prometheus_efs_storage_class" {
  yaml_body = <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: efs-prometheus
provisioner: efs.csi.aws.com
parameters:
  provisioningMode: efs-ap
  fileSystemId: ${aws_efs_file_system.prometheus.id}
  directoryPerms: "777"
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
YAML

depends_on = [ 
    aws_eks_cluster.main,
    helm_release.karpenter
 ]
}