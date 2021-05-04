# Boilerplate for a basic AWS infrastructure with EKS cluster

[![Developed by Mad Devs](https://maddevs.io/badge-dark.svg)](https://maddevs.io?utm_source=github&utm_medium=madboiler)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Advantages of this boilerplate

- **Infrastructure as Code (IaC)**: using Terraform, you get an infrastructure that’s smooth and efficient
- **State management**: Terraform saves the current infrastructure state, so you can review further changes without applying them. Also, state can be stored remotely, so you can work on the infrastructure in a team
- **Scalability and flexibility**: the infrastructure built based on this boilerplate can be expanded and updated anytime
- **Comprehensiveness**: you get scaling and monitoring instruments along with the basic infrastructure. You don’t need to manually modify anything in the infrastructure; you can simply make changes in Terraform as needed and deploy them to AWS and Kubernetes
- **Control over resources**: the IaC approach makes the infrastructure more observable and prevents waste of resources
- **Clear documentation**: your Terraform code effectively becomes your project documentation. It means that you can add new members to the team, and it won’t take them too much time to figure out how the infrastructure works

## Why you should use this boilerplate

- **Safe and polished**: we’ve used these solutions in our own large-scale, high-load projects. We’ve been perfecting this infrastructure building process for months, making sure that it results in a system that is safe to use, secure, and reliable
- **Saves time**: you can spend weeks doing your own research and making the unavoidable mistakes to build an infrastructure like this. Instead, you can rely on this boilerplate and create the infrastructure you need within a day
- **It’s free**: we’re happy to share the results of our work

[![boilerplate asciicast](https://asciinema.org/a/wCS0HdC6UViWDKO7GypyIJjaB.png)](https://asciinema.org/a/wCS0HdC6UViWDKO7GypyIJjaB?autoplay=1&speed=2)

## Description

This repository contains the know-how of the Mad Devs team for the rapid deployment of a Kubernetes cluster, supporting services, and the underlying infrastructure in the Amazon cloud. The main development and delivery tool is [terraform](https://www.terraform.io/).

In our company’s work, we have tried many infrastructure solutions and services and traveled the path from on-premise hardware to serverless. As of today, Kubernetes has become our standard platform for deploying applications, and AWS has become the main cloud.

It is worth noting here that although 90% of our and our clients’ projects are hosted on AWS and [AWS EKS](https://aws.amazon.com/eks/) is used as the Kubernetes platform, we do not insist, do not drag everything to Kubernetes, and do not force anyone to be hosted on AWS. Kubernetes is offered only after the collection and analysis of service architecture requirements.

And then, when choosing Kubernetes, it makes almost no difference to applications how the cluster itself is created—manually, through kops or using managed services from cloud providers—in essence, the Kubernetes platform is the same everywhere. So the choice of a particular provider is then made based on additional requirements, expertise, etc.

We know that the current implementation is far from being perfect. For example, we deploy services to the cluster using `terraform`: it is rather clumsy and against the Kuber approaches, but it is convenient for bootstrap because, by using state and interpolation, we convey proper `IDs`, `ARNs`, and other attributes to resources and names or secrets to templates and generate values ​​from them for the required charts all within terraform.

There are more specific drawbacks: the `data "template_file"` resources that we used for most templates are extremely inconvenient for development and debugging, especially if there are 500+ line rolls like `terraform/layer2-k8s/templates/elk-values.yaml`. Also, despite `helm3` got rid of the `tiller`, a large number of helm releases still at some point leads to plan hanging. Partially, but not always, it can be solved by `terraform apply -target`, but for the consistency of the state, it is desirable to execute `plan` and `apply` on the entire configuration. If you are going to use this boilerplate, it is advisable to split the `terraform/layer2-k8s` layer into several ones, taking out large and complex releases into separate modules.

You may reasonably question the number of .tf files. This monolith certainly should be refactored and split into many micro-modules adopting terragrunt approach. This is exactly what we will do in the near future, solving along the way the problems described above.

## Table of contents

- [Architecture diagram](#architecture-diagram)
- [Current infrastructure cost](#current-infrastructure-cost)
- [Namespace structure in the K8S cluster](#namespace-structure-in-the-k8s-cluster)
- [Useful tools](#useful-tools)
- [Useful VSCode extensions](#useful-vscode-extensions)
- [AWS account](#aws-account)
  - [IAM settings](#iam-settings)
  - [Setting up awscli](#setting-up-awscli)
- [How to use this repo](#how-to-use-this-repo)
  - [Getting ready](#getting-ready)
    - [S3 state backend](#s3-state-backend)
    - [Secrets](#secrets)
    - [Domain and SSL](#domain-and-ssl)
  - [Working with terraform](#working-with-terraform)
    - [init](#init)
    - [plan](#plan)
    - [apply](#apply)
  - [terragrunt](#terragrunt)
- [What to do after deployment](#what-to-do-after-deployment)
  - [examples](#examples)
- [Coding conventions](#coding-conventions)
  - [Names and approaches used in code](#names-and-approaches-used-in-code)
    - [Base project name](#base-project-name)
    - [Unique prefix of resource names](#unique-prefix-of-resource-names)
    - [Separators](#separators)
    - [Resource names](#resource-names)
    - [Variable names](#variable-names)
    - [Output names](#output-names)
  - [Names of terraform files, directories, and modules](#names-of-terraform-files-directories-and-modules)
    - [General configuration files](#general-configuration-files)
    - [Specific configuration files](#specific-configuration-files)
    - [Modules](#modules)
  - [Project structure](#project-structure)

## Architecture diagram

![aws-base-diagram](docs/aws-base-diagrams-Infrastracture-v6.svg)

This diagram describes the default infrastructure:

- We use three availability Zones
- VPC
  - Three public subnets for resources that can be accessible from the Internet
    - Elastic load balancing - entry point to the k8s cluster
    - Internet gateway - entry point to the created VPC
    - Single Nat Gateway - service for organizing access for instances from private networks to public ones.
  - Three private subnets with Internet access via Nat Gateway
  - Three intra subnets without Internet access
  - Three private subnets for RDS
  - Route tables for private networks
  - Route tables for public networks
- Autoscaling groups
  - On-demand - a group with 1-5 on-demand instances for resources with continuous uptime requirements
  - Spot - a group with 1-6 spot instances for resources where interruption of work is not critical
  - CI - a group with 0-3 spot instances created based on gitlab-runner requests; located in the public network
- EKS control plane - nodes of the k8s clusters’ control plane
- Route53 - DNS management service
- Cloudwatch - service for obtaining the metrics about resources’ state of operation in the AWS cloud
- AWS Certificate manager - service for AWS certificate management
- SSM parameter store - service for storing, retrieving, and controlling configuration values
- S3 bucket - this bucket is used to store terraform state
- Elastic container registry - service for storing docker images

## Current infrastructure cost

| Resource      | Type/size                | Price per hour $ | Price per GB $ | Number | Monthly cost      |
|---------------|--------------------------|-----------------:|---------------:|-------:|------------------:|
| EKS           |                          | 0.1              |                | 1      | 73                |
| EC2 ondemand  | t3.medium                | 0.0456           |                | 1      | 33,288            |
| EC2 Spot      | t3.medium/t3a.medium     | 0.0137/0.0125    |                | 1      | 10                |
| EC2 Spot Ci   | t3.medium/t3a.medium     | 0.0137/0.0125    |                | 0      | 10                |
| EBS           | 100 Gb                   |                  | 0.11           | 2      | 22                |
| NAT gateway   |                          | 0.048            | 0.048          | 1      | 35                |
| Load Balancer | Classic                  | 0.028            | 0.008          | 1      | 20.44             |
| S3            | Standart                 |                  |                | 1      | 1                 |
| ECR           | 10 Gb                    |                  |                | 2      | 1.00              |
| Route53       | 1 Hosted Zone            |                  |                | 1      | 0.50              |
| Cloudwatch    | First 10 Metrics - free  |                  |                |        | 0                 |
|               |                          |                  |                | Total  | 216.8             |

> The cost is indicated without counting the amount of traffic for Nat Gateway Load Balancer and S3

## Namespace structure in the K8S cluster

![aws-base-namespaces](docs/aws-base-diagrams-Namespaces-v3.svg)

This diagram shows the namespaces used in the cluster and the services deployed there

| Namespace   |  service                                                                                                            | Description                                                                                                             |
|-------------|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| kube-system | [core-DNS](https://github.com/coredns/coredns)                                                                      | DNS server used in the cluster                                                                                      |
| certmanager | [cert-manager](https://github.com/jetstack/cert-manager)                                                            | Service for automation of management and reception of TLS certificates                                                        |
| certmanager | [cluster-issuer](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/cluster-issuer)         | Resource representing a certification center that can generate signed certificates using different CA |
| ing         | [nginx-ingress](https://github.com/kubernetes/ingress-nginx)                                                        | Ingress controller that uses nginx as a reverse proxy                                                   |
| ing         | [Certificate](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/certificate)               | The certificate object used for nginx-ingress                                                             |
| dns         | [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns)                                  | Service for organizing access to external DNS from the cluster                                                               |
| ci          | [gitlab-runner](https://gitlab.com/gitlab-org/charts/gitlab-runner)                                                 | Gitlab runner used to launch gitlab-ci agents                                                                |
| sys         | [aws-node-termination-handler](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler)   | Service for controlling the correct termination of EC2                                                                  |
| sys         | [autoscaler](https://github.com/kubernetes/autoscaler)                                                              | Service that automatically adjusts the size of the k8s cluster depending on the requirements                                |
| sys         | [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)                      | Service for working with external secret stores, such as secret-manager, ssm parameter store, etc                 |
| sys         | [Reloader](https://github.com/stakater/Reloader)                                                                    | Service that monitors changes in external secrets and updates them in the cluster                                          |
| monitoring  | [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | Umbrella chart including a group of services used to monitor cluster performance and visualize data       |
| monitoring  | [loki-stack](https://github.com/grafana/loki/tree/master/production/helm/loki-stack)                                | Umbrella chart including a service used to collect container logs and visualize data                     |
| elk         | [elk](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/elk)                               | Umbrella chart including a group of services for collecting logs and metrics and visualizing this data                     |

## Useful tools

- [tfenv](https://github.com/tfutils/tfenv) - tool for managing different versions of terraform; the required version can be specified directly as an argument or via `.terraform-version`
- [terraform](https://www.terraform.io/) - terraform itself, our main development tool: `tfenv install`
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) - console utility to work with AWS API
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - conssole utility to work with Kubernetes API
- [kubectx + kubens](https://github.com/ahmetb/kubectx) - power tools for kubectl help you switch between Kubernetes clusters and namespaces
- [helm](https://helm.sh/docs/intro/install/) - tool to create application packages and deploy them into k8s
- [helmfile](https://github.com/roboll/helmfile) - "docker compose" for helm
- [terragrunt](https://terragrunt.gruntwork.io/) - small terraform wrapper providing DRY approach in some cases
- [awsudo](https://github.com/meltwater/awsudo) - simple console utility that allows running awscli commands assuming specific roles
- [aws-vault](https://github.com/99designs/aws-vault) -  tool for securely managing AWS keys and running console commands
- [aws-mfa](https://github.com/broamski/aws-mfa) - utility for automating the reception of temporary STS tockens when MFA is enabled
- [vscode](https://code.visualstudio.com/) - our main IDE

> Optionally, a pre-commit hook can be set up and configured for terraform: [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform), this will allow formatting and validating code at the commit stage

## Useful VSCode extensions

- [editorconfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
- [terraform](https://marketplace.visualstudio.com/items?itemName=4ops.terraform)
- [drawio](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)
- [yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [embrace](https://marketplace.visualstudio.com/items?itemName=mycelo.embrace)
- [js-beautify](https://marketplace.visualstudio.com/items?itemName=HookyQR.beautify)
- [docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [git-extension-pack](https://marketplace.visualstudio.com/items?itemName=donjayamanne.git-extension-pack)
- [githistory](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)
- [kubernetes-tools](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
- [markdown-preview-enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)
- [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
- [file-tree-generator](https://marketplace.visualstudio.com/items?itemName=Shinotatwu-DS.file-tree-generator)
- [gotemplate-syntax](https://marketplace.visualstudio.com/items?itemName=casualjim.gotemplate)

## AWS account

We will not go deep into security settings since everyone has different requirements. However, there are the simplest and most basic steps worth following to move on. If you have everything in place, feel free to skip this section.

> It is highly recommended not to use a root account to work with AWS. Make an extra effort of creating users with required/limited rights.

### IAM settings

So, you have created an account, passed confirmation, perhaps even created Access Keys for the console. In any case, go to your [account](https://console.aws.amazon.com/iam/home#/security_credentials) security settings and be sure to follow these steps:

- Set a strong password
- Activate MFA for the root account
- Delete and do not create access keys of the root account

Further in the [IAM](https://console.aws.amazon.com/iam/home#/home) console:

- In the [Policies](https://console.aws.amazon.com/iam/home#/policies) menu, create `MFASecurity` policy that prohibits users from using services without activating [MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage-mfa-only.html)
- In the [Roles](https://console.aws.amazon.com/iam/home?region=us-east-1#/roles) menu, create new role `administrator`. Select *Another AWS Account* - and enter your account number in the *Account ID* field. Check the *Require MFA* checkbox. In the next *Permissions* window, attach the `AdministratorAccess` policy to it.
- In the [Policies](https://console.aws.amazon.com/iam/home#/policies) menu, create `assumeAdminRole` policy:

  ```json
  {
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::<your-account-id>:role/administrator"
    }
  }
  ```

- In the [Groups](https://console.aws.amazon.com/iam/home#/groups) menu, create the `admin` group; in the next window, attach `assumeAdminRole` and `MFASecurity` policy to it. Finish creating the group.
- In the [Users](https://console.aws.amazon.com/iam/home#/users) menu, create a user to work with AWS by selecting both checkboxes in *Select AWS access type*. In the next window, add the user to the `admin` group. Finish and download CSV with credentials.

> In this doc, we haven't considered a more secure and correct method of user management that uses external Identity providers. These include G-suite, Okta, and [others](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html)

### Setting up awscli

- Terraform can work with environment variables for [AWS access key ID and a secret access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) or AWS profile; in this example, we will create an aws profile:

  ```bash
  $ aws configure --profile maddevs
  AWS Access Key ID [None]: *****************
  AWS Secret Access Key [None]: *********************
  Default region name [None]: us-east-1
  Default output format [None]: json
  ```

  ```bash
  $ export AWS_PROFILE=maddevs
  ```

- Go [here](https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-temporary-credentials.html) to learn how to get temporary session tokens and assume role
- Alternatively, to use your `awscli`, `terraform` and other CLI utils with [MFA](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/)and roles, you can use `aws-mfa`, `aws-vault` and `awsudo`

## How to use this repo

### Getting ready

#### S3 state backend

S3 is used as a backend for storing terraform state and for exchanging data between layers. You can manually create s3 bucket and then put backend setting into `backend.tf` file in each layer. Alternatively you can run from `terraform/` directory:

  ```bash
  $ export TF_REMOTE_STATE_BUCKET=my-new-state-bucket
  $ terragrunt run-all init
  ```

#### Inputs

File `terraform/layer1-aws/demo.tfvars.example` contains example values. Copy this file to `terraform/layer1-aws/terraform.tfvars` and set you values:

```bash
$ cp terraform/layer1-aws/demo.tfvars.example terraform/layer1-aws/terraform.tfvars
```

> You can find all possible variables in each layer's Readme.

#### Secrets

In the root of `layer2-k8s` is the `aws-sm-secrets.tf` where several local variables expect [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name}-${local.environment}/infra/layer2-k8s`. These secrets are used for authentication with Kibana and Grafana using GitLab and register gitlab runner.

  ```json
  {
    "kibana_gitlab_client_id": "access key token",
    "kibana_gitlab_client_secret": "secret key token",
    "kibana_gitlab_group": "gitlab group",
    "grafana_gitlab_client_id": "access key token",
    "grafana_gitlab_client_secret": "secret key token",
    "gitlab_registration_token": "gitlab-runner token",
    "grafana_gitlab_group": "gitlab group",
    "alertmanager_slack_url": "slack url",
    "alertmanager_slack_channel": "slack channel"
  }
  ```

> Set proper secrets; you can set empty/mock values. If you won't use these secrets, delete this `.tf` file from the `layer2-k8s` root.

#### Domain and SSL

You will need to purchase or use an already purchased domain in Route53. The domain name and zone ID will need to be set in the `domain_name` and `zone_id` variables in layer1.

By default, the variable `create_acm_certificate` is set to `false`. Which instructs terraform to search ARN of an existing ACM certificate. Set to `true` if you want terraform to create a new ACM SSL certificate.

### Working with terraform

#### init

The `terraform init` command is used to initialize the state and its backend, downloads providers, plugins, and modules. This is the first command to be executed in `layer1` and `layer2`:

  ```bash
  $ terraform init
  ```

  Correct output:

  ```
  * provider.aws: version = "~> 2.10"
  * provider.local: version = "~> 1.2"
  * provider.null: version = "~> 2.1"
  * provider.random: version = "~> 2.1"
  * provider.template: version = "~> 2.1"

  Terraform has been successfully initialized!
  ```

#### plan

The `terraform plan` command reads terraform state and configuration files and displays a list of changes and actions that need to be performed to bring the state in line with the configuration. It's a convenient way to test changes before applying them. When used with the `-out` parameter, it saves a batch of changes to a specified file that can later be used with `terraform apply`. Call example:

  ```bash
  $ terraform plan
  # ~600 rows skipped
  Plan: 82 to add, 0 to change, 0 to destroy.

  ------------------------------------------------------------------------

  Note: You didn't specify an "-out" parameter to save this plan, so Terraform
  can't guarantee that exactly these actions will be performed if
  "terraform apply" is subsequently run.
  ```

#### apply

The `terraform apply` command scans `.tf` in the current directory and brings the state to the configuration described in them by making changes in the infrastructure. By default, `plan` with a continuation dialog is performed before applying. Optionally, you can specify a saved plan file as input:

  ```bash
  $ terraform apply
  # ~600 rows skipped
  Plan: 82 to add, 0 to change, 0 to destroy.

  Do you want to perform these actions?
    Terraform will perform the actions described above.
    Only 'yes' will be accepted to approve.

    Enter a value: yes

  Apply complete! Resources: 82 added, 0 changed, 0 destroyed.
  ```

We do not always need to re-read and compare the entire state if small changes have been added that do not affect the entire infrastructure. For this, you can use targeted `apply`; for example:

  ```bash
  $ terraform apply -target helm_release.kibana
  ```

Details can be found [here](https://www.terraform.io/docs/cli/run/index.html)

> The first time, the `apply` command must be executed in the layers in order: first layer1, then layer2. Infrastructure `destroy` should be done in the reverse order.

### terragrunt

We've also used `terragrunt` to simplify s3 bucket creation and terraform backend configuration. All you need to do is to set s3 bucket name in the `TF_REMOTE_STATE_BUCKET` env variable and run terragrunt command in the `terraform/` directory:

 ```bash
 $ export TF_REMOTE_STATE_BUCKET=my-new-state-bucket
 $ terragrunt run-all init
 $ terragrunt run-all apply
 ```

By running this `terragrunt` will create s3 bucket, configure terraform backend and then will run `terraform init` and `terraform apply` in layer-1 and layer-2 sequentially.

## What to do after deployment

After applying this configuration, you will get the infrastructure described and outlined at the beginning of the document. In AWS and within the EKS cluster, the basic resources and services necessary for the operation of the EKS k8s cluster will be created.

You can get access to the cluster using this command:

  ```bash
  aws eks update-kubeconfig --name maddevs-demo-use1 --region us-east-1
  ```

## Update terraform version

Change terraform version in this files

`terraform/.terraform-version` - the main terraform version for tfenv tool

`.github/workflows/terraform-ci.yml` - the terraform version for github actions need for `terraform-validate` and `terraform-format`.

Terraform version in each layer.
```
terraform/layer1-aws/main.tf
terraform/layer2-k8s/main.tf
```

## Updated terraform providers

Change terraform providers version in this files

```
terraform/layer1-aws/main.tf
terraform/layer2-k8s/main.tf
```

When we changed terraform provider versions, we need to update terraform state. For update terraform state in layers we need to run this command:

```
terragrunt run-all init -upgrade
```

Or in each layer run command:

```
terragrunt init -upgrade
```

### examples

Each layer has an `examples/` directory that contains working examples that expand the basic configuration. The files’ names and contents are in accordance with our coding conventions, so no additional description is required. If you need to use something, just move it from this folder to the root of the layer.

This will allow you to expand your basic functionality by launching a monitoring system based on ELK or Prometheus Stack, etc.

## Coding conventions

This section contains the most basic recommendations for users and contributors on coding, naming, etc. The goal is consistent, standardized, readable code. Additions, suggestions and changes are welcome.

### Names and approaches used in code

#### Base project name

The base name is set in the name variable in `variables.tf` and is used to form unique resource names:

```
variable "name" {
  default = "demo"
}
```

#### Unique prefix of resource names

Based on the variables `name`, `region` and the `terraform.workspace` value, we form a unique prefix for resource names:

```
locals {
  env            = terraform.workspace == "default" ? var.environment : terraform.workspace
  short_region   = var.short_region[var.region]
  name           = "${var.name}-${local.env}-${local.short_region}"
}
```

Prefix example:

- name = "demo"
- region = "us-east-2"
- terraform.workspace = "test"

`demo-test-use2`

The `local.name` value is then used as a prefix for all `name` and `name_prefix` attributes. This allows us to run copies of the infrastructure even in one account.

#### Separators

- For the `name` or `name_prefix` attributes of resources, modules, etc., as well as for output data values, the hyphen character `-` is used as the separator:

  ```
  name = "${local.name}-example"
  ```

  or

  ```
  name = "demo-test-use2-example"
  ```

- For complex names in the declaration of resources, variables, modules, and outputs in code, the underscore character `_` is used:

  ```
  resource "aws_iam_role_policy_attachment" "pritunl_server"{
  }

  variable "cluster_name" {
  }

  module "security_groups" {
  }
  ```

> Use `name_prefix` where possible

#### Resource names

- The resource type should not be duplicated in the resource name (either partially or in full):
  - Good: `resource "aws_route_table" "public" {}`
  - Bad: `resource "aws_route_table" "public_route_table" {}`
  - Bad: `resource "aws_route_table" "public_aws_route_table" {}`

- If the resource is unique within the module, you should use `this` when naming. For example, the module contains one `aws_nat_gateway` resource and several `aws_route_table` resources; in this case, `aws_nat_gateway` should be named `this`, while `aws_route_table` should have more meaningful names, e.g. `private`, `public`, `database`:

  ```
  resource "aws_nat_gateway" "this" {
    ...
  }
  resource "aws_route_table" "public"{
    ...
  }
  resource "aws_route_table" "private"{
    ...
  }
  ```

- Nouns must be used for names

#### Variable names

- Use the same variable names, description, and default value as defined in the official terraform documentation for the resource you are working on
- Don’t specify `type = "list"` if there is `default = []`
- Don’t specify `type = "map"` if there is `default = {}`
- Use plurals in the names of variables like list and map:

  ```
  variable "rds_parameters" {
  default = [
    {
      name  = "log_min_duration_statement"
      value = "2000"
    },
  ]
  }
  ```

- Always use description for variables
- The higher the level of variable declaration, the more desirable it is to use semantic prefixes for each variable:

  ```
  variable "ecs_instance_type" {
  ...
  }

  variable "rds_instance_type" {
  ...
  }
  ```

#### Output names

- Output names must be understandable outside terraforms and outside the module’s context (when a user uses the module, the type and attribute of the return value must be clear)
- The general recommendation for data output naming is that the name should describe the value inside and should not have redundancies
- The correct structure for output names looks like `{name}_{type}_{attribute}` for non-unique attributes and resources and `{type}_{attribute}` for unique ones; an example of displaying one of several security groups and a unique public address:

  ```
  output "alb_security_group_id" {
    description = "The ID of the example security group"
    value       = "${aws_security_group.alb.id}"
  }

  output "public_ip" {
    description = "Public Ip Address of the Elasti IP assigned to ec2 instance"
    value       = "${aws_eip.this.public_ip}"
  }
  ```

- If the return value is a list, it must have a plural name
- Use description for outputs

### Names of terraform files, directories, and modules

#### General configuration files

Each terraform module and configuration contains a set of general files ending in `.tf`:

- `main.tf` - contains terraform settings if it is the top layer; or the main working code if it is a module
- `variables.tf` - module input values
- `outputs.tf` - module output values

Besides these, there may be:

- `locals.tf` - contains a set of variables obtained by interpolation from remote state, outputs, variables, etc
- `providers.tf` - contains settings from terraform providers, e.g. `aws`, `kubernetes`, etc
- `iam.tf` - IAM configurations of policies, roles, etc

This is not a full list; each configuration, module, or layer may need additional files and manifests. The objective is to name them as succinctly and closer in meaning to the content as possible. Do not use prefixes.

> Terraform itself doesn't care how many files you create. It collects all layer and module manifests into one object, builds dependencies, and executes.

#### Specific configuration files

These configuration files and manifests include the following: `data "template_file"` or `templatefile ()` template resources, a logical resource group placed in a separate `.tf` file, one or more deployments to k8s using `resource "helm_release"`, module initialization, aws resources that do not require a separate module, etc.

> It should be noted that since some kind of a logical group of resources is being, why not move it all into a separate module. But it turned out that it is easier to manage helm releases, templates for them, and additional resources in separate `.tf` files at the root of a layer. And for many such configurations, when moving to modules, the amount of code can double + what we move to modules is usually what we are going to reuse.

Each specific `.tf` file must begin with a prefix indicating the service or provider to which the main resource or group being created belongs, e.g. `aws`. Optionally, the type of service is indicated next, e.g. `iam`. Next comes the name of the main service or resource or resource group declared inside, and after that, an explanatory suffix can optionally be added if there are several such files. All the parts of the name are separated by hyphens`

So the formula looks like this: `provider|servicename`-[`optional resource/service type`]-`main resourcename|group-name`-[`optional suffix`].tf

Examples:

- `aws-vpc.tf` - terraform manifest describing the creation of a single vpc
- `aws-vpc-stage.tf` - terraform manifest describing the creation of one of several vpc, for staging
- `eks-namespaces.tf` - group of namespaces created in the EKS cluster
- `eks-external-dns.tf` - contains the description of external-dns service deployment to the EKS cluster
- `aws-ec2-pritunl.tf` - contains the initialization of the module that creates an EC2 instance in AWS with pritunl configured

#### Modules

The approach to naming module directories is exactly the same as for specific `.tf` files and uses this formula: `provider|servicename`-[`optional resource/service type`]-`main resourcename|group-name`-[`optional suffix`]

Examples:

- `eks-rbac-ci` - module for creating rbac for CI inside the EKS cluster
- `aws-iam-autoscaler` - module for creating IAM policies for autoscaler
- `aws-ec2-pritunl` - module for creating pritunl ec2 instance

### Project structure

```
aws-eks-base
 ┣ docker
 ┣ examples
 ┣ helm-charts
 ┣ terraform
 ┃ ┣ layer1-aws
 ┃ ┃ ┣ examples
 ┃ ┃ ┣ templates
 ┃ ┃ ┣ aws-acm.tf
 ┃ ┃ ┣ aws-eks.tf
 ┃ ┃ ┣ aws-vpc.tf
 ┃ ┃ ┣ locals.tf
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┣ providers.tf
 ┃ ┃ ┗ variables.tf
 ┃ ┣ layer2-k8s
 ┃ ┃ ┣ examples
 ┃ ┃ ┣ templates
 ┃ ┃ ┣ eks-aws-node-termination-handler.tf
 ┃ ┃ ┣ eks-cert-manager.tf
 ┃ ┃ ┣ eks-certificate.tf
 ┃ ┃ ┣ eks-cluster-autoscaler.tf
 ┃ ┃ ┣ eks-cluster-issuer.tf
 ┃ ┃ ┣ eks-external-dns.tf
 ┃ ┃ ┣ eks-external-secrets.tf
 ┃ ┃ ┣ eks-namespaces.tf
 ┃ ┃ ┣ eks-network-policy.tf
 ┃ ┃ ┣ eks-nginx-ingress-controller.tf
 ┃ ┃ ┣ locals.tf
 ┃ ┃ ┣ main.tf
 ┃ ┃ ┣ outputs.tf
 ┃ ┃ ┣ providers.tf
 ┃ ┃ ┣ ssm-ps-secrets.tf
 ┃ ┃ ┗ variables.tf
 ┃ ┗ modules
 ┃ ┃ ┣ aws-iam-alb-ingress-controller
 ┃ ┃ ┣ aws-iam-autoscaler
 ┃ ┃ ┣ aws-iam-ci
 ┃ ┃ ┣ aws-iam-external-dns
 ┃ ┃ ┣ aws-iam-grafana
 ┃ ┃ ┣ aws-iam-roles
 ┃ ┃ ┣ aws-iam-s3
 ┃ ┃ ┣ aws-iam-ssm
 ┃ ┃ ┣ eks-rbac-ci
 ┃ ┃ ┣ kubernetes-namespace
 ┃ ┃ ┣ kubernetes-network-policy-namespace
 ┃ ┃ ┣ pritunl
 ┃ ┃ ┗ self-signed-certificate
 ┣ .editorconfig
 ┣ .gitignore
 ┣ .gitlab-ci.yml
 ┣ .pre-commit-config.yaml
 ┣ README.md
 ┗ README_OLD.md
```

---

| FILE / DIRECTORY| DESCRIPTION   |
| --------------- |:-------------:|
| docker/      | custom dockerfiles for examples |
| examples/    | example k8s deployments |
| helm-charts/ | directory contains custom helm charts |
| helm-charts/certificate | helm chart which creates ssl certificate for nginx ingress |
| helm-charts/cluster-issuer | helm chart which creates cluster-issuer using cert manager cdrs |
| helm-charts/elk | umbrella chart to deploy elk stack |
| helm-charts/teamcity | helm chart which deploys teamcity agent and/or server |
|terraform/| directory contains terraform configuration files |
|terraform/layer1-aws| directory contains aws resources |
|terraform/layer2-k8s| directory contains resources deployed to k8s-EKS |
|terraform/modules| directory contains terraform modules |
|.editorconfig| |
|.gitlab-ci.yml||
|.pre-commit-config.yaml||

[![Analytics](https://ga-beacon.appspot.com/UA-83208754-8/aws-eks-base/readme?pixel)](https://github.com/igrigorik/ga-beacon)
