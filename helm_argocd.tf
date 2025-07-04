resource "helm_release" "argocd" {

  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  set {
    name  = "server.extensions.enabled"
    value = "true"
  }

  set {
    name  = "server.enable.proxy.extension"
    value = "true"
  }

  set {
    name  = "server.extensions.image.repository"
    value = "quay.io/argoprojlabs/argocd-extension-installer"
  }

  set {
    name  = "server.extensions.extensionList[0].name"
    value = "rollout-extension"
  }

  set {
    name  = "server.extensions.extensionList[0].env[0].name"
    value = "EXTENSION_URL"
  }

  set {
    name  = "server.extensions.extensionList[0].env[0].value"
    value = "https://github.com/argoproj-labs/rollout-extension/releases/download/v0.3.6/extension.tar"
  }

  depends_on = [
    aws_eks_cluster.main,
  ]

}