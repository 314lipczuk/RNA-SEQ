import subprocess
from dataclasses import dataclass
"""
Script that is meant to be run, when one wants to reproduce the computational part of this analysis. 
Each step of the analysis consists of at least one shell/slurm script.
They can be run manually, one by one, 
but a nicer way to have whole analysis done is to run this one script and have them be queued all at once.
I utilize the slurm job dependency mechanism to schedule all the jobs, and set correct dependencies between them, so that they are executed in correct sequence.
"""

def main():
    pass

"""
Design question:
Is it better to make:
    children (jobs that depend on this one)
    or
    parents (jobs that this one depends on)

The version with children makes more sense at first, but also implies that we need to have children defined before we have parent (going from leaf to root on the dependency graph), which is unintuitive. 
I feel like the way to go is to design this in a way where i define jobs in order they are executed in, and then have a way to add all the new nodes to the tree as i define them.
"""

@dataclass
class Job:
    path:str
    children:list[Job]

    def depends_on(self, parent):
        parent.children.append(self)

    def run(self):
        # TODO: make this run the sbatch w/ subprocess
        pass

# TODO: add paths to scripts and make sure all steps are in them (there is no 'glue' that i wrote in terminal at the time)

if __name__ == '__main__':
    main()

