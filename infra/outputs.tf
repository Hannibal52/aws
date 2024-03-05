

output "cluster_name" {
  description = "Name of EKS cluster in AWS."
  value       = module.eks.cluster_name
}


output "eks_oidc_id" {
  description = "The OIDC ID for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}



output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
  description = "The endpoint for the EKS cluster"
}

output "cluster_ca_certificate" {
  value = module.eks.cluster_certificate_authority_data
  description = "The certificate authority data for the EKS cluster"
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "ecr_app_url" {
  description = "ECR repo name for app"
  value       = aws_ecr_repository.app.repository_url
}

output "ecr_proxy_url" {
  description = "ECR repo name for proxy"
  value       = aws_ecr_repository.proxy.repository_url
}

output "efs_csi_sa_role" {
  value = module.efs_csi_irsa_role.iam_role_arn
}

output "efs_id" {
  value = aws_efs_file_system.data.id
}

output "db_instance_address" {
  description = "The address of the RDS instance"
  value       = module.db.db_instance_address
}
