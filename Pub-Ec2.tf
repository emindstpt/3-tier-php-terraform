# Creating 1st EC2 instance in Public Subnet1
resource "aws_instance" "jumpbox" {
  ami                         = "ami-049a62eb90480f276"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "eminds"
  vpc_security_group_ids      = [aws_security_group.jumpsg.id]
  subnet_id                   = aws_subnet.public-sub1.id
  associate_public_ip_address = true
  

tags = {
    Name = "Jumpbox-Ec2"
  }
}

# Creating 1st EC2 instance in Public Subnet1
resource "aws_instance" "Web1" {
  ami                         = "ami-049a62eb90480f276"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "eminds"
  vpc_security_group_ids      = [aws_security_group.Websg.id]
  subnet_id                   = aws_subnet.Web-sub1.id
  associate_public_ip_address = false
  user_data                   = <<-EOT
  #!/bin/bash
    yum update -y
    yum install git -y
    yum install -y httpd wget php-fpm php-mysqli php-json php php-devel
    systemctl start httpd
    systemctl enable httpd
    systemctl status httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    git clone https://github.com/Akiranred/php-lamp.git /var/www/html
    cd /var/www/html/php
    sudo bash -c 'echo "<?php
    function Createdb(){
      \$servername = \"${aws_db_instance.rds_database.endpoint}\";
      \$username = \"admin\";
      \$password = \"12345678\";
      \$dbname = \"bookstore\";

      // create connection
      \$con = mysqli_connect(\$servername, \$username, \$password);

      // Check Connection
      if (!\$con){
          die(\"Connection Failed : \" . mysqli_connect_error());
      }

      // create Database
      \$sql = \"CREATE DATABASE IF NOT EXISTS \$dbname\";

      if(mysqli_query(\$con, \$sql)){
          \$con = mysqli_connect(\$servername, \$username, \$password, \$dbname);

          \$sql = \"
                          CREATE TABLE IF NOT EXISTS books(
                              id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
                              book_name VARCHAR (25) NOT NULL,
                              book_publisher VARCHAR (20),
                              book_price FLOAT
                          );
         \";

          if(mysqli_query(\$con, \$sql)){
              return \$con;
          }else{
              echo \"Cannot Create table...!\";
          }

      }else{
          echo \"Error while creating database \" . mysqli_error(\$con);
      }

    }
    ?>" > /var/www/html/php/db.php'
    systemctl restart httpd
    EOT

tags = {
    Name = "Web-Ec2-1"
  }
}

# Creating 2nd EC2 instance in Public Subnet2
resource "aws_instance" "Web2" {
  ami                         = "ami-049a62eb90480f276"
  instance_type               = "t2.micro"
  count                       = 1
  key_name                    = "eminds"
  vpc_security_group_ids      = [aws_security_group.Websg.id]
  subnet_id                   = aws_subnet.Web-sub2.id
  associate_public_ip_address = false
  user_data                   = <<-EOT
  #!/bin/bash
    yum update -y
    yum install git -y
    yum install -y httpd wget php-fpm php-mysqli php-json php php-devel
    systemctl start httpd
    systemctl enable httpd
    systemctl status httpd
    usermod -a -G apache ec2-user
    chown -R ec2-user:apache /var/www
    git clone https://github.com/Akiranred/php-lamp.git /var/www/html
    cd /var/www/html/php
    sudo bash -c 'echo "<?php
    function Createdb(){
      \$servername = \"${aws_db_instance.rds_database.endpoint}\";
      \$username = \"admin\";
      \$password = \"12345678\";
      \$dbname = \"bookstore\";

      // create connection
      \$con = mysqli_connect(\$servername, \$username, \$password);

      // Check Connection
      if (!\$con){
          die(\"Connection Failed : \" . mysqli_connect_error());
      }

      // create Database
      \$sql = \"CREATE DATABASE IF NOT EXISTS \$dbname\";

      if(mysqli_query(\$con, \$sql)){
          \$con = mysqli_connect(\$servername, \$username, \$password, \$dbname);

          \$sql = \"
                          CREATE TABLE IF NOT EXISTS books(
                              id INT(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
                              book_name VARCHAR (25) NOT NULL,
                              book_publisher VARCHAR (20),
                              book_price FLOAT
                          );
         \";

          if(mysqli_query(\$con, \$sql)){
              return \$con;
          }else{
              echo \"Cannot Create table...!\";
          }

      }else{
          echo \"Error while creating database \" . mysqli_error(\$con);
      }

    }
    ?>" > /var/www/html/php/db.php'
    systemctl restart httpd
    EOT

tags = {
    Name = "Web-Ec2-2"
  }
}

# Creating Security Group 
resource "aws_security_group" "jumpsg" {
  vpc_id = aws_vpc.php-vpc.id
  #inboud rules for jump box
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "Websg" {
  vpc_id = aws_vpc.php-vpc.id
  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
    ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# for database server
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


# Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "Web-SG"
  }
}
