# Boilerplate for a basic AWS infrastructure with EKS cluster

[![Developed by Mad Devs](https://maddevs.io/badge-dark.svg)](https://maddevs.io?utm_source=github&utm_medium=madboiler)
[![License](https://img.shields.io/github/license/maddevsio/aws-eks-base)](https://github.com/maddevsio/aws-eks-base/blob/main/LICENSE.md)
[![CI Status](https://github.com/maddevsio/aws-eks-base/workflows/Terraform-ci/badge.svg)](https://github.com/maddevsio/aws-eks-base/actions)

## Advantages of this boilerplate and IaC

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

This repository contains [terraform](https://www.terraform.io/) modules and configuration of the Mad Devs team for
the rapid deployment of a Kubernetes cluster, supporting services, and the underlying AWS infrastructure.

In our company’s work, we have tried many infrastructure solutions and services and traveled the path from on-premise hardware to serverless. As of today, Kubernetes has become our standard platform for deploying applications, and AWS has become the main cloud.

It is worth noting here that although 90% of our and our clients’ projects are hosted on AWS and [AWS EKS](https://aws.amazon.com/eks/) is used as the Kubernetes platform, we do not insist, do not drag everything to Kubernetes, and do not force anyone to be hosted on AWS. Kubernetes is offered only after the collection and analysis of service architecture requirements.

And then, when choosing Kubernetes, it makes almost no difference to applications how the cluster itself is created—manually, through kops or using managed services from cloud providers—in essence, the Kubernetes platform is the same everywhere. So the choice of a particular provider is then made based on additional requirements, expertise, etc.

We know that the current implementation is far from being perfect. For example, we deploy services to the cluster
using `terraform`: it is rather clumsy and against the k8s approache, but it is convenient for bootstrapping because,
by using state and interpolation, we convey proper `IDs`, `ARNs`, and other attributes to resources and names or
secrets to templates and generated values from them for the required charts all within terraform.

There are more specific drawbacks: the `data "template_file"` resources that we used for most templates are extremely inconvenient for development and debugging, especially if there are 500+ line rolls like `terraform/layer2-k8s/templates/elk-values.yaml`. Also, despite `helm3` got rid of the `tiller`, a large number of helm releases still at some point leads to plan hanging. Partially, but not always, it can be solved by `terraform apply -target`, but for the consistency of the state, it is desirable to execute `plan` and `apply` on the entire configuration. If you are going to use this boilerplate, it is advisable to split the `terraform/layer2-k8s` layer into several ones, taking out large and complex releases into separate modules.

You may reasonably question the number of .tf files. This monolith certainly should be refactored and split into many micro-modules adopting terragrunt approach. This is exactly what we will do in the near future, solving along the way the problems described above.

You can find more about this project in Anton Babenko stream:

[![boilerplate stream with Anton Babenko](https://img.youtube.com/vi/giVShrQHf8E/0.jpg)](https://youtu.be/giVShrQHf8E)

## Table of contents

<!-- TOC -->
* [Boilerplate for a basic AWS infrastructure with EKS cluster](#boilerplate-for-a-basic-aws-infrastructure-with-eks-cluster)
  * [Advantages of this boilerplate and IaC](#advantages-of-this-boilerplate-and-iac)
  * [Why you should use this boilerplate](#why-you-should-use-this-boilerplate)
  * [Description](#description)
  * [Table of contents](#table-of-contents)
  * [FAQ: Frequently Asked Questions](#faq--frequently-asked-questions)
  * [Architecture diagram](#architecture-diagram)
  * [Current infrastructure cost](#current-infrastructure-cost)
  * [Namespace structure in the K8S cluster](#namespace-structure-in-the-k8s-cluster)
  * [Useful tools](#useful-tools)
  * [Useful VSCode extensions](#useful-vscode-extensions)
  * [AWS account](#aws-account)
    * [IAM settings](#iam-settings)
    * [Setting up awscli](#setting-up-awscli)
  * [How to use this repo](#how-to-use-this-repo)
    * [Getting ready](#getting-ready)
      * [Secrets](#secrets)
      * [Domain and SSL](#domain-and-ssl)
    * [terragrunt](#terragrunt)
      * [Apply infrastructure by modules with `terragrunt`](#apply-infrastructure-by-modules-with-terragrunt)
      * [Target apply by `terragrunt`](#target-apply-by-terragrunt)
      * [Destroy infrastructure by `terragrunt`](#destroy-infrastructure-by-terragrunt)
  * [What to do after deployment](#what-to-do-after-deployment)
    * [Additional components](#additional-components)
  * [TFSEC](#tfsec)
  * [Contributing](#contributing)
<!-- TOC -->

## FAQ: Frequently Asked Questions

[FAQ](docs/FAQ.md): Frequently Asked Questions and **HOW TO**

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

| Resource      | Type/size               | Price per hour $ | Price per GB $ | Number | Monthly cost |
| ------------- | ----------------------- | ---------------: | -------------: | -----: | -----------: |
| EKS           |                         |              0.1 |                |      1 |           73 |
| EC2 ondemand  | t3.medium               |           0.0456 |                |      1 |       33,288 |
| EC2 Spot      | t3.medium/t3a.medium    |    0.0137/0.0125 |                |      1 |           10 |
| EC2 Spot Ci   | t3.medium/t3a.medium    |    0.0137/0.0125 |                |      0 |           10 |
| EBS           | 100 Gb                  |                  |           0.11 |      2 |           22 |
| NAT gateway   |                         |            0.048 |          0.048 |      1 |           35 |
| Load Balancer | Classic                 |            0.028 |          0.008 |      1 |        20.44 |
| S3            | Standart                |                  |                |      1 |            1 |
| ECR           | 10 Gb                   |                  |                |      2 |         1.00 |
| Route53       | 1 Hosted Zone           |                  |                |      1 |         0.50 |
| Cloudwatch    | First 10 Metrics - free |                  |                |        |            0 |
|               |                         |                  |                |  Total |        216.8 |

> The cost is indicated without counting the amount of traffic for Nat Gateway Load Balancer and S3
## Namespace structure in the K8S cluster

![aws-base-namespaces](docs/aws-base-diagrams-Namespaces-v3.svg)

This diagram shows the namespaces used in the cluster and the services deployed there

| Namespace   | service                                                                                                             | Description                                                                                            |
| ----------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| kube-system | [core-DNS](https://github.com/coredns/coredns)                                                                      | DNS server used in the cluster                                                                         |
| certmanager | [cert-manager](https://github.com/jetstack/cert-manager)                                                            | Service for automation of management and reception of TLS certificates                                 |
| certmanager | [cluster-issuer](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/cluster-issuer)         | Resource representing a certification center that can generate signed certificates using different CA  |
| ing         | [nginx-ingress](https://github.com/kubernetes/ingress-nginx)                                                        | Ingress controller that uses nginx as a reverse proxy                                                  |
| ing         | [Certificate](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/certificate)               | The certificate object used for nginx-ingress                                                          |
| dns         | [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns)                                  | Service for organizing access to external DNS from the cluster                                         |
| ci          | [gitlab-runner](https://gitlab.com/gitlab-org/charts/gitlab-runner)                                                 | Gitlab runner used to launch gitlab-ci agents                                                          |
| sys         | [aws-node-termination-handler](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler)   | Service for controlling the correct termination of EC2                                                 |
| sys         | [autoscaler](https://github.com/kubernetes/autoscaler)                                                              | Service that automatically adjusts the size of the k8s cluster depending on the requirements           |
| sys         | [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)                      | Service for working with external secret stores, such as secret-manager, ssm parameter store, etc      |
| sys         | [Reloader](https://github.com/stakater/Reloader)                                                                    | Service that monitors changes in external secrets and updates them in the cluster                      |
| monitoring  | [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | Umbrella chart including a group of services used to monitor cluster performance and visualize data    |
| monitoring  | [loki-stack](https://github.com/grafana/loki/tree/master/production/helm/loki-stack)                                | Umbrella chart including a service used to collect container logs and visualize data                   |
| elk         | [elk](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/elk)                               | Umbrella chart including a group of services for collecting logs and metrics and visualizing this data |

## Useful tools

- [tfenv](https://github.com/tfutils/tfenv) - tool for managing different versions of terraform; the required version can be specified directly as an argument or via `.terraform-version`
- [tgenv](https://github.com/cunymatthieu/tgenv) - tool for managing different versions of terragrunt; the required version can be specified directly as an argument or via `.terragrunt-version`
- [terraform](https://www.terraform.io/) - terraform itself, our main development tool: `tfenv install`
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) - console utility to work with AWS API
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - conssole utility to work with Kubernetes API
- [kubectx + kubens](https://github.com/ahmetb/kubectx) - power tools for kubectl help you switch between Kubernetes clusters and namespaces
- [helm](https://helm.sh/docs/intro/install/) - tool to create application packages and deploy them into k8s
- [helmfile](https://github.com/roboll/helmfile) - "docker compose" for helm
- [terragrunt](https://terragrunt.gruntwork.io/) - small terraform wrapper providing DRY approach in some cases: `tgenv install`
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

<details>
  <summary> Click to expand IAM and awscli configuration</summary>

### IAM settings

So, you have created an account, passed confirmation, perhaps even created Access Keys for the console. In any case, go to your [account](https://console.aws.amazon.com/iam/home#/security_credentials) security settings and be sure to follow these steps:

- Set a strong password
- Activate MFA for the root account
- Delete and do not create access keys for the root account

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
- Alternatively, to use your `awscli`, `terraform` and other CLI utils with [MFA](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/) and roles, you can use `aws-mfa`, `aws-vault` and `awsudo`
</details>

## How to use this repo

### Getting ready

To start using this project you need to make several small preparation steps.

#### Secrets

Some local variables expect [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home) secret with the pattern `/${local.name_wo_region}/infra/layer2-k8s`.

> The secret `/${local.name_wo_region}/infra/layer2-k8` must be created before running `terraform apply`. Which
> parameters should be placed in the SM secret for services is discussed in the [FAQ](docs/FAQ.md).

#### Domain and SSL

You will need to purchase or use an already purchased domain in Route53. After that set `domain_name` and `zone_id`
variables in `variables.tf`, tfvars files of env.yaml if you use terragrunt.

By default, the variable `create_acm_certificate` is set to `false`. Which instructs terraform to search ARN of an existing ACM certificate. Set to `true` if you want terraform to create a new ACM SSL certificate.

### terragrunt

We've also used `terragrunt` to simplify s3 bucket creation and terraform backend configuration. All you need to do is to set s3 bucket name in the `TF_REMOTE_STATE_BUCKET` env variable and run terragrunt command in the `terragrunt/demo/us-east-1` directory:

 ```bash
 $ export TF_REMOTE_STATE_BUCKET=my-new-state-bucket
 $ cd terragrunt/demo/us-east-1
 $ terragrunt run-all init
 $ terragrunt run-all apply
 ```

By running this `terragrunt` will create s3 bucket, configure terraform backend and then will run `terraform init` and `terraform apply` in layer-1 and layer-2 sequentially.

> Terragrunt version pinned in `terragrunt.hcl` file.

#### Modules apply with `terragrunt`

Go to layer folder `terragrunt/demo/us-east-1/aws-base` or `terragrunt/demo/us-east-1/k8s-addons` and run this command:

```
terragrunt apply
```

> Module `k8s-addons` depends on `aws-base`.

#### Target apply by `terragrunt`

Go to layer folder `terragrunt/demo/us-east-1/aws-base` and run this command:

```
terragrunt apply -target=module.eks
```

> The `-target` is formed from the following parts `resource type` and `resource name`.
> For example: `-target=module.eks`, `-target=helm_release.loki_stack`

#### Destroy infrastructure by `terragrunt`

To destroy everything at once, run this command from `terragrunt/demo/us-east-1/` folder:

```
terragrant run-all destroy
```

> The `k8s-addons` depends on `aws-base`, so `k8s-addons` will be destroyed automatically first.

If you want to destroy modules manually, then destroy `k8s-addons` first, ie run this command from
`terragrunt/demo/us-east-1/k8s-addons` folder:

```
terragrunt destroy
```

> Clear all buckets before destroying.

## What to do after deployment

* After applying this configuration, you will get the infrastructure described and outlined at the beginning of the document. In AWS and within the EKS cluster, the basic resources and services necessary for the operation of the EKS k8s cluster will be created.

  * You can get access to the cluster using this command:

    ```bash
    aws eks update-kubeconfig --name maddevs-demo-use1 --region us-east-1
    ```

* If you use default configuration and want to serve traffic for a main domain (example.com) by an application deployed into a k8s cluster, youn need to manually create DNS record in Route53 with type A + Alias
* DNS record `*.example.com` created automatically and points to Load Balancer in front of k8s cluster.

### Additional components

This boiler installs all basic and necessary components. However, we also provide several additional components. Both layers have such components. To enable them in:
* `terraform/layer1-aws`: search `***_enable` variables and set them to **true**
* `terraform/layer2-k8s`: check `helm-releases.yaml` file and set **enabled: true** or **enabled:false** for components
  that you want to **deploy** or to **unistall**

Notes:
* [To use pure terraform](docs/FAQ.md#apply-using-terraform)
* [Gitlab-runner](docs/FAQ.md#gitlab-runner)
* [Monitoring](docs/FAQ.md#monitoring)

## TFSEC

[TFSEC](docs/TFSEC.md): Notes related to tfsec ignores

## Contributing

If you're interested in contributing to the project:

- Start by reading the [Contributing](https://github.com/maddevsio/aws-eks-base/blob/main/.github/CONTRIBUTING.md) guide
- Explore [current issues](https://github.com/maddevsio/aws-eks-base/issues?q=is%3Aopen+is%3Aissue).
