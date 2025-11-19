output "cluster_endpoint" {
  value       = aws_redshift_cluster.this.endpoint
  description = "JDBC endpoint for the Redshift cluster"
}

output "cluster_id" {
  value       = aws_redshift_cluster.this.id
  description = "Redshift cluster id"
}

output "redshift_security_group_id" {
  value = aws_security_group.redshift.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_ids" {
  value = [for s in aws_subnet.public : s.id]
}

output "private_subnet_ids" {
  value = [for s in aws_subnet.private : s.id]
}
