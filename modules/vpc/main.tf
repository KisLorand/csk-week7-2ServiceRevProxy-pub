locals {
  subnets = { for sn in var.subnets : sn.name => sn } // this is only used in the next two lines for mapping
  public_subnets = { for sn in var.subnets : sn.name => sn if sn.type == "public" }
  private_subnets = { for sn in var.subnets : sn.name => sn if sn.type == "private" }
  all_subnets = merge(aws_subnet.public_subnets, aws_subnet.private_subnets)
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(
    {
      Project = var.project_name
      Name    = "${var.project_name}-vpc"
    }, 
    var.vpc_tags)
}

resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.this.id

  for_each = local.public_subnets
  cidr_block = each.value.cidr_block
  availability_zone = "${var.aws_region}${each.value.availability_zone}"

  tags = {
    Project = var.project_name
    Name    = "${var.project_name}-${each.value.type}-subnet-${each.key}"
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.this.id

  for_each = local.private_subnets
  cidr_block = each.value.cidr_block
  availability_zone = "${var.aws_region}${each.value.availability_zone}"

  tags = {
    Project = var.project_name
    Name    = "${var.project_name}-${each.value.type}-subnet-${each.key}"
  }
}

// gateways
resource "aws_eip" "NAT_IP" {
  count = var.NAT_subnet != "" ? 1 : 0

  domain = "vpc"

  tags = {
    Project = var.project_name
    Name = "${var.vpc_name}-NAT_IP"
  }
}

resource "aws_nat_gateway" "this" {
  count = var.NAT_subnet != "" ? 1 : 0
  allocation_id = aws_eip.NAT_IP[0].id
  subnet_id     = aws_subnet.public_subnets[var.NAT_subnet].id

  tags = {
    Project = var.project_name
    Name = "${var.vpc_name}-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.this
  ]
}


resource "aws_internet_gateway" "this" {
  count = length(local.public_subnets) != 0 ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = {
    Project = var.project_name
    Name = "${var.vpc_name}-igw"
  }

  depends_on = [ 
    aws_vpc.this
  ]
}

// route tables
resource "aws_route_table" "public_rt" {
  count = length(local.public_subnets) != 0 ? 1 : 0 
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = {
    Project = var.project_name
    Name = "${var.vpc_name}-RT-PUBLIC"
  }

  depends_on = [ 
    aws_internet_gateway.this
  ]
}

resource "aws_route_table" "private_rt" {
  count = length(local.private_subnets) != 0 ? 1 : 0 
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[0].id
  }

  tags = {
    Name = "${var.vpc_name}-RT-PRIVATE"
  }

  depends_on = [ 
    aws_nat_gateway.this
  ]
}

resource "aws_route_table_association" "public1" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.public_rt[0].id
}

resource "aws_route_table_association" "priv1" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.private_rt[0].id
}
