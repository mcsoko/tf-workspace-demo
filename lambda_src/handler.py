import os
import random
import boto3
from datetime import datetime

s3 = boto3.client('s3')

def lambda_handler(event, context):
    bucket = os.environ.get('TARGET_BUCKET')
    if not bucket:
        raise Exception('TARGET_BUCKET env var not set')

    num = random.randint(0, 1000000)
    timestamp = datetime.utcnow().isoformat() + 'Z'
    key = f"random/{timestamp}.txt"
    body = f"{timestamp} - {num}\n"

    s3.put_object(Bucket=bucket, Key=key, Body=body.encode('utf-8'))

    return {
        'statusCode': 200,
        'body': body
    }
