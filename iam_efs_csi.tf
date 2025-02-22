data "aws_iam_policy_document" "efs_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "efs_role" {
  assume_role_policy = data.aws_iam_policy_document.efs_role.json
  name               = format("%s-efs-csi-role", var.project_name)
}

resource "aws_iam_role_policy_attachment" "efs_csi_role" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
  role       = aws_iam_role.efs_role.name
}

resource "aws_eks_pod_identity_association" "efs_csi" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "efs-csi-controller-sa"
  role_arn        = aws_iam_role.efs_role.arn
}