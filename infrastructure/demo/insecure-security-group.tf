resource "aws_security_group" "demo" {
  name = "insecure-demo"

  ingress {
    description = "Intentional portfolio security test"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
