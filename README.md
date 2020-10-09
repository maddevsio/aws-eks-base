# demo Infrastructure

This project contains Infrastructure as Code(IaC) written on HCL. It provisions new version of the demo Infrastructure on AWS with two `terraform apply` commands.

## Getting Started

Instructions bellow will explain which tools you'll need in order to work with this code and deploy infrastructure

### Prerequisites

* [terraform](https://www.terraform.io/)

  This project uses terraform 0.12. You won't be able to run it on terraform lower 0.12.20 version. Use tfenv to install latest version:

  ```bash
  $ tfenv install 0.12.28

  $ terraform version
  Terraform v0.12.28
  ```

* [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)

  ```bash
  $ pip install awscli --upgrade --user
  $ aws --version
  aws-cli/1.16.161
  ```

  Or using bundle:

  ```bash
  curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" \
      && unzip awscli-bundle.zip \
      && sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws \
      && rm -rf awscli-bundle*
  ```

* [aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator)

  ```bash
  $ curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator
  $ chmod +x ./aws-iam-authenticator
  $ mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator
  ```

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

  ```bash
  $ curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
      && chmod +x ./kubectl \
      && mkdir -p $HOME/bin && cp ./kubectl $HOME/bin/kubectl
  ```

  ```bash
  $ export PATH=$HOME/bin:$PATH
  $ echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
  ```

* [helm 3](https://helm.sh/docs/intro/install/)

* [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)

  ```bash
  sudo apt install python-pip3 gawk &&\
  pip3 install pre-commit
  curl -L "$(curl -s https://api.github.com/repos/segmentio/terraform-docs/releases/latest | grep -o -E "https://.+?-linux-amd64")" > terraform-docs && chmod +x terraform-docs && sudo mv terraform-docs /usr/bin/
  curl -L "$(curl -s https://api.github.com/repos/wata727/tflint/releases/latest | grep -o -E "https://.+?_linux_amd64.zip")" > tflint.zip && unzip tflint.zip && rm tflint.zip && sudo mv tflint /usr/bin/
  ```

  Set it globally:

  ```bash
  DIR=~/.git-template
  git config --global init.templateDir ${DIR}
  pre-commit init-templatedir -t pre-commit ${DIR}
  ```

* MacOS

  Use `brew` to install these utils on macOS.

  ```bash 
  $ brew install pre-commit awk terraform-docs tflint tfenv terraform awscli helm kubernetes-cli
  ```

### AWS

#### Account

In order to deploy and work with infrastructure AWS Account with `AdministratorAccess` policy should be created. For security reasons you should not use root AWS Account.

#### S3 Bucket for states

All states of of all layers are stored in private `madops-terraform-state-us-east-1` s3 bucket with encryption and versioning enabled. Each layer stores it's states in the directory of the bucket with the same name, ie `layer1-aws`. Also this bucket is used to exhachge data between layers.

### Terraform

#### Layers

Configuration of this infrastructure has been splitted into two layers. This approach provides more reliable and faster deployemnt of the changes.

* layer1-aws contains aws resources: VPC network and security groups, RDS instances, EKS cluster and it's nodes
* layer2-k8s contains part of the infrastructure which should be deployed to the EKS cluster: namespaces, secrets, ssl keys, ingresses, monitoring and log services.

#### terraform init

`terraform init` command is used to initialize a working directory containing terraform configuration files. This is the first command that should be run after writing a new terraform configuration, adding module or cloning this code for the first time. It is safe to run this command multiple times.

`terraform init` command must be run from each "layer" folder inside the project.

```bash
$ terraform init
```

Normal output would be:

```
* provider.aws: version = "~> 2.10"
* provider.local: version = "~> 1.2"
* provider.null: version = "~> 2.1"
* provider.random: version = "~> 2.1"
* provider.template: version = "~> 2.1"

Terraform has been successfully initialized!
```

#### Secret variables save in ssm parameter store
````bash 
/maddevs/infra/grafana/gitlab_client_id	
/maddevs/infra/grafana/gitlab_client_secret	
/maddevs/infra/kibana/gitlab_client_id	  
/maddevs/infra/kibana/gitlab_client_secret  
````

#### terraform plan

`terraform plan` command is used to create an execution plan. Terraform determines what actions are necessary to achieve the desired state specified in the configuration files.

This command is a convenient way to check whether the execution plan for new set of changes matches your expectations without making any changes to real resources or to the state. For example, `terraform plan` might be run before committing a change to version control, to create confidence that it will behave as expected.

The optional -out argument can be used to save the generated plan to a file for later execution with terraform apply, which can be useful when running Terraform in automation.

Normal output example:

```bash
$ terraform plan
# ~600 rows skipped
Plan: 82 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.
```

#### terraform apply

The terraform apply command is used to apply the changes required to reach the desired state of the configuration, or the pre-determined set of actions generated by a terraform plan execution plan.

By default, apply scans the current directory for the configuration and applies the changes appropriately. However, a path to another configuration or an execution plan can be provided. Explicit execution plans files can be used to split plan and apply into separate steps within automation systems.

```bash
$ terraform apply
# ~600 rows skipped
Plan: 82 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
 will be performed if
"terraform apply" is subsequently run.

```

If you will type "yes" and press the "enter" key, terraform will start to deploy infrastructure in accordiance to code.

```
Apply complete! Resources: 82 added, 0 changed, 0 destroyed.
```

#### terraform apply -target

You can use target as a parameter for the apply which allows you to deploy specific resource:

```bash
$ terraform apply -target helm_release.kibana
```

#### terraform destroy

The terraform destroy command is used to destroy the Terraform-managed infrastructure.

```bash
$ terraform destroy
random_string.database_user: Refreshing state... (ID: none)
data.template_file.map_accounts[0]: Refreshing state...
random_string.database_prefix: Refreshing state... (ID: none)
# ~600 rows skipped
Plan: 0 to add, 0 to change, 82 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value:
```

If you will type "yes" and press the "enter" key, terraform will start to destroy all managed infrastructure from project files.

```
# ~700 rows skipped
aws_iam_user.uploader: Destruction complete after 2s

Destroy complete! Resources: 82 destroyed.
```

### EKS

After `terraform apply` in layer1 is finished, it will print to the output your EKS cluster name and command to configure kubectl in `eks_kubectl_console_config` output variable. You can use it to authenticate in k8s and use `kubectl`:

```bash
$ aws eks update-kubeconfig --name maddevs-demo-use1 --region us-east-1
$ kubectl get nodes
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-0-165.us-east-1.compute.internal   Ready    <none>   11h   v1.16.11-eks-af3caf
ip-10-0-1-241.us-east-1.compute.internal   Ready    <none>   11h   v1.16.11-eks-af3caf
ip-10-0-1-60.us-east-1.compute.internal    Ready    <none>   11h   v1.16.11-eks-af3caf
```

### Upgrade from terraform 12 to terraform 13
If the state was created by version 12, you need to run:  
`terraform init -reconfigure`
