output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_cidr_block" {
  value = aws_vpc.this.cidr_block
}

output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "private_subnets" {
  value = aws_subnet.private_subnets
}

output "all_subnets" {
  value = merge(aws_subnet.public_subnets, aws_subnet.private_subnets)
}

output "all_subnets_list" {
  value = [ for key, sn in local.all_subnets: { name = key, val = sn } ]
}

output "NAT" {
  value = aws_nat_gateway.this[0]
}