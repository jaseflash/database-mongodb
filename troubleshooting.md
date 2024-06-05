<!-- TOC -->

- [Troubleshooting](#troubleshooting)
    - [AWS EC2 - Helpful Commands](#aws-ec2---helpful-commands)
    - [AWS EC2 - Review Cloud-init execution](#aws-ec2---review-cloud-init-execution)
    - [AWS EC2 - logs](#aws-ec2---logs)
    - [AWS EC2 - Test client connectivity with nc](#aws-ec2---test-client-connectivity-with-nc)
  - [EKS / Kubernetes](#eks--kubernetes)
    - [EKS - Login / Set Context](#eks---login--set-context)
    - [Attach debug container to pod to run additional commands (tcpdump, netstat, dig, curl, etc...)](#attach-debug-container-to-pod-to-run-additional-commands-tcpdump-netstat-dig-curl-etc)
    - [Get Security Context of all Pods in all namespaces](#get-security-context-of-all-pods-in-all-namespaces)

<!-- /TOC -->
# Troubleshooting

## AWS EC2 / VM

### AWS EC2 - Helpful Commands

SCP file through public bastion from K8s cluster to an internal VM.
```
scp -o 'ProxyCommand ssh ubuntu@54.202.45.196 -W %h:%p' ./ca.pem ubuntu@10.17.1.130:/tmp/ca.pem
```

Generate AWS kubeconfig file for VM (`cluster-name: jase-usw2-consul1`)
```
aws eks --region us-west-2 update-kubeconfig --name jase-usw2-consul1 --kubeconfig ./kubeconfig
```

### AWS EC2 - Review Cloud-init execution
When a user data script is processed, it is copied to and run from /var/lib/cloud/instances/instance-id/. The script is not deleted after it is run and can be found in this directory with the name user-data.txt.  
```
sudo cat /var/lib/cloud/instance/user-data.txt
```
The cloud-init log captures mongo output of the user-data script run.
```
sudo cat /var/log/cloud-init-output.log
```

### AWS EC2 - logs
To investigate systemd errors starting consul use `journalctl`.  
```
journalctl -u mongod -xn | less
```
pipe to less to avoid line truncation in terminal

### AWS EC2 - Test client connectivity with nc
```
ping $ip
nc -zv 35.162.230.47 27017   # TCP Test to remote port
nc -zvu 35.162.230.47 27017  # UDP 27017
nc -zv  35.162.230.47 27017  # TCP 27017
```

## EKS / Kubernetes

### EKS - Login / Set Context
Set default Namespace in current context
```
kubectl config set-context --current --namespace=consul
```

Label node
```
kubectl label nodes ip-10-15-1-126.us-west-2.compute.internal nodetype=tasky
```

### Attach debug container to pod to run additional commands (tcpdump, netstat, dig, curl, etc...)
```
kubectl -n fortio-baseline debug -it $POD_NAME --image=nicolaka/netshoot
#kubectl -n fortio-baseline debug -q -i $POD_NAME --image=nicolaka/netshoot
kubectl -n web debug -it $POD_NAME --target consul-dataplane --image nicolaka/netshoot -- tcpdump -i eth0 dst port 20000 -A
```

### Get Security Context of all Pods in all namespaces
```
kubectl get pods --all-namespaces -o go-template \
    --template='{{range .items}}{{"pod: "}}{{.metadata.name}}
{{if .spec.securityContext}}
  PodSecurityContext:
    {{"runAsGroup: "}}{{.spec.securityContext.runAsGroup}}                               
    {{"runAsNonRoot: "}}{{.spec.securityContext.runAsNonRoot}}                           
    {{"runAsUser: "}}{{.spec.securityContext.runAsUser}}                                 {{if .spec.securityContext.seLinuxOptions}}
    {{"seLinuxOptions: "}}{{.spec.securityContext.seLinuxOptions}}                       {{end}}
{{else}}PodSecurity Context is not set
{{end}}{{range .spec.containers}}
{{"container name: "}}{{.name}}
{{"image: "}}{{.image}}{{if .securityContext}}                                      
    {{"allowPrivilegeEscalation: "}}{{.securityContext.allowPrivilegeEscalation}}   {{if .securityContext.capabilities}}
    {{"capabilities: "}}{{.securityContext.capabilities}}                           {{end}}
    {{"privileged: "}}{{.securityContext.privileged}}                               {{if .securityContext.procMount}}
    {{"procMount: "}}{{.securityContext.procMount}}                                 {{end}}
    {{"readOnlyRootFilesystem: "}}{{.securityContext.readOnlyRootFilesystem}}       
    {{"runAsGroup: "}}{{.securityContext.runAsGroup}}                               
    {{"runAsNonRoot: "}}{{.securityContext.runAsNonRoot}}                           
    {{"runAsUser: "}}{{.securityContext.runAsUser}}                                 {{if .securityContext.seLinuxOptions}}
    {{"seLinuxOptions: "}}{{.securityContext.seLinuxOptions}}                       {{end}}{{if .securityContext.windowsOptions}}
    {{"windowsOptions: "}}{{.securityContext.windowsOptions}}                       {{end}}
{{else}}
    SecurityContext is not set
{{end}}
{{end}}{{end}}'
```
