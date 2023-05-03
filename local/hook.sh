#!/bin/bash
set -e
# Local log file to track hostname / port / ...
LOG=$(mktemp -d)/remote.out
CLUSTER=$1
CORES=$2
MEMORY=$3
MAX_TIME=$4
GPUS=$5

GATEWAY=$CLUSTER.computecanada.ca

find_free_port() {
  # define a range of potentially free ports
  lower_port=50000
  upper_port=51000

  # find a free port within the range
  while :
  do
      check_port=$(shuf -i $lower_port-$upper_port -n 1)
      timeout 1 bash -c "cat < /dev/null > /dev/tcp/127.0.0.1/${check_port}" 2>/dev/null
      if [ $? -ne 0 ]; then
          free_port=${check_port}
          break
      fi
  done

  echo "$free_port"
}


show_queue() {
  ssh "$GATEWAY" "squeue -u $USER"
}

show_queue

echo "Log file: $LOG"
echo
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
REMOTE_CMD="
cd ~
if cd compcan; then
  git fetch --all;
  git reset --hard origin/main;
else
  git clone https://github.com/m2b3/compcan.git;
fi

cd ~/compcan/remote && ./run_interactive.sh $RI_ARGS"
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

notify-send "Job $JOB_ID's Jupyter is ready" || true

echo
pair=$(sed -rn 's/^.*http:\/\/(.*):([[:digit:]]+).*/\1 \2/p' <<< "$url")
COMPUTE_HOST=$(cut -f1 -d' ' <<< $pair)
REMOTE_PORT=$(cut -f2 -d' ' <<< $pair)
LOCAL_PORT=$(find_free_port)
URL_PATH=$(sed -r s'/http:\/\/.*:[[:digit:]]+//g' <<< "$url")
local_url="http://127.0.0.1:$LOCAL_REPORT/$URL_PATH"
echo "COMPUTE_HOST: $COMPUTE_HOST"
echo "REMOTE PORT: $REMOTE_PORT"
echo "LOCAL PORT: $LOCAL_PORT"
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
  echo "ssh -t -L $LOCAL_PORT:$COMPUTE_HOST:$REMOTE_PORT $GATEWAY ssh $COMPUTE_HOST"
}
trap cleanup EXIT

echo "Tunneling port $REMOTE_PORT through $LOCAL_PORT and opening interactive session on compute node $COMPUTE_HOST..."
echo

# Prevent sleep - that would kill the tunnel.
systemd-inhibit \
  ssh -t -L $LOCAL_PORT:$COMPUTE_HOST:$REMOTE_PORT $GATEWAY ssh $COMPUTE_HOST

