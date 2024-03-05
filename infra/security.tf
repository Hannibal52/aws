
# AWS KMS Key pour Secrets Manager
resource "aws_kms_key" "my_key" {
  description             = "KMS key for database secrets"
  deletion_window_in_days = 10
}


# Secret dans AWS Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name                   = "db_secret"
  kms_key_id             = aws_kms_key.my_key.arn
  recovery_window_in_days = 30
}
resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.db_secret.id
  secret_string = "{\"username\":\"dbuser\",\"password\":\"dbpassword\"}"
}


# CloudTrail
resource "aws_cloudtrail" "my_trail" {
  name                          = "my_cloudtrail"
  s3_bucket_name                = "my_trail_bucket"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
}

# GuardDuty
resource "aws_guardduty_detector" "my_detector" {
  enable = true
}



# AWS WAF Web ACL
resource "aws_wafv2_web_acl" "example" {
  name        = "example"
  description = "Example ACL"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "example"
    sampled_requests_enabled   = true
  }
}


# Création d'un groupe de logs CloudWatch
resource "aws_cloudwatch_log_group" "exemple_log_group" {
  name = "exemple_log_group"
  retention_in_days = 30
}

# Création d'un flux de logs CloudWatch
resource "aws_cloudwatch_log_stream" "exemple_log_stream" {
  name           = "exemple_log_stream"
  log_group_name = aws_cloudwatch_log_group.exemple_log_group.name
}

# Création d'un filtre de métrique de logs CloudWatch
resource "aws_cloudwatch_log_metric_filter" "exemple_metric_filter" {
  name           = "exemple_metric_filter"
  pattern        = "ERROR"
  log_group_name = aws_cloudwatch_log_group.exemple_log_group.name
  metric_transformation {
    name      = "ErrorCount"
    namespace = "YourNamespace"
    value     = "1"
  }
}

# Création d'un filtre d'abonnement de logs CloudWatch
resource "aws_cloudwatch_log_subscription_filter" "exemple_subscription_filter" {
  name            = "exemple_subscription_filter"
  log_group_name  = aws_cloudwatch_log_group.exemple_log_group.name
  filter_pattern  = "ERROR"
  destination_arn = "arn:aws:lambda:region:account-id:function:your-lambda-function-name"
}

# (Optionnel) Création d'une politique de protection des données sensibles
resource "aws_cloudwatch_log_data_protection_policy" "exemple_data_protection_policy" {
  log_group_name = aws_cloudwatch_log_group.exemple_log_group.name
  policy_document = jsonencode({
    Name    = "exemple_data_protection_policy"
    Version = "2021-06-01"
    Statement = [
      {
        Sid = "Audit"
        DataIdentifier = ["arn:aws:dataprotection::aws:data-identifier/Address",
          "arn:aws:dataprotection::aws:data-identifier/BankAccountNumber-US",
        "arn:aws:dataprotection::aws:data-identifier/BankAccountNumber-GB"]
        Operation = {
          Audit = {
            FindingsDestination = {
              S3 = {
                Bucket = "your-audit-bucket"
              }
            }
          }
        }
      },
      {
        Sid = "Redact"
        DataIdentifier = ["arn:aws:dataprotection::aws:data-identifier/Address",
          "arn:aws:dataprotection::aws:data-identifier/BankAccountNumber-US",
        "arn:aws:dataprotection::aws:data-identifier/BankAccountNumber-GB"]
        Operation = {
          Deidentify = {
            MaskConfig = {}
          }
        }
      }
    ]
  })
}


