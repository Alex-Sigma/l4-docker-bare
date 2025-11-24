FROM python:3.11-slim

# Ensure Python runs in a clean, predictable way
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install system dependencies (needed e.g. for some Python packages to compile)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 1️⃣ Copy dependency manifest(s) first – to use Docker layer cache for deps
COPY pyproject.toml uv.lock ./

# 2️⃣ Install Python dependencies
#    - CPU-only PyTorch from the official CPU index
#    - FastAPI stack
#    - Transformers + HuggingFace Hub
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
         --index-url https://download.pytorch.org/whl/cpu \
         torch \
    && pip install --no-cache-dir \
         "fastapi[standard]" \
         "uvicorn[standard]" \
         transformers \
         huggingface_hub

# 3️⃣ Copy the rest of the project files (code, src/, download_model.py, etc.)
COPY . /app

# 4️⃣ Download the HuggingFace model at build time
RUN python download_model.py

# App listens on 8000
EXPOSE 8000

# Exactly as in homework: run FastAPI dev server
CMD ["fastapi", "dev", "--host", "0.0.0.0", "src/4_docker_example"]
