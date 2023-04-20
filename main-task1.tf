# creating a user -devops and a group -engineers w membership in it
resource "aws_iam_user" "username" {
    name = "devops"
}
resource "aws_iam_group" "group_name" {
    name = "engineers"
}
resource "aws_iam_group_membership" "team" {
    name = "tf-testing-membership"

    users = [
        aws_iam_user.username.name,
    ]

    group = aws_iam_group.group_name.name
}
# creating a private S3 bucket 
resource "aws_s3_bucket" "bucket" {
    bucket = "lab-devops-for-storing-tffiles"
    acl = "private"
    versioning {
      enabled = true 
    }

    tags = {
      managed-by = "terraform"
    }
}
#creating our RDS DB 
resource "aws_db_instance" "my_rds" {
  allocated_storage    = 10
  db_name              = "devx"
  engine               = "mysql"
  engine_version       = "8.0.27"
  storage_type         = "gp2"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "passw0rddd123"
  skip_final_snapshot  = true
  publicly_accessible  = true 

  tags = {
    Managed-by = "terraform"
  } 
}
