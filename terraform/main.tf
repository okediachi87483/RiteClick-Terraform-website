# ---------------------------------------------------------
# Default VPC
# ---------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------------
# New Security Group (HTTP + SSH)
# ---------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "database-secgroup"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  # Allow HTTP (port 80)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow SSH (port 22)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "database-secgroup"
  }
}

# ---------------------------------------------------------
# EC2 Instance (Ubuntu)
# ---------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0b6d9d3d33ba97d99"   # Ubuntu AMI (us-east-1)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name               = "my-password"

  # -------------------------------------------------------
  # Embedded user-data script (Ubuntu)
  # -------------------------------------------------------
  user_data = <<-EOF
    #!/bin/bash
    apt update -y
    apt install -y apache2 git

    systemctl enable apache2
    systemctl start apache2

    # Clone your GitHub repo (must be public)
    REPO_URL="https://github.com/okediachi87483/RiteClick-Terraform-website.git"

    cd /tmp
    git clone "$REPO_URL"

    # Copy website files to Apache document root
    cp -r /tmp/RiteClick-Terraform-website/website/* /var/www/html/

    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
  EOF

  tags = {
    Name = "rite-click-web"
  }
}

# ---------------------------------------------------------
# Outputs
# ---------------------------------------------------------
output "instance_public_ip" {
  description = "Public IP of the web server"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the web server"
  value       = aws_instance.web.public_dns
}
