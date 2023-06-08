#!/bin/bash -l

#SBATCH --job-name=ops-jupyter
#SBATCH --partition=cpu
#SBATCH --ntasks=1
#SBATCH --mem=2G
#SBATCH --signal=USR2
#SBATCH --chdir=/scratch/prj/ukirtc_rtd/ML-AI/D
#SBATCH --cpus-per-task=1
#SBATCH --output=/scratch/users/%u/%j.out

echo 'loading python'
module load python/3.8.12-gcc-9.4.0

echo 'loaded python, now preparing file'
# get unused socket per https://unix.stackexchange.com/a/132524
readonly IPADDRESS=$(hostname -I | tr ' ' '\n' | grep '10.211.4.')
readonly PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command:

   ssh -NL 8889:${HOSTNAME}:${PORT} ${USER}@hpc.create.kcl.ac.uk

   and point your web browser to http://localhost:8889/lab?token=<add the token from the jupyter output below>

When done using the notebook, terminate the job by
issuing the following command on the login node:

      scancel -f ${SLURM_JOB_ID}

END

echo 'file prepared, now opening jupyter'
source /users/${USER}/.bashrc
source activate db
jupyter-lab --port=${PORT} --ip=${IPADDRESS} --no-browser

echo 'Finished with jupyter'
printf 'notebook exited' 1>&2
