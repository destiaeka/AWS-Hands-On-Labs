import json
import boto3
import os
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('PRODUCT_TABLE', 'Products')
table = dynamodb.Table(table_name)

# Fungsi bantu untuk convert Decimal ke float
def decimal_default(obj):
    if isinstance(obj, Decimal):
        return float(obj)
    raise TypeError

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "GET,POST,PUT,DELETE,OPTIONS"
        },
        "body": json.dumps(body, default=decimal_default)  # pakai decimal_default di sini
    }

def lambda_handler(event, context):
    method = event.get('httpMethod', '')

    # --- CORS Preflight ---
    if method == 'OPTIONS':
        return response(200, {"message": "CORS preflight OK"})

    # --- GET: list semua produk ---
    if method == 'GET':
        try:
            items = table.scan().get("Items", [])
            return response(200, items)
        except Exception as e:
            return response(500, {"error": str(e)})

    # --- POST: tambah produk baru ---
    elif method == 'POST':
        try:
            data = json.loads(event.get('body', '{}'))
            if "id" not in data or "name" not in data or "price" not in data:
                return response(400, {"error": "Missing required fields: id, name, price"})
            table.put_item(Item=data)
            return response(201, {"message": "Product added", "product": data})
        except Exception as e:
            return response(500, {"error": str(e)})

    # --- PUT: update produk ---
    elif method == 'PUT':
        try:
            data = json.loads(event.get('body', '{}'))
            if "id" not in data:
                return response(400, {"error": "Missing product id"})
            table.put_item(Item=data)
            return response(200, {"message": "Product updated", "product": data})
        except Exception as e:
            return response(500, {"error": str(e)})

    # --- DELETE: hapus produk ---
    elif method == 'DELETE':
        try:
            params = event.get("queryStringParameters", {})
            if not params or "id" not in params:
                return response(400, {"error": "Product ID missing"})
            table.delete_item(Key={"id": params["id"]})
            return response(200, {"message": "Product deleted"})
        except Exception as e:
            return response(500, {"error": str(e)})

    # --- Method tidak dikenal ---
    return response(405, {"error": f"Method {method} not allowed"})
