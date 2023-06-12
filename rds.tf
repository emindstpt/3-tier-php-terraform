# Creating RDS Instance
resource "aws_db_subnet_group" "rds_database" {
  name       = "main"
  subnet_ids = [aws_subnet.db-sub1.id, aws_subnet.db-sub2.id]
tags = {
    Name = "My DB subnet group"
  }
}
resource "aws_db_instance" "rds_database" {
  engine            = "mariadb"
  engine_version    = "10.5.16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  max_allocated_storage = 1000
  storage_type      = "gp2"
  storage_encrypted = false
  auto_minor_version_upgrade = true

  identifier                = "bookstore"
  username                  = "admin"
  password                  = "12345678"
  publicly_accessible       = false
  db_subnet_group_name      = aws_db_subnet_group.bookstore_subnet_group.name
  vpc_security_group_ids    = [aws_security_group.dbsg.id]
  
  skip_final_snapshot = true

  tags = {
    Name = "Bookstore-DB"
  }
}

resource "aws_db_subnet_group" "bookstore_subnet_group" {
  name       = "bookstore-subnet-group"
  subnet_ids = [aws_subnet.public-sub1.id, aws_subnet.public-sub2.id]
}

