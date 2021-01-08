# Base image for postgresql-backups

* This docker image contains a python script for creating a backup of a postgresql database.
* After creating the database dump, the dump is copied to the s3 bucket.
* If it succeeds or if there is an error when creating the dump or copying, there is a notification in the slack. 

# Build and push docker image

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

# Auth in AWS 

* Use `AWS CLI` for default authentication 

  or

* Path AWS authentication variables to docker container

# Run docker container locally

```docker
docker run -d --name postgresql-backups -e AWS_ACCESS_KEY_ID=aws-access-key-id -e AWS_SECRET_ACCESS_KEY=aws-access-secret-key -e AWS_BUCKET_REGION=eu-west-1 -e AWS_BUCKET_NAME=aws-bucket-name -e SLACK_URL=slack-web-hook -e PG_HOST=postgres -e PG_PORT=5432 -e PG_USER=postgres -e PG_DATABASE=pg_db -e PG_PASS=postgres postgresql-backups
```

# Show logs 

```docker 
docker logs postgresql-backups
```

* Environment variables

```yaml
# Optional variable
SLACK_URL=slack-notification-url

# Requered variables
AWS_ACCESS_KEY_ID=aws-access-key-id
AWS_SECRET_ACCESS_KEY=aws-access-secret-key
AWS_BUCKET_REGION=aws-bucket-region
AWS_BUCKET_NAME=bucket-name-for-backups
PG_HOST=postgresql-host
PG_PORT=5432
PG_USER=postgres
PG_DATABASE=pg_db
PG_PASS=postgres
```

>Note
Setting this variables `SLACK_URL` is optional. 
If the variable is not set, no notifications are sent to the slack.



