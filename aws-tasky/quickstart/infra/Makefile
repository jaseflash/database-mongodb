.PHONY: fmt clean infra all

all: infra getIngress
scan: pre-scan post-scan

infra: fmt
	@terraform init
	@-terraform apply -auto-approve
	@terraform apply -auto-approve

getIngress:
	@. ../../scripts/kubectl_connect_eks.sh .
	@echo ""
	@echo "Tasky URL - http://`kubectl -n tasky get ingress -o json | jq -r '.items[].status.loadBalancer.ingress[].hostname'`"
clean:
	@-kubectl delete -f ../k8s-service
	@-helm uninstall -n kube-system aws-load-balancer-controller
	@-kubectl delete -n kube-system sa aws-load-balancer-controller
	@-terraform destroy -auto-approve