#
export DIR=RUN_SINGLE_MULTICORE_ORIGINAL_NVIDIA
export EXE=bgk2d.multicore.x
#
echo "-------------------------------"
echo "starting test Backeard Step    " 
echo " ---> nvidia                   "
echo " ---> single precision         "
echo " ---> orig                     "
echo " ---> multicore                "
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
#
make clean
make multicore NVIDA=1 BFS=1 
#
cd -
cp ../../../RUN/$EXE  .
cp ../bgk.input .
#
# step 2: running test
export ACC_NUM_CORES=2
echo "step 2: running test with cores=" $ACC_NUM_CORES
#
./$EXE >& out.log
#
if (-e "bgk.perf") then
   echo "run ended succesfully..."
else
   echo "running test fails..."
   exit 1
fi

