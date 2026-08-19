
# ---------------------------------------------------------
# Default VPC
# ---------------------------------------------------------
data "aws_vpc" "default" {
  default = true
}

# ---------------------------------------------------------
# Existing Security Group (database-secgroup)
# ---------------------------------------------------------
data "aws_security_group" "web_sg" {
  name   = "database-secgroup"
  vpc_id = data.aws_vpc.default.id
}

# ---------------------------------------------------------
# EC2 Instance (Ubuntu)
# ---------------------------------------------------------
resource "aws_instance" "web" {
  ami                    = "ami-0b6d9d3d33ba97d99"   # Ubuntu AMI (us-east-1)
  instance_type          = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.web_sg.id]
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
    cp -r /tmp/<YOUR_REPO>/website/* /var/www/html/

    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html
  EOF

  tags = {
    Name = "rite-click-web"
  }
}

