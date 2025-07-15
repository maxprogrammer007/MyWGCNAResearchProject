#!/usr/bin/env bash
# scripts/deploy.sh
# -----------------
# Usage: ./scripts/deploy.sh [tag]
# Example: ./scripts/deploy.sh v0.1.0

TAG=${1:-latest}
IMAGE_NAME=mydockerhubusername/mywgcna:${TAG}

echo "📦 Building Docker image: $IMAGE_NAME"
docker build -t $IMAGE_NAME .

echo "🔑 Pushing to Docker Hub"
docker push $IMAGE_NAME

echo "✅ Deployment image pushed: $IMAGE_NAME"
