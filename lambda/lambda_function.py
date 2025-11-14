import os
import json
import random
import boto3
from datetime import datetime

s3 = boto3.client('s3')
BUCKET = os.environ.get('BUCKET')

def lambda_handler(event, context):
    if BUCKET is None:
        return {"statusCode": 500, "body": "BUCKET environment variable not set"}

    value = random.random()
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    key = f"random_{timestamp}.txt"
    body = json.dumps({"timestamp": timestamp, "value": value})

    s3.put_object(Bucket=BUCKET, Key=key, Body=body.encode('utf-8'))

    return {"statusCode": 200, "body": json.dumps({"key": key, "value": value})}
