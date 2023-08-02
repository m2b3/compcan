#!/bin/bash
ACCT=rrg-skrishna

GPUS_OPTION=""

if [ -n "$4" ]; then
	GPUS_OPTION="--gpus-per-node=${4}"
fi

SBATCH_SCRIPT="$(mktemp -d)/slurm_job.sh"
echo "batch script: $SBATCH_SCRIPT"

# Create the batch script
echo "#!/bin/bash
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${1:-1}
#SBATCH --mem=${2:-1024M}
#SBATCH --time=${3:-"1:0:0"}
#SBATCH --account=$ACCT
$GPUS_OPTION

srun --account=$ACCT jupyterlab.sh" >$SBATCH_SCRIPT

# Submit the job script to SLURM
sbatch $SBATCH_SCRIPT
