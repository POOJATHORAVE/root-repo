#!/bin/bash
set -e

echo "Running Gitleaks scan..."
docker run --rm \
  -v $(pwd):/repo \
  zricethezav/gitleaks:latest detect \
  --source="/repo" \
  --config="/repo/gitleaks.toml" \
  --verbose \
  --exit-code 1