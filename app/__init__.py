from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from sqlalchemy import text

from config import Config

db = SQLAlchemy()
migrate = Migrate()


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)

    db.init_app(app)
    migrate.init_app(app, db)

    @app.route("/health")
    def health():
        db.session.execute(text("SELECT 1"))
        return jsonify({"status": "ok", "database": "connected"})

    return app