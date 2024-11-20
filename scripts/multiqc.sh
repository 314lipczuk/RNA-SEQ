#!/bin/bash
#SBATCH --time=15:00:00
#SBATCH --mem=4g
#SBATCH --cpus-per-task=4
#SBATCH --job-name=slurm_array
#SBATCH --output=array_%J.out
#SBATCH --error=array_%J.err
#SBATCH --partition=pibu_el8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail

# define variables
WORKDIR="/data/users/$USER/RNASEQ"
OUTFILE="$OUTDIR/${SAMPLE}"

module load MultiQC/1.11-foss-2021a

multiqc "$WORKDIR/results"

