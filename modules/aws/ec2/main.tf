resource "aws_instance" "this" {
  for_each = var.ec2_instances

  ami                         = each.value.ami_instance
  instance_type               = each.value.instance_type
  associate_public_ip_address = each.value.associate_public_ip_address
  availability_zone           = each.value.availability_zone
  vpc_security_group_ids      = each.value.sg_ids
  subnet_id                   = each.value.subnet_id
  key_name                    = each.value.key_name
  iam_instance_profile        = each.value.iam_instance_profile
  hibernation                 = each.value.hibernation
  # ebs_block_device
  # launch_template
  # user_data


  tags = merge(
    {
      Name = "${var.env}${var.project_name != null ? "-${var.project_name}" : ""}-${each.key}"
    },
    var.tags,
  )
}



