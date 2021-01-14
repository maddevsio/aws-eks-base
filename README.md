# Бойлерплейт базовой AWS инфраструктуры для запуска EKS-кластера

В данной репе собраны наработки команды MadOps для быстрого развертывания Kubernetes кластера, вспомогательных сервисов и нижележащей инфраструктуры в облаке Amazon. Основным инструментом разработки и поставки является [terraform](https://www.terraform.io/)

За время работы компании мы перепробовали много инфрастуктурных решений и сервисов, и прошли путь от on-premise железа до serverless. В итоге на текущий момент нашей стандартной платформой для развертывания приложений стал Kubernetes, а основным облаком - AWS. Тут стоит отметить, что не смотря на то, что 90% наших и клиентских проектов хостится на AWS, а в качестве kubernetes платформы используется (AWS EKS)[https://aws.amazon.com/eks/] - мы не упираемся рогом, и не тащим все подряд в кубер или заставляем хостится в AWS. Kubernetes предлагается только после сбора и анализа требований к архитектуре сервиса. А далее при выборе кубера - приложениям почти не важно, как создан сам кластер - вручную, через kops или используя managed услуги облачных провайдеров - в основе своей платформа кубера везде одинакова. И выбор конкретного провайдера уже складывается из дополнительный требований, экспертизы итд.

Мы знаем, что текущая реализация далеко не идеальна. Например, в кластер мы деплоим сервисы с помощью `terraform` - это довольно топорно и против подходов кубера, но это удобно для бутстрапа - тк используя стейт и интерполяцию, мы передаем необходимые `ids`, `arns` и другие указатели на ресурсы и имена или секреты в шаблоны и генерим из них `values` для нужных чартов, не выходя за пределы терраформа. Есть более специфичные минусы, ресурсы `data "template_file"` которые мы использовали для большинства шаблонов крайне неудобны для разработки и отладки, особенно если это такие 500+ строчные рулоны, типа `terraform/layer2-k8s/templates/elk-values.yaml`. Так-же, смотря на `helm3` и избавление от `tiller` - большое количество helm-релизов все равно в какой-то момент приводит к зависанию плана. Частично, но не всегда решается путем таргетированного `terraform apply -target`, но для консистентности стейцта желательно выполнять `plan` и `apply` целиком на всей конфигурации. Если собираетесь использовать данный бойлер, желательно разбить слой `terraform/layer2-k8s` на несколько, вынеся крупные и комплексные релизы в отдельные подслои.

Могут возникнуть справедлыевые вопросы к количеству `.tf` файлов. Оно конечно просится на рефакторинг и обмодуливание. Чем мы и займемся в ближайшее время, попутно решая озвученные проблемы выше.

## Архитекутрная схема

<тут надо вставить картинку со схемой и добавить короткое описание>

## Стоимость текущей инфры

<тут надо вставить табличку со стоимостью используемых ресурсов в час и в месяц с итого>

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
* [vscode](https://code.visualstudio.com/)

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

## Работа с terraform кодом

<Добавить описание слоев, подготовку входящих параметров, шаги/команды и замечания по работе с террафором>
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

К таким конфигурационным файлам и манифестам можно отнести следующее: темплейты для ресурсов `data "template_file"` или `templatefile()`, вынесенные в отдельный `.tf` файл группа ресурсов, отдельный деплоймент в кубер с помощью `resource "helm_release"`, вызов модуля итд.

---
**На заметку**



---

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
