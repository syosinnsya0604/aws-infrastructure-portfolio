resource "aws_db_subnet_group" "main" {
  name = "aws-infra-portfolio-db-subnet-group"

  subnet_ids = [
    aws_subnet.db_1a.id,
    aws_subnet.db_1c.id
  ]

  tags = {
    Name = "aws-infra-portfolio-db-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier = "aws-infra-portfolio-db"

  engine         = "postgres"
  engine_version = "17"

  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 20
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "equipmentdb"
  username = "dbadmin"

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    aws_security_group.rds.id
  ]

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1

  deletion_protection = false
  skip_final_snapshot = true

  tags = {
    Name = "aws-infra-portfolio-db"
  }
}