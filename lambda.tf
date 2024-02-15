data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#data "archive_file" "lambda" {
#  type        = "zip"
#  source_file = "lambda.js"
#  output_path = "lambda_function_payload.zip"
#}

resource "aws_lambda_function" "test_lambda" {
  filename      = "./lambda_function/lambda_function.zip"
  function_name = "${var.name_prefix}-hello-world"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "python3.10"
  handler       = "lambda_function.lambda_handler"
}