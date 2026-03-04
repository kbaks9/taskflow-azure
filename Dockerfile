# Stage 1: Build dependencies
FROM python:3.12-alpine AS build
WORKDIR /app

# Install build tools
RUN apk add --no-cache build-base libffi-dev musl-dev linux-headers

# Copy requirements first for caching
COPY app/requirements.txt .

# Create virtualenv and install dependencies
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime image
FROM python:3.12-alpine
WORKDIR /app

# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copy virtualenv and app code
COPY --from=build --chown=appuser:appgroup /opt/venv /opt/venv
COPY --chown=appuser:appgroup app/ ./app

# Use virtualenv by default
ENV PATH="/opt/venv/bin:$PATH"

# Run as non-root user
USER appuser

EXPOSE 8080
CMD ["python", "app/app.py"]