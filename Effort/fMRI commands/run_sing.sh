#!/bin/bash
#SBATCH -e slurm.err
#SBATCH --mem=24G

singularity run --cleanenv -B /hpc/group/egnerlab:/mnt \
/hpc/group/egnerlab/my_images/fmriprep-20.2.3.simg \
/mnt/tw260/Effort/Nifti \
/mnt/tw260/Effort/derivatives \
participant \
--fs-license-file /mnt/freesurfer.txt \
--participant-label 03 \
--dummy-scans 5
--work-dir /work