#!/bin/bash
ACCT=rrg-skrishna

srun \
	--ntasks=1 \
	--cpus-per-task=${1:-1} \
	--mem=${2:-1024M}       \
	--time=${3:-"1:0:0"}    \
	--account="$ACCT"       \
	--x11 \
	--pty bash -i
