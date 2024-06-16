FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY app/ /app

CMD ["gunicorn", "--config", "gunicorn.conf.py", "__init__:app"]