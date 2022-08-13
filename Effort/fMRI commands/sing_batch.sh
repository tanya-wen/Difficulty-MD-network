#!/bin/bash
#
#SBATCH -J fmriprep
#SBATCH --time=100:00:00
#SBATCH -n 1
#SBATCH --cpus-per-task=24
#SBATCH --mem-per-cpu=4G
#SBATCH -p common  # Queue names you can submit to
# Outputs ----------------------------------
#SBATCH -o slurm_%A_%a.out
#SBATCH -e slurm_%A_%a.err
#SBATCH --mail-user=tanya.wen@duke.edu
#SBATCH --mail-type=ALL
# ------------------------------------------
##SBATCH --requeue
#Specifies that the job will be requeued after a node failure.
#The default is that the job will not be requeued.

BIDS_DIR="$STUDY/tw260/Effort/Nifti"

# Prepare some writeable bind-mount points.
TEMPLATEFLOW_HOST_WORK=/work/.cache/templateflow
FMRIPREP_HOST_CACHE=/work/.cache/fmriprep
mkdir -p ${TEMPLATEFLOW_HOST_WORK}
mkdir -p ${FMRIPREP_HOST_CACHE}

# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE=$STUDY/.freesurfer.txt

# Designate a templateflow bind-mount point
export SINGULARITYENV_TEMPLATEFLOW_WORK="/templateflow"
SINGULARITY_CMD="singularity run --cleanenv -B $STUDY:/study -B ${TEMPLATEFLOW_HOST_WORK}:${SINGULARITYENV_TEMPLATEFLOW_WORK} -B /work:/mnt $STUDY/my_images/fmriprep-20.2.3.simg"

# Parse the participants.tsv file and extract one subject ID from the line corresponding to this SLURM task.
subject=$( sed -n -E "$((${SLURM_ARRAY_TASK_ID} + 1))s/sub-(\S*)\>.*/\1/gp" ${BIDS_DIR}/participants.tsv )

# Compose the command line
cmd="${SINGULARITY_CMD} /study/tw260/Effort/Nifti /study/tw260/Effort/derivatives participant --participant-label $subject -w /mnt --dummy-scans 5 -vv --omp-nthreads 8 --nthreads 12 --mem_mb 50000 --fs-license-file /study/freesurfer.txt"

# Setup done, run the command
echo Running task ${SLURM_ARRAY_TASK_ID}
echo Commandline: $cmd
eval $cmd
exitcode=$?

# Output results to a table
echo "sub-$subject   ${SLURM_ARRAY_TASK_ID}    $exitcode" \
      >> ${SLURM_JOB_NAME}.${SLURM_ARRAY_JOB_ID}.tsv
echo Finished tasks ${SLURM_ARRAY_TASK_ID} with exit code $exitcode
exit $exitcode