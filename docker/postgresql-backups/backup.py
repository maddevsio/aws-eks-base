#!/usr/bin/python3
import os
import sys
import requests
import boto3
import subprocess
import json
from datetime import datetime


def send_slack_notification(message):
  SLACK_URL = os.getenv('SLACK_URL')
  title = "New Incoming Message :zap:"
  slack_data = {
    "username": "Backup Notification bot",
    "icon_emoji": ":satellite:",
    "attachments": [
      {
        "color": "#9733EE",
        "fields": [
          {
            "title": title,
            "value": message,
            "short": "false",
          }
        ]
      }
    ]
  }
  byte_length = str(sys.getsizeof(slack_data))
  headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
  response = requests.post(SLACK_URL, data=json.dumps(slack_data), headers=headers)
  if response.status_code != 200:
    raise Exception(response.status_code, response.text)


def backup_postgres_db(host, database_name, port, user, password, dest_file):
  try:
    # TODO need to add compress
    process = subprocess.Popen(
      ['pg_dump',
       '--dbname=postgresql://{}:{}@{}:{}/{}'.format(user, password, host, port, database_name),
       '-f', dest_file,
       '-v'],
      stdout=subprocess.PIPE
    )
    output = process.communicate()[0]
    if int(process.returncode) != 0:
      print('Command failed. Return code : {}'.format(process.returncode))
      send_slack_notification(message_fail)
      exit(1)
    return output
  except Exception as e:
    send_slack_notification(message_fail)
    print(e)
    exit(1)


def upload_to_s3(file_full_path, aws_bucket_name, dest_file_path):
  s3_client = boto3.client('s3')
  try:
    print(f"Upload file {file_full_path} to S3 bucket {aws_bucket_name}/{dest_file_path}")
    s3_client.upload_file(file_full_path, aws_bucket_name, dest_file_path)
    os.remove(file_full_path)
  except boto3.exceptions.S3UploadFailedError as exc:
    send_slack_notification(message_fail)
    print(exc)
    exit(1)


def create_directory(bucket_name, target_path):
  dirs = []
  s3 = boto3.client("s3")
  # TODO need to add MaxKeys=1000 options
  all_objects = s3.list_objects_v2(Bucket=bucket_name)

  if all_objects.get("Contents"):
    for i in all_objects.get("Contents"):
      k = i.get('Key')
      if k[-1] == '/':
        dirs.append(k)
  else:
    print(f"Create directory {target_path}")
    s3.put_object(Bucket=bucket_name, Key=(target_path))

  if target_path in dirs:
    print(f"Directory exists {target_path}")
  else:
    print(f"Create directory {target_path}")
    s3.put_object(Bucket=bucket_name, Key=(target_path))


if __name__ == '__main__':
  SLACK_URL = os.getenv('SLACK_URL')
  AWS_BUCKET_NAME = os.getenv('AWS_BUCKET_NAME')
  PG_HOST = os.getenv('PG_HOST')
  PG_USER = os.getenv('PG_USER')
  PG_DATABASE = os.getenv('PG_DATABASE')
  PG_PORT = os.getenv('PG_PORT')
  PG_PASS = os.getenv('PG_PASS')

  dest_path = datetime.strftime(datetime.now(), "%Y/%B/")
  source_path = "/tmp/"
  dumpname = 'psql-' + datetime.strftime(datetime.now(), "%Y-%m-%d-%H-%M") + '-UTC' + '.sql'
  message_succ = ("The backup of the production database was successfully created. \n"
                  "The database dump name: \n" + dumpname)
  message_fail = "The backup failed, please check the logs."

  backup_postgres_db(PG_HOST, PG_DATABASE, PG_PORT, PG_USER, PG_PASS, source_path + dumpname)
  create_directory(AWS_BUCKET_NAME, dest_path)
  upload_to_s3(source_path + dumpname, AWS_BUCKET_NAME, dest_path + dumpname)
  if SLACK_URL is None:
    print("Slack web hook not defined")
  else:
    send_slack_notification(message_succ)
