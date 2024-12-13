import os
from bson import json_util
import logging
from sys import stdout

from dotenv import load_dotenv
from flask import Flask, jsonify
from pymongo import MongoClient

app = Flask(__name__)

#Force refresh .env variables if there is a change
load_dotenv(override=True)

# Get the MongoDB URL from the environment variables
MONGO_URL = os.environ.get("MONGO_URL", "")

# Setup basic logging
logger=logging.getLogger("werkzeug")
logging.basicConfig(stream=stdout)
logger.setLevel(logging.INFO)

# Connect to mongodb 
try:
    client = MongoClient(MONGO_URL)
except Exception as e:
  logger.error("Failed to connect to MongoDB.",exc_info=True)
else:
  logger.info("Connected to MongoDB")  

def populate_db():
    db = client["projet_cloud"]
    baskets = db["baskets"]
    items = db["items"]
    users = db["users"]
    
    with open("./source_data/baskets.json") as f:
        baskets_data = json_util.loads(f.read())

    with open("./source_data/items.json") as f:
        items_data = json_util.loads(f.read())

    with open("./source_data/users.json") as f:
        users_data = json_util.loads(f.read())

    # Send the data to each table
    baskets.insert_many(baskets_data)
    items.insert_many(items_data)
    users.insert_many(users_data)

@app.route("/baskets")
def baskets():
    db = client["projet_cloud"]
    baskets = db["baskets"]
    result = list(baskets.find())
    # Make ObjectID serializable
    for basket in result:
        basket["_id"] = str(basket["_id"])
    return jsonify({"status":"success","results":result})

@app.route("/items")
def items():
    # Return the list of items from the database
    db = client["projet_cloud"]
    items = db["items"]
    result = list(items.find())
    # Make ObjectID serializable
    for basket in result:
        basket["_id"] = str(basket["_id"])
    return jsonify(result)

@app.route("/users")
def users():
    # Return the list of users from the database
    db = client["projet_cloud"]
    users = db["users"]
    result = list(users.find())
    # Make ObjectID serializable
    for basket in result:
        basket["_id"] = str(basket["_id"])
    return jsonify(result)

@app.route("/")
def index():
    return app.send_static_file("index.html")

@app.route("/update_db" , methods=["POST"])
def update_db():
    try:
        populate_db()
    except Exception as e:
        logger.error("Failed to populate MongoDB",exc_info=True)
        return jsonify({"status":"failed","message":"Failed to populate MongoDB"})
    else:
        logger.info("Populated MongoDB")
        return jsonify({"status":"success","message":"Populated MongoDB"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)