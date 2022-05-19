# Contributing

When contributing to this repository, please first discuss the change you wish to make via issue,
email, or any other method with the owners of this repository before making a change.

Please note we have a code of conduct, please follow it in all your interactions with the project.

## Table of contents

- [Contributing](#contributing)
  - [Table of contents](#table-of-contents)
  - [Pull Request Process](#pull-request-process)
  - [Checklists for contributions](#checklists-for-contributions)
  - [Semantic Pull Requests](#semantic-pull-requests)
  - [Updating changelog](#updating-changelog)
  - [Coding conventions](#coding-conventions)
    - [Names and approaches used in code](#names-and-approaches-used-in-code)
      - [Base project name](#base-project-name)
      - [Unique prefix of resource names](#unique-prefix-of-resource-names)
      - [Separators](#separators)
      - [Resource and Data Source Conventions](#resource-and-data-source-conventions)
      - [Resource names](#resource-names)
      - [Variable names](#variable-names)
      - [Output names](#output-names)
      - [Resources order in .tf files](#resources-order-in-tf-files)
    - [Names of terraform files, directories, and modules](#names-of-terraform-files-directories-and-modules)
      - [General configuration files](#general-configuration-files)
      - [Specific configuration files](#specific-configuration-files)
      - [Modules](#modules)
  - [### Project structure](#-project-structure)

## Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a build.
2. Update the README.md with details of changes to the interface, this includes new environment variables, exposed ports, useful file locations, and container parameters.
3. Once all outstanding comments and checklist items have been addressed, your contribution will be merged! Merged PRs will be included in the next release. The aws-eks-base maintainers take care of updating the CHANGELOG as they merge.

## Checklists for contributions

- [ ] Add [semantics prefix](#semantic-pull-requests) to your PR or Commits (at least one of your commit groups)
- [ ] CI tests are passing

## Semantic Pull Requests

To generate changelog, Pull Requests or Commits must have semantic and must follow conventional specs below:

- `feat:` for new features
- `fix:` for bug fixes
- `improvement:` for enhancements
- `enh:` for enhancements
- `doc:` for documentation and examples
- `refactor:` for code refactoring
- `test:` for tests
- `ci:` for CI purpose
- `chore:` for chores stuff

The `chore` prefix skipped during changelog generation. It can be used for `chore: update changelog` commit message by example.

## Updating changelog

All changes had been made before version 1.0.0 described in **CHANGELOG.previous.md** file. Starting from that version our Pull Requests or Commits have semantic and follow conventional specs above. So, we decided to keep new changes in **CHANGELOG.md** file. 

**CHANGELOG.md** file should be updated after each change merged in the `main` branch. If there are several Pull Requests will be merged consistently, it's possible to update **CHANGELOG.md** once after merging all of them. 

How to generate CHANGELOG automatically:
1. Merge Pull Request using `Squash`. Your commit message must follow next rule: `doc: my commit message (#1)`, where
  - `doc` - type of changes (see Semantic Pull Requests)
  - `my commit message` - commit message
  - `(#1)` - Pull Request number
2. Rebase your local main branch on the latest changes from `main` branch
3. Run next command:
```bash
git-chglog -o CHANGELOG.md --next-tag $(semtag final -s minor -o)
```
where:
`minor` - is a type of changes related to the semver

Utilities:
* [git-chlog](https://github.com/git-chglog/git-chglog) 
* [semtag](https://github.com/nico2sh/semtag)
4. Create a new branch, commit and push your changes
5. Open Pull Request using prefix `chore:`
6. Merge Pull request. Make sure your commit message looks like: `chore: Update CHANGELOG` and don't forget to clean `optional extended description`
7. Create a new Release and create the new tag (you got it when ran `$(semtag final -s minor -o)`). Click `Auto-generate release notes` and edit message leaving only commit messages:
```bash
How it was:

## What's Changed
* doc: Changelog process by @user_name in https://github.com/maddevsio/aws-eks-base/pull/#number
* chore: Update CHANGELOG by @user_name in https://github.com/maddevsio/aws-eks-base/pull/#number


**Full Changelog**: https://github.com/maddevsio/aws-eks-base/compare/previous_tag...new_tag
```

```bash
How it should be:

## What's Changed
* doc: Changelog process
* chore: Update CHANGELOG
```

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

#### Resource and Data Source Conventions
- Include `count` an argument inside resource blocks as the first argument at the top and separate by newline after it:

```
resource "aws_instance" "app" {
  count = "3"
  
  ...
}
```

- Include `tags` the argument, if supported by resource as the last real argument, following by `depends_on` and `lifecycle`, if necessary. All of these should be separated by a single empty line:

```
resource "aws_instance" "app" {
  count = "1"
  
  ...

  tags = {
    Name = "..."
  }

  depends_on = []

  lifecycle {}
}
```

- When using condition in `count` argument use boolean value if it makes sense, otherwise use `length` or other interpolation:

```
resource "aws_instance" "app" {
  count = var.run_app_instance ? 1 : 0

  ...
}
```

```
resource "aws_route_table_association" "intra" {
  count = var.create_vpc && length(var.intra_subnets) > 0 ? length(var.intra_subnets) : 0

  ...
}
```

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
- Always use singular nouns for names
  - Good: `resource "aws_route_table" "public" {}`
  - Bad: `resource "aws_route_table" "publics" {}`

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

#### Resources order in .tf files

Resources in `.tf` files should be described in the following order:
1. locals
2. data
3. modules
4. resources

### Names of terraform files, directories, and modules

#### General configuration files

Each terraform module and configuration contains a set of general files ending in `.tf`:

- `main.tf` - contains terraform settings and resources that can't be somehow grouped if it is the top layer; or the main working code if it is a module
- `variables.tf` - module input values
- `outputs.tf` - module output values

Besides these, there may be:

- `locals.tf` - contains a set of variables obtained by interpolation from remote state, outputs, variables, etc
- `providers.tf` - contains settings from terraform providers, e.g. `aws`, `kubernetes`, etc
- `iam.tf` - IAM configurations of policies, roles, etc

This is not a full list; each configuration, module, or layer may need additional files and manifests. The objective is to name them as succinctly and closer in meaning to the content as possible. Do not use prefixes (for files inside modules).

> Terraform itself doesn't care how many files you create. It collects all layer and module manifests into one object, builds dependencies, and executes.

#### Specific configuration files

These configuration files and manifests include a logical resource group placed in a separate `.tf` file.

> It should be noted that since some kind of a logical group of resources is being, why not move it all into a separate module. But it turned out that it is easier to manage helm releases, templates for them, and additional resources in separate `.tf` files at the root of a layer. And for many such configurations, when moving to modules, the amount of code can double + what we move to modules is usually what we are going to reuse.

Each specific `.tf` file must begin with a prefix indicating the service or provider to which the main resource or group being created belongs, e.g. `aws`. Next comes the name of the main service or resource or resource group declared inside, and after that, an explanatory suffix can optionally be added if there are several such files. All the parts of the name are separated by hyphens`

So the formula looks like this: `provider|servicename`-`main resourcename|group-name`-[`optional suffix`].tf

Examples:

- `aws-vpc.tf` - terraform manifest describing the creation of a group resources for vpc (vpc + vpc endpoints)
- `aws-vpc-stage.tf` - terraform manifest describing the creation of one of several vpc, for staging
- `eks-external-dns.tf` - contains the description of external-dns service deployment to the EKS cluster

If a resource isn't related to any others (for example: `resource "aws_iam_account_password_policy" "default"`), it can be stored in the `main.tf` file. 

#### Modules

The approach to naming module directories is exactly the same as for specific `.tf` files and uses this formula: `provider|servicename`-[`optional resource/service type`]-`main resourcename|group-name`-[`optional suffix`]

Examples:

- `eks-rbac-ci` - module for creating rbac for CI inside the EKS cluster
- `aws-iam-autoscaler` - module for creating IAM policies for autoscaler
- `aws-pritunl` - module for creating pritunl ec2 instance

### Project structure
---

| FILE / DIRECTORY           |                           DESCRIPTION                           |
| -------------------------- | :-------------------------------------------------------------: |
| docker/                    |                 custom dockerfiles for examples                 |
| examples/                  |                     example k8s deployments                     |
| helm-charts/               |              directory contains custom helm charts              |
| helm-charts/certificate    |   helm chart which creates ssl certificate for nginx ingress    |
| helm-charts/cluster-issuer | helm chart which creates cluster-issuer using cert manager cdrs |
| helm-charts/elk            |               umbrella chart to deploy elk stack                |
| helm-charts/teamcity       |      helm chart which deploys teamcity agent and/or server      |
| terraform/                 |        directory contains terraform configuration files         |
| terraform/layer1-aws       |                directory contains aws resources                 |
| terraform/layer2-k8s       |        directory contains resources deployed to k8s-EKS         |
| terraform/modules          |              directory contains terraform modules               |
| .editorconfig              |                                                                 |
| .gitlab-ci.yml             |                                                                 |
| .pre-commit-config.yaml    |                                                                 |
