#!/bin/bash
# Avvia il backend FastAPI
cd "$(dirname "$0")"
python3 -m venv venv 2>/dev/null
source venv/bin/activate
pip install -q -r requirements.txt
echo "🚀 Backend Wanderlist su http://localhost:8000"
uvicorn main:app --reload --port 8000
