export STUDY=/hpc/group/egnerlab
cd /hpc/group/egnerlab/tw260/Effort
sbatch --array=1-$(( $( wc -l $STUDY/tw260/Effort/Nifti/participants.tsv | cut -f1 -d' ' ) - 1 )) sing_batch.sh