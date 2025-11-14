import os
import random
import time
from datetime import datetime
import boto3

S3_BUCKET = os.environ.get("BUCKET")
S3 = boto3.client("s3")

def lambda_handler(event, context):
    value = random.random()
    now = datetime.utcnow().strftime("%Y%m%dT%H%M%SZ")
    key = f"random-{now}-{int(value*1e9)}.txt"
    body = f"{value}\n"

    S3.put_object(Bucket=S3_BUCKET, Key=key, Body=body.encode('utf-8'))

    return {
        'statusCode': 200,
        'body': f"Wrote {key} to {S3_BUCKET}"
    }
