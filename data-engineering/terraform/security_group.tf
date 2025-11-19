# Security group for Redshift cluster
resource "aws_security_group" "redshift" {
  name        = "redshift-sg"
  description = "Allow Redshift access from allowed CIDR on port 5439"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "Redshift (JDBC/psql)"
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }

  # Optional: if you have a bastion security group, you could add security_groups = [aws_security_group.bastion.id]
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "redshift-sg" })
}
