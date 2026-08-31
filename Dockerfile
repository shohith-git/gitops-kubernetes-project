FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && apt-get upgrade -y && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir --upgrade "setuptools>=78.1.1" "msgpack>=1.2.1" && pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]