from pathlib import Path
from huggingface_hub import snapshot_download
from transformers import AutoTokenizer, AutoModelForSequenceClassification, pipeline

LOCAL_DIR = Path("models")
LOCAL_DIR.mkdir(parents=True, exist_ok=True)

snapshot_download(
    repo_id="distilbert-base-uncased-finetuned-sst-2-english",
    local_dir=str(LOCAL_DIR),
    local_dir_use_symlinks=False,
)

tok = AutoTokenizer.from_pretrained(LOCAL_DIR, local_files_only=True)
mdl = AutoModelForSequenceClassification.from_pretrained(
    LOCAL_DIR, local_files_only=True
)
pipe = pipeline("sentiment-analysis", model=mdl, tokenizer=tok)
