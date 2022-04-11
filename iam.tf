data "aws_iam_policy_document" "ecs_task_execution_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_data_bucket_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["s3:GetObject"]

    resources = ["*"]
  }

  statement {
    sid       = ""
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["*"]
  }

}

resource "aws_iam_role" "ecs_task_execution_role" {
  name                 = "${local.name_prefix}-ecs-execution-role"
  assume_role_policy   = data.aws_iam_policy_document.ecs_task_execution_role.json
  permissions_boundary = var.permissions_boundary
  tags                 = var.tags
}

resource "aws_iam_role" "ecs_instance_role" {
  name               = "${local.name_prefix}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_custom_role_policy_attach" {
  # TODO: Get this to work with for_each instead of count
  # for_each = toset(var.custom_iam_policies)
  # policy_arn = each.value
  count      = length(var.custom_iam_policies)
  policy_arn = var.custom_iam_policies[count.index]
  role       = aws_iam_role.ecs_instance_role.name
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${local.name_prefix}-s3-policy"
  policy = data.aws_iam_policy_document.s3_data_bucket_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy_attach_s3" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_policy" "ssm" {
  name        = "${local.name_prefix}-ssm-policy"
  description = "ssm policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:Describe*",
        "ssm:Get*",
        "ssm:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "secrets" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.secrets.arn
}

resource "aws_iam_policy" "secrets" {
  name        = "${local.name_prefix}-secrets-policy"
  description = "secrets policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "secretsmanager:*",
                "cloudformation:CreateChangeSet",
                "cloudformation:DescribeChangeSet",
                "cloudformation:DescribeStackResource",
                "cloudformation:DescribeStacks",
                "cloudformation:ExecuteChangeSet",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:DescribeKey",
                "kms:ListAliases",
                "kms:ListKeys",
                "lambda:ListFunctions",
                "rds:DescribeDBClusters",
                "rds:DescribeDBInstances",
                "redshift:DescribeClusters",
                "tag:GetResources"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Action": [
                "lambda:AddPermission",
                "lambda:CreateFunction",
                "lambda:GetFunction",
                "lambda:InvokeFunction",
                "lambda:UpdateFunctionConfiguration"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:lambda:*:*:function:SecretsManager*"
        },
        {
            "Action": [
                "serverlessrepo:CreateCloudFormationChangeSet",
                "serverlessrepo:GetApplication"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:serverlessrepo:*:*:applications/SecretsManager*"
        },
        {
            "Action": [
                "s3:GetObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::awsserverlessrepo-changesets*",
                "arn:aws:s3:::secrets-manager-rotation-apps-*/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_execution_role_custom_policy" {
  for_each    = toset(var.ecs_task_execution_role_custom_policies)
  name        = "${local.name_prefix}-ecs-task-execution-role-custom-policy"
  description = "A custom policy for ${local.name_prefix}-ecs-task-execution-role IAM Role"
  policy      = each.value
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_custom_policy" {
  for_each   = aws_iam_policy.ecs_task_execution_role_custom_policy
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = each.value.arn
}

