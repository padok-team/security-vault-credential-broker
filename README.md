# Purpose
This GitHub repository contains code for deploying a proof of concept of Vault as a credential broker for Boundary, with a PostgreSQL database as target.

This article explains the code: https://security.padok.fr/blog/vault-credential-broker 

# Installation

## Tools

You should have all these tools installed: 

* terraform: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

* AWS CLI: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

* Helm: https://helm.sh/docs/intro/install/

* direnv: https://direnv.net/

## Prerequisites

* Clone this repository

* Have a VPC with 2 subnets and an EKS cluster deployed on AWS

* Create AWS profile "padok_univ_3" in ~/.aws/config, or if you want to use a profile of yours, search each occurence of "padok_univ_3" and replace them with your profile name
  * then `direnv allow`

* Login to AWS: `aws sso login`

* Replace domain name with your domain name: search each occurence of "padok.school" and replace them with your domain name

## Bootstrap

* Create terraform backend for remote state: in folder `terraform/layers/0-bootstrap`
   * `terraform init`
   * `terraform apply`

## Backbone

- Create RDS, EIP and KMS keys: in folder `terraform/layers/1-backbone`
   * In file locals.tf: 
     * Replace local.name with your EKS cluster name
     * Complete vpc_id and vpc_private_subnets_ids with your VPC information
     * Complete node_group_iam_role_name with the name of the node group's iam role of your cluster
   * `terraform init`
   * `terraform apply`

## Install an EBS CSI Driver
  
- Add the SSO role in aws-auth for admin : `AWSReservedSSO_AdministratorAccess_2b50550798c1af39` to permit access to the cluster

```bash
eksctl create iamidentitymapping --cluster poc-vcb --region=eu-west-3 \
    --arn arn:aws:iam::405157225880:role/aws-reserved/sso.amazonaws.com/eu-west-2/AWSReservedSSO_AdministratorAccess_2b50550798c1af39 --username admin --group eks-console-dashboard-full-access-group \
    --no-duplicate-arns
```

- Install the ebs-csi-driver
```bash
eksctl create iamserviceaccount --name ebs-csi-controller-sa --namespace kube-system --cluster poc-vcb --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy --approve --role-only --role-name AmazonEKS_EBS_CSI_DriverRole --profile padok_univ_3
eksctl create addon --name aws-ebs-csi-driver --service-account-role-arn arn:aws:iam::$(aws sts get-caller-identity --profile padok_univ_3 | jq -r '.Account'):role/AmazonEKS_EBS_CSI_DriverRole --cluster poc-vcb --profile padok_univ_3
```

## Boundary installation

- Create POSTGRESQL database for Boundary
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install postgresql bitnami/postgresql -n boundary --create-namespace
kubectl get secret --namespace boundary postgresql -o jsonpath="{.data.postgres-password}" | base64 -d
```

- __/!\ WARNING:__ If you have a single node cluster, you need to check in which zone your node is:
  ```bash
  kubectl get nodes
  kubectl describe node <NODE_ID>
  ```
  Look for zone in result, for example: `topology.kubernetes.io/zone=eu-west-3a`

- In helm/boundary-controller, edit values.yaml file:
  * service.beta.kubernetes.io/aws-load-balancer-eip-allocations: eipalloc-xxxxxxxx,eipalloc-yyyyyyyy
    * write eip ids of both boundary-controller eip
  * public_cluster_ip: "xx.xx.xx.xx"
    * change ip with a controller elastic ip created for controller in backbone/eip.tf

      __/!\ WARNING:__ If you have a single node cluster, you need to use the first elastic ip you wrote in the controller load balancer config if your node is in the first zone, else the second elastic ip
  * postgres_url: "postgresql://postgres:xxxxxxxx@postgresql.boundary.svc.cluster.local:5432/postgres"
    * write password of your POSTGRESQL database that you got at the end of the previous step when you created the database
  * kms:
      root: "xxxxxxxx"
      worker: "xxxxxxxx"
      recovery: "xxxxxxxx"
    * write kms key ids

- In helm/boundary-worker, edit values.yaml file:
  * service.beta.kubernetes.io/aws-load-balancer-eip-allocations: eipalloc-xxxxxxxx,eipalloc-yyyyyyyy
    * write eip ids of both boundary-worker eip
  * controller:
      ip: "xx.xx.xx.xx"
    * change ip with the same controller elastic ip you used in values.yaml of boundary controller
  * kms:
      worker: "xxxxxxxx"
    * write worker kms key id
  * config.hostname + ingress.hosts.host :
    * change both ips with the worker elastic ip __in the zone where your node is__ (eip created for worker in backbone/eip.tf)

     __/!\ WARNING:__ If you have a single node cluster, you need to use the first elastic ip you wrote in the worker load balancer config if your node is in the first zone, else the second elastic ip


- Install boundary
```bash
helm install boundary-controller -n boundary . #in helm/boundary-controller
helm install boundary-worker -n boundary . #in helm/boundary-worker
```

- Wait for network load balancers to be active, then restart boundary-controller and boundary-worker deployments

## Populate RDS 

* Ouvrir un shell dans un des pods boundary
* Install postgresl : `apk add postgresql`
* Copy both files of rds folder in pod : northwind-database.sql et northwind-roles.sql
* Populate RDS with these commands ($PG_URL is connexion url to RDS: postgresql://{user}:{password}@{rds_endpoint}:5432/postgres)
```bash
$ psql -d $PG_URL -f northwind-database.sql
$ psql -d $PG_URL -f northwind-roles.sql
```

## DNS
  
- Apply the `2-dns` layer

## Vault installation and configuration

- Install vault
```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install vault hashicorp/vault -n vault --create-namespace
```

- Initialize vault
```bash
kubectl exec -it vault-0 -n vault -- /bin/sh
$ vault operator init # /!\ Note three unseal keys and initial root token
$ vault operator unseal <key1>
$ vault operator unseal <key2>
$ vault operator unseal <key3>
```

- Port-forward the Vault service
```bash
kubectl port-forward svc/vault -n vault 8200:8200
```

- In `3-vault/providers.tf`, edit token with your initial root token

- Apply `3-vault` layer

## Boundary configuration

- __/!\ WARNING:__ As stated in this [documentation](https://developer.hashicorp.com/boundary/docs/configuration/kms/awskms), you need to provide access_key, secret_key and session token from SSO and export is as env variables
```bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

- Then, port-forward the Boundary service
```bash
kubectl port-forward svc/boundary-controller-api -n boundary 9200:80
```

- Apply `4-boundary` layer 

# Usage

To log into Boundary (password: \$uper\$ecure):

`boundary authenticate password -addr http://boundary-api.padok.school -auth-method-id <AUTH_METHOD_ID> -login-name jeff`

To list organization:

`boundary scopes list -addr http://boundary-api.padok.school`

To list projects in organization:

`boundary scopes list -addr http://boundary-api.padok.school -scope-id <ORG_ID>`

To list targets in project:

`boundary targets list -addr http://boundary-api.padok.school -scope-id <PROJECT_ID>`

To connect to PostgreSQL target:

`boundary connect postgres -target-id <TARGET_ID> -addr http://boundary-api.padok.school -dbname postgres`


