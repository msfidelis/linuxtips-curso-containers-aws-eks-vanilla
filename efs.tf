resource "aws_efs_file_system" "main" {
  creation_token   = "chip-efs-sharedd"
  performance_mode = "generalPurpose"

  tags = {
    Name = "chip"
  }
}

resource "aws_security_group" "efs" {
  name   = "efs"
  vpc_id = data.aws_ssm_parameter.vpc.value

  ingress {
    from_port = 2049
    to_port   = 2049
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

resource "aws_efs_mount_target" "efs_mount_pods" {
  count = length(data.aws_ssm_parameter.pod_subnets)


  file_system_id = aws_efs_file_system.main.id
  subnet_id = data.aws_ssm_parameter.pod_subnets[count.index].value
  security_groups = [
    aws_security_group.efs.id
  ]
}