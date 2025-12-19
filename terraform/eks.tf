module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = ">= 19.0.0"

  name                = var.kubernetes_cluster_name
  kubernetes_version  = var.kubernetes_cluster_version
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t3.small"]

      additional_iam_policies = [
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      ]
    }
  }

  tags = {
    Environment = "Production"
    Terraform   = "true"
  }
}
