# Exists once per account, already there: look it up.
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "service_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:KisLorand@92023199/csk-week7-2ServiceRevProxy@1450366638:*"] // Remove this!!
    }
  }
}

resource "aws_iam_role" "gha_service" {
  name               = "${var.name}-gha-service"
  assume_role_policy = data.aws_iam_policy_document.service_trust.json
}

# + aws_iam_role_policy: ecr:GetAuthorizationToken on "*", push actions on aws_ecr_repository.hello.arn
# + the same for "${var.name}-gha-infra": sub = repo:<you>/infra-code:pull_request
#   and repo:<you>/infra-code:ref:refs/heads/main, AdministratorAccess attached

data "aws_iam_role" "gha_infra" {
  name = "lori-gha-admin-access"
}

# something separate for the lori-gha-admin-access and lori-ecr-push-week7-task-role roles.
#   their ARNs are needed in the github secrets, so they should be created before
resource "aws_eks_access_entry" "gha_infra" {
  cluster_name  = var.cluster_name
  principal_arn = data.aws_iam_role.gha_infra.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "gha_infra" {
  cluster_name  = var.cluster_name
  principal_arn = aws_eks_access_entry.gha_infra.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  access_scope {
    type = "cluster"
  }
}