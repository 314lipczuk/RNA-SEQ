import subprocess
from dataclasses import dataclass
import re
"""
Script that is meant to be run, when one wants to reproduce the computational part of this analysis. 
Each step of the analysis consists of at least one shell/slurm script.
They can be run manually, one by one, 
but a nicer way to have whole analysis done is to run this one script and have them be queued all at once.
I utilize the slurm job dependency mechanism to schedule all the jobs, and set correct dependencies between them, so that they are executed in correct sequence.
"""

# TODO: add paths to scripts and make sure all steps are in them (there is no 'glue' that i wrote in terminal at the time)
# TODO: make some kind of basescript/config.sh with bash variables that will be sourced into every step of the pipeline. This will make it nicer for anyone who would want to repro it later, as they dont have to change every single path in every script, just one path in the base script.
# TODO: fucking get_samplelist wants an argument. god damnit. I should've written it correctly the first time around.

@dataclass
class Job:
    path:str 
    children:list[any]
    def depends_on(self, parent):
        parent.children.append(self)

    def __repr__(self):
        return f'script {self.path}, children:{", ".join(c.__repr__() for c in self.children)}|'

    def run(self, run_by=None):
        dep = [f'--dependency=afterok:{run_by}'] if run_by is not None else []
        sbatch_command = ['sbatch', *dep, self.path ]
        print('sbatch command:', sbatch_command)
        job = subprocess.run(sbatch_command, capture_output=True, text=True)
        print('running', self.path)
        assert(job.returncode == 0)
        output = job.stdout.strip()
        match = re.search(r"Submitted batch job (\d+)", output)
        if match:
            job_id = match.group(1)
            for child in self.children:
                child.run(run_by=job_id)
        else:
            assert(False)
"""
Design question:
Is it better to make:
    children (jobs that depend on this one)
    or
    parents (jobs that this one depends on)

The version with children makes more sense at first, but also implies that we need to have children defined before we have parent (going from leaf to root on the dependency graph), which is unintuitive. 
I feel like the way to go is to design this in a way where i define jobs in order they are executed in, and then have a way to add all the new nodes to the tree as i define them.
"""

# Job definition
get_samplelist = Job("./scripts/get_samplelist.sh", [])
fastqc = Job("./scripts/fastqc.sh", [])
multiqc = Job("./scripts/multiqc.sh", [])
make_idx = Job("./mapping/1-make_index.sh", [])
map_reads = Job("./mapping/2-map_reads.sbatch", [])
mapping_qc = Job("./mapping/multiqc.sh", [])
feature_count = Job("./feature_counts/featureCount.sbatch", [])

# Dependency definition
fastqc.depends_on(get_samplelist)
multiqc.depends_on(fastqc)
make_idx.depends_on(multiqc)
map_reads.depends_on(make_idx)
mapping_qc.depends_on(map_reads)
feature_count.depends_on(mapping_qc)

def main():
    get_samplelist.run()

if __name__ == '__main__':
    main()

