#To allow autoscaling we are going to create five differente resources:

#First resouce: AWS Autoscaler policy
#this will allow pods make calls to AWS Autoscaling resources
resource "aws_iam_policy" "cluster-autoscaler" {
  name        = "EKS-Cluster-Autoscaler"
  description = "Allow Pods use autoscaling resources."

  policy = file("iam-policies/autoscaler.json")
}

#Second resouce: AWS Trust relationships
#this will to some specifc serviceAccount in our k8s cluster use our IAM Role.
data "aws_iam_policy_document" "autoscaler_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"

      values = [
        "system:serviceaccount:kube-system:${var.eks_autoscaling_role_name}"
      ]
    }

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }
  }
}

#Third resouce: AWS Role
#this will create a role and attach our previous IAM Policy and Trust relationships
resource "aws_iam_role" "autoscaler_role" {
  name                = var.eks_autoscaling_role_name
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.autoscaler_assume_policy.json
  managed_policy_arns = [aws_iam_policy.cluster-autoscaler.arn]
}

#Fourth resource: k8s cluster-autoscaler
#this helm chart will install the cluster-autoscaler service
resource "helm_release" "cluster-autoscaler" {
  name       = "cluster-autoscaler"
  chart      = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.eks_cluster_name
  }
  set {
    name  = "awsRegion"
    value = var.region
  }
  set {
    name  = "rbac.serviceAccount.name"
    value = var.eks_autoscaling_role_name
  }
  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.autoscaler_role.arn
  }
}