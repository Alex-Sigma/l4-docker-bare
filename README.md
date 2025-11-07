### Installation
    uv sync

### Run
    uvicorn 4_docker_example:app --host 0.0.0.0 --port 8000 --reload

### Run via docker
    docker compose build
    docker compose up

### Check the app
```bash
curl -s -X POST http://0.0.0.0:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"texts": ["I love MLOps!", "This is awful..."], "top_k": 2}'
```
