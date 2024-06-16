import redis
from flask import Flask
from app.config import Config
from app.talisman import init_talisman
from app.models import db
from app.routes import init_routes
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from flask_bootstrap import Bootstrap5

app = Flask(__name__)
app.config.from_object(Config)

bootstrap = Bootstrap5(app)

init_talisman(app)

db.init_app(app)
limiter = Limiter(get_remote_address, app=app, storage_uri="redis://redis_cache:6379")

init_routes(app)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
