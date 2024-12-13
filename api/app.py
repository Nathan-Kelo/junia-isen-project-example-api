import os
import logging
from sys import stdout
from pathlib import Path

from dotenv import load_dotenv
from flask import Flask, jsonify, Response
from bson import json_util
from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, BulkWriteError

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
# As of version 3.0 and above this will always succeed
# https://pymongo.readthedocs.io/en/stable/api/pymongo/mongo_client.html#pymongo.mongo_client.MongoClient
try:
  client = MongoClient(MONGO_URL)
except ConnectionFailure:
  logger.error("Failed to connect to MongoDB.",exc_info=True)
else:
  logger.info("Connected to MongoDB")  

def populate_db()->None:
  """Populates the database with dummy data."""
  
  # Path to source_data from current file rather than from where app was called
  path=Path(__file__).parent / "source_data"
  logger.debug(f"Path to source_data:{path.parts[-2:]}")

  db = client["projet_cloud"]
  baskets = db["baskets"]
  items = db["items"]
  users = db["users"]
  
  with open(path / "baskets.json","r") as f:
      baskets_data = json_util.loads(f.read())

  with open(path / "items.json","r") as f:
      items_data = json_util.loads(f.read())

  with open(path / "users.json","r") as f:
      users_data = json_util.loads(f.read())

  # Send the data to each table
  try:
    baskets.insert_many(baskets_data)
  except BulkWriteError:
    logger.info("Basket data already present avoiding duplciation.")
    
  try:
    items.insert_many(items_data)
  except BulkWriteError:
    logger.info("Items data already present avoiding duplciation.")
    
  try:
    users.insert_many(users_data)
  except BulkWriteError:
    logger.info("Users data already present avoiding duplciation.")

@app.route("/baskets")
def baskets()->Response:
  """Returns all baskets."""
  db = client["projet_cloud"]
  baskets = db["baskets"]
  result = list(baskets.find())
  # Make ObjectID serializable
  for basket in result:
      basket["_id"] = str(basket["_id"])
  return jsonify({"status":"success","results":result})

@app.route("/items")
def items()->Response:
  """Returns the list of items from the database"""
  db = client["projet_cloud"]
  items = db["items"]
  result = list(items.find())
  # Make ObjectID serializable
  for basket in result:
      basket["_id"] = str(basket["_id"])
  return jsonify(result)

@app.route("/users")
def users()->Response:
  """Return the list of users from the database"""
  db = client["projet_cloud"]
  users = db["users"]
  result = list(users.find())
  # Make ObjectID serializable
  for basket in result:
      basket["_id"] = str(basket["_id"])
  return jsonify(result)

# Health check route for application health
@app.route("/health")
def health_check()->Response:
  """Pings Database to check connectivity with it. Returns satuts code 200
  if succesful or else returns a status code of 500.
  """
  try:
    client.admin.command('ping')
  except ConnectionFailure:
    return Response(
      response=jsonify({"content":"Failed to reach Database."}).get_data(as_text=True),
      status=500,
      mimetype="application/json"
    )
  else:
    return Response(
      response=jsonify({"content":"Connected to Database."}).get_data(as_text=True),
      status=200,
      mimetype="application/json"
    )
    
  

@app.route("/")
def index()->Response:
  return app.send_static_file("index.html")

@app.route("/update_db" , methods=["POST"])
def update_db()->Response:
  """Updates database."""
  try:
      populate_db()
  except Exception as e:
      logger.error("Failed to populate MongoDB",exc_info=True)
      return jsonify({"status":"failed","message":"Failed to populate MongoDB"})
  else:
      logger.info("Populated MongoDB")
      return jsonify({"status":"success","message":"Populated MongoDB"})
  


app.run(host="0.0.0.0", port=5000)