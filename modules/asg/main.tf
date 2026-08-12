# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template for Flask App Instances
resource "aws_launch_template" "app" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.app_sg_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y python3 python3-pip git

              # Create app directory
              mkdir -p /home/ec2-user/app
              cd /home/ec2-user/app

              # Clone repository to fetch the Flask application files
              git clone https://github.com/Ibad84671/secvault-aws-terraform.git /tmp/repo
              cp -r /tmp/repo/app/* /home/ec2-user/app/
              chown -R ec2-user:ec2-user /home/ec2-user/app

              # Set environment variables for RDS connection
              export DB_HOST="${var.db_host}"
              export DB_USER="${var.db_user}"
              export DB_PASSWORD="${var.db_password}"
              export DB_NAME="${var.db_name}"

              # Fetch requirements and setup Flask app
              pip3 install flask pymysql gunicorn

              # Write systemd service to keep app running in background
              cat << 'SERVICE' > /etc/systemd/system/secvault.service
              [Unit]
              Description=SecVault Flask SOC Dashboard
              After=network.target

              [Service]
              User=root
              WorkingDirectory=/home/ec2-user/app
              Environment="DB_HOST=${var.db_host}"
              Environment="DB_USER=${var.db_user}"
              Environment="DB_PASSWORD=${var.db_password}"
              Environment="DB_NAME=${var.db_name}"
              ExecStart=/usr/local/bin/gunicorn --bind 0.0.0.0:5000 app:app
              Restart=always

              [Install]
              WantedBy=multi-user.target
              SERVICE

              systemctl daemon-reload
              systemctl enable secvault
              systemctl start secvault
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-app-instance"
    }
  }
}

# Auto Scaling Group (Name: secvault-asg to match GUI)
resource "aws_autoscaling_group" "app" {
  name                = "${var.project_name}-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = [var.target_group_arn]

  min_size            = 2
  max_size            = 4
  desired_capacity    = 2

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-asg-instance"
    propagate_at_launch = true
  }
}