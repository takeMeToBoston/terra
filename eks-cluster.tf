provider "kubernetes" {
  
  host   = data.aws_eks_cluster.myapp-cluster.endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
} 
  
data "aws_eks_cluster" "myapp-cluster" {
    name = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "myapp-cluster" {
    name = module.eks.cluster_name
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.0"

  cluster_name    = "myapp-eks-cluster"
  cluster_version = "1.25"

  subnet_ids = module.myapp-vpc.private_subnets 
  
  tags = {
    environment = "development"
    application = "app"
  }
  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 2
      max_size     = 5
      desired_size = 2

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
      labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }

      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "gpuGroup"
          effect = "NO_SCHEDULE"
        }
      }

      update_config = {
        max_unavailable_percentage = 33 # or set `max_unavailable`
      }

      tags = {
        ExtraTag = "example"
      }
    }
  }





}