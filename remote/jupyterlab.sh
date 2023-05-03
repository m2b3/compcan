#!/bin/bash
set -ve

source load_environment

# Jupyter startup
unset XDG_RUNTIME_DIR

# RUNTIME_ROOT is set by load_environment
export JUPYTER_RUNTIME_DIR="$RUNTIME_ROOT"/jupyter-runtime
export JUPYTER_DATA_DIR="$RUNTIME_ROOT"/jupyter-data
export JUPYTER_CONFIG_PATH="$RUNTIME_ROOT"/jupyter-config
mkdir -p "$JUPYTER_RUNTIME_DIR" "$JUPYTER_DATA_DIR" "$JUPYTER_CONFIG_PATH"

jupyter-lab --ip $(hostname -f) --no-browser
