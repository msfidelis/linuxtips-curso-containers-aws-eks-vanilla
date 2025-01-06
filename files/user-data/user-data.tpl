MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="//"

--//
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    apiServerEndpoint: ${KUBERNETES_ENDPOINT}
    certificateAuthority: ${KUBERNETES_CERTIFICATE_AUTHORITY}
    cidr: 172.20.0.0/16
    name: ${CLUSTER_NAME}
  kubelet:
    config:
      maxPods: 35
      clusterDNS:
      - 172.20.0.10

--//--