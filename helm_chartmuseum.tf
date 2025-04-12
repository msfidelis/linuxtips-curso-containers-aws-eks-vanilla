resource "helm_release" "chartmuseum" {
  name       = "chartmuseum"
  repository = "https://chartmuseum.github.io/charts"
  chart      = "chartmuseum"
  namespace  = "chartmuseum"

  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "env.open.AWS_SDK_LOAD_CONFIG"
    value = "true"
  }

  set {
    name  = "env.open.DISABLE_API"
    value = "false"
  }

  set {
    name  = "env.open.STORAGE"
    value = "amazon"
  }

  set {
    name  = "env.open.DISABLE_STATEFILES"
    value = "true"
  }

  set {
    name  = "env.open.STORAGE_AMAZON_BUCKET"
    value = aws_s3_bucket.chartmuseum.id
  }

  set {
    name  = "env.open.STORAGE_AMAZON_REGION"
    value = var.region
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_fargate_profile.karpenter
  ]
}

resource "aws_s3_object" "linuxtips" {
  bucket = aws_s3_bucket.chartmuseum.id
  key    = "linuxtips-0.1.0.tgz"
  source = "${path.module}/helm/linuxtips-0.1.0.tgz"
  etag   = filemd5("${path.module}/helm/linuxtips-0.1.0.tgz")
}