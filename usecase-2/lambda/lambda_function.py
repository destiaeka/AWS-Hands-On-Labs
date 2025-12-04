import json
import boto3
import uuid
import os
from datetime import datetime
from decimal import Decimal

# DynamoDB client
dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ.get("DYNAMODB_TABLE")
table = dynamodb.Table(TABLE_NAME)

# Custom serializer untuk Decimal
def decimal_default(obj):
    if isinstance(obj, Decimal):
        return int(obj)  # atau float(obj) kalau ada pecahan
    raise TypeError

def lambda_handler(event, context):
    http_method = event.get("httpMethod")

    headers = {
        "Content-Type": "application/json"
    }

    # ---------- POST REQUEST ----------
    if http_method == "POST":
        try:
            body = json.loads(event.get("body") or "{}")
            question = body.get("question")
            if not question:
                return {
                    "statusCode": 400,
                    "headers": headers,
                    "body": json.dumps({"error": "Question is required"})
                }

            # Dummy AI response
            answer = f"AI Response to: {question}"

            # Simpan ke DynamoDB
            item = {
                "chat_id": str(uuid.uuid4()),
                "question": question,
                "answer": answer,
                "timestamp": int(datetime.utcnow().timestamp()),
            }
            table.put_item(Item=item)

            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps({"question": question, "answer": answer})
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "headers": headers,
                "body": json.dumps({"error": str(e)})
            }

    # ---------- GET REQUEST ----------
    elif http_method == "GET":
        try:
            response = table.scan()
            items = response.get("Items", [])

            # Sort by timestamp descending
            items.sort(key=lambda x: x["timestamp"], reverse=True)

            return {
                "statusCode": 200,
                "headers": headers,
                "body": json.dumps(items, default=decimal_default)  # <-- pakai serializer custom
            }

        except Exception as e:
            return {
                "statusCode": 500,
                "headers": headers,
                "body": json.dumps({"error": str(e)})
            }

    # ---------- METHOD NOT ALLOWED ----------
    else:
        return {
            "statusCode": 405,
            "headers": headers,
            "body": json.dumps({"error": "Method not allowed"})
        }
