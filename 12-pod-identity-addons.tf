
#EKS Pod Identities provide the ability to manage credentials for your applications, 
#similar to the way that Amazon EC2 instance profiles provide credentials to Amazon EC2 instances.
resource "aws_eks_addon" "pod_identity" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "eks-pod-identity-agent"
  #addon_version = "v1.2.0-eksbuild.1"
  depends_on = [aws_eks_node_group.general]
}

# check the aws eks addon version


