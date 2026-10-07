# AWS Network Architecture

## Objective

Provide a multi-AZ AWS network foundation for the Secure Travel Journal
Platform while separating internet-facing, application and database
trust zones.

## VPC

CIDR:

`10.40.0.0/16`

Region:

`eu-west-2`

Availability Zones:

- eu-west-2a
- eu-west-2b

## Public tier

Public subnets are reserved for internet-facing AWS-managed resources
such as the future Application Load Balancer.

Automatic public IPv4 assignment is disabled.

Public subnets route internet traffic through the VPC Internet Gateway.

## Application tier

EKS workloads run in private subnets.

Private subnets have no direct route to the Internet Gateway.

Outbound internet connectivity is provided through an AWS Regional NAT
Gateway.

## Database tier

Database subnets are isolated.

They do not contain default internet or NAT routes.

Future RDS PostgreSQL instances are placed exclusively in these subnets.

## EKS subnet discovery

Public subnets use:

`kubernetes.io/role/elb = 1`

Private workload subnets use:

`kubernetes.io/role/internal-elb = 1`

## Network telemetry

VPC Flow Logs capture accepted and rejected network traffic.

Logs are stored in an encrypted CloudWatch Logs group using a dedicated
KMS key.

## Security boundaries

Internet
→ public load-balancer tier
→ private EKS application tier
→ isolated database tier

The design does not permit direct internet routing to EKS nodes or
database subnets.