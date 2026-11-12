/* resource "aws_secretsmanager_secret" "this" {
  name = "my-app-secret"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    username = "admin"
    password = "asd"  // var.db_password   # pass in via a sensitive variable, don't hardcode
  })
} */
/* 
// pull from or push to an S3 maybe?
resource "aws_eks_addon" "pod_identity" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "eks-pod-identity-agent"
}

resource "aws_eks_pod_identity_association" "app" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "my-namespace"
  service_account = "my-app-sa"
  role_arn        = aws_iam_role.app.arn  # trust policy: pods.eks.amazonaws.com, actions sts:AssumeRole + sts:TagSession
} */