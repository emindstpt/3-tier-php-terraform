
#create vpc
resource "aws_vpc" "php-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "php-vpc"
  }
}

#creating Public subnets for jump-box server
#Public subnet-1
resource "aws_subnet" "public-sub1" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"

  tags = {
    Name = "public-sub1"
  }
}

#Public subnet-2
resource "aws_subnet" "public-sub2" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1b"

  tags = {
    Name = "public-sub2"
  }
}

#creating Private Subnets
#private subnet1 - Web-app
resource "aws_subnet" "Web-sub1" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Web-sub1"
  }
}

#private subnet2 - Web-app
resource "aws_subnet" "Web-sub2" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Web-sub2"
  }
}

#Private subnet1 - Database
resource "aws_subnet" "db-sub1" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "DB-sub1"
  }
}

#private subnet2 - Database
resource "aws_subnet" "db-sub2" {
  vpc_id     = aws_vpc.php-vpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "DB-sub2"
  }
}

# Creating Internet Gateway 
resource "aws_internet_gateway" "php_igw" {
  vpc_id = aws_vpc.php-vpc.id

  tags = {
    Name = "demoigw"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-sub1.id

  tags = {
    Name = "php-nat"
  }
}

# Create EIP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc      = true
  tags = {
    Name = "php-nat-eip"
  }
}

# Creating Public Route Table
resource "aws_route_table" "Public_rt" {
    vpc_id = aws_vpc.php-vpc.id
route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.php_igw.id
    }
tags = {
        Name = "Public Rt"
    }
}

# Creating Private Route Table
resource "aws_route_table" "Private_rt" {
    vpc_id = aws_vpc.php-vpc.id

    tags = {
      Name = "Private Rt"
    }
}

# Associate NAT Gateway with the Private Route Table
resource "aws_route" "private_rt_nat_gateway" {
  route_table_id            = aws_route_table.Private_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat_gateway.id

}

# Associating Route Table to jumpbox sunbets
resource "aws_route_table_association" "public_rt_association_subnet1" {
    subnet_id = aws_subnet.public-sub1.id
    route_table_id = aws_route_table.Public_rt.id
}

resource "aws_route_table_association" "public_rt_association_subnet2" {
    subnet_id = aws_subnet.public-sub2.id
    route_table_id = aws_route_table.Public_rt.id
}

# Associating Route Table to web subnets
resource "aws_route_table_association" "private_rt_assocaiation_subnet3" {
    subnet_id = aws_subnet.Web-sub1.id
    route_table_id = aws_route_table.Private_rt.id
}

resource "aws_route_table_association" "private_rt_assocaiation_subnet4" {
    subnet_id = aws_subnet.Web-sub2.id
    route_table_id = aws_route_table.Private_rt.id
}

# Associating Route Table to db sunbets
resource "aws_route_table_association" "private_rt_assocaiation_subnet5" {
    subnet_id = aws_subnet.db-sub1.id
    route_table_id = aws_route_table.Private_rt.id
}

resource "aws_route_table_association" "private_rt_assocaiation_subnet6" {
    subnet_id = aws_subnet.db-sub2.id
    route_table_id = aws_route_table.Private_rt.id
}


