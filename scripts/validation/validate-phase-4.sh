#!/usr/bin/env bash

set -euo pipefail

REGION="${AWS_REGION:-eu-west-2}"
TF_DIR="${TF_DIR:-infrastructure/environments/dev}"

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

terraform_output() {
  terraform -chdir="${TF_DIR}" output -raw "$1"
}

echo "=== Phase 4 Platform Validation ==="

VPC_ID="$(terraform_output vpc_id)"
CLUSTER_NAME="$(terraform_output eks_cluster_name)"
DB_RESOURCE_ID="$(terraform_output rds_instance_id)"

[[ -n "${VPC_ID}" ]] || fail "VPC ID unavailable"
[[ -n "${CLUSTER_NAME}" ]] || fail "EKS cluster name unavailable"
[[ -n "${DB_RESOURCE_ID}" ]] || fail "RDS resource ID unavailable"

pass "Terraform platform outputs available"

CLUSTER_STATUS="$(
  aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${REGION}" \
    --query 'cluster.status' \
    --output text
)"

[[ "${CLUSTER_STATUS}" == "ACTIVE" ]] \
  || fail "EKS cluster is not ACTIVE"

pass "EKS cluster is ACTIVE"

PRIVATE_API="$(
  aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${REGION}" \
    --query 'cluster.resourcesVpcConfig.endpointPrivateAccess' \
    --output text
)"

[[ "${PRIVATE_API}" == "True" ]] \
  || fail "EKS private API endpoint is disabled"

pass "EKS private API endpoint is enabled"

OPEN_API="$(
  aws eks describe-cluster \
    --name "${CLUSTER_NAME}" \
    --region "${REGION}" \
    --query "contains(cluster.resourcesVpcConfig.publicAccessCidrs, '0.0.0.0/0')" \
    --output text
)"

[[ "${OPEN_API}" != "True" ]] \
  || fail "EKS public API allows 0.0.0.0/0"

pass "EKS API is not internet-open"

RDS_DETAILS="$(
  aws rds describe-db-instances \
    --filters "Name=dbi-resource-id,Values=${DB_RESOURCE_ID}" \
    --region "${REGION}" \
    --query 'DBInstances[0].[DBInstanceStatus,PubliclyAccessible,StorageEncrypted,DeletionProtection]' \
    --output text
)"

[[ -n "${RDS_DETAILS}" ]] || fail "RDS instance was not found"

read -r RDS_STATUS RDS_PUBLIC RDS_ENCRYPTED RDS_DELETION_PROTECTION \
  <<< "${RDS_DETAILS}"

[[ "${RDS_STATUS}" == "available" ]] \
  || fail "RDS instance is not available"

pass "RDS is available"

[[ "${RDS_PUBLIC}" == "False" ]] \
  || fail "RDS is publicly accessible"

pass "RDS public access is disabled"

[[ "${RDS_ENCRYPTED}" == "True" ]] \
  || fail "RDS storage encryption is disabled"

pass "RDS storage is encrypted"

[[ "${RDS_DELETION_PROTECTION}" == "True" ]] \
  || fail "RDS deletion protection is disabled"

pass "RDS deletion protection is enabled"

FLOW_LOG_STATUS="$(
  aws ec2 describe-flow-logs \
    --filter "Name=resource-id,Values=${VPC_ID}" \
    --region "${REGION}" \
    --query 'FlowLogs[0].FlowLogStatus' \
    --output text
)"

[[ "${FLOW_LOG_STATUS}" == "ACTIVE" ]] \
  || fail "VPC Flow Logs are not ACTIVE"

pass "VPC Flow Logs are active"

kubectl get nodeclass travel-journal-backend >/dev/null
pass "Backend NodeClass exists"

kubectl get nodepool travel-journal-backend >/dev/null
pass "Backend NodePool exists"

kubectl get networkpolicy default-deny \
  -n travel-journal >/dev/null
pass "Namespace default-deny NetworkPolicy exists"

POD_ID_COUNT="$(
  aws eks list-pod-identity-associations \
    --cluster-name "${CLUSTER_NAME}" \
    --namespace travel-journal \
    --region "${REGION}" \
    --query 'length(associations)' \
    --output text
)"

[[ "${POD_ID_COUNT}" -ge 2 ]] \
  || fail "Expected Pod Identity associations are missing"

pass "Required EKS Pod Identity associations exist"

echo
echo "===================================="
echo "PHASE 4 PLATFORM VALIDATION PASSED"
echo "===================================="