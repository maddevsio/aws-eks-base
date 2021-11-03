# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/) and this
project adheres to [Semantic Versioning](http://semver.org/).

<a name="unreleased"></a>
## [Unreleased]





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



[Unreleased]: https://github.com/maddevsio/aws-eks-base/compare/v2.0.0...HEAD
[v2.0.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.1.0...v2.0.0
[v1.1.0]: https://github.com/maddevsio/aws-eks-base/compare/v1.0.0...v1.1.0
