# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]





<a name="v9.0.0"></a>
## [v9.0.0] - 2022-10-20
FEATURES:
- Decoupled layers by using terragrunt v2 ([#313](https://github.com/maddevsio/aws-eks-base/issues/313))
- CIS benchmark alerts using Eventbridge ([#283](https://github.com/maddevsio/aws-eks-base/issues/283))

ENHANCEMENTS:
- Use aws-load-balancer-controller in front of ingress-nginx ([#293](https://github.com/maddevsio/aws-eks-base/issues/293))
- Switch from aws-calico helm chart to tigera operator helm chart ([#288](https://github.com/maddevsio/aws-eks-base/issues/288))
- Configure AWS account password policy ([#287](https://github.com/maddevsio/aws-eks-base/issues/287))
- Use k8s serviceaccount + irsa for vpc-cni add-on ([#280](https://github.com/maddevsio/aws-eks-base/issues/280))

REFACTORS:
- Change code structure; update code conventions ([#290](https://github.com/maddevsio/aws-eks-base/issues/290))

BUG FIXES:
- Issue [#304](https://github.com/maddevsio/aws-eks-base/issues/304) layer2-aws terraform plan error ([#305](https://github.com/maddevsio/aws-eks-base/issues/305))
- Update tfsec for layer 1 ([#299](https://github.com/maddevsio/aws-eks-base/issues/299))

DOCS:
- Disable gitlab clusterwide default access in case of use additional sa for runners
- Update documentation for used terraform modules ([#285](https://github.com/maddevsio/aws-eks-base/issues/285))




<a name="v8.0.0"></a>
## [v8.0.0] - 2022-05-02
FEATURES:
- Configure cluster endpoint ([#251](https://github.com/maddevsio/aws-eks-base/issues/251))

ENHANCEMENTS:
- Update k8s cluster to the latest version ([#274](https://github.com/maddevsio/aws-eks-base/issues/274))
- Update used helm-charts to the latest versions ([#271](https://github.com/maddevsio/aws-eks-base/issues/271))
- Update terraform modules, providers ([#270](https://github.com/maddevsio/aws-eks-base/issues/270))
- Update terraform eks module ([#261](https://github.com/maddevsio/aws-eks-base/issues/261))
- Change cluster-autoscaler configuration to improve cluster utilization ([#255](https://github.com/maddevsio/aws-eks-base/issues/255))

REFACTORS:
- Switch from aws-managed nodegroups to self-managed ([#277](https://github.com/maddevsio/aws-eks-base/issues/277))
- Switch from kubernetes-external-secrets to External Secrets Operator ([#276](https://github.com/maddevsio/aws-eks-base/issues/276))
- Fix layer*/README.md files content ([#273](https://github.com/maddevsio/aws-eks-base/issues/273))

BUG FIXES:
- Delete unnecessary istio-sidecar configuration ([#257](https://github.com/maddevsio/aws-eks-base/issues/257))




<a name="v7.0.0"></a>
## [v7.0.0] - 2022-02-14
ENHANCEMENTS:
- Switch from local istio-operator helm chart to official public helm chart ([#249](https://github.com/maddevsio/aws-eks-base/issues/249))




<a name="v6.1.1"></a>
## [v6.1.1] - 2022-01-06

- Update CHANGELOG ([#242](https://github.com/maddevsio/aws-eks-base/issues/242))
- Allow external secrets to get secrets from AWS Secrets Manager ([#241](https://github.com/maddevsio/aws-eks-base/issues/241))




<a name="v6.1.0"></a>
## [v6.1.0] - 2021-12-28
ENHANCEMENTS:
- ELK upgrade ([#239](https://github.com/maddevsio/aws-eks-base/issues/239))

DOCS:
- Fixed contributing.md url ([#238](https://github.com/maddevsio/aws-eks-base/issues/238))




<a name="v6.0.1"></a>
## [v6.0.1] - 2021-12-23
ENHANCEMENTS:
- Moved elasticsearch image to public ECR ([#233](https://github.com/maddevsio/aws-eks-base/issues/233))




<a name="v6.0.0"></a>
## [v6.0.0] - 2021-11-29
FEATURES:
- Moved bottlerocket to managed node groups ([#228](https://github.com/maddevsio/aws-eks-base/issues/228))
- Introduce possibility to install VictoriaMetrics or Prometheus ([#222](https://github.com/maddevsio/aws-eks-base/issues/222))

REFACTORS:
- Delete Teamcity helm release ([#220](https://github.com/maddevsio/aws-eks-base/issues/220))

BUG FIXES:
- Removed this prefix from r53 and acm modules outputs [#223](https://github.com/maddevsio/aws-eks-base/issues/223) ([#224](https://github.com/maddevsio/aws-eks-base/issues/224))

DOCS:
- Changed License banner, added CI Status badge [#225](https://github.com/maddevsio/aws-eks-base/issues/225) ([#226](https://github.com/maddevsio/aws-eks-base/issues/226))




<a name="v5.1.0"></a>
## [v5.1.0] - 2021-11-22
ENHANCEMENTS:
- Use basic auth for Grafana by default and feature flag to switch between basic auth, github oauth and gitlab oauth ([#215](https://github.com/maddevsio/aws-eks-base/issues/215))

REFACTORS:
- Do not use templates/istio/istio-operator-values.yaml and set necessary values in the eks-istio.tf file ([#214](https://github.com/maddevsio/aws-eks-base/issues/214))
- Do not use templates/calico-values.yaml and set necessary values in the eks-calico.tf file ([#210](https://github.com/maddevsio/aws-eks-base/issues/210))
- Do not use templates/teamcity-values.yaml and set necessary values in the eks-teamcity.tf file ([#208](https://github.com/maddevsio/aws-eks-base/issues/208))
- Do not use templates/nginx-ingress-values.yaml and set necessary values in the eks-ingress-nginx-controller.tf file ([#206](https://github.com/maddevsio/aws-eks-base/issues/206))
- Do not use templates/elk-values.yaml and set necessary values in the eks-elk.tf file ([#204](https://github.com/maddevsio/aws-eks-base/issues/204))
- Do not use templates/gitlab-runner-values.yaml and set necessary values in the eks-gitlab-runner.tf file ([#202](https://github.com/maddevsio/aws-eks-base/issues/202))
- Do not use templates/cluster-autoscaler-values.yaml and set necessary values in the eks-cluster-autoscaler.tf file ([#200](https://github.com/maddevsio/aws-eks-base/issues/200))
- Do not use templates/loki-stack-values.yaml and set necessary values in the eks-loki-stack.tf file ([#198](https://github.com/maddevsio/aws-eks-base/issues/198))
- Do not use templates/prometheus-values.yaml and set necessary values in the eks-kube-prometheus-stack.tf file ([#196](https://github.com/maddevsio/aws-eks-base/issues/196))
- Do not use templates/external-secrets-values.yaml and set necessary values in the eks-external-secrets.tf file ([#194](https://github.com/maddevsio/aws-eks-base/issues/194))
- Do not use templates/external-dns-values.yaml and set necessary values in the eks-external-dns.tf file ([#192](https://github.com/maddevsio/aws-eks-base/issues/192))
- Do not use templates/aws-node-termination-handler-values.yaml and set necessary values in the eks-aws-node-termination-handler.tf file ([#190](https://github.com/maddevsio/aws-eks-base/issues/190))
- Do not use templates/alb-ingress-controller-values.yaml and set necessary values in the eks-aws-loadbalancer-controller.tf ([#188](https://github.com/maddevsio/aws-eks-base/issues/188))

DOCS:
- Update documentation related to secrets ([#217](https://github.com/maddevsio/aws-eks-base/issues/217))
- Move TFSEC notes from README.md into separate file ([#185](https://github.com/maddevsio/aws-eks-base/issues/185))




<a name="v5.0.0"></a>
## [v5.0.0] - 2021-11-15
ENHANCEMENTS:
- Use flags to enabled/disable additional functionalities instead of using examples folder ([#176](https://github.com/maddevsio/aws-eks-base/issues/176))
- Documentation and tf update ([#177](https://github.com/maddevsio/aws-eks-base/issues/177))




<a name="v4.0.0"></a>
## [v4.0.0] - 2021-11-10
FEATURES:
- Add keda helm chart ([#170](https://github.com/maddevsio/aws-eks-base/issues/170))
- Add default networkpolicies for all namespaces except istio-system and teamcity ([#168](https://github.com/maddevsio/aws-eks-base/issues/168))
- Each helm release has its own namespace ([#164](https://github.com/maddevsio/aws-eks-base/issues/164))

ENHANCEMENTS:
- Move gitlab-runner and elk-stack s3 buckets from layer1-aws into layer2-k8s ([#166](https://github.com/maddevsio/aws-eks-base/issues/166))




<a name="v3.0.0"></a>
## [v3.0.0] - 2021-11-05
ENHANCEMENTS:
- Do not use terraform modules for deploying aws-load-balancer-controller ([#160](https://github.com/maddevsio/aws-eks-base/issues/160))

REFACTORS:
- Use dedicated file to set some helm charts options (name, repository, version) ([#156](https://github.com/maddevsio/aws-eks-base/issues/156))




<a name="v2.0.0"></a>
## [v2.0.0] - 2021-11-03
FEATURES:
- Add limitrange, resourcequota and networkpolicy features for k8s namespace ([#147](https://github.com/maddevsio/aws-eks-base/issues/147))

REFACTORS:
- Delete unused examples ([#144](https://github.com/maddevsio/aws-eks-base/issues/144))
- Use aws-iam-eks-trusted module to create all roles used in k8s ([#143](https://github.com/maddevsio/aws-eks-base/issues/143))

DOCS:
- Add some notes about coding conventions ([#146](https://github.com/maddevsio/aws-eks-base/issues/146))




<a name="v1.1.0"></a>
## [v1.1.0] - 2021-10-19
ENHANCEMENTS:
- Changes in PR and Issue templates, CONTRIBUTING.md ([#132](https://github.com/maddevsio/aws-eks-base/issues/132))
- Use priority expander for cluster autoscaler configuration to prioritize spot node_pool ([#129](https://github.com/maddevsio/aws-eks-base/issues/129))

BUG FIXES:
- Disable aws_loadbalancer_controller by default ([#128](https://github.com/maddevsio/aws-eks-base/issues/128))

DOCS:
- Describe the process of updating CHANGELOG.md ([#136](https://github.com/maddevsio/aws-eks-base/issues/136))



[Unreleased]: https://github.com/maddevsio/aws-eks-base/compare/v9.0.0...HEAD
[v9.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v8.0.0...v9.0.0
[v8.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v7.0.0...v8.0.0
[v7.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v6.1.1...v7.0.0
[v6.1.1]: https://github.com/maddevsio/aws-eks-base/compare/v6.1.0...v6.1.1
[v6.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v6.0.1...v6.1.0
[v6.0.1]: https://github.com/maddevsio/aws-eks-base/compare/v6.0.0...v6.0.1
[v6.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v5.1.0...v6.0.0
[v5.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v5.0.0...v5.1.0
[v5.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v4.0.0...v5.0.0
[v4.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v3.0.0...v4.0.0
[v3.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v2.0.0...v3.0.0
[v2.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.1.0...v2.0.0
[v1.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.0.0...v1.1.0
