#IAM
data "aws_caller_identity" "current" {}
locals {
  eks_oidc_id = chomp("${module.eks.cluster_oidc_issuer_url}")
}


resource "aws_iam_role" "secrets_manager_role" {
  name = "secrets_manager_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(local.eks_oidc_id, "https://", "")}"
        
        # Dans cet exemple, local.eks_oidc_id est utilisé pour stocker l'URL du fournisseur OIDC nettoyée (en supprimant le https://),
        # et cette valeur locale est ensuite utilisée pour construire l'ARN dans la politique IAM.
        # Original : 
        # Federated = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B716D3041E"
        },
        Condition = {
          StringEquals = {
            "${replace(local.eks_oidc_id, "https://", "")}:sub" = "system:serviceaccount:defalut:my-serviceaccount"
          }
        }
      }
    ]
  })
}




resource "aws_iam_policy" "secrets_manager_policy" {
  name        = "secrets_manager_policy"
  description = "A policy that allows a service account to access specific secrets"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"  # Include this if you are using KMS for encryption
        ],
        Effect   = "Allow",
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:my-secret-name-*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "secrets_manager_attach" {
  role       = aws_iam_role.secrets_manager_role.name
  policy_arn = aws_iam_policy.secrets_manager_policy.arn
}