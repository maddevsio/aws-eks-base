<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name                                              | Version |
| ------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a     |

## Modules

| Name                                                                    | Source                                                    | Version |
| ----------------------------------------------------------------------- | --------------------------------------------------------- | ------- |
| <a name="module_backup_role"></a> [backup\_role](#module\_backup\_role) | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 4.14.0  |
| <a name="module_ec2_sg"></a> [ec2\_sg](#module\_ec2\_sg)                | terraform-aws-modules/security-group/aws                  | 4.8.0   |
| <a name="module_efs_sg"></a> [efs\_sg](#module\_efs\_sg)                | terraform-aws-modules/security-group/aws                  | 4.8.0   |
| <a name="module_iam_policy"></a> [iam\_policy](#module\_iam\_policy)    | terraform-aws-modules/iam/aws//modules/iam-policy         | 4.14.0  |
| <a name="module_this_role"></a> [this\_role](#module\_this\_role)       | terraform-aws-modules/iam/aws//modules/iam-assumable-role | 4.14.0  |

## Resources

| Name                                                                                                                                               | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group)                        | resource    |
| [aws_backup_plan.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_plan)                                    | resource    |
| [aws_backup_selection.efs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_selection)                           | resource    |
| [aws_backup_vault.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/backup_vault)                                  | resource    |
| [aws_efs_file_system.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system)                            | resource    |
| [aws_efs_mount_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target)                          | resource    |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)                                                    | resource    |
| [aws_iam_instance_profile.this_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource    |
| [aws_launch_template.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template)                            | resource    |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)                                       | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document)                 | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                                        | data source |

## Inputs

| Name                                                                                                                                                        | Description                                                                          | Type                                                                                                                                                              | Default      | Required |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ | :------: |
| <a name="input_encrypted"></a> [encrypted](#input\_encrypted)                                                                                               | Encrypt or not EFS                                                                   | `bool`                                                                                                                                                            | `true`       |    no    |
| <a name="input_environment"></a> [environment](#input\_environment)                                                                                         | Environment name                                                                     | `string`                                                                                                                                                          | `"infra"`    |    no    |
| <a name="input_ingress_with_cidr_blocks"></a> [ingress\_with\_cidr\_blocks](#input\_ingress\_with\_cidr\_blocks)                                            | A list of Pritunl server security group rules where source is CIDR                   | <pre>list(object({<br>    protocol    = string<br>    from_port   = string<br>    to_port     = string<br>    cidr_blocks = string<br>  }))</pre>                 | `[]`         |    no    |
| <a name="input_ingress_with_source_security_group_id"></a> [ingress\_with\_source\_security\_group\_id](#input\_ingress\_with\_source\_security\_group\_id) | A list of Pritunl server security group rules where source is another security group | <pre>list(object({<br>    protocol        = string<br>    from_port       = string<br>    to_port         = string<br>    security_groups = string<br>  }))</pre> | `[]`         |    no    |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)                                                                                 | Pritunl server instance type                                                         | `string`                                                                                                                                                          | `"t3.small"` |    no    |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id)                                                                                        | KMS key ID in case of using CMK                                                      | `any`                                                                                                                                                             | `null`       |    no    |
| <a name="input_name"></a> [name](#input\_name)                                                                                                              | Name used for all resources in this module                                           | `string`                                                                                                                                                          | `"pritunl"`  |    no    |
| <a name="input_private_subnets"></a> [private\_subnets](#input\_private\_subnets)                                                                           | A list of private subnets where EFS will be created                                  | `list(any)`                                                                                                                                                       | n/a          |   yes    |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets)                                                                              | A list of public subnets where Pritunl server will be run                            | `list(any)`                                                                                                                                                       | n/a          |   yes    |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)                                                                                                      | ID of the VPC where to create security groups                                        | `string`                                                                                                                                                          | n/a          |   yes    |

## Outputs

| Name                                                                                                       | Description |
| ---------------------------------------------------------------------------------------------------------- | ----------- |
| <a name="output_pritunl_endpoint"></a> [pritunl\_endpoint](#output\_pritunl\_endpoint)                     | n/a         |
| <a name="output_pritunl_security_group"></a> [pritunl\_security\_group](#output\_pritunl\_security\_group) | n/a         |
<!-- END_TF_DOCS -->

## Architecture diagram

![pritunl-server-architecture-diagram](../../../docs/aws-ec2-pritunl-diagram.svg)

## Description
* AWS ASG is used to automatically run "broken" instance again
* The entire logic is located in user-data script:
  * Install MongoDB
  * Install Pritunl-server
  * Configure sysctl
  * Attache Elastic IP
  * Disable source-destination check, because this instance will forward traffic
  * Mount EFS filesystem into directory with MongoDB data. We don't want to care about AZ and EBS disks
* AWS Backup is configured to backup EFS storage
