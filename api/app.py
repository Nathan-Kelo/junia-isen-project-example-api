from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/baskets")
def baskets():
    return jsonify({"message": "Basket list"})

@app.route("/items")
def items():
    return jsonify({"message": "Items list"})

@app.route("/users")
def users():
    return jsonify({"message": "Users list"})

@app.route("/")
def home():
    return jsonify({"message": "Welcome to the Shop API!"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
