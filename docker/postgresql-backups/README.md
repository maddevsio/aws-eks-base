# Base image for postgresql-backups

* This docker image contains a python script for creating a backup of a postgresql database.
* After creating the database dump, the dump is copied to the s3 bucket.
* If it succeeds or if there is an error when creating the dump or copying, there is a notification in the slack. 

# How create postgresql backup ? 

* Build docker image

```yaml
docker build -t postgresql-backups .
```

```yaml
docker tag postgresql-backups ecr-repository-url
```

```yaml
docker push ecr-repository-url
```

* Run docker container locally

```docker
docker run -d --name postgresql-backups -e "SLACK_URL=slacl-notification-url" -e "AWS_BUCKET_NAME=backet-name" -e PG_HOST=postgresql-host -e PG_PORT=5432 -e PG_USER=postgres -e PG_DATABASE=itc_db -e PG_PASS=postgres postgresql-back
```

* Environment variables

```yaml
SLACK_URL=slacl-notification-url
AWS_BUCKET_NAME=backet-name-for-backups
PG_HOST=postgresql-host
PG_PORT=5432
PG_USER=postgres
PG_DATABASE=itc_db
PG_PASS=postgres
```
