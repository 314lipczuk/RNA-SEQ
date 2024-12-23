# RNA-SEQ

# Introduction and reproduction
For reproducing results, `reproduce.py` was made. Read it, understand it, and run it to run all the boring computational steps, and get results.
Sadly, current version has a couple constraints:
- Assumes it's being run in a cluster hpc environment (slurm), and assumes tooling using `module` command is available
- Assumes existence of important files already on the disk. These files are:
	- mapping/reference.fa 
	- toxoplasma_de (directory with the sample reads)

# FastQC & MultiQC
Got it done, most of it looks good, but in all samples there are 2 persistant problems:
- Per base sequence content
- Sequence deduplication levels

### Per base sequence content
Proportions of each base are off.
Could suggest a technical artifacts

### Sequence deduplication levels
There is way too much of a certain type of sequence in the data.
This suggests either technical artifacts (PCR overamplification, etc.), or possibly a natural occurence in some types of sequences.

PCR overaplification is probably the cause here

### Conclusion
After consulting, it seems that at this level they are inconsequential. We move on.

# Mapping

- Download reference
- Produce index files with hisat
- map reads to reference
- sam -> bam

...
