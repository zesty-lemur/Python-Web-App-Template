FROM python:3.10-slim

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# RUN wget https://github.com/twbs/bootstrap/releases/download/v5.3.0/bootstrap-5.3.0-dist.zip && \
#     unzip bootstrap-5.3.0-dist.zip -d static/ && \
#     rm bootstrap-5.3.0-dist.zip

CMD ["python", "app/__init__.py"]
