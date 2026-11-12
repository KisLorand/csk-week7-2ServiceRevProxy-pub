output "eks_node_group" {
  value = aws_eks_node_group.this.resources[0].autoscaling_groups[0].name
  # TODO: rename this
}