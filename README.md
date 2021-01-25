# Бойлерплейт базовой AWS инфраструктуры для запуска EKS-кластера

В данной репе собраны наработки команды MadOps для быстрого развертывания Kubernetes кластера, вспомогательных сервисов и нижележащей инфраструктуры в облаке Amazon. Основным инструментом разработки и поставки является [terraform](https://www.terraform.io/)

За время работы компании мы перепробовали много инфрастуктурных решений и сервисов, и прошли путь от on-premise железа до serverless. В итоге на текущий момент нашей стандартной платформой для развертывания приложений стал Kubernetes, а основным облаком - AWS. Тут стоит отметить, что не смотря на то, что 90% наших и клиентских проектов хостится на AWS, а в качестве kubernetes платформы используется [AWS EKS](https://aws.amazon.com/eks/) - мы не упираемся рогом, и не тащим все подряд в кубер или заставляем хостится в AWS. Kubernetes предлагается только после сбора и анализа требований к архитектуре сервиса. А далее при выборе кубера - приложениям почти не важно, как создан сам кластер - вручную, через kops или используя managed услуги облачных провайдеров - в основе своей платформа кубера везде одинакова. И выбор конкретного провайдера уже складывается из дополнительный требований, экспертизы итд.

Мы знаем, что текущая реализация далеко не идеальна. Например, в кластер мы деплоим сервисы с помощью `terraform` - это довольно топорно и против подходов кубера, но это удобно для бутстрапа - тк используя стейт и интерполяцию, мы передаем необходимые `ids`, `arns` и другие указатели на ресурсы и имена или секреты в шаблоны и генерим из них `values` для нужных чартов, не выходя за пределы терраформа. Есть более специфичные минусы, ресурсы `data "template_file"` которые мы использовали для большинства шаблонов крайне неудобны для разработки и отладки, особенно если это такие 500+ строчные рулоны, типа `terraform/layer2-k8s/templates/elk-values.yaml`. Так-же, смотря на `helm3` и избавление от `tiller` - большое количество helm-релизов все равно в какой-то момент приводит к зависанию плана. Частично, но не всегда решается путем таргетированного `terraform apply -target`, но для консистентности стейцта желательно выполнять `plan` и `apply` целиком на всей конфигурации. Если собираетесь использовать данный бойлер, желательно разбить слой `terraform/layer2-k8s` на несколько, вынеся крупные и комплексные релизы в отдельные подслои.

Могут возникнуть справедлыевые вопросы к количеству `.tf` файлов. Оно конечно просится на рефакторинг и обмодуливание. Чем мы и займемся в ближайшее время, попутно решая озвученные проблемы выше.

## Архитекутрная схема

![aws-base-diagram](docs/aws-base-diagrams-Infrastructure-v4.svg)

Эта схема описывает инфраструктуру создаваемую по умолчанию.
Небольшое описание того что мы имеем на схеме. Инфраструктура в облаке AWS

* Мы используем две availability Zone
* Основная сеть VPC
  * Две публичные подсети для ресурсов которым нужен доступ в мир
    * Elastic load balancing - точка входа в k8s cluster
    * Internet gateway - точка входа в созданную VPC
    * Single Nat Gateway - сервис для огранизации доступа для инстансов из привтных сетей в публичные.
  * Две приватные подсети для EKS workers
  * Две приватные подсети для RDS
  * Две приватные подсети для Elastic Cache
  * Route tables для приватных сетей
  * Route tables для публичных сетей  
* Autoscaling groups
  * On-demand - эта группа с 1-5 on-demand instances для ресурсов с требованиям бесперебойной работы
  * Spot     - эта группа с 1-6 spot instances для ресурсов которым не критично прерывание работы
  * CI       - эта группа с 0-3 spot instances создающихся по требования gitlab-runner, расположены в публичной сети
* EKS control plane - это узлы плоскости управления кластеров k8s
* Route53 - сервис для управления DNS
* Cloudwatch - сервис для получения метрик о состоянии работы ресурсов в облаке AWS
* AWS Certificate manager - сервис для управления сертификатами AWS
* SSM parameter store - сервис для хранения извлечения и контроля значений конфигурации
* S3 bucket - это бакет используется для хранения terraform state
* Elastic container registry - сервис для хранения docker images

## Стоимость текущей инфры

| Resource      | Type/size                | Price per hour $ | Price per GB $ | Number | Monthly cost      |
|---------------|--------------------------|------------------|----------------|--------|-------------------|
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

> Стоимость указана без подсчета количество трафика для Nat Gateway Load Balancer и S3

## Структура неймспейсов в K8S кластере

На этой схему указаны неймспейсы которые используются в кластере, и ресурсы которые находятся в этих неймспесах по умолчанию.

![aws-base-namespaces](docs/aws-base-diagrams-Namespaces-v3.svg)

Используемые в кластере чарты, с указанием неймспейса и коротким описанием.

| Namespace   |  service                                                                                                            | Description                                                                                                             |
|-------------|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| kube-system | [core-DNS](https://github.com/coredns/coredns)                                                                      | DNS сервер используемый в кластере                                                                                      |
| certmanager | [cert-manager](https://github.com/jetstack/cert-manager)                                                            | Cервис для автоматизации управления и получения сертификатов TLS                                                        |
| certmanager | [cluster-issuer](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/cluster-issuer)         | Ресурс представляющий центр сертификации, который может генерировать подписанные сертификаты, выполняя запросы подписи. |
| ing         | [nginx-ingress](https://github.com/kubernetes/ingress-nginx)                                                        | Ингресс контролер, который использует nginx в качестве реверс прокси.                                                   |
| ing         | [Certificate](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/certificate)               | Объект сертификата, который используется для nginx-ingress.                                                             |
| dns         | [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns)                                  | Сервис для огранизации доступа к внешним DNS из кластера.                                                               |
| ci          | [gitlab-runner](https://gitlab.com/gitlab-org/charts/gitlab-runner)                                                 | Гитлаб раннер используемый для запуска агентов gitla-ci.                                                                |
| sys         | [aws-node-termination-handler](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler)   | Сервис для конроля корректного заверешения работы EC2.                                                                  |
| sys         | [autoscaler](https://github.com/kubernetes/autoscaler)                                                              | Сервис который автоматически регулирует размер k8s кластера в зависимости от требований.                                |
| sys         | [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)                      | Сервис для работы с внешними хранилищами секретов, такими как secret-manager, ssm parameter store и тд.                 |
| sys         | [Reloader](https://github.com/stakater/Reloader)                                                                    | Сервис который следит за изменения внешних секретов и обновляет их в кластере.                                          |
| monitoring  | [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | Зонтичный чарт включает в себя группу сервисов используемых для мониторинга работы класте и визуализациия данных.       |
| monitoring  | [loki-stack](https://github.com/grafana/loki/tree/master/production/helm/loki-stack)                                | Зонтичный чарт включает в себя сервис сбора логов контейнеров и визуализации данных.                                    |
| elk         | [elk](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/elk)                               | Зонтичный чарт включает в себя группу сервисов, для сбора логов, метрик и визуализации этих данных.                     |

## Необходимый инструментарий

* [tfenv](https://github.com/tfutils/tfenv) - утилита для менеджмента разных версий терраформа: `tfenv install 0.13.5`
* [terraform v0.13.5](https://www.terraform.io/) - тот самый терраформ, наш главный инструмент разработки
* [awscli v2.1.15](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) - консольная утилита для работы с AWS API
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - консольная тула для работы с кубер кластерами
* [helm v3.4.2](https://helm.sh/docs/intro/install/) - тула для создания и деплоя шаблонизированных чартов приложений в кубер
* [helmfile v0.136.0](https://github.com/roboll/helmfile) - "докер композ" для хелм чартов
* [terragrunt v0.26.7](https://terragrunt.gruntwork.io/) - небольшой wrapper для терраформа обеспечивающий DRY для некоторых статичных частей терраформ кода
* [awsudo](https://github.com/meltwater/awsudo) - простая консольная утилита, позволяющая запускать команды awscli из под определенных ролей
* [aws-vault](https://github.com/99designs/aws-vault) - тула для секурного менеджмента ключей AWS и запуска консольных команд
* [vscode](https://code.visualstudio.com/) - ???

> Опционально, можно поставить и сконфигурить пре-коммит хук для терраформа: [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform), что позволит форматировать и проверять код еще на этапе коммита

## Полезные экстеншены VSCode

* [editorconfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
* [terraform](https://marketplace.visualstudio.com/items?itemName=4ops.terraform)
* [drawio](https://marketplace.visualstudio.com/items?itemName=eightHundreds.vscode-drawio)
* [yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
* [embrace](https://marketplace.visualstudio.com/items?itemName=mycelo.embrace)
* [js-beautify](https://marketplace.visualstudio.com/items?itemName=HookyQR.beautify)
* [docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
* [git-extension-pack](https://marketplace.visualstudio.com/items?itemName=donjayamanne.git-extension-pack)
* [githistory](https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory)
* [kubernetes-tools](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
* [markdown-preview-enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)
* [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
* [file-tree-generator](https://marketplace.visualstudio.com/items?itemName=Shinotatwu-DS.file-tree-generator)
* [gotemplate-syntax](https://marketplace.visualstudio.com/items?itemName=casualjim.gotemplate)

## AWS аккаунт

Мы не будем сильно углубляться в настройки безопасности, тк требования у всех разные. Однако есть самые простые и базовые шаги, которые стоит выполнить, чтобы идти дальше. Если у вас все готово, смело пропускайте этот раздел.

> Крайне не рекомендуется использовать рутовый аккаунт для работы с AWS. Не ленитесь создавать пользователей с требуемыми/ограниченными правами.

### Настройки IAM

Итак, вы создали акк, прошли подтверждение, возможно уже даже создали Access Keys для консоли. В любом случае перейдите в настройки безопасности [аккаунта](https://console.aws.amazon.com/iam/home#/security_credentials) и обязательно выполните следующие шаги:

* Задайте/смените сильный пароль
* Активируйте MFA для аккаунта
* Удалить и не создавать access keys для рута

Далее в [IAM](https://console.aws.amazon.com/iam/home#/home) консоли:

* В разделе [Policies](https://console.aws.amazon.com/iam/home#/policies) создайте политику `MFASecurity`, запрещающую пользователям пользоваться серивисами без активации [MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage-mfa-only.html)
* В разделе [Groups](https://console.aws.amazon.com/iam/home#/groups) создайте группу `admin`, в следующем окне прикрепите к ней политику `AdministratorAccess` и `MFASecurity`. Завершите создание группы.
* В разделе [Users](https://console.aws.amazon.com/iam/home#/users) создайте пользователя для работы с AWS, выбрав обе галочки в *Select AWS access type*. В следующем окне добавьте пользователя в группу `admin`. Завершите создание и скачайте CSV с реквизитами доступа.

> В рамках этой доки мы не рассмотрели более секурный и правильный метод управления пользователями, используя внешние Identity провайдеры. Такие как G-suite, Okta и [другие](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html).

### Настройка awscli

* Terraform умеет работать с переменными окруения для [AWS access key ID and a secret access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) или AWS профилем, в данном примере создадим aws profile:
  
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

* В качестве альтернатив мможно извользовать `aws-vault` и `awsudo`

## Как использовать этот репо

<Добавить подготовку перед первым апплайем, шаги/команды и замечания по работе с террафором>
<Добавить описание работы с examples, как добавить доп сервисы или убрать ненужные>

## Что делать после деплоя

<Добавить шаги по конфигурации kubectl и постдеплойным шагам и проверкам>

## Coding conventions

В данном разделе собраны самые базовые рекомендации для пользователей и контрибьютеров по написанию кода, неймингу итд. Задача - однородный, стандартизированные, читаемый код. Дополнение, предложения и изменения - приветствутся.

### Название файлов, директорий и модулей терраформа

#### Общие конфигурационные файлы

Каждый модуль и конфигурация терраформа соедержит набор общих файлов заканчивающихся на `.tf`:

* `main.tf` - содержит настройки терраформа, если это верхний слой; или основной рабочий код если это модуль
* `variables.tf` - входные значения конфигурации или модуля
* `outputs.tf` - выходные значения конфигурации или модуля

Помимо этого могут присутствовать:

* `locals.tf` - содержит набор переменных, полученных путем интерполяции из remote state, outputs, variables итд.
* `providers.tf` - содержит настройки провайдеров терраформа, например `aws`, `kubernetes` итд
* `iam.tf` - сюда могут быть вынесены IAM конфигурации политик, ролей итд

Это не конечный список, каждая конфигурация, модуль или слой могут нуждаться в дополнительных файлах и манифестах. Задача - называть как можно емче и ближе по смыслу к сожержимому. Префиксы не использовать.

> Самом терраформу не важно сколько файлов вы создаете. Он собирает все манифесты слоев и модулей в один объект, строит зависимости и исполняет.

#### Специфичные конфигурационные файлы

К таким конфигурационным файлам и манифестам можно отнести следующее: темплейты для ресурсов `data "template_file"` или `templatefile()`, вынесенные в отдельный `.tf` файл логическая группа ресурсов, один или несколько деплойментов в кубер с помощью `resource "helm_release"`, вызов модуля итд.

> Справедливо будет заметить, что раз создается какая-то логическая группа ресурсов и это будет реюзаться, то почему не вынести эт овсе в отдельынй модуль. Но оказалось, что менеджить хелм релизы, темплейты для них и дополнительные ресурсы проще в отдельных .tf файлах в корне слоя. И для многих таких конфигураций с переездом в модули количество кода может удвоиться + в модули обычно мы переносим то, что собираемя реюзать.

### Структура проекта

```
aws-eks-base
 ┣ docker
 ┃ ┣ aws-eks-utils
 ┃ ┣ elasticsearch
 ┃ ┣ teamcity-agent
 ┃ ┗ wordpress
 ┣ examples
 ┣ helm-charts
 ┃ ┣ calico-daemonset
 ┃ ┣ certificate
 ┃ ┣ cluster-issuer
 ┃ ┣ elk
 ┃ ┗ teamcity
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
| docker/      ||
| examples/    ||
| helm-charts/ ||
| helm-charts/calico-daemonset ||
| helm-charts/certificate ||
| helm-charts/cluster-issuer ||
| helm-charts/elk ||
| helm-charts/teamcity ||
|terraform/||
|terraform/layer1-aws||
|terraform/layer2-k8s||
|terraform/modules||
|.editorconfig||
|.gitlab-ci.yml||
|.pre-commit-config.yaml||
