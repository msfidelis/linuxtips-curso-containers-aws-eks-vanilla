resource "helm_release" "nginx_controller" {
  name       = "ingress-nginx"
  namespace  = "ingress-nginx"
  chart      = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  version    = "4.11.3"

  create_namespace = true

  set {
    name  = "controller.service.internal.enabled"
    value = "true"
  }

  set {
    name  = "controller.publishService.enable"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }

  # Autoscaling
  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }

  set {
    name  = "controller.autoscaling.minReplicas"
    value = var.nginx_min_replicas
  }

  set {
    name  = "controller.autoscaling.maxReplicas"
    value = var.nginx_max_replicas
  }

  # Capacity
  set {
    name  = "controller.resources.requests.cpu"
    value = var.nginx_requests_cpu
  }

  set {
    name  = "controller.resources.requests.memory"
    value = var.nginx_requests_memory
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = var.nginx_limits_cpu
  }

  set {
    name  = "controller.resources.limits.memory"
    value = var.nginx_limits_memory
  }

  # Service Monitors 

  set {
    name  = "controller.metrics.enabled"
    value = "true"
  }

  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }

  set {
    name  = "controller.podAnnotations.prometheus\\.io/scrape"
    value = "true"
  }

    set {
    name  = "controller.podAnnotations.prometheus\\.io/port"
    value = "10254"
  }

  set {
    name  = "controller.kind"
    value = "Deployment"
    # value = "DaemonSet"
  }

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubectl_manifest" "target_binding_80" {
  yaml_body = <<YAML
apiVersion: elbv2.k8s.aws/v1beta1
kind: TargetGroupBinding
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  serviceRef:
    name: ingress-nginx-controller
    port: 80
  targetGroupARN: ${aws_lb_target_group.main.arn}
  targetType: instance
YAML
  depends_on = [
    helm_release.nginx_controller
  ]
}