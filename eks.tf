data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"

  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets
  enable_irsa     = true

  vpc_id = module.vpc.vpc_id

  worker_groups = [
    {
      instance_type = "t3.medium"
      asg_max_size  = 10
      asg_min_size  = 1
      tags = [
        {
          key                 = "k8s.io/cluster-autoscaler/enabled"
          value               = "TRUE"
          propagate_at_launch = true
        },
        {
          key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          value               = "owned"
          propagate_at_launch = true
        }
      ]
  }]

  write_kubeconfig = false
}
