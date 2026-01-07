#!/bin/bash
docker run --rm aquasec/trivy image cobank-frontend:latest
docker run --rm aquasec/trivy image cobank-backend:latest
