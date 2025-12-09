import json
import os
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table_name = os.environ.get("DYNAMODB_TABLE")
table = dynamodb.Table(table_name)


def decimal_to_int(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    return obj


def lambda_handler(event, context):
    http_method = event.get("httpMethod", "")
    path = event.get("path", "")

    # GET /product -> list semua product
    if http_method == "GET" and path.endswith("/product"):
        response = table.scan()
        items = response.get("Items", [])
        return build_response(200, items)

    # POST /product -> tambahkan data product
    if http_method == "POST" and path.endswith("/product"):
        try:
            body = json.loads(event.get("body", "{}"))

            if "product_id" not in body:
                return build_response(400, {"error": "product_id is required"})

            table.put_item(Item=body)
            return build_response(201, {"message": "Product added", "data": body})

        except Exception as e:
            return build_response(500, {"error": str(e)})

    return build_response(400, {"message": "Unsupported route or method"})


def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(body, default=decimal_to_int)  # <-- FIXED
    }
