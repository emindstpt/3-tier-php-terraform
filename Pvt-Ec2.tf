# Creating 1st EC2 instance in Private Subnet1
data "aws_db_instance" "rds" {
  db_instance_identifier = aws_db_instance.rds_database.identifier
}

resource "aws_instance" "dbec2-1" {
  ami                         = "ami-049a62eb90480f276"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "eminds"
  vpc_security_group_ids      = [aws_security_group.dbsg.id]
  subnet_id                   = aws_subnet.db-sub1.id
  associate_public_ip_address = false
  user_data                   = <<-EOT
  #!/bin/bash
  yum -y install mariadb105-server
  systemctl start mariadb
  systemctl enable mariadb
  DB_ENDPOINT="${data.aws_db_instance.rds.endpoint}
   EOT
  
tags = {
    Name = "dbec2-1"
  }
}

# Creating 2nd EC2 instance in Private Subnet2

resource "aws_instance" "dbec2-2" {
  ami                         = "ami-049a62eb90480f276"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "eminds"
  vpc_security_group_ids      = [aws_security_group.dbsg.id]
  subnet_id                   = aws_subnet.db-sub2.id
  associate_public_ip_address = false
  user_data                   = <<-EOT
  #!/bin/bash
  yum -y install mariadb105-server
  systemctl start mariadb
  systemctl enable mariadb
  DB_ENDPOINT="${data.aws_db_instance.rds.endpoint}
   EOT

tags = {
    Name = "dbec2-2"
  }
}

# Creating Security Group 
resource "aws_security_group" "dbsg" {
  vpc_id = aws_vpc.php-vpc.id
#inbound rules
ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    description     = "Allow traffic from application layer"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

# Outbound rules
egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

tags = {
    Name = "DB SG"
  }
}




