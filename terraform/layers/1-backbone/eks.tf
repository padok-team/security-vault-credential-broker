data "aws_eks_cluster" "this" {
  name = local.name
}

resource "aws_iam_role_policy" "kms" {
  role = local.node_group_iam_role_name
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [{
      "Effect" : "Allow",
      "Action" : "kms:*",
      "Resource" : "*"
    }]
  })
}