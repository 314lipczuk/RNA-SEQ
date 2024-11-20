# RNA-SEQ

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

# Mapping

- Download reference
- Produce index files with hisat
- map reads to reference
- sam -> bam

# Current:
running the mapping-2 job overnight. Will look at results in the morning
