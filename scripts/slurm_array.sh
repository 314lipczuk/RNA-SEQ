#!/bin/bash
#SBATCH --array=1-16
#SBATCH --time=15:00:00
#SBATCH --mem=1g
#SBATCH --cpus-per-task=1
#SBATCH --job-name=slurm_array
#SBATCH --output=array_%J.out
#SBATCH --error=array_%J.err
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# define variables
WORKDIR="/data/users/$USER/RNASEQ"
OUTDIR="$WORKDIR/results"
SAMPLELIST="$WORKDIR/list.txt"

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

OUTFILE="$OUTDIR/${SAMPLE}"

############################


mkdir -p $OUTFILE

#echo "Run task for $SAMPLE with $READ1 and $READ2 ..." > $OUTFILE
module load FastQC/0.11.9-Java-11
module load MultiQC/1.11-foss-2021a
fastqc $READ1 $READ2 -o $OUTFILE 

