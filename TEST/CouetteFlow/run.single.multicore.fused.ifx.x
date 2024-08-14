#!/bin/tcsh
#
setenv DIR RUN_SINGLE_MULTICORE_FUSED_IFX
setenv EXE bgk2d.multicore.x
#
echo "-------------------------------"
echo "starting test Couette flow     " 
echo " ---> nvfortran                "
echo " ---> single precision         "
echo " ---> fused                    "
echo " ---> multicore                "
echo " ---> doconcurrent             "
echo " ---> "$EXE
echo " ---> "$DIR
echo "-------------------------------"
#
rm -r $DIR
mkdir $DIR
cd $DIR

# step 1: compiling
echo "step 1: compiling"
cd ../../../SRC
make clean
make multicore FUSED=1 INTEL=1 COU=1 SINGLE=1
if ($?) then
   echo "compiling fails..."
   exit 1
else
   cd -
   cp ../../../RUN/$EXE  .
   cp ../bgk.input .
   echo "compiling  ended succesfully..."
endif


# step 2: running test
echo "step 2: running test"
setenv OMP_NUM_THREADS 6
./$EXE >& out.log
if (-e "bgk.perf") then
   echo "run ended succesfully..."
else
   echo "running test fails..."
   exit 1
endif

