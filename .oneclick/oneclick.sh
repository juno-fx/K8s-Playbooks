#!/bin/bash
#
# Entrypoint for chrooted or containarized Juno install 


if [ ! -f /tmp/juno_bootstrap_chart_values.yaml ]; then
  echo "Error: /tmp/juno_bootstrap_chart_values.yaml not found. Please ensure the file exists and is filled out when running the oneclick installer."
  exit 1
fi

ansible-playbook -i /oneclick/inventory /oneclick/oneclick-playbook.yaml
