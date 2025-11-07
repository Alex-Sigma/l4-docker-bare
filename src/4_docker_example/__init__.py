from typing import List
from fastapi import FastAPI
from pydantic import BaseModel
from fastapi.concurrency import run_in_threadpool

import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline
from pathlib import Path

MODEL_DIR = Path("models")

app = FastAPI(title="HF sentiment via FastAPI")

nlp = None


class PredictRequest(BaseModel):
    texts: List[str]
    top_k: int = 1


class Prediction(BaseModel):
    label: str
    score: float


class PredictResponse(BaseModel):
    predictions: List[List[Prediction]]


@app.on_event("startup")
def load_model():
    global nlp
    tok = AutoTokenizer.from_pretrained(MODEL_DIR, local_files_only=True)
    mdl = AutoModelForSequenceClassification.from_pretrained(
        MODEL_DIR, local_files_only=True
    )
    device = 0 if torch.cuda.is_available() else -1
    nlp = pipeline("sentiment-analysis", model=mdl, tokenizer=tok, device=device)
    _ = nlp("warmup")


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.post("/predict", response_model=PredictResponse)
async def predict(req: PredictRequest):
    def _infer():
        out = nlp(req.texts, top_k=req.top_k, truncation=True)
        if isinstance(out, list) and len(out) > 0 and isinstance(out[0], dict):
            out = [out]
        return [
            [
                Prediction(label=pred["label"], score=float(pred["score"]))
                for pred in sample
            ]
            for sample in out
        ]

    predictions = await run_in_threadpool(_infer)
    return PredictResponse(predictions=predictions)
