#!/bin/bash
ACCT=rrg-skrishna

GPUS_OPTION=""

if [ -n "$4" ]; then
  GPUS_OPTION="--gpus-per-node=${4}"
fi

salloc \
	--ntasks=1 \
	--cpus-per-task=${1:-1} \
	--mem=${2:-1024M}       \
	--time=${3:-"1:0:0"}    \
	--account="$ACCT"       \
	$GPUS_OPTION            \
	srun --account="$ACCT" jupyterlab.sh


