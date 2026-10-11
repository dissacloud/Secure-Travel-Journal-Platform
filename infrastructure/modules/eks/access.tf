resource "aws_eks_access_entry" "administrator" {
  cluster_name = aws_eks_cluster.this.name

  principal_arn = var.admin_principal_arn

  type = "STANDARD"

  tags = {
    Name = "${var.cluster_name}-administrator"
  }
}

resource "aws_eks_access_policy_association" "administrator" {
  cluster_name = aws_eks_cluster.this.name

  principal_arn = aws_eks_access_entry.administrator.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
