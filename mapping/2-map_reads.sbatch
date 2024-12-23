#!/bin/bash

#SBATCH --job-name=2-map_reads
#SBATCH --output=/data/users/ppilipczuk/logs/2-map_reads/%j.out
#SBATCH --error=/data/users/ppilipczuk/logs/2-map_reads/%j.err
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --array=1-16
#SBATCH --partition=pibu_el8

module load Pysam/0.16.0.1-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0
module load HISAT2/2.2.1-gompi-2021a

source config.sh

# define variables
WORKDIR="$BASEDIR/mapping"
OUTDIR="$WORKDIR/results"
SAMPLELIST="$WORKDIR/../reads.list"

SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

OUTFILE="$OUTDIR/${SAMPLE}"
mkdir -p $OUTFILE
cd $OUTFILE 

# Map the reads
hisat2 -x "$WORKDIR/reference_idx" -1 $READ1 -2 $READ2 -S "${SAMPLE}.sam"
echo "Done mapping reads"

# Convert .sam to .bam
samtools view -S -b "${SAMPLE}.sam" > "${SAMPLE}.bam"
echo "Done converting to binary format"

# sort by genomic coordinates
samtools sort "${SAMPLE}.bam" -o "${SAMPLE}_sorted.bam"
echo "Done sorting "

# indexing bam file (creating .bai file)
samtools index "${SAMPLE}_sorted.bam"
echo "Done indexing"

rm "${SAMPLE}.sam"
