from flask import Blueprint, render_template
from models import db, User

rbp = Blueprint('rbp', __name__)

@rbp.route('/')
def home():
    return render_template('home.html', title='Home')