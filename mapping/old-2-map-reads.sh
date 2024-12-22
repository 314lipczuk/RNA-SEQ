#!/bin/sh

#SBATCH --job-name="RNASEQ:mapping:2-map_reads"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --array=1-16
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --output=/data/users/ppilipczuk/RNASEQ/out/output_mapping%j.out
#SBATCH --error=/data/users/ppilipczuk/RNASEQ/out/error_mapping%j.e
#SBATCH --mem-per-cpu=4000M
#SBATCH --time=36:00:00
#SBATCH --partition=pibu_el8

#XX=$1
#GROUP=$2
#THREADS=2

#bcreate and go to the TP directory
#mkdir bwa$1
#cd bwa$1

export PATH=/data/users/lfalquet/SBC07107_24/scripts:/software/bin:/usr/local/bin:$PATH;
export PATH=/data/users/lfalquet/SBC07107_24/scripts/canu-2.2/bin:/data/users/lfalquet/SBC07104_23/scripts/Flye-2.9/bin:$PATH

module load Pysam/0.16.0.1-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0
module load HISAT2/2.2.1-gompi-2021a

# define variables
WORKDIR="/data/users/$USER/RNASEQ/mapping"
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

# Convert .sam to .bam
samtools view -S -b "${SAMPLE}.sam" > "${SAMPLE}.bam"

# sort by genomic coordinates
samtools sort "${SAMPLE}.bam" -o "${SAMPLE}_sorted.bam"

# indexing bam file (creating .bai file)
samtools index "${SAMPLE}_sorted.bam"

rm "${SAMPLE}.sam"
