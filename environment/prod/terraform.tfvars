project_name = "linuxtips-cluster"
region       = "us-east-1"

k8s_version = "1.31"

auto_scale_options = {
  min     = 2
  max     = 10
  desired = 2
}

nodes_instance_sizes = [
  "t3.large",
  "t3a.large"
]

ssm_vpc = "/linuxtips-vpc/vpc/id"

ssm_public_subnets = [
  "/linuxtips-vpc/subnets/public/us-east-1a/linuxtips-public-1a",
  "/linuxtips-vpc/subnets/public/us-east-1b/linuxtips-public-1b",
  "/linuxtips-vpc/subnets/public/us-east-1c/linuxtips-public-1c",
]

ssm_private_subnets = [
  "/linuxtips-vpc/subnets/private/us-east-1a/linuxtips-private-1a",
  "/linuxtips-vpc/subnets/private/us-east-1b/linuxtips-private-1b",
  "/linuxtips-vpc/subnets/private/us-east-1c/linuxtips-private-1c",

]

ssm_pod_subnets = [
  "/linuxtips-vpc/subnets/private/us-east-1a/linuxtips-pods-1a",
  "/linuxtips-vpc/subnets/private/us-east-1b/linuxtips-pods-1b",
  "/linuxtips-vpc/subnets/private/us-east-1c/linuxtips-pods-1c",
]

# /aws/service/eks/optimized-ami/1.31/x86_64/standard/recommended/image_id

karpenter_capacity = [
  {
    name               = "linuxtips-capacity"
    workload           = "linuxtips-workload"
    ami_family         = "AL2023"
    ami_ssm            = "/aws/service/eks/optimized-ami/1.31/amazon-linux-2023/x86_64/standard/recommended/image_id"
    instance_family    = ["t3", "t3a", "c6", "c6a", "c7", "c7a"]
    instance_sizes     = ["large", "xlarge", "2xlarge"]
    capacity_type      = ["spot", "on-demand"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  },
  {
    name               = "chip-capacity"
    workload           = "chip"
    ami_family         = "Bottlerocket"
    ami_ssm            = "/aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id"
    instance_family    = ["t3", "t3a", "c6", "c6a", "c7", "c7a"]
    instance_sizes     = ["large", "xlarge", "2xlarge"]
    capacity_type      = ["spot"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  },

  {
    name               = "critical"
    workload           = "critical"
    ami_family         = "Bottlerocket"
    ami_ssm            = "/aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id"
    instance_family    = ["t3", "t3a", "c6", "c6a", "c7", "c7a"]
    instance_sizes     = ["large", "xlarge", "2xlarge"]
    capacity_type      = ["on-demand"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  },

  {
    name               = "soft"
    workload           = "soft"
    ami_family         = "Bottlerocket"
    ami_ssm            = "/aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id"
    instance_family    = ["t3", "t3a", "c6", "c6a", "c7", "c7a"]
    instance_sizes     = ["large", "xlarge", "2xlarge"]
    capacity_type      = ["spot"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  },
  {
    name               = "general"
    workload           = "general"
    ami_family         = "Bottlerocket"
    ami_ssm            = "/aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id"
    instance_family    = ["t3", "t3a", "c6", "c6a", "c7", "c7a"]
    instance_sizes     = ["large", "xlarge", "2xlarge"]
    capacity_type      = ["spot", "on-demand"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  },
  {
    name               = "prometheus"
    workload           = "prometheus"
    ami_family         = "Bottlerocket"
    ami_ssm            = "/aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id"
    instance_family    = ["c7a"]
    instance_sizes     = ["large"]
    capacity_type      = ["spot"]
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
]