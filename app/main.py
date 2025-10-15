from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)

# -----------------------
# Database configuration from environment variables
# -----------------------
DB_USER = os.environ.get("DB_USER", "postgres123")
DB_PASS = os.environ.get("DB_PASS", "postgres123")
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "bankdb")

app.config['SQLALCHEMY_DATABASE_URI'] = (
    f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# -----------------------
# Models
# -----------------------
class Account(db.Model):
    __tablename__ = 'account'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50))
    balance = db.Column(db.Float, default=0.0)

# -----------------------
# Initialize DB and default account
# -----------------------
with app.app_context():
    db.create_all()  # Creates tables if they don't exist

    # Create default account with id=1 if not exists
    default_account = db.session.get(Account, 1)
    if not default_account:
        new_account = Account(id=1, name="Test User", balance=1000)
        db.session.add(new_account)
        db.session.commit()

# -----------------------
# Routes / Endpoints
# -----------------------
@app.route('/balance/<int:account_id>', methods=['GET'])
def get_balance(account_id):
    account = db.session.get(Account, account_id)
    if account:
        return jsonify({"account_id": account.id, "balance": account.balance})
    return jsonify({"error": "account not found"}), 404

@app.route('/version', methods=['GET'])
def get_version():
    return jsonify({"Version 1.0"})


@app.route('/deposit', methods=['POST'])
def deposit():
    data = request.get_json()
    account_id = data.get('account_id')
    amount = float(data.get('amount', 0))

    account = db.session.get(Account, account_id)
    if not account:
        return jsonify({"error": "account not found"}), 404
    if amount > 0:
        account.balance += amount
        db.session.commit()
    else:
      return jsonify({"error": "Invalid amount"}), 400

    return jsonify({"account_id": account.id, "balance": account.balance})

@app.route('/withdraw', methods=['POST'])
def withdraw():
    data = request.get_json()
    account_id = data.get('account_id')
    amount = float(data.get('amount', 0))

    if not account_id or amount is None:
        return jsonify({"error": "account_id and amount are required"}), 400

    account = db.session.get(Account, account_id)
    if not account:
        return jsonify({"error": "account not found"}), 404

    if account.balance < amount:
        return jsonify({"error": "insufficient funds"}), 400

    account.balance -= amount
    db.session.commit()
    return jsonify({"account_id": account.id, "balance": account.balance})

# -----------------------
# Run the app
# -----------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
