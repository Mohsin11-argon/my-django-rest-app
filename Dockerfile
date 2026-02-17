FROM python:3.11-slim

# Format theek kiya taake warning na aaye
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y libpq-dev gcc && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Static files collect karne se pehle folder bana letay hain
RUN mkdir -p /app/staticfiles

# Ensure collectstatic works (Make sure STATIC_ROOT is in settings.py)
RUN python manage.py collectstatic --noinput

EXPOSE 8000

CMD ["gunicorn", "--bind", "0.0.0.0:8000", "core.wsgi:application"]