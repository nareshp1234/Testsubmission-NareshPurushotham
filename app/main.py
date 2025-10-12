from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)

# Update this if Postgres is in another container or host
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres123:postgres123@host.docker.internal:5432/bankdb'
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

@app.route('/deposit', methods=['POST'])
def deposit():
    data = request.get_json()
    account_id = data['account_id']
    amount = data['amount']

    account = db.session.get(Account, account_id)
    if not account:
        return jsonify({"error": "account not found"}), 404

    account.balance += amount
    db.session.commit()
    return jsonify({"account_id": account.id, "balance": account.balance})

@app.route('/withdraw', methods=['POST'])
def withdraw():
    data = request.get_json()
    account_id = data.get('account_id')
    amount = data.get('amount')

    if not account_id or amount is None:
        return jsonify({"error": "account_id and amount are required"}), 400

    account = Account.session.get(account_id)
    if not account:
        return jsonify({"error": "account not found"}), 404

    if account.balance < float(amount):
        return jsonify({"error": "insufficient funds"}), 400

    account.balance -= float(amount)
    db.session.commit()
    return jsonify({"account_id": account.id, "balance": account.balance})

# -----------------------
# Run the app
# -----------------------
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
