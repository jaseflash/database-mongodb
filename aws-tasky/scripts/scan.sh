#!/bin/bash
trivy container and namespace testing
echo "Running trivy image scan on tasky"
trivy image --severity HIGH,CRITICAL jaseflash1234/tasky:1.3
echo
echo "Running trivy k8s deployment scan on tasky namespace"
trivy k8s --include-namespaces kube-system --report summary 
trivy k8s --include-namespaces tasky --report summary
echo
echo "Running trivy aws scan to see S3 bucket findings"
trivy aws