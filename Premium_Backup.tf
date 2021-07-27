# ################################################################
# . Author : Ankit Upadhyay
# . Follow me on github for more aws maintainance resources  http://github.com/ankitosh
# 
# ################################################################


resource "aws_iam_role" "IamRoleForAwsBackup" {
  name               = "Premium_Backup_Role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "IamRoleForAwsBackupManagedPolicyRoleAttachment0" {
  role       = aws_iam_role.IamRoleForAwsBackup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "IamRoleForAwsBackupManagedPolicyRoleAttachment1" {
  role       = aws_iam_role.IamRoleForAwsBackup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}



resource "aws_backup_vault" "BackupVault1" {
  name        = "Premium"
  kms_key_arn = aws_kms_key.backup_key.arn
}

resource "aws_backup_plan" "BackupPlan" {
  name = "Premium"

  rule {
    rule_name         = "Premium_Daily_4Hour_Backup"
    schedule          = "cron(0 0/4 ? * * *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 1
    }
  }
  rule {
    rule_name         = "Premium_Daily_Backup"
    schedule          = "cron(0 0 * * ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 31
    }
  }
  rule {
    rule_name         = "Premium_Monthly"
    schedule          = "cron(0 0 1 1/1 ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after       = 365
      cold_storage_after = 15
    }
  }
  rule {
    rule_name         = "Premium_Yearly"
    schedule          = "cron(0 0 31 12 ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after       = 2555
      cold_storage_after = 15
    }
  }
}

resource "aws_backup_selection" "BackupResourceSelection1" {
  name         = "Premium"
  plan_id      = aws_backup_plan.BackupPlan.id
  iam_role_arn = aws_iam_role.IamRoleForAwsBackup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "premium"
  }
}
