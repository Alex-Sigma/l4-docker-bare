### Progress

The required steps of the homework were fully completed.

A Dockerfile was created for the project l4-docker-bare, and the Hugging Face sentiment analysis model
distilbert-base-uncased-finetuned-sst-2-english was downloaded during the Docker build using download_model.py.

The final Docker image included:

CPU-only PyTorch
FastAPI + Uvicorn
Transformers
HuggingFace Hub

The pre-downloaded model saved inside the models/ directory

The docker was hosted on the ec2, which was created using the terraform.
The terrform main.tf to be found in the infra file.

🔧 Building the Docker Image
docker build -t sentiment-app .

▶️ Running the Container
docker run --rm -p 8000:8000 sentiment-app

The FastAPI development server started successfully at:

http://0.0.0.0:8000

and the /predict endpoint became available.

📡 Testing the /predict Endpoint

In a second terminal, the following request was executed:

```bash
curl -s -X POST http://0.0.0.0:8000/predict \
  -H "Content-Type: application/json" \
  -d '{"texts": ["I love MLOps!", "This is awful..."], "top_k": 2}'
```

🟩 Actual Output Received
{
"predictions": [
[
{"label": "POSITIVE", "score": 0.9997370839118958},
{"label": "NEGATIVE", "score": 0.0002629468508530408}
],
[
{"label": "NEGATIVE", "score": 0.9997850060462952},
{"label": "POSITIVE", "score": 0.00021496601402759552}
]
]
}
