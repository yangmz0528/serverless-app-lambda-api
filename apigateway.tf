resource "aws_api_gateway_rest_api" "helloAPI" {
  name = "${var.name_prefix}-rest-api"
}

resource "aws_api_gateway_resource" "helloResource" {
  parent_id   = aws_api_gateway_rest_api.helloAPI.root_resource_id
  path_part   = "hello"
  rest_api_id = aws_api_gateway_rest_api.helloAPI.id
}

resource "aws_api_gateway_method" "helloMethod" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.helloResource.id
  rest_api_id   = aws_api_gateway_rest_api.helloAPI.id
}

resource "aws_api_gateway_integration" "helloIntegration" {
  http_method = aws_api_gateway_method.helloMethod.http_method
  resource_id = aws_api_gateway_resource.helloResource.id
  rest_api_id = aws_api_gateway_rest_api.helloAPI.id
  type        = "AWS_PROXY"
  uri         = aws_lambda_function.test_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "helloDeployment" {
  rest_api_id = aws_api_gateway_rest_api.helloAPI.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.helloAPI.body,
      aws_api_gateway_method.helloMethod.method,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "example" {
  deployment_id = aws_api_gateway_deployment.helloDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.helloAPI.id
  stage_name    = "dev"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "aws_api_gateway_rest_api.helloAPI.arn/*/*"
  #source_arn = "arn:aws:execute-api:${var.myregion}:${var.accountId}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}