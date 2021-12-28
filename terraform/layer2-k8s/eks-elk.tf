locals {
  elk = {
    name          = local.helm_releases[index(local.helm_releases.*.id, "elk")].id
    enabled       = local.helm_releases[index(local.helm_releases.*.id, "elk")].enabled
    chart         = local.helm_releases[index(local.helm_releases.*.id, "elk")].chart
    repository    = local.helm_releases[index(local.helm_releases.*.id, "elk")].repository
    chart_version = local.helm_releases[index(local.helm_releases.*.id, "elk")].chart_version
    namespace     = local.helm_releases[index(local.helm_releases.*.id, "elk")].namespace
  }
  kibana_domain_name          = "kibana-${local.domain_suffix}"
  apm_domain_name             = "apm-${local.domain_suffix}"
  elasticsearch_password      = local.elk.enabled ? random_string.elasticsearch_password[0].result : "test123"
  elk_snapshot_retention_days = 90
  elk_index_retention_days    = 14
  kibana_user                 = "kibana-${local.env}"
  kibana_password             = local.elk.enabled ? random_string.kibana_password[0].result : "test123"
  elk_snapshots_bucket_name   = local.elk.enabled ? aws_s3_bucket.elastic_stack[0].id : "bucket_name"
  elk_elasticsearch_values    = <<VALUES
elasticsearch:
  enabled: true
  image: "public.ecr.aws/o7m5y2d9/elasticsearch" # Uses this dockerfile https://github.com/maddevsio/aws-eks-base/blob/main/docker/elasticsearch/Dockerfile
  imageTag: 7.16.2
  esMajorVersion: 7
  replicas: 1
  clusterHealthCheckParams: "wait_for_status=yellow&timeout=1s"
  clusterName: "elasticsearch"

  volumeClaimTemplate:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: advanced
    resources:
      requests:
        storage: 100Gi

  resources:
    limits:
      cpu: 1000m
      memory: 2Gi
    requests:
      cpu: 512m
      memory: 2Gi

  esJavaOpts: -Xmx1500m -Xms1500m
  protocol: https
  esConfig:
    elasticsearch.yml: |
      xpack.security.enabled: true
      xpack.monitoring.collection.enabled: true
      xpack.security.transport.ssl.enabled: true
      xpack.security.transport.ssl.verification_mode: certificate
      xpack.security.transport.ssl.key: /usr/share/elasticsearch/config/certs/tls.key
      xpack.security.transport.ssl.certificate: /usr/share/elasticsearch/config/certs/tls.crt
      xpack.security.http.ssl.enabled: true
      xpack.security.http.ssl.key: /usr/share/elasticsearch/config/certs/tls.key
      xpack.security.http.ssl.certificate: /usr/share/elasticsearch/config/certs/tls.crt

  extraEnvs:
    - name: ELASTIC_PASSWORD
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: password
    - name: ELASTIC_USERNAME
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: username

  secretMounts:
    - name: elastic-certificates
      secretName: elastic-certificates
      path: /usr/share/elasticsearch/config/certs

  keystore:
    - secretName: elasticsearch-s3-user-creds
      items:
      - key: aws_s3_user_access_key
        path: s3.client.default.access_key
      - key: aws_s3_user_secret_key
        path: s3.client.default.secret_key

  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: eks.amazonaws.com/capacityType
          operator: In
          values:
            - ON_DEMAND
VALUES
  elk_kibana_values           = <<VALUES
kibana:
  enabled: true
  resources:
    requests:
      cpu: "512m"
      memory: "1Gi"
    limits:
      cpu: "512m"
      memory: "1Gi"

  ingress:
    enabled: true
    className: nginx
    annotations:
      nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
    path: /
    hosts:
      - ${local.kibana_domain_name}

  elasticsearchHosts: "https://elasticsearch-master:9200"

  extraEnvs:
    - name: "NODE_OPTIONS"
      value: "--max-old-space-size=800"
    - name: 'ELASTICSEARCH_USERNAME'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: username
    - name: 'ELASTICSEARCH_PASSWORD'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: password
    - name: 'KIBANA_ENCRYPTION_KEY'
      valueFrom:
        secretKeyRef:
          name: kibana-encryption-key
          key: encryptionkey

  kibanaConfig:
    kibana.yml: |
      server.ssl:
        enabled: true
        key: /usr/share/kibana/config/certs/tls.key
        certificate: /usr/share/kibana/config/certs/tls.crt
      xpack.security.encryptionKey: $${KIBANA_ENCRYPTION_KEY}
      elasticsearch.ssl:
        verificationMode: none
        certificateAuthorities: /usr/share/kibana/config/certs/tls.crt

  protocol: https

  secretMounts:
    - name: elastic-certificates
      secretName: elastic-certificates
      path: /usr/share/kibana/config/certs

  podAnnotations:
    co.elastic.logs/module: kibana

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - SPOT

  extraInitContainers:
    - name: es-check
      image: "appropriate/curl:latest"
      imagePullPolicy: "IfNotPresent"
      command:
        - "/bin/sh"
        - "-c"
        - |
          is_down=true
          while "$is_down"; do
            if curl -k -sSf --fail-early --connect-timeout 5 -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200;
            then
              is_down=false
            else
              sleep 5
            fi
          done
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: s3-repo
      image: "appropriate/curl:latest"
      imagePullPolicy: "IfNotPresent"
      command:
        - "/bin/sh"
        - "-c"
        - "curl -k -X PUT -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_snapshot/s3_repository -H 'Content-Type:application/json' -d '{ \"type\": \"s3\", \"settings\": {\"bucket\": \"${local.elk_snapshots_bucket_name}\", \"server_side_encryption\": \"true\"}}'"
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: roles
      command:
        - /bin/sh
        - -c
        - 'curl -X POST -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_security/role/kibana_basic_user -H ''Content-Type: application/json''
          -d ''{"applications":[{"application":"kibana-.kibana","privileges":["feature_discover.all","feature_visualize.all","feature_dashboard.all","feature_dev_tools.all","feature_advancedSettings.all"],"resources":["space:default"]}]}''
          &&
          curl -X POST -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_security/role/all_indexes_read -H ''Content-Type: application/json''
          -d ''{"indices":[{"names":["*"],"privileges":["read"],"allow_restricted_indices":false}]}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: kibana-user
      command:
        - /bin/sh
        - -c
        - 'curl -X POST -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_security/user/${local.kibana_user} -H ''Content-Type: application/json''
          -d ''{"password" : "${local.kibana_password}","roles" : [ "superuser"],"full_name" : "Kibana User","email" : ""}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: snapshots
      command:
        - /bin/sh
        - -c
        - 'curl -X PUT -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_slm/policy/daily-snapshots?pretty -H ''Content-Type: application/json''
          -d ''{"schedule": "0 30 1 * * ?","name": "<daily-snap-{now/d}>","repository": "s3_repository","config": {"ignore_unavailable": false,"include_global_state": false},"retention": {"expire_after": "${local.elk_snapshot_retention_days}d","min_count": 5,"max_count": 50}}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: delete-old-indicies
      command:
        - /bin/sh
        - -c
        - 'curl -X PUT -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_ilm/policy/delete_old_indicies -H ''Content-Type: application/json''
          -d ''{"policy": {"phases": {"hot": {"actions": {"set_priority": {"priority": 100 }}}, "delete": { "min_age": "${local.elk_index_retention_days}d", "actions": {"delete": {} }}}}}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: filebeat-template
      command:
        - /bin/sh
        - -c
        - 'curl -X PUT -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_template/filebeat?pretty -H ''Content-Type: application/json''
          -d ''{"index_patterns": ["filebeat-*"], "settings": {"number_of_shards": 1,"number_of_replicas": 1,"index.lifecycle.name": "delete_old_indicies" }}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: apm-template
      command:
        - /bin/sh
        - -c
        - 'curl -X PUT -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_template/apm?pretty -H ''Content-Type: application/json''
          -d ''{"index_patterns": ["apm-*"], "settings": {"number_of_shards": 1,"number_of_replicas": 1,"index.lifecycle.name": "delete_old_indicies" }}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
    - name: metricbeat-template
      command:
        - /bin/sh
        - -c
        - 'curl -X PUT -k -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD https://elasticsearch-master:9200/_template/metricbeat?pretty -H ''Content-Type: application/json''
          -d ''{"index_patterns": ["metricbeat-*"], "settings": {"number_of_shards": 1,"number_of_replicas": 1,"index.lifecycle.name": "delete_old_indicies" }}'''
      image: appropriate/curl:latest
      imagePullPolicy: IfNotPresent
      env:
        - name: 'ELASTICSEARCH_USERNAME'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: username
        - name: 'ELASTICSEARCH_PASSWORD'
          valueFrom:
            secretKeyRef:
              name: elastic-credentials
              key: password
VALUES
  #tfsec:ignore:general-secrets-sensitive-in-attribute-value
  elk_filebeat_values = <<VALUES
filebeat:
  enabled: true
  filebeatConfig:
    filebeat.yml: |
      filebeat.modules:
        - module: system
          syslog:
            enabled: true
            #var.paths: ["/var/log/syslog"]
      filebeat.autodiscover:
        providers:
          - type: kubernetes
            node: $${NODE_NAME}
            hints.enabled: true
            hints.default_config:
              type: container
              paths:
                - /var/log/containers/*$${data.kubernetes.container.id}.log

      processors:
        - drop_event:
            when:
              equals:
                kubernetes.container.name: "filebeat"

      output.elasticsearch:
        username: '$${ELASTICSEARCH_USERNAME}'
        password: '$${ELASTICSEARCH_PASSWORD}'
        protocol: https
        hosts: ["elasticsearch-master:9200"]
        ssl.verification_mode: none

  extraVolumeMounts:
    - name: elastic-certificates
      mountPath: /usr/share/filebeat/config/certs

  extraVolumes:
    - name: elastic-certificates
      secret:
        secretName: elastic-certificates

  extraEnvs:
    - name: 'ELASTICSEARCH_USERNAME'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: username
    - name: 'ELASTICSEARCH_PASSWORD'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: password

  tolerations:
    - effect: NoSchedule
      operator: Exists
VALUES
  #tfsec:ignore:general-secrets-sensitive-in-attribute-value
  elk_apm_values = <<VALUES
apm-server:
  enabled: false
  ingress:
    enabled: true
    annotations:
      kubernetes.io/ingress.class: nginx
    path: /
    hosts:
      - ${local.apm_domain_name}

  apmConfig:
    apm-server.yml: |
      apm-server:
        host: "0.0.0.0:8200"
        # ssl:
        #   enabled: true
        #   certificate: /usr/share/apm-server/config/certs/tls.crt
        #   key: /usr/share/apm-server/config/certs/tls.key
      queue: {}
      output.elasticsearch:
        username: '$${ELASTICSEARCH_USERNAME}'
        password: '$${ELASTICSEARCH_PASSWORD}'
        protocol: https
        hosts: ["elasticsearch-master:9200"]
        ssl.verification_mode: none

  secretMounts:
    - name: elastic-certificates
      secretName: elastic-certificates
      path: /usr/share/apm-server/config/certs

  extraEnvs:
    - name: 'ELASTICSEARCH_USERNAME'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: username
    - name: 'ELASTICSEARCH_PASSWORD'
      valueFrom:
        secretKeyRef:
          name: elastic-credentials
          key: password

  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: eks.amazonaws.com/capacityType
            operator: In
            values:
              - ON_DEMAND
VALUES
  #tfsec:ignore:general-secrets-sensitive-in-attribute-value
  elk_metricbeat_values = <<VALUES
metricbeat:
  enabled: false
  daemonset:
    extraEnvs:
      - name: 'ELASTICSEARCH_USERNAME'
        valueFrom:
          secretKeyRef:
            name: elastic-credentials
            key: username
      - name: 'ELASTICSEARCH_PASSWORD'
        valueFrom:
          secretKeyRef:
            name: elastic-credentials
            key: password
    # Allows you to add any config files in /usr/share/metricbeat
    # such as metricbeat.yml for daemonset
    metricbeatConfig:
      metricbeat.yml: |
        metricbeat.autodiscover:
          providers:
            - type: kubernetes
              hints.enabled: true

        metricbeat.modules:
        - module: kubernetes
          metricsets:
            - container
            - node
            - pod
            - system
            - volume
          period: 10s
          host: "$${NODE_NAME}"
          hosts: ["https://$${NODE_NAME}:10250"]
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          ssl.verification_mode: "none"
          # If using Red Hat OpenShift remove ssl.verification_mode entry and
          # uncomment these settings:
          #ssl.certificate_authorities:
            #- /var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt
          processors:
          - add_kubernetes_metadata: ~
        - module: kubernetes
          enabled: true
          metricsets:
            - event
        - module: system
          period: 10s
          metricsets:
            - cpu
            - load
            - memory
            - network
            - process
            - process_summary
          processes: ['.*']
          process.include_top_n:
            by_cpu: 5
            by_memory: 5
        - module: system
          period: 1m
          metricsets:
            - filesystem
            - fsstat
          processors:
          - drop_event.when.regexp:
              system.filesystem.mount_point: '^/(sys|cgroup|proc|dev|etc|host|lib)($|/)'
        output.elasticsearch:
          username: '$${ELASTICSEARCH_USERNAME}'
          password: '$${ELASTICSEARCH_PASSWORD}'
          protocol: https
          hosts: ["elasticsearch-master:9200"]
          ssl.verification_mode: none

    secretMounts:
    - name: elastic-certificates
      secretName: elastic-certificates
      path: /usr/share/metricbeat/config/certs

  deployment:
    extraEnvs:
      - name: 'ELASTICSEARCH_USERNAME'
        valueFrom:
          secretKeyRef:
            name: elastic-credentials
            key: username
      - name: 'ELASTICSEARCH_PASSWORD'
        valueFrom:
          secretKeyRef:
            name: elastic-credentials
            key: password
    # Allows you to add any config files in /usr/share/metricbeat
    # such as metricbeat.yml for deployment
    metricbeatConfig:
      metricbeat.yml: |
        metricbeat.modules:
        - module: kubernetes
          enabled: true
          metricsets:
            - state_node
            - state_deployment
            - state_replicaset
            - state_pod
            - state_container
          period: 10s
          hosts: ["$${KUBE_STATE_METRICS_HOSTS}"]
        - module: prometheus
          metricsets: ["collector"]
          metrics_path: /metrics
          period: 10s
          hosts: ["nginx-ingress-controller-metrics.ing:9913"]
          namespace: ing
        output.elasticsearch:
          username: '$${ELASTICSEARCH_USERNAME}'
          password: '$${ELASTICSEARCH_PASSWORD}'
          protocol: https
          hosts: ["elasticsearch-master:9200"]
          ssl.verification_mode: none

    secretMounts:
    - name: elastic-certificates
      secretName: elastic-certificates
      path: /usr/share/metricbeat/config/certs
VALUES
}

#tfsec:ignore:kubernetes-network-no-public-egress tfsec:ignore:kubernetes-network-no-public-ingress
module "elk_namespace" {
  count = local.elk.enabled ? 1 : 0

  source = "../modules/kubernetes-namespace"
  name   = local.elk.namespace
  network_policies = [
    {
      name         = "default-deny"
      policy_types = ["Ingress", "Egress"]
      pod_selector = {}
    },
    {
      name         = "allow-this-namespace"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {
        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.elk.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-ingress"
      policy_types = ["Ingress"]
      pod_selector = {}
      ingress = {

        from = [
          {
            namespace_selector = {
              match_labels = {
                name = local.ingress_nginx.namespace
              }
            }
          }
        ]
      }
    },
    {
      name         = "allow-apm"
      policy_types = ["Ingress"]
      pod_selector = {
        match_expressions = {
          key      = "app"
          operator = "In"
          values   = ["apm-server"]
        }
      }
      ingress = {
        ports = [
          {
            port     = "8200"
            protocol = "TCP"
          }
        ]
      }
    },
    {
      name         = "allow-egress"
      policy_types = ["Egress"]
      pod_selector = {}
      egress = {
        to = [
          {
            ip_block = {
              cidr = "0.0.0.0/0"
              except = [
                "169.254.169.254/32"
              ]
            }
          }
        ]
      }
    }
  ]
}

module "elastic_tls" {
  count = local.elk.enabled ? 1 : 0

  source                = "../modules/self-signed-certificate"
  name                  = local.name
  common_name           = "elasticsearch-master"
  dns_names             = [local.domain_name, "*.${local.domain_name}", "elasticsearch-master", "elasticsearch-master.${module.elk_namespace[count.index].name}", "kibana", "kibana.${module.elk_namespace[count.index].name}", "kibana-kibana", "kibana-kibana.${module.elk_namespace[count.index].name}", "logstash", "logstash.${module.elk_namespace[count.index].name}"]
  validity_period_hours = 8760
  early_renewal_hours   = 336
}

module "aws_iam_elastic_stack" {
  count = local.elk.enabled ? 1 : 0

  source = "../modules/aws-iam-user-with-policy"
  name   = "${local.name}-${local.elk.name}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:ListBucketMultipartUploads",
          "s3:ListBucketVersions"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_stack[count.index].id}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:AbortMultipartUpload",
          "s3:ListMultipartUploadParts"
        ],
        "Resource" : [
          "arn:aws:s3:::${aws_s3_bucket.elastic_stack[count.index].id}/*"
        ]
      }
    ]
  })
}

### ADDITIONAL RESOURCES FOR ELK
resource "kubernetes_secret" "elasticsearch_credentials" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elastic-credentials"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "username" = "elastic"
    "password" = random_string.elasticsearch_password[count.index].result
  }
}

resource "kubernetes_secret" "elasticsearch_certificates" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elastic-certificates"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "tls.crt" = module.elastic_tls[count.index].cert_pem
    "tls.key" = module.elastic_tls[count.index].private_key_pem
    "tls.p8"  = module.elastic_tls[count.index].p8
  }
}

resource "kubernetes_secret" "elasticsearch_s3_user_creds" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "elasticsearch-s3-user-creds"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "aws_s3_user_access_key" = module.aws_iam_elastic_stack[count.index].access_key_id
    "aws_s3_user_secret_key" = module.aws_iam_elastic_stack[count.index].access_secret_key
  }
}

resource "random_string" "elasticsearch_password" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

resource "kubernetes_secret" "kibana_enc_key" {
  count = local.elk.enabled ? 1 : 0

  metadata {
    name      = "kibana-encryption-key"
    namespace = module.elk_namespace[count.index].name
  }

  data = {
    "encryptionkey" = random_string.kibana_enc_key[count.index].result
  }
}

resource "random_string" "kibana_enc_key" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

resource "random_string" "kibana_password" {
  count = local.elk.enabled ? 1 : 0

  length  = 32
  special = false
  upper   = true
}

#tfsec:ignore:aws-s3-enable-versioning tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "elastic_stack" {
  count = local.elk.enabled ? 1 : 0

  bucket        = "${local.name}-elastic-stack"
  acl           = "private"
  force_destroy = true
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  tags = {
    Name        = "${local.name}-elastic-stack"
    Environment = local.env
  }
}

resource "aws_s3_bucket_public_access_block" "elastic_stack_public_access_block" {
  count = local.elk.enabled ? 1 : 0

  bucket = aws_s3_bucket.elastic_stack[count.index].id
  # Block new public ACLs and uploading public objects
  block_public_acls = true
  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true
  # Block new public bucket policies
  block_public_policy = true
  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}

resource "helm_release" "elk" {
  count = local.elk.enabled ? 1 : 0

  name        = local.elk.name
  chart       = local.elk.chart
  repository  = local.elk.repository
  version     = local.elk.chart_version
  namespace   = module.elk_namespace[count.index].name
  timeout     = "900"
  max_history = var.helm_release_history_size

  values = [
    local.elk_elasticsearch_values,
    local.elk_kibana_values,
    local.elk_filebeat_values,
    local.elk_apm_values,
    local.elk_metricbeat_values
  ]

}

output "kibana_domain_name" {
  value       = local.elk.enabled ? local.kibana_domain_name : null
  description = "Kibana dashboards address"
}

output "apm_domain_name" {
  value       = local.elk.enabled ? local.apm_domain_name : null
  description = "APM domain name"
}

output "elasticsearch_elastic_password" {
  value       = local.elk.enabled ? local.elasticsearch_password : null
  sensitive   = true
  description = "Password of the superuser 'elastic'"
}

output "elastic_stack_bucket_name" {
  value       = local.elk.enabled ? local.elk_snapshots_bucket_name : null
  description = "Name of the bucket for ELKS snapshots"
}
