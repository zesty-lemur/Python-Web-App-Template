import os
from uuid import uuid4

class Config:
    SECRET_KEY = os.getenv('SECRET_KEY', uuid4())
    SQLALCHEMY_DATABASE_URI = os.getenv('DATABASE_URL', f'postgresql://{uuid4()}:{uuid4()}@postgres_db/{uuid4()}')
    SQLALCHEMY_TRACK_MODIFICATIONS = False
