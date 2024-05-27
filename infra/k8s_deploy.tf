data "kubectl_filename_list" "manifests" {
  pattern = "/Users/jasonbroadbent/jason/learn-consul-kubernetes/AWS_EKS/Seb/consul-aws-eks-terraform/scripts/vm/Mongo/tasky/aws-tasky-main/quickstart/infra/k8s-service/*.yaml"
}
resource "kubectl_manifest" "test" {
  count     = length(data.kubectl_filename_list.manifests.matches)
  yaml_body = file(element(data.kubectl_filename_list.manifests.matches, count.index))
}