#!/bin/bash

check_url() {
    local url="$1"
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" "${url}")
    echo "$status_code"
}

extract_urls() {
    local file="$1"
    grep -oP '\(https://[^\)]+\)' "${file}" | sed 's/[\(\)]//g'
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

if [ ! -f "$input_file" ]; then
    echo "Error: File '$input_file' not found"
    exit 1
fi

error_count=0

while IFS= read -r url; do
    if [ -n "${url}" ]; then
        status_code=$(check_url "${url}")
        if [ "$status_code" -ne 200 ]; then
            echo "Error: URL '$url' returned HTTP status code $status_code"
            ((error_count++))
        fi
    fi
done < <(extract_urls "${input_file}")

if [ "$error_count" -eq 0 ]; then
    echo "All URLs returned HTTP status code 200"
else
    echo "Found $error_count URL(s) with errors"
fi

exit 0
