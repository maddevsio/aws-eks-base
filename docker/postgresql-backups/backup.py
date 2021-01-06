#!/usr/bin/python3
import os
import sys
import requests
import boto3
import subprocess
import json
from datetime import datetime


def send_slack_notification(slack_url, message, color):
  if slack_url is None:
    print("Slack web hook not defined")
  else:
    title = "New Incoming Message :zap:"
    slack_data = {
      "username": "Backup Notification bot",
      "icon_emoji": ":satellite:",
      "attachments": [
        {
          "title": title,
          "color": color,
          "text": message,
        }
      ]
    }
    byte_length = str(sys.getsizeof(slack_data))
    headers = {'Content-Type': "application/json", 'Content-Length': byte_length}
    response = requests.post(slack_url, data=json.dumps(slack_data), headers=headers)
    if response.status_code != 200:
      raise Exception(response.status_code, response.text)


def backup_postgres_db(host, database_name, port, user, password, dest_file):
  try:
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
      return 1
    return output
  except Exception as e:
    print(e)
    return 1


def upload_to_s3(file_full_path, aws_bucket_name, dest_obj_path, aws_bucket_region):
  s3_client = boto3.client('s3', region_name=aws_bucket_region)

  try:
    print(f"Upload file {file_full_path} to S3 bucket {aws_bucket_name}/{dest_obj_path}")
    s3_client.upload_file(file_full_path, aws_bucket_name, dest_obj_path)
    os.remove(file_full_path)
    return 0
  except boto3.exceptions.S3UploadFailedError as exc:
    print(exc)
    return 1


if __name__ == '__main__':
  # This variable is optional.
  SLACK_URL = os.getenv('SLACK_URL')

  AWS_BUCKET_REGION = os.environ['AWS_BUCKET_REGION']
  AWS_BUCKET_NAME = os.environ['AWS_BUCKET_NAME']
  PG_HOST = os.environ['PG_HOST']
  PG_USER = os.environ['PG_USER']
  PG_DATABASE = os.environ['PG_DATABASE']
  PG_PORT = os.environ['PG_PORT']
  PG_PASS = os.environ['PG_PASS']

  dest_path = datetime.strftime(datetime.now(), "%Y/%B/")
  source_path = "/tmp/"
  dumpname = 'psql-' + datetime.strftime(datetime.now(), "%Y-%m-%d-%H-%M") + '-UTC' + '.sql'
  message_succ = ("The backup was successfully created. \n"
                  "The database dump name: " + dumpname)
  message_fail = ("The backup failed, please check logs.")
  succ_color = "#36ee33"
  fail_color = "#ee3f33"

  if backup_postgres_db(PG_HOST, PG_DATABASE, PG_PORT, PG_USER, PG_PASS, source_path + dumpname) != 1:
    if upload_to_s3(source_path + dumpname, AWS_BUCKET_NAME, dest_path + dumpname, AWS_BUCKET_REGION) != 1:
      send_slack_notification(SLACK_URL, message_succ, succ_color)
    else:
      send_slack_notification(SLACK_URL, message_fail, fail_color)
  else:
    send_slack_notification(SLACK_URL, message_fail, fail_color)
