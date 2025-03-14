resource "aws_security_group" "this" {
  for_each    = var.security_groups
  name        = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-${each.key}"
  description = each.value.description
  vpc_id      = each.value.vpc_id

  dynamic "ingress" {
    for_each = coalesce(try(each.value.ingress_rules, []), [])
    content {
      description     = ingress.value.description
      from_port       = ingress.value.from_port
      to_port         = ingress.value.to_port
      protocol        = ingress.value.protocol
      cidr_blocks     = ingress.value.cidr_blocks
      security_groups = ingress.value.sg
    }
  }
  dynamic "egress" {
    for_each = coalesce(try(each.value.egress_rules, []), [])
    content {
      description     = egress.value.description
      from_port       = egress.value.from_port
      to_port         = egress.value.to_port
      protocol        = egress.value.protocol
      cidr_blocks     = egress.value.cidr_blocks
      security_groups = egress.value.sg
    }
  }

  tags = merge(
    {
      "Name" = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-${each.key}"
    },
    var.tags,
  )
}