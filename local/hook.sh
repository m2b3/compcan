#!/bin/bash
set -e
# Local log file to track hostname / port / ...
LOG=remote.out
CLUSTER=$1
CORES=$2
MEMORY=$3
MAX_TIME=$4
GPUS=$5

GATEWAY=$CLUSTER.computecanada.ca

show_queue() {
  ssh "$GATEWAY" "squeue -u $USER"
}

echo "=== New job info ==="
echo "Cluster: $CLUSTER"
echo "Cores: ${CORES:-default}"
echo "Memory (total): ${MEMORY:-default}"
echo "Max job duration: ${MAX_TIME:-default}"
echo "GPUs: ${GPUS:-}"
echo

export RI_ARGS="\"$CORES\" \"$MEMORY\" \"$MAX_TIME\" $GPUS"

# Erase old logs.
rm -f "$LOG" && touch "$LOG"

# Run Jupyter on compute node.
REMOTE_CMD="cd ~/compcan/remote && ./run_interactive.sh $RI_ARGS"
echo "Connecting through $GATEWAY to run:"
echo "  $REMOTE_CMD"
ssh "$GATEWAY" "$REMOTE_CMD" > "$LOG" 2>&1 &

JOB_ID=$(tail -f "$LOG" | grep "job allocation" -m 1 | sed -nr 's/^.*Pending job allocation ([[:digit:]]+).*$/\1/p')
[ -n "$JOB_ID" ]

echo "Job ID will be $JOB_ID"

# Get server info
echo "Waiting for Jupyter..."

url=$(tail -f "$LOG" \
  | grep -m1 -A1 --line-buffered "one of these" \
  | tail -n 1 \
  | tr -d " ")

echo
pair=$(sed -rn 's/^.*http:\/\/(.*):([[:digit:]]+).*/\1 \2/p' <<< "$url")
COMPUTE_HOST=$(cut -f1 -d' ' <<< $pair)
PORT=$(cut -f2 -d' ' <<< $pair)
local_url="http://127.0.0.1:$(sed -r s'/http:\/\/.*://g' <<< "$url")"
echo "COMPUTE_HOST: $COMPUTE_HOST"
echo "PORT: $PORT"
echo


echo
echo "JOB QUEUE"
show_queue
echo

# Tunnel
echo
echo "Remote URL: $url"
echo "Local URL: $local_url"
firefox "$local_url"

# use -N for no interactivity
# -t: pty allocation
function cleanup {
  echo
  echo "Exiting tunneling, but don't forget job $JOB_ID might still be running!"
  echo
  echo "If you wish to reestablish the tunnel, run:"
  echo "ssh -t -L $PORT:$COMPUTE_HOST:$PORT $GATEWAY ssh $COMPUTE_HOST"
}
trap cleanup EXIT

echo "Tunneling port $PORT and opening interactive session on compute node $COMPUTE_HOST..."
echo

# Prevent sleep - that would kill the tunnel.
systemd-inhibit \
  ssh -t -L $PORT:$COMPUTE_HOST:$PORT $GATEWAY ssh $COMPUTE_HOST
