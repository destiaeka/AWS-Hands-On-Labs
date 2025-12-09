import json
import boto3
from decimal import Decimal

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("service2")  # Pastikan nama sesuai env var nanti


def decimal_to_int(obj):
    if isinstance(obj, Decimal):
        return int(obj)
    return obj

def lambda_handler(event, context):
    http_method = event.get("httpMethod", "")
    path = event.get("path", "")
    body = event.get("body")
    path_params = event.get("pathParameters") or {}

    # GET all books
    if http_method == "GET" and path == "/book":
        response = table.scan()
        return build_response(200, response.get("Items", []))

    # GET book by ID
    if http_method == "GET" and "id" in path_params:
        book_id = path_params["id"]
        response = table.get_item(Key={"book_id": book_id})

        if "Item" in response:
            return build_response(200, response["Item"])
        return build_response(404, {"message": "Book not found"})

    # POST create book
    if http_method == "POST" and path == "/book":
        if not body:
            return build_response(400, {"message": "Missing request body"})

        data = json.loads(body)

        # Validate required field
        if "book_id" not in data:
            return build_response(400, {"message": "Missing 'book_id'"})

        table.put_item(Item=data)
        return build_response(201, {"message": "Book created", "data": data})

    return build_response(400, {"message": "Unsupported method or endpoint"})

def build_response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps(body, default=decimal_to_int)
    }
