import json
import boto3
import os
import uuid
from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('ORDER_TABLE', 'Orders')
table = dynamodb.Table(table_name)

# Custom encoder untuk Decimal
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            # Konversi ke int kalau tidak ada desimal, else float
            if obj % 1 == 0:
                return int(obj)
            else:
                return float(obj)
        return super(DecimalEncoder, self).default(obj)

def response(status, body):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "*",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS"
        },
        "body": json.dumps(body, cls=DecimalEncoder)
    }

def lambda_handler(event, context):
    method = event.get("httpMethod", "")

    # CORS preflight
    if method == "OPTIONS":
        return response(200, {"message": "CORS preflight OK"})

    # POST
    if method == "POST":
        body = json.loads(event.get("body", "{}"))
        if "product_id" not in body or "quantity" not in body:
            return response(400, {"error": "Missing required fields: product_id, quantity"})

        order = {
            "id": str(uuid.uuid4()),
            "product_id": body["product_id"],
            "quantity": Decimal(str(body["quantity"])),
            "status": "processed",
            "created_at": datetime.utcnow().isoformat()
        }

        table.put_item(Item=order)
        return response(201, {"message": "Order created successfully", "order": order})

    # GET
    if method == "GET":
        try:
            result = table.scan()
            orders = result.get("Items", [])
            return response(200, orders)
        except Exception as e:
            return response(500, {"error": str(e)})

    return response(405, {"error": f"Method {method} not allowed"})
