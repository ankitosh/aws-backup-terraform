# ################################################################
# . Author : Ankit Upadhyay
# . Follow me on github for more aws maintainance resources  http://github.com/ankitosh
# 
# ################################################################

resource "aws_iam_role" "IamRoleForAwsBackup" {
  name               = "Gold_Backup_Role"
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
  name        = "Gold_Backup_Vault"
  kms_key_arn = aws_kms_key.backup_key.arn
}

resource "aws_backup_plan" "BackupPlan" {
  name = "Gold_Backup"

  rule {
    rule_name         = "Gold_Daily_Backup_Rule"
    schedule          = "cron(0 0 * * ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 31
    }
  }
  rule {
    rule_name         = "Gold_Monthly_Backup_Role"
    schedule          = "cron(0 0 1 1/1 ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 365
    }
  }
  rule {
    rule_name         = "Gold_Yearly_Backup_Rule"
    schedule          = "cron(0 0 31 12 ? *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 2555
    }
  }
}

resource "aws_backup_selection" "BackupResourceSelection1" {
  name         = "Gold_Backup_Select"
  plan_id      = aws_backup_plan.BackupPlan.id
  iam_role_arn = aws_iam_role.IamRoleForAwsBackup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "gold"
  }
}
