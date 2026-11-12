# --- The private ECR repository ---------------------------------------------
resource "aws_ecr_repository" "this" {
  name                 = var.name
  image_tag_mutability = var.image_tag_mutability # a tag can never be overwritten -> reproducible deploys
  force_delete         = var.force_delete         # protect against destroying a repo full of images

  image_scanning_configuration {
    scan_on_push = var.scan_on_push               # basic vulnerability scan on every push
  }

  encryption_configuration {
    encryption_type = var.encryption_type         # or "KMS" with kms_key = aws_kms_key.x.arn
  }

  tags = {
    Name       = var.name
    ManagedBy = "terraform"
  }
}

# --- Lifecycle policy: keep storage costs under control ---------------------
resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images after 7 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        }
        action = { type = "expire" }
      },
      {
        rulePriority = 2
        description  = "Keep only the 30 most recent images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })
}

# --- Pull-through cache: mirror public images into your own ECR -------------
# After this exists, a pod can use:
#   <account>.dkr.ecr.<region>.amazonaws.com/ecr-public/nginx/nginx:stable
# and ECR fetches + caches it from public.ecr.aws on first pull.

/* resource "aws_ecr_pull_through_cache_rule" "ecr_public" {
  ecr_repository_prefix = "ecr-public"  // ecr-public/lori
  upstream_registry_url = "public.ecr.aws"
} */

# Docker Hub needs credentials stored in Secrets Manager (name must start
# with "ecr-pullthroughcache/"). Uncomment and supply the secret ARN:
#
# resource "aws_ecr_pull_through_cache_rule" "docker_hub" {
#   ecr_repository_prefix = "docker-hub"
#   upstream_registry_url = "registry-1.docker.io"
#   credential_arn        = aws_secretsmanager_secret.dockerhub.arn
# }
