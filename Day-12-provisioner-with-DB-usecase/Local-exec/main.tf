provider "aws" {
  region = "us-west-1"
}


# Create the RDS instance
resource "aws_db_instance" "mysql_rds" {
  identifier              = "my-mysql-db"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  username                = "admin"
  password                = "Cloud123!"
  db_name                 = "babu"
  allocated_storage       = 20
  skip_final_snapshot     = true
  publicly_accessible     = true
}

# Use null_resource to execute the SQL script from your local machine
# resource "null_resource" "local_sql_exec" {
#   depends_on = [aws_db_instance.mysql_rds]

#   provisioner "local-exec" {
#     command = "mysql -h ${aws_db_instance.mysql_rds.address} -u admin -pCloud123! babu < init.sql"
#   }

#   triggers = {
#     always_run = timestamp()
#   }
# }
resource "null_resource" "local_sql_exec" {
  depends_on = [aws_db_instance.mysql_rds]

  provisioner "local-exec" {
    interpreter = ["cmd", "/C"]

    command = "\"C:\\Program Files\\MySQL\\MySQL Server 8.4\\bin\\mysql.exe\" -h ${aws_db_instance.mysql_rds.address} -u admin -pCloud123! babu < init.sql"
  }

  triggers = {
    always_run = timestamp()
  }
}