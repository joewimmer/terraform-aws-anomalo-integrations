resource "aws_cloudwatch_event_rule" "cloudwatch" {
  name           = "${var.prefix}-Logs"
  event_bus_name = var.event_bus_arn
  event_pattern = jsonencode({
    source = [var.anomalo_event_source]
  })
}

resource "aws_cloudwatch_event_target" "cloudwatch" {
  rule           = aws_cloudwatch_event_rule.cloudwatch.name
  event_bus_name = var.event_bus_arn
  arn            = aws_lambda_function.cloudwatch.arn
  role_arn       = aws_iam_role.cloudwatch.arn
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}


resource "aws_lambda_function" "cloudwatch" {
  function_name    = "${var.prefix}-Publisher"
  filename         = data.archive_file.lambda_zip.output_path
  handler          = "cloudwatch.main"
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  runtime          = "python3.11"
  role             = aws_iam_role.cloudwatch.arn
  environment {
    variables = {
      LOG_GROUP_NAME = var.anomalo_cloudwatch_log_group_name
    }
  }
}



resource "aws_iam_policy" "cloudwatch" {
  name = "${var.prefix}-Invoke-Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = aws_lambda_function.cloudwatch.arn
      },
      {
        Effect = "Allow",
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams"
        ],
        Resource = "${aws_cloudwatch_log_group.anomalo_events.arn}:*"
      }
    ]
  })
}


resource "aws_iam_role" "cloudwatch" {
  name = "${var.prefix}-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "aws:SourceArn" = aws_cloudwatch_event_rule.cloudwatch.arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_policy" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_log_group" "anomalo_events" {
  name              = var.anomalo_cloudwatch_log_group_name
  retention_in_days = 14
}