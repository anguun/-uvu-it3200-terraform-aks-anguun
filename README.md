
This project uses Terraform to build a small Kubernetes cluster on Azure, a private registry for container images, and the permissions that let them work together. It then runs a test nginx web app from that private registry.

Files
*main.tf - resource group, registry, cluster, role assignment
*service_principal.tf - optional service principal
*variables.tf - outputs.tf, versions.tf - inputs, outputs, providers
*k8s/ - deplyoment and service for the test app
*terraform.tfvars.example - copy to treraform.tfvars and fill in



How to run it
*You need Terraform, Azure CLI, kubectl and kubelogin.
az login
copy terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

Deploy the test app:
az acr import -n acruvuit3200anguun --source docker.io/library/nginx:stable --image nginx:stable
az aks get-credentials -g rg-uvu-it3200-anguun -n aks-uvu-it3200-anguun
kubelogin convert-kubeconfig -l azurecli
kubectl apply -f k8s/namespace.yaml
(Get-Content k8s/deployment.yaml) -replace 'REPLACE_ACR','acruvuit3200anguun.azurecr.io' | kubectl apply -f -
kubectl apply -f k8s/service.yaml

kubectl get pods -n demo-app
kubectl port-forward -n demo-app svc/web 8080:80
Open http://localhost:8080 to see the nginx page.

verify
The node showed Ready
The pod showed Running
The pod's image was acruvuit3200anguun.azurecr.io/nginx:stable, so it was pulled from my private registry.
The nginx page loaded at http://localhost:8080

terraform destroy
to be done with
