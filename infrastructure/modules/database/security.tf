resource "aws_security_group" "application_db_client" {
  #checkov:skip=CKV2_AWS_5:Application database-client security group is intentionally pre-created for attachment to application workloads in a subsequent deployment phase.

  name        = "${var.name_prefix}-app-db-client"
  description = "Security group for workloads permitted to connect to PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.name_prefix}-app-db-client"
    Purpose = "application-database-client"
  }
}

resource "aws_security_group" "database" {
  name        = "${var.name_prefix}-postgresql"
  description = "Security group protecting PostgreSQL"
  vpc_id      = var.vpc_id

  tags = {
    Name    = "${var.name_prefix}-postgresql"
    Purpose = "database"
  }
}

resource "aws_vpc_security_group_ingress_rule" "database_from_application" {
  security_group_id = aws_security_group.database.id

  referenced_security_group_id = aws_security_group.application_db_client.id

  ip_protocol = "tcp"

  from_port = var.database_port
  to_port   = var.database_port

  description = "PostgreSQL from approved application workloads only"
}

resource "aws_vpc_security_group_egress_rule" "application_to_database" {
  security_group_id = aws_security_group.application_db_client.id

  referenced_security_group_id = aws_security_group.database.id

  ip_protocol = "tcp"

  from_port = var.database_port
  to_port   = var.database_port

  description = "Application access to PostgreSQL only"
}