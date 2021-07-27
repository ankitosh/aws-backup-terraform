# ################################################################
# . Author : Ankit Upadhyay
# . Follow me on github for more aws maintainance resources  http://github.com/ankitosh
# 
# ################################################################

resource "aws_iam_role" "IamRoleForAwsBackup" {
  name               = "Silver_Backup_Role"
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
  name        = "Silver_Backup_Vault"
  kms_key_arn = aws_kms_key.backup_key.arn
}

resource "aws_backup_plan" "BackupPlan" {
  name = "Silver_Backup_Plan"

  rule {
    rule_name         = "Silver_Backup_Daily"
    schedule          = "cron(0 5 ? * * *)"
    target_vault_name = aws_backup_vault.BackupVault1.id
    lifecycle {
      delete_after = 7
    }
  }
}

resource "aws_backup_selection" "BackupResourceSelection1" {
  name         = "Silver_Backup_resource"
  plan_id      = aws_backup_plan.BackupPlan.id
  iam_role_arn = aws_iam_role.IamRoleForAwsBackup.arn

  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = "silver"
  }
}
