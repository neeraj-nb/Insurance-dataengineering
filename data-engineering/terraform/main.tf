locals {
  master_password         = "SuperSecret123!"
}

# Redshift subnet group (required)
resource "aws_redshift_subnet_group" "this" {
  name       = "${var.cluster_identifier}-subnet-group"
  description = "Subnet group for ${var.cluster_identifier}"
  subnet_ids = aws_subnet.private[*].id
}

# Optional parameter group (example - customize as needed)
resource "aws_redshift_parameter_group" "this" {
  name        = "${var.cluster_identifier}-param-group"
  family      = "redshift-1.0"
  description = "Parameter group for ${var.cluster_identifier}"

  parameter {
    name  = "log_statement"
    value = "none"
  }
}

# KMS key lookup (optional)
data "aws_kms_key" "selected" {
  count = var.kms_key_id == "" ? 0 : 1
  key_id = var.kms_key_id
}

# Pull master password from Secrets Manager (recommended)
# This assumes the secret's secret_string is plain password OR JSON like {"password":"xxx"}.
# data "aws_secretsmanager_secret_version" "master_pw" {
#   secret_id = var.master_password_secret_id
# }

# locals {
#   master_password = try(
#     jsondecode(data.aws_secretsmanager_secret_version.master_pw.secret_string).password,
#     data.aws_secretsmanager_secret_version.master_pw.secret_string
#   )
# }

# # Security group that restricts access (if you prefer terraform-managed SG)
# resource "aws_security_group" "redshift" {
#   name        = "${var.cluster_identifier}-sg"
#   description = "Allow access to Redshift cluster"
#   vpc_id      = data.aws_subnet_ids.selected.vpc_id  # optional - remove if you pass SG ids directly

#   # Example inbound rule: restrict to provided SGs or IPs - replace as appropriate
#   ingress {
#     description      = "Allow from ETL servers"
#     from_port        = 5439
#     to_port          = 5439
#     protocol         = "tcp"
#     security_groups  = aws_se
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.cluster_identifier}-sg"
#   }
# }

# Redshift cluster
resource "aws_redshift_cluster" "this" {
  cluster_identifier = var.cluster_identifier
  database_name      = var.db_name
  master_username    = var.master_username
  master_password    = local.master_password

  node_type          = var.node_type
  cluster_type       = var.cluster_type

  # If single-node, number_of_nodes must be 1
  number_of_nodes    = var.cluster_type == "single-node" ? 1 : var.number_of_nodes

  # network / security
  cluster_subnet_group_name = aws_redshift_subnet_group.this.name
  vpc_security_group_ids    = [aws_security_group.redshift.id]

  # encryption
  encrypted  = true
  kms_key_id = length(data.aws_kms_key.selected) > 0 ? data.aws_kms_key.selected[0].key_id : null

  # parameter group
  cluster_parameter_group_name = aws_redshift_parameter_group.this.id

  tags = {
    Name = var.cluster_identifier
  }

  # Optional: snapshot retention / automated snapshots
  automated_snapshot_retention_period = 7

  # Prevent accidental deletion (can be overridden)
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.cluster_identifier}-final-${timestamp()}"
}
