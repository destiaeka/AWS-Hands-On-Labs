import boto3
import base64
import uuid
import os
import re

s3 = boto3.client("s3")
BUCKET = os.environ.get("BUCKET")

def lambda_handler(event, context):

    method = event.get("httpMethod")

    # ---------- GET REQUEST ----------
    if method == "GET":
        try:
            objects = s3.list_objects_v2(Bucket=BUCKET)

            if "Contents" not in objects:
                return {
                    "statusCode": 200,
                    "body": "Bucket is empty"
                }

            files = [obj["Key"] for obj in objects["Contents"]]

            return {
                "statusCode": 200,
                "body": "\n".join(files)
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "body": f"Error: {str(e)}"
            }

    # ---------- POST REQUEST ----------
    try:
        if "body" not in event:
            return {
                "statusCode": 400,
                "body": "No file received"
            }

        body = event["body"]

        # Decode body if base64
        if event.get("isBase64Encoded", False):
            body = base64.b64decode(body).decode("utf-8", errors="ignore")

        # Parse multipart text file
        match = re.search(r"Content-Type: text/plain\r\n\r\n(.*?)\r\n--", body, re.DOTALL)

        if not match:
            return {
                "statusCode": 400,
                "body": "File parsing failed"
            }

        file_content = match.group(1)

        filename = f"upload-{uuid.uuid4()}.txt"

        s3.put_object(
            Bucket=BUCKET,
            Key=filename,
            Body=file_content
        )

        return {
            "statusCode": 200,
            "body": f"File uploaded successfully: {filename}"
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"Error: {str(e)}"
        }
