#!/bin/bash
set -ve

source load_environment

# RUNTIME_ROOT is set by load_environment
export XDG_CONFIG_HOME="$RUNTIME_ROOT"/xdg_config
export XDG_RUNTIME_DIR="$RUNTIME_ROOT"/xdg_run
export XDG_CACHE_HOME="$RUNTIME_ROOT"/xdg_cache
export JUPYTER_RUNTIME_DIR="$RUNTIME_ROOT"/jupyter-runtime
export JUPYTER_DATA_DIR="$RUNTIME_ROOT"/jupyter-data
export JUPYTER_CONFIG_PATH="$RUNTIME_ROOT"/jupyter-config
export IPYTHONDIR="$RUNTIME_ROOT"/ipythondir
mkdir -p "$JUPYTER_RUNTIME_DIR" "$JUPYTER_DATA_DIR" "$JUPYTER_CONFIG_PATH"

cd
jupyter-lab --ip $(hostname -f) --no-browser
