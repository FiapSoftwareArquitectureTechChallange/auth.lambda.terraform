locals {
  account_id = data.aws_caller_identity.current.account_id
  LabRoleArn = "arn:aws:iam::${local.account_id}:role/${var.LabRoleName}"
}

resource "aws_lambda_function" "burgerroyale_auth_lambda_function" {
  function_name = var.functionName
  role          = local.LabRoleArn
  timeout       = 360
  image_uri     = "${aws_ecr_repository.burgerroyale_auth_ecr_repository.repository_url}:latest"
  package_type  = "Image"

  environment {
    variables = {
      "ConnectionStrings__DefaultConnection" = "Server=${data.aws_db_instance.database.address},1433;Database=${var.dbName};User Id=${var.dbUserName};TrustServerCertificate=True;Password='${var.dbPassword}';Connection Timeout=30;"
      "Jwt__Issuer"                          = var.jwtIssuer
      "Jwt__Audience"                        = var.jwtIssuer
      "Jwt__SecretKey"                       = var.jwtSecret
    }
  }

  vpc_config {
    subnet_ids = [
      data.aws_subnet.private_subnet_1.id,
      data.aws_subnet.private_subnet_2.id
    ]
    security_group_ids = [
      data.aws_security_group.default_security_group.id
    ]
  }
}
