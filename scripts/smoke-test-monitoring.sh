#!/usr/bin/env bash
set -e

echo "Checking backend metrics endpoint..."
curl -sf http://localhost:3000/metrics | grep http_request_duration_seconds

echo "Monitoring smoke test passed"
