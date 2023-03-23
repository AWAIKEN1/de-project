#creates policy document locally for ingestion_lambda to access required S3 resources
data "aws_iam_policy_document" "ingestion_lambda_code_bucket_access" {
  statement {

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.code_bucket.arn}/ingestion_lambda/*"
    ]
  }
  statement {

    actions = ["s3:PutObject", "s3:ListBucket"]

    resources = [
      "${aws_s3_bucket.ingestion_zone_bucket.arn}/*"
    ]
  }
}

#creates above policy in IAM
resource "aws_iam_policy" "ingestion_lambda_code_bucket_access" {
  name_prefix = "s3-access-policy-ingestion-lambda-"
  policy      = data.aws_iam_policy_document.ingestion_lambda_code_bucket_access.json
}

#creates policy locally to allow ingestion_lambda lambda to utilise log group
data "aws_iam_policy_document" "ingestion_lambda_cw_document" {
  statement {

    actions = ["logs:CreateLogStream", "logs:PutLogEvents"]

    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${resource.aws_cloudwatch_log_group.ingestion_lambda_log.name}:*"
    ]
  }
}

# creates above policy in IAM
resource "aws_iam_policy" "ingestion_lamba_cw_policy" {
  name_prefix = "cw-policy-ingestion-lambda-"
  policy      = data.aws_iam_policy_document.ingestion_lambda_cw_document.json
}

# creates lambda role 
resource "aws_iam_role" "ingestion_lambda_role" {
  name_prefix        = "role-ingestion-lambda-"
  assume_role_policy = <<EOF
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "sts:AssumeRole"
                ],
                "Principal": {
                    "Service": [
                        "lambda.amazonaws.com"
                    ]
                }
            }
        ]
    }
    EOF
}

# attach IAM policy to lambda role 
resource "aws_iam_role_policy_attachment" "ingestion_lambda_s3_policy_attachment" {
  role       = aws_iam_role.ingestion_lambda_role.name
  policy_arn = aws_iam_policy.ingestion_lambda_code_bucket_access.arn
}

resource "aws_iam_role_policy_attachment" "ingestion_lambda_cw_policy_attachment" {
  role       = aws_iam_role.ingestion_lambda_role.name
  policy_arn = aws_iam_policy.ingestion_lamba_cw_policy.arn
}