data "aws_iam_policy_document" "node_termination_handler" {
  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]
    effect = "Allow"

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
  }
}

resource "aws_iam_role" "node_termination_handler" {
  name               = format("%s-node-termination-handler", var.project_name)
  assume_role_policy = data.aws_iam_policy_document.node_termination_handler.json
}

data "aws_iam_policy_document" "aws_node_termination_handler_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "autoscaling:CompleteLifecycleAction",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "ec2:DescribeInstances",
      "sqs:DeleteMessage",
      "sqs:ReceiveMessage"
    ]

    resources = [
      "*"
    ]

  }
}

resource "aws_iam_policy" "node_termination_handler" {
  name   = format("%s-node-termination-handler", var.project_name)
  policy = data.aws_iam_policy_document.aws_node_termination_handler_policy.json
}

resource "aws_iam_role_policy_attachment" "node_termination_handler" {
  role       = aws_iam_role.node_termination_handler.name
  policy_arn = aws_iam_policy.node_termination_handler.arn
}