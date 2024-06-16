import redis
from flask import Flask
from config import Config
from talisman import init_talisman
from models import db
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_bootstrap import Bootstrap5
from flask_migrate import Migrate

app = Flask(__name__)
bootstrap = Bootstrap5(app)
app.config.from_object(Config)

init_talisman(app)

db.init_app(app)
migrate = Migrate(app, db)
limiter = Limiter(get_remote_address, app=app, storage_uri="redis://redis_cache:6379")

from routes import rbp as rbp
app.register_blueprint(rbp)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
