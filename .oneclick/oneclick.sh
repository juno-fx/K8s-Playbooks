#!/bin/bash
#
# Entrypoint for chrooted or containarized Juno install 


if [ ! -f /tmp/juno_bootstrap_chart_values.yaml ]; then
  echo "Error: /tmp/juno_bootstrap_chart_values.yaml not found. Please ensure the file exists and is filled out when running the oneclick installer."
  exit 1
fi

extra_vars=${1}
extra_vars_full_args=""
if [ "${extra_vars}" ]; then
    extra_vars_full_args="--extra-vars \"$extra_vars\""
fi

ansible-playbook -i /oneclick/inventory /oneclick/oneclick-playbook.yaml "$extra_vars_full_args"