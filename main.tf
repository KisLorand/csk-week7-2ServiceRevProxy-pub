locals {
  ec2_instance_map = { for i in var.ec2_instances : i.name => i }
  security_groups  = { for sg in var.security_groups : sg.name => sg }
  ecr_registries   = { for ecr in var.ecr_registries : ecr.name => ecr }
}


module "vpc" {
  source = "./modules/vpc"

  project_name = var.project_name
  aws_region   = var.aws_region

  vpc_name = var.vpc.name
  vpc_cidr = var.vpc.cidr_block

  vpc_tags   = var.vpc.tags
  NAT_subnet = var.vpc.NAT_subnet
  subnets    = var.vpc.subnets
}

module "load_balancer" {
  source = "./modules/load_balancer"

  project_name       = var.project_name
  security_group_ids = []
  subnet_ids         = [for sn in module.vpc.public_subnets : sn.id]
  vpc_id             = module.vpc.vpc_id
  // vpc_cidr_block     = module.vpc.vpc_cidr_block

  depends_on = [
    module.vpc
  ]
}

module "ecr" {
  source   = "./modules/ecr_repositoy"
  for_each = local.ecr_registries

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete
  scan_on_push         = each.value.scan_on_push
  encryption_type      = each.value.encryption_type
}

module "eks" {
  source = "./modules/eks"

  project_name = var.project_name

  name        = var.eks_cluster.name
  subnet_ids  = [for sn in module.vpc.all_subnets_list : sn.val.id if contains(var.eks_cluster.subnets, sn.name)] // in local??
  k8s_version = var.eks_cluster.version
  vpc_id      = module.vpc.vpc_id

  configure_kubectl = var.eks_cluster.configure_kubectl ? { aws_region = var.aws_region, aws_cli_profile = var.aws_profile } : {}

  lb_sg_id = module.load_balancer.sg_id
  depends_on = [
    module.ecr
  ]
}

module "gh-oidc" {
  source = "./modules/github_oidc"

  name = "lori-gh-oidc"
  cluster_name = var.eks_cluster.name

  depends_on = [ 
    module.eks 
  ]
}

module "nlb_listener" {
  source = "./modules/nlb_listener"

  lb_arn = module.load_balancer.lb_arn
  vpc_id = module.vpc.vpc_id
  eks_node_group = module.eks.eks_node_group

  depends_on = [ 
    module.eks,
    module.load_balancer,
    module.vpc
  ]
}




/* module "load_balancer" {
  source = "./modules/load_balancer"

  project_name       = var.project_name
  security_group_ids = [module.security_group["load_balancer_sg"].sg_id]
  subnet_ids         = [for sn in module.vpc.public_subnets : sn.id]

  vpc_id = module.vpc.vpc_id

  // this depends_on is not technically needed, 
  //  because of the implicit dependency (module.vpc.vpc_id reference) 
  //  in the previous row
  depends_on = [
    module.vpc,
    module.security_group
    // aws_internet_gateway.this
  ]
}

module "security_group" {
  source = "./modules/security_group"

  for_each = local.security_groups

  project_name = var.project_name
  name         = each.value.name
  description  = each.value.description
  vpc_id       = module.vpc.vpc_id

  ingress_rules = each.value.ingress
  egress_rules  = each.value.egress
  // cidr_block    = each.value.cidr_block     // module.vpc.vpc_cidr_block
  dynamic_cidrs = {
    bastion_ip = "${aws_eip.BASTION_IP.public_ip}/32"
  }

  depends_on = [ 
    aws_eip.BASTION_IP 
  ]
} */
