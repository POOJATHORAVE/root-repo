#!/bin/bash
set -e

echo "========================================"
echo "Running Terrascan Security Scan"
echo "========================================"

# Define variables
SCAN_DIR="${1:-.}"
CONFIG_FILE="${2:-terrascan-config.toml}"
OUTPUT_FORMAT="${3:-human}"

# Check if terrascan is installed
if ! command -v terrascan &> /dev/null; then
    echo "Error: Terrascan is not installed or not in PATH"
    echo "Please install terrascan first: https://github.com/tenable/terrascan"
    exit 1
fi

echo "Terrascan version:"
terrascan version

echo ""
echo "Scanning directory: $SCAN_DIR"
echo "Configuration file: $CONFIG_FILE"
echo "Output format: $OUTPUT_FORMAT"
echo ""

# Validate configuration file if provided
if [ "$CONFIG_FILE" != "terrascan-config.toml" ] && [ -n "$CONFIG_FILE" ]; then
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Warning: Configuration file '$CONFIG_FILE' not found. Using default settings."
        CONFIG_FILE=""
    elif [ ! -r "$CONFIG_FILE" ]; then
        echo "Error: Configuration file '$CONFIG_FILE' is not readable."
        exit 1
    fi
fi

# Run terrascan scan
# --iac-type: Specify IaC type (terraform, k8s, helm, docker, etc.)
# --scan-rules: Use custom policy path if needed
# --config-path: Path to config file
# --verbose: Enable verbose logging

if [ -f "$CONFIG_FILE" ]; then
    echo "Using configuration file: $CONFIG_FILE"
    terrascan scan \
        --iac-type all \
        --config-path "$CONFIG_FILE" \
        --verbose \
        --output "$OUTPUT_FORMAT"
else
    echo "No configuration file found, using default settings"
    terrascan scan \
        --iac-type all \
        --verbose \
        --output "$OUTPUT_FORMAT"
fi

SCAN_EXIT_CODE=$?

echo ""
echo "========================================"
if [ $SCAN_EXIT_CODE -eq 0 ]; then
    echo "✅ Terrascan scan completed successfully - No violations found"
else
    echo "❌ Terrascan scan found violations - Exit code: $SCAN_EXIT_CODE"
fi
echo "========================================"

exit $SCAN_EXIT_CODE
