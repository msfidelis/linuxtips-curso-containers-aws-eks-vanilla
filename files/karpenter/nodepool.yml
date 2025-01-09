apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ${NAME}
spec:
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
  template:
    metadata:
      labels:
        workload: "${WORKLOAD}"  
    spec:
      requirements:
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values:
%{ for family in INSTANCE_FAMILY ~}
          - ${family}
%{ endfor ~}          

        - key: karpenter.k8s.aws/instance-size
          operator: In
          values:
%{ for size in INSTANCE_SIZES ~}
          - ${size}
%{ endfor ~}  

        - key: karpenter.sh/capacity-type
          operator: In
          values:
%{ for type in CAPACITY_TYPE ~}
          - ${type}
%{ endfor ~}  

        - key: "topology.kubernetes.io/zone" 
          operator: In
          values:

%{ for az in AVAILABILITY_ZONES ~}
          - ${az}
%{ endfor ~} 
                
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: ${NAME}