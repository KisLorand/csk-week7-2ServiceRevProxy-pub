FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install dependencies first to take advantage of layer caching
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY service_a.py .

# Run as a non-root user
RUN useradd --create-home --uid 1000 appuser
USER appuser

EXPOSE 8080

# Gunicorn is a production-grade WSGI server; Flask's built-in server is for development only
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "2", "service_a:app"]
