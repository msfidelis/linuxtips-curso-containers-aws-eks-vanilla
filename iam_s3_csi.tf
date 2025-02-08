data "aws_iam_policy_document" "s3_role" {
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

resource "aws_iam_role" "s3_role" {
  assume_role_policy = data.aws_iam_policy_document.s3_role.json
  name               = format("%s-s3-csi-role", var.project_name)
}

resource "aws_iam_role_policy_attachment" "s3_csi_role" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.s3_role.name
}

resource "aws_eks_pod_identity_association" "s3_csi" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "kube-system"
  service_account = "s3-csi-driver-sa"
  role_arn        = aws_iam_role.s3_role.arn
}