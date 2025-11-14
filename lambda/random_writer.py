import os
import json
import random
import boto3
from datetime import datetime

s3 = boto3.client('s3')

def handler(event, context):
    bucket = os.environ.get('BUCKET')
    if not bucket:
        raise Exception('BUCKET env var not set')

    value = random.randint(0, 1000000)
    timestamp = datetime.utcnow().strftime('%Y%m%dT%H%M%SZ')
    key = f"random-{timestamp}-{value}.txt"

    body = str(value)
    s3.put_object(Bucket=bucket, Key=key, Body=body)

    return {
        'statusCode': 200,
        'body': json.dumps({'key': key, 'value': value})
    }
