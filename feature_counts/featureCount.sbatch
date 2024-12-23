#!/bin/bash

#SBATCH --job-name=featureCount
#SBATCH --output=/data/users/ppilipczuk/logs/featureCount/%j.out
#SBATCH --error=/data/users/ppilipczuk/logs/featureCount/%j.err
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --time=10:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G
#SBATCH --partition=pibu_el8

# Use featureCounts from Subread:
# featureCounts takes as input SAM/BAM files and an annotation file including chromosomal coordinates of features. It outputs numbers of reads assigned to features (or meta-features). It also outputs stat info for the overall summrization results, including number of successfully assigned reads and number of reads that failed to be assigned due to various reasons (these reasons are included in the stat info). 

module load Subread/2.0.3-GCC-10.3.0

source config.sh

PREFIX_DIR="$BASEDIR"
ANNOTATION_FILE="$PREFIX_DIR/mapping/mouse_annotations.gtf"
WORKDIR="$PREFIX_DIR/feature_counts"
OUTDIR="$WORKDIR/results"
SAMPLELIST=`find $PREFIX_DIR/mapping/results/*/*sorted.bam`
REFERENCE_FILE="$PREFIX_DIR/mapping/reference.fa"

#SAMPLE=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $1; exit}' $SAMPLELIST`
#READ1=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $2; exit}' $SAMPLELIST`
#READ2=`awk -v line=$SLURM_ARRAY_TASK_ID 'NR==line{print $3; exit}' $SAMPLELIST`

mkdir -p $OUTDIR
cd $OUTDIR

featureCounts -J -G $REFERENCE_FILE -s 2 -p -a $ANNOTATION_FILE -o result.txt -T 8 $SAMPLELIST 
echo "Done"

