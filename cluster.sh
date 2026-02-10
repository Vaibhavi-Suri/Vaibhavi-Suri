#!/bin/bash
set -e
echo "Starting Docker daemon (DinD)..."
dockerd > /var/log/dockerd.log 2>&1 &
sleep 8
echo "Building wiki-service Docker image..."
docker build -t wiki-service_image:latest /app/wiki-service
echo "Creating k3d cluster and exposing port 8080..."
k3d cluster create wiki-cluster -p "8080:80@loadbalancer"
echo "Waiting for cluster to be ready..."
sleep 15
helm install wiki-charts ./wiki-chart
echo "Waiting for all pods to become ready..."
kubectl wait --for=condition=ready pod --all --timeout=180s
echo "Cluster is ready. Access services on port 8080."
tail -f /dev/null