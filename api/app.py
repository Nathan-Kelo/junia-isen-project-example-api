import os
from sys import stdout
import logging

from dotenv import load_dotenv
from flask import Flask, jsonify
from azure.cosmos.cosmos_client import CosmosClient
#This is because we are using Python 3.9 if we modern python this
#pkg is deprecated
from azure.cosmos.errors import HTTPFailure
from pymongo import MongoClient

#Force refresh .env everytimes
load_dotenv(override=True)

logger=logging.getLogger(__name__)
logging.basicConfig(stream=stdout)
logger.setLevel(logging.DEBUG)


ACCOUNT_URI=os.environ.get("ACCOUNT_URI","")
ACCOUNT_KEY=os.environ.get("ACCOUNT_KEY","")

logger.debug(f"ACCOUNT_URI: {ACCOUNT_URI[:4]}")

app = Flask(__name__)
try:
  Cclient=CosmosClient(
    url_connection=ACCOUNT_URI,
  )
except Exception as e:
  logger.error(f"Failed to connect to CosmosDB service. {e.with_traceback(e.__traceback__)}")
else:
  logger.info("Connected to CosmosDB service.")

try:
  Mclient=MongoClient(
    host=ACCOUNT_URI
  ) 
except Exception as e:
  logger.error(f"Failed to connect to MongoDB service. {e.with_traceback(e.__traceback__)}")
else:
  logger.info("Connected to MongoDB service.")


@app.route("/")
def home():
    return jsonify({"message": "Welcome to the Shop API!"})

@app.route("/test")
def db_connection_test():
  database_name = 'testDatabase'
  try:
    database = Cclient.CreateDatabase({'id': database_name})
  except HTTPFailure:
    database = Cclient.ReadDatabase("dbs/" + database_name)
  return jsonify(database)
  
@app.route("/test2")
def db_connection_test_2():
  database_name = 'testDatabase'
  database = Mclient.get_database(database_name)
  id=database.dummy_collection.insert_one({
    'name':"John doe",
    'addy':"ur mother"
  }).inserted_id
  return jsonify({"status":"Created a new document.","return":id})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
