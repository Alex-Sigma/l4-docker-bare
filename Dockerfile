FROM python:3.11-slim

# Ensure Python runs in a clean, predictable way
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Install minimal system dependencies (optional but good practice)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy the whole project into the image
COPY . /app

# Install Python dependencies (now including torch)
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
         torch \
         fastapi \
         uvicorn[standard] \
         transformers \
         huggingface_hub

# Download the HuggingFace model at build time
# This will create the `models/` folder and bake it into the image
RUN python download_model.py

# App listens on 8000
EXPOSE 8000

# Start FastAPI app as in the homework:
#   fastapi dev --host 0.0.0.0 src/4_docker_example
CMD ["fastapi", "dev", "--host", "0.0.0.0", "src/4_docker_example"]
