provider "kubernetes" {
  #load_config_file = "false"
  #token  = data.aws_eks_cluster_auth.myapp-cluster.token
  #cluster_ca_certificate = base64decode(data.aws_eks_cluster.myapp-cluster.certificate_authority.0.data)     
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

  subnet_ids = module.myapp-vpc.private_subnets #or just "subnets"
  vpc_id     = module.myapp-vpc.vpc_id
  
  tags = {
    environment = "development"
    application = "app"
  }
  eks_managed_node_groups = {
    blue = {}
    green = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

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




  /*node_groups = [
    {
        instance_type  = "t2.small"
        name           = "worker-group-1"
        asg_max_size   = 2
    }
  ]*/
}