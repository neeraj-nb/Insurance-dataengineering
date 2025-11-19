variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cluster_identifier" {
  type    = string
  default = "tf-redshift-cluster"
}

variable "node_type" {
  type    = string
  default = "ra3.large"
  description = "RA3 is recommended for modern workloads. Change as needed."
}

variable "cluster_type" {
  type    = string
  default = "single-node"
}

variable "number_of_nodes" {
  type    = number
  default = 1
}

# variable "vpc_security_group_ids" {
#   type        = list(string)
#   description = "List of SGs that allow access to Redshift (eg. from ETL servers / bastion)."
# }

# variable "subnet_ids" {
#   type        = list(string)
#   description = "List of private subnet ids to create the Redshift subnet group in."
# }

variable "db_name" {
  type    = string
  default = "dev"
}

variable "master_username" {
  type    = string
  default = "redshift_admin"
}

# We will read master_password from Secrets Manager - pass the secret id (or ARN)
variable "master_password_secret_id" {
  type        = string
  description = "Secrets Manager secret id or ARN that contains the master password as the secret string or JSON with key 'password'."
}

variable "kms_key_id" {
  type        = string
  description = "Optional KMS Key ID/ARN for cluster encryption. If empty, AWS-managed key will be used."
  default     = ""
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
  description = "VPC CIDR block"
}

variable "az_count" {
  type    = number
  default = 2
  description = "Number of AZs to create subnets in (recommended >=2 for Redshift subnet group)"
}

variable "public_subnet_suffix" {
  type    = string
  default = "public"
}

variable "private_subnet_suffix" {
  type    = string
  default = "private"
}

variable "allowed_cidr" {
  type    = string
  default = "223.181.9.208/32"
  description = "CIDR allowed to connect to Redshift on port 5439 (set to your office/bastion IP range)"
}

variable "tags" {
  type = map(string)
  default = {
    Project = "redshift-lab"
    Owner   = "team"
  }
}

