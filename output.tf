
output "aws_resource_info" {
    value = {
        vpc_id = aws_vpc.eks_vpc.id
        vpc_arn = aws_vpc.eks_vpc.arn
        public_subnet_a_id = aws_subnet.eks_pub_sub_one.id
        public_subnet_b_id = aws_subnet.eks_pub_sub_two.id
        static_elastic_id = aws_eip.nat_eip.id
        cluster_arn = aws_eks_cluster.eks_cluster.kubeconfig
    }
    description = "EKS cluster resources general information"
}
