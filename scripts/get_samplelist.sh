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

source config.sh
FASTQ_FOLDER="$BASEDIR/toxoplasma_de/reads"
readlist_file="reads.list.2"

for FILE in $FASTQ_FOLDER/*_*1.fastq.gz
do 
    PREFIX="${FILE%_*.fastq.gz}"
    SAMPLE=`basename $PREFIX`
    echo -e "${SAMPLE}\t$FILE\t${FILE%?.fastq.gz}2.fastq.gz" >> "$readlist_file"
done
