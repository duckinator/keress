#!/usr/bin/env python3

import boto3
import datetime
from glob import glob
import os

region_name  = os.environ["AWS_REGION"]
endpoint_url = "https://{}.digitaloceanspaces.com".format(region_name)
access_key   = os.environ["AWS_ACCESS_KEY"]
secret_key   = os.environ["AWS_SECRET_KEY"]
bucket_name  = os.environ["AWS_BUCKET"]

session = boto3.session.Session()
client = session.client("s3",
                        region_name=region_name,
                        endpoint_url=endpoint_url,
                        aws_access_key_id=access_key,
                        aws_secret_access_key=secret_key)

def store(file_path):
    dt = datetime.datetime.now()
    date = dt.strftime("%Y-%m-%d")
    file_name = "nightlies/{}/{}".format(date, file_path.split("/")[-1])

    print("Uploading: '{}' to '{}' as '{}'\n".format(file_path, bucket_name, file_name))

    with open(file_path, 'rb') as f:
        client.put_object(Bucket=bucket_name, Key=file_name, Body=f, ACL="public-read")

files = glob("./build/debug/*")
if len(files) == 0:
    print("No files to upload")
    exit(1)

list(map(store, files))

