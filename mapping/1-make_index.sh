#!/bin/sh

#SBATCH --job-name="RNASEQ:mapping:1-build_index"
#SBATCH --nodes=1
#SBATCH --cpus-per-task=8
#SBATCH --mail-user=przemyslaw.pilipczuk@students.unibe.ch
#SBATCH --mail-type=end,fail
#SBATCH --output=/data/users/ppilipczuk/RNASEQ/out/output_mapping%j.out
#SBATCH --error=/data/users/ppilipczuk/RNASEQ/out/error_mapping%j.e
#SBATCH --mem-per-cpu=4000M
#SBATCH --time=36:00:00
#SBATCH --partition=pibu_el8

module load Pysam/0.16.0.1-GCC-10.3.0
module load SAMtools/1.13-GCC-10.3.0
module load HISAT2/2.2.1-gompi-2021a

# requires having reference.fa

cd  /data/users/ppilipczuk/RNASEQ/mapping
hisat2-build reference.fa reference_idx
