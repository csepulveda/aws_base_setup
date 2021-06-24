#To allow autoscaling we are going to create five differente resources:

#First create a variable to use as name
locals {
  serviceName = "cluster-autoscaler"
}


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
        "system:serviceaccount:kube-system:${local.serviceName}"
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
  name                = local.serviceName
  path                = "/"
  assume_role_policy  = data.aws_iam_policy_document.autoscaler_assume_policy.json
  managed_policy_arns = [aws_iam_policy.cluster-autoscaler.arn]
}

# #Fourth resouce: k8s serviceaccount
# #this will create a serviceaccount in out k8s cluster.
# #now any pod attached to this service account will have permissions to use any policy attached to our Autoscaling Role
# resource "kubernetes_service_account" "autoscaler_serviceaccount" {
#   automount_service_account_token = true
#   metadata {
#     name      = local.serviceName
#     namespace = "kube-system"

#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.autoscaler_role.arn
#     }
#   }
# }

#Fifth resource: k8s cluster-autoscaler
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
    name  = "rbac.serviceAccount.annotations.\"eks.amazonaws.com/role-arn\""
    value = aws_iam_role.autoscaler_role.arn
  }
}