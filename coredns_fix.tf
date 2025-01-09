data "aws_iam_policy_document" "coredns_fix" {

  version = "2012-10-17"

  statement {

    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }

  }

}

resource "aws_iam_role" "coredns_fix" {
  name_prefix        = format("%s-coredns-fix", var.project_name)
  assume_role_policy = data.aws_iam_policy_document.coredns_fix.json
}

resource "aws_iam_role_policy_attachment" "coredns_fix" {
  role       = aws_iam_role.coredns_fix.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_security_group" "coredns_fix" {
  name   = format("%s-coredns-fix", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc.value

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


data "archive_file" "coredns_archive" {
  type        = "zip"
  source_dir  = "lambda/coredns"
  output_path = "lambda/coredns.zip"
}



resource "aws_lambda_function" "coredns_fix" {
  function_name    = format("%s-coredns-fix", var.project_name)
  runtime          = "python3.13"

  handler          = "main.handler"
  role             = aws_iam_role.coredns_fix.arn
  filename         = data.archive_file.coredns_archive.output_path
  source_code_hash = data.archive_file.coredns_archive.output_base64sha256
  timeout          = 120

  vpc_config {
    subnet_ids = data.aws_ssm_parameter.private_subnets[*].value
    security_group_ids = [aws_security_group.coredns_fix.id]
  }
}

data "aws_lambda_invocation" "coredns_fix" {
  function_name = aws_lambda_function.coredns_fix.function_name
  input         = <<JSON
{
  "endpoint": "${aws_eks_cluster.main.endpoint}",
  "token": "${data.aws_eks_cluster_auth.default.token}"
}
JSON

  depends_on = [
    aws_lambda_function.coredns_fix,
    aws_eks_fargate_profile.kube_system
  ]
}