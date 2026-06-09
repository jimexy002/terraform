import json

def lambda_handler(event, context):
    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from VEERA NIT')
    }
# resource "aws_lambda_function" "name" {
#   function_name = "my-lambda-function"
#   role          = aws_iam_role.lambda_exec_role.arn
#   handler       = "index.handler"
#   runtime       = "nodejs14.x"
#   filename      = "lambda_function_payload.zip"
# }