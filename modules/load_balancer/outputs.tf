output "lb_id" {
  value = aws_lb.this.id
}

output "lb_arn" {
  value = aws_lb.this.arn
}

output "sg_id" {
  value = module.security_group.sg_id
}