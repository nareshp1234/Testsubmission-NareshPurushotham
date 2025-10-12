resource "aws_db_subnet_group" "db_subnet" {
  name       = "${var.project}-db-subnet"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_kms_key" "rds_key" {
  description = "KMS key for RDS encryption"
}

resource "aws_db_instance" "postgres" {
  identifier              = "${var.project}-db"
  engine                  = "postgres"
  engine_version          = "15.7-R4"
  instance_class          = "db.t3.micro"
  db_name                 = "bankdb"
  username                = var.db_username
  password                = var.db_password
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.db_subnet.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_encrypted       = true
  kms_key_id              = aws_kms_key.rds_key.arn
  deletion_protection     = false
  backup_retention_period = 7
  tags = { Name = "${var.project}-rds" }
}
