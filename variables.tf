variable "region" {
  type    = string
  default = "us-west-2"
}

variable "primary_domain_name" {
  type    = string
  default = "csepulveda.io"
}

variable "eks_cluster_name" {
  type    = string
  default = "cluster1"
}

variable "eks_autoscaling_role_name" {
  type    = string
  default = "cluster-autoscaler-aws"
}