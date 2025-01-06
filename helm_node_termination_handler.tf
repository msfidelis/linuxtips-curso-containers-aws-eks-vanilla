resource "helm_release" "node_termination_handler" {
  name      = "aws-node-termination-handler"
  namespace = "kube-system"

  chart      = "aws-node-termination-handler"
  repository = "https://aws.github.io/eks-charts/"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.node_termination_handler.arn
  }

  set {
    name  = "awsRegion"
    value = var.region
  }

  set {
    name  = "queueURL"
    value = aws_sqs_queue.node_termination.url
  }

  set {
    name  = "enableSqsTerminationDraining"
    value = true
  }

  set {
    name  = "enableSpotInterruptionDraining"
    value = true
  }

  set {
    name  = "enableRebalanceMonitoring"
    value = true
  }

  set {
    name  = "enableRebalanceDraining"
    value = true
  }

  set {
    name  = "enableScheduledEventDraining"
    value = true
  }

  set {
    name  = "deleteSqsMsgIfNodeNotFound"
    value = true
  }

  set {
    name  = "checkTagBeforeDraining"
    value = false
  }

}