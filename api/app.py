from flask import Flask, jsonify
from pymongo import MongoClient
import os

app = Flask(__name__)

# Get the MongoDB URL from the environment variables
mongo_url = os.environ.get("MONGO_URL", "mongodb://localhost:27017")
# Connect to mongodb 
client = MongoClient(mongo_url)

@app.route("/baskets")
def baskets():
    # Return the list of baskets from the database
    db = client["projet_cloud"]
    baskets = db["baskets"]
    result = list(baskets.find())
    # Make ObjectID serializable
    for basket in result:
        basket["_id"] = str(basket["_id"])
    return jsonify(result)

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
def home():
    return jsonify({"message": "Welcome to the Shop API!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
