import json
import boto3
from PIL import Image
import io
import os

s3 = boto3.client('s3')
THUMBNAIL_SIZE = (128, 128)

def lambda_handler(event, context):
    for record in event['Records']:
        bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        
        # Download image from S3
        response = s3.get_object(Bucket=bucket, Key=key)
        img = Image.open(response['Body'])
        
        # Resize
        img.thumbnail(THUMBNAIL_SIZE)
        
        # Save to bytes
        buffer = io.BytesIO()
        img.save(buffer, 'JPEG')
        buffer.seek(0)
        
        # Upload thumbnail
        thumb_key = f"thumbnails/{key}"
        s3.put_object(Bucket=bucket, Key=thumb_key, Body=buffer, ContentType='image/jpeg')
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Image resized'})
    }
