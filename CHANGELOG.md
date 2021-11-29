# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]





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



[Unreleased]: https://github.com/maddevsio/aws-eks-base/compare/v6.0.0...HEAD
[v6.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v5.1.0...v6.0.0
[v5.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v5.0.0...v5.1.0
[v5.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v4.0.0...v5.0.0
[v4.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v3.0.0...v4.0.0
[v3.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v2.0.0...v3.0.0
[v2.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.1.0...v2.0.0
[v1.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.0.0...v1.1.0
