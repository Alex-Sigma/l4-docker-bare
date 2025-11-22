FROM python:3.11-slim

# Ensure Python runs in a clean, predictable way
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . /app

# Install Python dependencies:
# 1) CPU-only PyTorch from official index
# 2) FastAPI stack + transformers + HF hub
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
         --index-url https://download.pytorch.org/whl/cpu \
         torch \
    && pip install --no-cache-dir \
         fastapi \
         uvicorn[standard] \
         transformers \
         huggingface_hub

# Download the HuggingFace model at build time
RUN python download_model.py

# App listens on 8000
EXPOSE 8000

CMD ["fastapi", "dev", "--host", "0.0.0.0", "src/4_docker_example"]
