locals {
  // ingress = { for ig in var.ingress_rules : ig.name => ig }
  // egress = { for eg in var.egress_rules : eg.name => eg }

  ingress = {
    for r in [  // creates a new list, in which each ingress rule has a "cidr" attribute
      for rule in var.ingress_rules: 
      merge(rule, { // adds the "cidr: value" and merges into the existing map/ingress rule
        cidr    = rule.cidr_ref != null ? var.dynamic_cidrs[rule.cidr_ref] : rule.cidr_block
      })
    ] : r.name => r  // finally maps the name of the object/ingress_rule to t object/ingress_rule itself
  }
  egress = {
    for r in [
      for rule in var.egress_rules: 
      merge(rule, {
        cidr    = rule.cidr_ref != null ? var.dynamic_cidrs[rule.cidr_ref] : rule.cidr_block
      })
    ] : r.name => r
  }

  /* ingress_rules = {
    for r in flatten([
      for sg in var.security_groups : [
        for rule in sg.ingress : merge(rule, {
          sg_name = sg.name
          cidr    = rule.cidr_ref != null ? var.dynamic_cidrs[rule.cidr_ref] : rule.cidr_block
        })
      ]
    ]) : "${r.sg_name}-${r.description}" => r   # key must NOT contain the cidr
  } */
}

// TODO: should the security group be passed as an object or as multiple parameters?
resource "aws_security_group" "this" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.name}"
  }
}


resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = local.ingress

  description = try(each.value.description, "")
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value.cidr // TODO: option for ipv6 and validation
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port

  tags = {
    Name = "${var.project_name}-${each.value.name}"
  }

  depends_on = [ 
    aws_security_group.this 
  ]
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = local.egress

  description = try(each.value.description, "")
  security_group_id = aws_security_group.this.id
  cidr_ipv4         = each.value.cidr  // TODO: option for ipv6 and validation
  from_port         = each.value.ip_protocol == "-1" ? null : each.value.from_port
  ip_protocol       = each.value.ip_protocol 
  to_port           = each.value.ip_protocol == "-1" ? null : each.value.to_port

  tags = {
    Name = "${each.value.name}"
  }

  depends_on = [ 
    aws_security_group.this 
  ]
}