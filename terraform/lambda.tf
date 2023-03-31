resource "aws_lambda_function" "transform_lambda" {
  function_name    = "transform_lambda"
  role             = aws_iam_role.transformation_lambda_role.arn
  handler          = var.transform_lambda_handler
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.local_file.transform_lambda_archive.filename)
  timeout          = 30
  memory_size      = 192

  // Here's where we specify the code location
  s3_bucket = aws_s3_bucket.code_bucket.bucket
  s3_key    = aws_s3_object.transform_lambda_code.key

  depends_on = [
    aws_s3_object.transform_lambda_code
  ]
  environment {
    variables = {
      OI_STORER_INFO = jsonencode({ "s3_bucket_name" : "${aws_s3_bucket.ingestion_zone_bucket.id}" })
    }
  }
}

resource "aws_lambda_function" "ingestion_lambda" {
  function_name    = "extraction_lambda"
  role             = aws_iam_role.ingestion_lambda_role.arn
  handler          = var.extraction_lambda_handler
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.local_file.ingestion_lambda_archive.filename)
  timeout          = 30
  memory_size      = 192

  // Here's where we specify the code location
  s3_bucket = aws_s3_bucket.code_bucket.bucket
  s3_key    = aws_s3_object.ingestion_lambda_code.key

  depends_on = [
    aws_s3_object.ingestion_lambda_code
  ]
  environment {
    variables = {
      OI_STORER_INFO = jsonencode({ "s3_bucket_name" : "${aws_s3_bucket.ingestion_zone_bucket.id}" })
      OI_TRANSFORM_LAMBDA_INFO = jsonencode({ "transform_lambda_arn" : "${aws_lambda_function.transform_lambda.arn}" })
    }
  }
}

# defines a Lambda function with the name transform_lambda.
# specifies the IAM role to be associated with the Lambda function using the aws_iam_role resource.
# specifies the runtime environment and source code for the Lambda function.
resource "aws_lambda_function" "transform_lambda" {
  function_name    = "transform_lambda"
  role             = aws_iam_role.transform_lambda_role.arn
  handler          = var.transform_lambda_handler
  runtime          = "python3.9"
  source_code_hash = filebase64sha256(data.local_file.transform_lambda_archive.filename)
  timeout          = 30
  memory_size      = 192

  s3_bucket = aws_s3_bucket.code_bucket.bucket
  s3_key    = aws_s3_object.transform_lambda_code.key

  depends_on = [
    aws_s3_object.transform_lambda_code
  ]
}

# defines a CloudWatch event rule which runs every minute
resource "aws_cloudwatch_event_rule" "scheduler" {
  name_prefix         = "ingestion-scheduler-"
  schedule_expression = "rate(1 minute)"
}

# gives permission for the events.amazonaws.com principal to invoke the ingestion_lambda function in response to the scheduler rule
resource "aws_lambda_permission" "allow_scheduler" {
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.ingestion_lambda.function_name
  principal      = "events.amazonaws.com"
  source_arn     = aws_cloudwatch_event_rule.scheduler.arn
  source_account = data.aws_caller_identity.current.account_id
}

# links the ingestion_lambda function with the scheduler rule as a target
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule = aws_cloudwatch_event_rule.scheduler.name
  arn  = aws_lambda_function.ingestion_lambda.arn
}

# gives permission for the lambda.amazonaws.com principal to invoke the transform_lambda function in response to the ingestion_lambda function
resource "aws_lambda_permission" "allow_ingestion_lambda" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transform_lambda.function_name
  principal     = "lambda.amazonaws.com"

  source_arn = aws_lambda_function.ingestion_lambda.arn
}

# # creates a mapping between the ingestion_lambda function and the transform_lambda function as an event source
# resource "aws_lambda_event_source_mapping" "ingestion_lambda_mapping" {
#   event_source_arn = aws_lambda_function.ingestion_lambda.arn
#   function_name    = aws_lambda_function.transform_lambda.function_name
# }