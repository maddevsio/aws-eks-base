# Бойлерплейт базовой AWS инфраструктуры c EKS-кластером

[![Developed by Mad Devs](https://maddevs.io/badge-dark.svg)](https://maddevs.io/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Преимущества этого бойлерплейта

- Инфраструктура как код (IaC): используя Terraform, вы получаете налаженную и продуктивную инфраструктуру
- Управление состоянием: Terraform сохраняет текущее состояние инфраструктуры, поэтому вы можете просматривать последующие изменения, не применяя их. Также возможность хранить стейт удаленно позволяет работать над инфраструктурой в команде
- Масштабируемость и гибкость: инфраструктуру, построенную на основе этого бойлерплейта, можно расширять и обновлять ​​в любое время
- Дополнения: вы получаете инструменты масштабирования и мониторинга вместе с базовой инфраструктурой. Вам не нужно вручную ничего изменять в инфраструктуре; вы можете просто подправить что-то в Terraform по мере необходимости и задеплоить это в AWS и Kubernetes
- Контроль над ресурсами: подход IaC делает инфраструктуру более наблюдаемой и предотвращает растрату ресурсов
- Четкая документация: ваш код в Terraform фактически становится вашей проектной документацией. Это означает, что вы можете добавлять новых членов в команду, и им не понадобится слишком много времени, чтобы понять, как работает инфраструктура

## Причины использовать этот бойлерплейт

- Безопасный и отшлифованный: мы использовали эти решения в наших собственных крупномасштабных, высоконагруженных проектах. Мы месяцами совершенствовали этот процесс построения инфраструктуры, чтобы в результате получилась безопасная в использовании, защищенная и надежная система
- Экономит время: вы можете потратить недели на собственные поиски и неизбежные ошибки, чтобы построить такую инфраструктуру. Или же вы можете положиться на этот бойлерплейт и поднять нужную инфраструктуру в течение дня
- Свободный: мы рады делиться результатами своей работы

[![boilerplate asciicast](https://asciinema.org/a/wCS0HdC6UViWDKO7GypyIJjaB.png)](https://asciinema.org/a/wCS0HdC6UViWDKO7GypyIJjaB?autoplay=1&speed=2)

## Описание

В данном репозитории собраны наработки команды Mad Devs для быстрого развертывания Kubernetes кластера, вспомогательных сервисов и нижележащей инфраструктуры в облаке Amazon. Основным инструментом разработки и поставки является [terraform](https://www.terraform.io/).

За время работы компании мы перепробовали много инфраструктурных решений и сервисов, и прошли путь от on-premise железа до serverless. В итоге на текущий момент нашей стандартной платформой для развертывания приложений стал Kubernetes, а основным облаком - AWS. 

Тут стоит отметить, что несмотря на то, что 90% наших и клиентских проектов хостится на AWS, а в качестве Kubernetes платформы используется [AWS EKS](https://aws.amazon.com/eks/), мы не упираемся рогом, не тащим все подряд в Kubernetes и не заставляем хостится в AWS. Kubernetes предлагается только после сбора и анализа требований к архитектуре сервиса. 

А далее при выборе Kubernetes - приложениям почти не важно, как создан сам кластер - вручную, через kops или используя managed услуги облачных провайдеров - в своей основе платформа Kubernetes везде одинакова. И выбор конкретного провайдера уже складывается из дополнительных требований, экспертизы и т.д.

Мы знаем, что текущая реализация далеко не идеальна. Например, в кластер мы деплоим сервисы с помощью `terraform` - это довольно топорно и против подходов кубера, но это удобно для бутстрапа - т.к. используя стейт и интерполяцию, мы передаем необходимые `ids`, `arns` и другие указатели на ресурсы и имена или секреты в шаблоны и генерим из них `values` для нужных чартов, не выходя за пределы терраформа. 

Есть более специфичные минусы: ресурсы `data "template_file"`, которые мы использовали для большинства шаблонов, крайне неудобны для разработки и отладки, особенно если это такие 500+ строчные рулоны, типа `terraform/layer2-k8s/templates/elk-values.yaml`. Также, смотря на `helm3` и избавление от `tiller` - большое количество helm-релизов все равно в какой-то момент приводит к зависанию плана. Частично, но не всегда решается путем таргетированного апплая `terraform apply -target`, но для консистентности стейта желательно выполнять `plan` и `apply` целиком на всей конфигурации. Если собираетесь использовать данный бойлер, желательно разбить слой `terraform/layer2-k8s` на несколько, вынеся крупные и комплексные релизы в отдельные подслои.

Могут возникнуть справедливые вопросы к количеству `.tf` файлов. Оно конечно просится на рефакторинг и "обмодуливание". Чем мы и займемся в ближайшее время, разбивая этот монолит на микромодули и вводя `terragrunt`, попутно решая озвученные проблемы выше.

Более подробно о нашем бойлерплейте смотрите в видео:

[![boilerplate youtube video](https://img.youtube.com/vi/loqSDGgtmKg/0.jpg)](https://youtu.be/loqSDGgtmKg)

## Оглавление

- [Архитектурная схема](#архитектурная-схема)
- [Стоимость текущей инфры](#стоимость-текущей-инфры)
- [Структура неймспейсов в K8S кластере](#структура-неймспейсов-в-k8s-кластере)
- [Необходимый инструментарий](#необходимый-инструментарий)
- [Полезные экстеншены VSCode](#полезные-экстеншены-vscode)
- [AWS аккаунт](#aws-аккаунт)
  - [Настройки IAM](#настройки-iam)
  - [Настройка awscli](#настройка-awscli)
- [Как использовать этот репо](#как-использовать-этот-репо)
  - [Подготовка](#подготовка)
    - [S3 state backend](#s3-state-backend)
    - [Секреты](#секреты)
    - [Домен и SSL](#домен-и-ssl)
  - [Работа с terraform](#работа-с-terraform)
    - [init](#init)
    - [plan](#plan)
    - [apply](#apply)
  - [terragrunt](#terragrunt)
- [Что делать после деплоя](#что-делать-после-деплоя)
  - [examples](#examples)
- [Coding conventions](#coding-conventions)
  - [Имена и подходы используемые в коде](#имена-и-подходы-используемые-в-коде)
    - [Базовое имя проекта](#базовое-имя-проекта)
    - [Формирование уникального префикса имен ресурсов](#формирование-уникального-префикса-имен-ресурсов)
    - [Разделители](#разделители)
    - [Формирование имен ресурсов](#формирование-имен-ресурсов)
    - [Формирование имен переменных](#формирование-имен-переменных)
    - [Формирование имен вывода данных](#формирование-имен-вывода-данных)
  - [Название файлов, директорий и модулей терраформа](#название-файлов-директорий-и-модулей-терраформа)
    - [Общие конфигурационные файлы](#общие-конфигурационные-файлы)
    - [Специфичные конфигурационные файлы](#специфичные-конфигурационные-файлы)
    - [Модули](#модули)
  - [Структура проекта](#структура-проекта)

## Архитектурная схема

![aws-base-diagram](docs/aws-base-diagrams-Infrastracture-v6.svg)

Эта схема описывает инфраструктуру, создаваемую по умолчанию.
Небольшое описание того, что мы имеем на схеме. Инфраструктура в облаке AWS

- Мы используем три availability Zone
- Основная сеть VPC
  - Три публичные подсети для ресурсов, которые должны быть доступны из интернета
    - Elastic load balancing - точка входа в k8s cluster
    - Internet gateway - точка входа в созданную VPC
    - Single Nat Gateway - сервис для организации доступа для инстансов из приватных сетей в публичные.
  - Три приватные подсети с доступом к интернету через Nat Gateway
  - Три интра подсети без доступа в интернет
  - Три приватные подсети для RDS
  - Route tables для приватных сетей
  - Route tables для публичных сетей
- Autoscaling groups
  - On-demand - эта группа с 1-5 on-demand instances для ресурсов с требованиями бесперебойной работы
  - Spot     - эта группа с 1-6 spot instances для ресурсов, которым не критично прерывание работы
  - CI       - эта группа с 0-3 spot instances, создающихся по требованию gitlab-runner, расположены в публичной сети
- EKS control plane - это узлы плоскости управления кластеров k8s
- Route53 - сервис для управления DNS
- Cloudwatch - сервис для получения метрик о состоянии работы ресурсов в облаке AWS
- AWS Certificate manager - сервис для управления сертификатами AWS
- SSM parameter store - сервис для хранения, извлечения и контроля значений конфигурации
- S3 bucket - это бакет используется для хранения terraform state
- Elastic container registry - сервис для хранения docker images

## Стоимость текущей инфры

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

> Стоимость указана без подсчета количества трафика для Nat Gateway Load Balancer и S3

## Структура неймспейсов в K8S кластере

На этой схеме указаны неймспейсы, которые используются в кластере, и ресурсы, которые находятся в этих неймспесах по умолчанию.

![aws-base-namespaces](docs/aws-base-diagrams-Namespaces-v3.svg)

Используемые в кластере чарты, с указанием неймспейса и коротким описанием.

| Namespace   |  service                                                                                                            | Description                                                                                                             |
|-------------|---------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------|
| kube-system | [core-DNS](https://github.com/coredns/coredns)                                                                      | DNS сервер, используемый в кластере                                                                                      |
| certmanager | [cert-manager](https://github.com/jetstack/cert-manager)                                                            | Cервис для автоматизации управления и получения сертификатов TLS                                                        |
| certmanager | [cluster-issuer](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/cluster-issuer)         | Ресурс, представляющий центр сертификации, который может генерировать подписанные сертификаты, выполняя запросы подписи. |
| ing         | [nginx-ingress](https://github.com/kubernetes/ingress-nginx)                                                        | Ингресс контролер, который использует nginx в качестве реверс прокси.                                                   |
| ing         | [Certificate](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/certificate)               | Объект сертификата, который используется для nginx-ingress.                                                             |
| dns         | [external-dns](https://github.com/bitnami/charts/tree/master/bitnami/external-dns)                                  | Сервис для организации доступа к внешним DNS из кластера.                                                               |
| ci          | [gitlab-runner](https://gitlab.com/gitlab-org/charts/gitlab-runner)                                                 | Гитлаб раннер используемый для запуска агентов gitlab-ci.                                                                |
| sys         | [aws-node-termination-handler](https://github.com/aws/eks-charts/tree/master/stable/aws-node-termination-handler)   | Сервис для контроля корректного завершения работы EC2.                                                                  |
| sys         | [autoscaler](https://github.com/kubernetes/autoscaler)                                                              | Сервис, который автоматически регулирует размер k8s кластера в зависимости от требований.                                |
| sys         | [kubernetes-external-secrets](https://github.com/external-secrets/kubernetes-external-secrets)                      | Сервис для работы с внешними хранилищами секретов, такими как secret-manager, ssm parameter store и тд.                 |
| sys         | [Reloader](https://github.com/stakater/Reloader)                                                                    | Сервис, который следит за изменения внешних секретов и обновляет их в кластере.                                          |
| monitoring  | [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) | Зонтичный чарт включает в себя группу сервисов, используемых для мониторинга работы кластера и визуализации данных.       |
| monitoring  | [loki-stack](https://github.com/grafana/loki/tree/master/production/helm/loki-stack)                                | Зонтичный чарт включает в себя сервис сбора логов контейнеров и визуализации данных.                                    |
| elk         | [elk](https://gitlab.com/madboiler/devops/aws-eks-base/-/tree/master/helm-charts/elk)                               | Зонтичный чарт включает в себя группу сервисов, для сбора логов, метрик и визуализации этих данных.                     |

## Необходимый инструментарий

- [tfenv](https://github.com/tfutils/tfenv) - утилита для менеджмента разных версий терраформа, необходимую версию можно задать напрямую аргументом или через `.terraform-version`
- [terraform](https://www.terraform.io/) - тот самый терраформ, наш главный инструмент разработки: `tfenv install`
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html) - консольная утилита для работы с AWS API
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) - консольная тула для работы с кубер кластерами
- [kubectx + kubens](https://github.com/ahmetb/kubectx) - консольные тулы для kubectl помогают переключаться между кластерами и неймспейсами Kubernetes
- [helm](https://helm.sh/docs/intro/install/) - пакетный менеджер для деплоя приоложений в кубер
- [helmfile](https://github.com/roboll/helmfile) - "докер композ" для хелм чартов
- [terragrunt](https://terragrunt.gruntwork.io/) - небольшой wrapper для терраформа обеспечивающий DRY для некоторых статичных частей терраформ кода
- [awsudo](https://github.com/meltwater/awsudo) - простая консольная утилита, позволяющая запускать команды awscli из-под определенных ролей
- [aws-vault](https://github.com/99designs/aws-vault) - тула для секурного менеджмента ключей AWS и запуска консольных команд
- [aws-mfa](https://github.com/broamski/aws-mfa) - утилита для автоматизации получения временных реквизитов доступа к AWS с включенным MFA
- [vscode](https://code.visualstudio.com/) - основная IDE

> Опционально, можно поставить и сконфигурить пре-коммит хук для терраформа: [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform), что позволит форматировать и проверять код еще на этапе коммита

## Полезные экстеншены VSCode

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

## AWS аккаунт

Мы не будем сильно углубляться в настройки безопасности, тк требования у всех разные. Однако есть самые простые и базовые шаги, которые стоит выполнить, чтобы идти дальше. Если у вас все готово, смело пропускайте этот раздел.

> Крайне не рекомендуется использовать рутовый аккаунт для работы с AWS. Не ленитесь создавать пользователей с требуемыми/ограниченными правами.

### Настройки IAM

Итак, вы создали акк, прошли подтверждение, возможно уже даже создали Access Keys для консоли. В любом случае перейдите в настройки безопасности [аккаунта](https://console.aws.amazon.com/iam/home#/security_credentials) и обязательно выполните следующие шаги:

- Задайте сильный пароль
- Активируйте MFA для root аккаунта
- Удалите и не создавайте access keys root аккаунта

Далее в [IAM](https://console.aws.amazon.com/iam/home#/home) консоли:

- В разделе [Policies](https://console.aws.amazon.com/iam/home#/policies) создайте политику `MFASecurity`, запрещающую пользователям пользоваться сервисами без активации [MFA](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage-mfa-only.html)
- В разделе [Roles](https://console.aws.amazon.com/iam/home?region=us-east-1#/roles) создайте новую роль `administrator`. Выберете *Another AWS Account*, указав в поле Account ID номер нашего аккаунт. Отметьте галочку *Require MFA*. В следующем окне Permissions прикрепите к ней политику `AdministratorAccess`
- В разделе [Policies](https://console.aws.amazon.com/iam/home#/policies) создайте политику `assumeAdminRole`:

  ```json
  {
    "Version": "2012-10-17",
    "Statement": {
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": "arn:aws:iam::730809894724:role/administrator"
    }
  }
  ```
- В разделе [Groups](https://console.aws.amazon.com/iam/home#/groups) создайте группу `admin`, в следующем окне прикрепите к ней политику `assumeAdminRole` и `MFASecurity`. Завершите создание группы.
- В разделе [Users](https://console.aws.amazon.com/iam/home#/users) создайте пользователя для работы с AWS, выбрав обе галочки в *Select AWS access type*. В следующем окне добавьте пользователя в группу `admin`. Завершите создание и скачайте CSV с реквизитами доступа.

> В рамках этой доки мы не рассмотрели более секурный и правильный метод управления пользователями, используя внешние Identity провайдеры. Такие как G-suite, Okta и [другие](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers.html).

### Настройка awscli

- Terraform умеет работать с переменными окружения для [AWS access key ID and a secret access key](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys) или AWS профилем, в данном примере создадим aws profile:

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
- Далее пройдите по [ссылке](https://docs.aws.amazon.com/neptune/latest/userguide/iam-auth-temporary-credentials.html), чтобы узнать как получить временные токены
- В качестве альтернативы, для того чтобы использовать `awscli` и соответственно `terraform` с [MFA](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/), можно использовать `aws-mfa`, `aws-vault` и `awsudo`

## Как использовать этот репо

### Подготовка

#### S3 state backend

В качестве бэкенда для хранения стейтов терраформа и для обмена данными между слоями используется S3. Есть два способа настроить бэкенд: создать вручную `backend.tf` файл в каждом слое и более простой способ - выполнить из `terraform/`:

  ```bash
  $ export TF_REMOTE_STATE_BUCKET=my-new-state-bucket
  $ terragrunt run-all init
  ```

#### Входные данные

В файле `terraform/demo.tfvars.example` представлен пример со значениями для терраформа. Скопируйте его в `terraform/terraform.tfvars` и отредактируйте по своему усмотрению:

```bash
$ cp terraform/layer1-aws/demo.tfvars.example terraform/layer1-aws/terraform.tfvars
```

> Все возможные параметры можно посмотреть в Readme для каждого слоя.

#### Секреты

В корне `layer2-k8s` лежит файл `aws-sm-secrets.tf`, ожидающий значения, заданные в секрете `/${local.name}-${local.environment}/infra/layer2-k8s` сервиса [AWS Secrets Manager](https://console.aws.amazon.com/secretsmanager/home?region=us-east-1#!/home). Данный секрет используется для аутентификации в Kibana и Grafana используя GitLab. Также задается токен для регистрации гитлаб раннера, параметры slack для алертменеджера:

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

> Задайте все необходимые значения, можно задать пустые значения. В случае если вы не будете использовать данные секреты, следует удалить этот `.tf` файл из корня `layer2-k8s`

#### Домен и SSL

Необходимо будет купить или подключить уже купленный домен в Route53. Имя домена и айди зоны нужно будет задать в переменных `domain_name` и `zone_id` в слое layer1.

По умолчанию значение переменной `create_acm_certificate = false`. Что указывает терраформу запросить arn существующего ACM сертификата. Установите значение `true` если вы хотите, чтобы терраформ создал новый SSL сертификат.

### Работа с terraform

#### init

Команда `terraform init` используется для инициализации стейта и его бэкенда, провайдеров, плагинов и модулей. Это первая команда, которую необходимо выполнить в `layer1` и `layer2`:

  ```bash
  $ terraform init
  ```

  Правильный аутпут:

  ```
  * provider.aws: version = "~> 2.10"
  * provider.local: version = "~> 1.2"
  * provider.null: version = "~> 2.1"
  * provider.random: version = "~> 2.1"
  * provider.template: version = "~> 2.1"

  Terraform has been successfully initialized!
  ```

#### plan

Команда `terraform plan` считывает стейт терраформа, конфигурационные файлы и выводит список изменений и действий, которые необходимо произвести, чтобы привести стейт в соответствие с конфигурацией. Удобный способ проверить изменения перед применением. В случае использования с параметром `-out` сохраняет пакет изменений в указанный файл, который позже можно будет использовать при `terraform apply`. Пример вызова:

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

Команда `terraform apply` сканирует `.tf` в текущей директории и приводит стейт к описанной в них конфигурации, производя изменения в инфраструктуре. По умолчанию перед применение производится `plan` с диалогом о продолжении. Опционально можно указать в качестве инпута сохраненный план файл:

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

Не всегда нам нужно перечитывать и сравнивать весь стейт, если были добавлены небольшие изменения не влияющие на всю инфру. Для таких целей можно использовать таргетный `apply`, например:

  ```bash
  $ terraform apply -target helm_release.kibana
  ```

Более подробно можно почитать по этой [ссылке](https://www.terraform.io/docs/cli/run/index.html)

> Первый раз команда `apply` должна производиться в слоях по порядку: сначала layer1, следом layer2.
А `destroy` инфраструктуры должен производиться в обратном порядке.

### terragrunt

Для упрощения создания remote state бакета и бэкенд конфигурации терраформа мы добавили `terragrunt`. Все, что нужно - это задать имя бакета в переменной окружения `TF_REMOTE_STATE_BUCKET` и выполнить команды terragrunt из директории `terraform/`:

 ```bash
 $ export TF_REMOTE_STATE_BUCKET=my-new-state-bucket
 $ terragrunt run-all init
 $ terragrunt run-all apply
 ```

Таким образом `terragrunt` создаст бакет, подготовит бэкенд терраформа, последовательно в layer-1 и layer-2 произведет `terraform init` и `terraform apply`.

## Что делать после деплоя

После апплая данной конфигурации вы получите инфраструктуру, описанную и обрисованную в начале документа. В AWS и внутри EKS кластера будут созданы базовые ресурсы и сервисы, необходимые для работы EKS k8s кластера.

Получить доступ к кластеру можно командой:

  ```bash
  aws eks update-kubeconfig --name maddevs-demo-use1 --region us-east-1
  ```

### examples

В каждом слое находится директория `examples/`, которая содержит рабочие примеры, расширяющие базовую конфигурацию. Название файлов и содержимое соответствует нашим кодинг соглашениям, поэтому дополнительное описание не требуется. Если необходимо что-то заюзать - достаточно перенести из этой папки в корень слоя.

Это позволит расширить вам базовый функционал запустив систему мониторинга на базе ELK или Prometheus Stack и тд
## Coding conventions

В данном разделе собраны самые базовые рекомендации для пользователей и контрибьютеров по написанию кода, неймингу и тд. Задача - однородный, стандартизированный, читаемый код. Дополнение, предложения и изменения - приветствуется.

### Имена и подходы, используемые в коде

#### Базовое имя проекта

Базовое имя задается в переменной name в variables.tf, используется при формировании уникальных имен ресурсов:

```
variable "name" {
  default = "demo"
}
```

#### Формирование уникального префикса имен ресурсов

На базе переменной name, целевого региона (переменная region) и значения terraform.workspace мы формируем уникальный префикс для имен ресурсов:

```
locals {
  env            = terraform.workspace == "default" ? var.environment : terraform.workspace
  short_region   = var.short_region[var.region]
  name           = "${var.name}-${local.env}-${local.short_region}"
}
```

Пример префикса:

- name = "demo"
- region = "us-east-2"
- terraform.workspace = "test"

`demo-test-use2`

После чего значение `local.name` используется в качестве префикса для всех атрибутов `name` и `name_prefix`. Это позволяет нам запускать копии инфраструктуры даже в одном аккаунте.

#### Разделители

- Для атрибутов `name` или `name_prefix` у ресурсов, модулей и тд, а так же для значений данных вывода в качестве разделителя используется символ дефиса `-`:

  ```
  name = "${local.name}-example"
  ```

  или

  ```
  name = "demo-test-use2-example"
  ```

- Для сложных имен в объявлении ресурсов, переменных, модулей, аутпутов в коде используется символ подчёркивания `_`:

  ```
  resource "aws_iam_role_policy_attachment" "pritunl_server"{
  }

  variable "cluster_name" {
  }

  module "security_groups" {
  }
  ```

#### Формирование имен ресурсов

- Не следует повторять тип ресурса в имени ресурса (ни частично, ни полностью):
  - Хорошо: `resource "aws_route_table" "public" {}`
  - Плохо: `resource "aws_route_table" "public_route_table" {}`
  - Плохо: `resource "aws_route_table" "public_aws_route_table" {}`

- Если ресурс уникален в рамках модуля, следует при именовании использовать `this`. Например модуль содержит один ресурс типа `aws_nat_gateway` и несколько ресурсов типа `aws_route_table`, в этом случае `aws_nat_gateway` должен быть назван `this`, а  `aws_route_table` должны иметь более осмысленные имена,например `private`, `public`, `database`:

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

- Для имен должны использоваться существительные
- В большинстве случаев, если ресурс поддерживает параметр `name_prefix`, следует использовать его вместо параметра `name`

#### Формирование имен переменных

- Используйте те же имена переменных, описание и значение по умолчанию, как определено в официальной документации терраформ для ресурса, над которым вы работаете
- Не указывать `type = "list"`, если есть `default = []`
- Не указывать `type = "map"`, если есть `default = {}`
- Используйте множественное число в имени переменных типа list и map:

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

- Всегда используйте description для переменных
- При объявлении переменных соблюдайте следующий порядок ключей: `description`, `type`, `default`
- Чем выше уровень объявления переменной, тем желательней использовать семантические префиксы для каждой переменной:

  ```
  variable "ecs_instance_type" {
  ...
  }

  variable "rds_instance_type" {
  ...
  }
  ```

#### Формирование имен вывода данных

- Имена вывода данных должны быть понятны за пределами терраформ и вне контекста модуля (когда пользователь использует модуль, должны быть понятны тип и атрибут возвращаемого значения)

- Общая рекомендация для именования вывода данных заключается в том, что имя должно описывать содержащееся в ней значение и не иметь излишеств

- Правильная структура для имен вывода выглядит как `{name}_{type}_{attribute}` для неуникальных атрибутов и ресурсов и `{type}_{attribute}` для уникальных, например вывод одной из нескольких security групп и уникального публичного адреса:

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

- Если возвращаемое значение является списком, оно должно иметь имя во множественном числе
- Всегда используйте description для вывода данных

### Название файлов, директорий и модулей терраформа

#### Общие конфигурационные файлы

Каждый модуль и конфигурация терраформа содержит набор общих файлов заканчивающихся на `.tf`:

- `main.tf` - содержит настройки терраформа, если это верхний слой; или основной рабочий код, если это модуль
- `variables.tf` - входные значения конфигурации или модуля
- `outputs.tf` - выходные значения конфигурации или модуля

Помимо этого могут присутствовать:

- `locals.tf` - содержит набор переменных, полученных путем интерполяции из remote state, outputs, variables и тд.
- `providers.tf` - содержит настройки провайдеров терраформа, например `aws`, `kubernetes` и тд
- `iam.tf` - сюда могут быть вынесены IAM конфигурации политик, ролей и тд

Это не конечный список, каждая конфигурация, модуль или слой могут нуждаться в дополнительных файлах и манифестах. Задача - называть их как можно ёмче и ближе по смыслу к содержимому. Префиксы не использовать.

> Самом терраформу не важно, сколько файлов вы создаете. Он собирает все манифесты слоев и модулей в один объект, строит зависимости и исполняет.

#### Специфичные конфигурационные файлы

К таким конфигурационным файлам и манифестам можно отнести следующее: темплейты для ресурсов `data "template_file"` или `templatefile()`, вынесенная в отдельный `.tf` файл логическая группа ресурсов, один или несколько деплойментов в кубер с помощью `resource "helm_release"`, создание aws ресурсов не требующих отдельного модуля, инициализация модуля и тд.

> Справедливо будет заметить, что раз создается какая-то логическая группа ресурсов и это будет реюзаться, то почему не вынести это все в отдельный модуль. Но оказалось, что менеджить хелм релизы, темплейты для них и дополнительные ресурсы проще в отдельных .tf файлах в корне слоя. И для многих таких конфигураций с переездом в модули количество кода может удвоиться + в модули обычно мы переносим то, что собираемся реюзать.

Каждый специфичный `.tf` файл должен начинаться с префикса, указывающего на сервис или провайдер, к которому относится основнoй создаваемый ресурс или группа, например `aws`. Следом опционально указывается тип сервиса, например `iam`. Далее идет название главного сервиса или ресурса или группы ресурсов, которые декларируется внутри, после чего опционально может быть добавлен поясняющий суффикс, если таких файлов будет несколько. Все части имени разделены `дефисами`.

Итого формула выглядит так:
`provider|servicename`-[`optional resource/service type`]-`main resourcename|group-name`-[`optional suffix`].tf

Примеры:

- `aws-vpc.tf` - терраформ манифест описывающий создание единственной vpc
- `aws-vpc-stage.tf` - терраформ манифест описывающий создание одной из vpc, для стейджинга
- `eks-namespaces.tf` - группа неймспейсов, создаваемых в EKS кластере
- `eks-external-dns.tf` - содержит описание деплоя external-dns сервиса в EKS кластер
- `aws-ec2-pritunl.tf` - содержит инициализацию модуля, который создает EC2 инстанс в AWS с настроенным pritunl

#### Модули

Подход к названию директорий модулей точно такой же, как и к специфичным `.tf` файлам и соответствует формуле:
`provider|servicename`-[`optional resource/service type`]-`main resourcename|group-name`-[`optional suffix`]

Примеры:

- `eks-rbac-ci` - модуль для создания рбак для CI внутри EKS кластера
- `aws-iam-autoscaler` - модуль для создания IAM политик для автоскейлера
- `aws-ec2-pritunl` -  модуль для создания pritunl ec2 инстанса

### Структура проекта

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
| docker/      | кастомные и модифицированные докерфайлы|
| examples/    | примеры k8s деплойментов |
| helm-charts/ | тут находятся используемые чарты |
| helm-charts/certificate | чарт создающий ssl сертификат для nginx-ingress |
| helm-charts/cluster-issuer | чарт создающий cluster-issuer используя CRD cert-manager |
| helm-charts/elk | зонтичный чарт для деплоя elk стэка |
| helm-charts/teamcity | helm chart для деплоя teamcity агента иои сервера |
|terraform/| здесь лежат файли терраформа |
|terraform/layer1-aws| базовые AWS ресурсы |
|terraform/layer2-k8s| здесь лежит описание ресурсов для деплоя в EKS |
|terraform/modules| директория содержащая небольшие самописные модули |
|.editorconfig| |
|.gitlab-ci.yml||
|.pre-commit-config.yaml||
