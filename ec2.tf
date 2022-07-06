resource "aws_instance" "bastion_host" {
  ami                         = var.instance_ami
  instance_type               = "t2.micro"
  vpc_security_group_ids      = aws_security_group.bastion_host_sg.id
  subnet_id                   = aws_subnet.public_subnet_1.id
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    delete_on_termination = true
    encrypted             = true
    volume_type           = "gp2"
    volume_size           = 15
  }
  tags = { Name = "${local.name_prefix}-bastion-instance" }
}

resource "aws_eip" "bastion_host_eip" {
  instance = aws_instance.bastion_host.id
  vpc      = true
}