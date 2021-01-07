# Base image for postgresql-backups

* This docker image contains the sql script for creating user with access to pg_stat_activity and pg_stat_replication 

# Build and push docker image

* Build docker image

```yaml
docker build -t pg-exporter-user .
```

```yaml
docker tag pg-exporter-user ecr-repository-url
```

```yaml
docker push ecr-repository-url
```




