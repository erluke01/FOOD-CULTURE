#!/bin/bash
# Avvia il frontend React
cd "$(dirname "$0")"
npm install
echo "🚀 Frontend Wanderlist su http://localhost:5173"
npm run dev
