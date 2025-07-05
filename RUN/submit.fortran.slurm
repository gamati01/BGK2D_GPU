#!/bin/bash
# 
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:1
#SBATCH --account=tra25_sumcfd
#SBATCH -t 00:30:00 
#SBATCH --partition=boost_usr_prod


echo $HOSTNAME > hostname.dat
#./bgk2d.openacc.x > out.log
./bgk2d.offload.x > out.log
#./bgk2d.doconcurrent.x > out.log

echo "That's all Folks!!!"



