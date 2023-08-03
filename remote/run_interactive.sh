#!/bin/bash
ACCT=$1

GPUS_OPTION=""

if [ -n "$4" ]; then
	GPUS_OPTION="--gpus-per-node=${5}"
fi

SBATCH_SCRIPT="$(mktemp -d)/slurm_job.sh"
echo "batch script: $SBATCH_SCRIPT"

# Create the batch script
echo "#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${2:-1}
#SBATCH --mem=${3:-1024M}
#SBATCH --time=${4:-"1:0:0"}
#SBATCH --account=$ACCT
#SBATCH -o ../logs/%j.out
$GPUS_OPTION

srun --account=$ACCT jupyterlab.sh" >$SBATCH_SCRIPT

# Submit the job script to SLURM
sbatch --parsable $SBATCH_SCRIPT
