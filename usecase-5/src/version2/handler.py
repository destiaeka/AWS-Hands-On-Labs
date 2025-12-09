import json
import os
import boto3
import requests
from datetime import datetime

# DynamoDB config
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ.get("DYNAMODB_TABLE"))

# Telegram config
TELEGRAM_BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID")
TELEGRAM_API_URL = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"


def lambda_handler(event, context):
    # Ambil body request
    body = json.loads(event.get("body", "{}"))
    message = body.get("message", "No message provided")

    # --- 1️⃣ Save to DynamoDB ---
    try:
        table.put_item(
            Item={
                "chat_id": TELEGRAM_CHAT_ID,
                "timestamp":int(datetime.now().timestamp()),
                "message": message
            }
        )
        db_status = "Saved to DB"
    except Exception as e:
        db_status = f"Failed saving to DB: {str(e)}"

    # --- 2️⃣ Send Telegram notification ---
    try:
        requests.post(
            TELEGRAM_API_URL,
            json={"chat_id": TELEGRAM_CHAT_ID, "text": f"📩 Pesan Baru:\n{message}"}
        )
        tg_status = "Telegram sent"
    except Exception as e:
        tg_status = f"Telegram failed: {str(e)}"

    # Response balik ke user
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET,POST,OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type"
        },
        "body": json.dumps({
            "message": message,
            "telegram": tg_status,
            "database": db_status
        })
    }
