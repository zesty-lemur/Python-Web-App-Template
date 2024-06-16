from flask import render_template
from app.models import db, User

def init_routes(app):
    @app.route('/')
    def home():
        return render_template('home.html', title='Home')
