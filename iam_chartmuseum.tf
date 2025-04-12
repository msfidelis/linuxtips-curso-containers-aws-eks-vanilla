data "aws_iam_policy_document" "chartmuseum_role" {
  version = "2012-10-17"

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

resource "aws_iam_role" "chartmuseum_role" {
  assume_role_policy = data.aws_iam_policy_document.chartmuseum_role.json
  name               = format("%s-chartmuseum", var.project_name)
}

data "aws_iam_policy_document" "chartmuseum_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "s3:*",
    ]

    resources = [
      format("%s/*", aws_s3_bucket.chartmuseum.arn),
      aws_s3_bucket.chartmuseum.arn,
    ]

  }
}

resource "aws_iam_policy" "chartmuseum_policy" {
  name        = format("%s-chartmuseum", var.project_name)
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.chartmuseum_policy.json
}

resource "aws_iam_policy_attachment" "chartmuseum" {
  name = "chartmuseum"
  roles = [
    aws_iam_role.chartmuseum_role.name
  ]

  policy_arn = aws_iam_policy.chartmuseum_policy.arn
}

resource "aws_eks_pod_identity_association" "chartmuseum" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "chartmuseum"
  service_account = "chartmuseum"
  role_arn        = aws_iam_role.chartmuseum_role.arn
}