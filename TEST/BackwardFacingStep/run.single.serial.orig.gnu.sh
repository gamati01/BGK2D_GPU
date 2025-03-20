#
export DIR=RUN_SINGLE_SERIAL_ORIGINAL_GNU
export EXE=bgk2d.serial.x
#
echo "-------------------------------"
echo "starting test Backeard Step    " 
echo " ---> gfortran                 "
echo " ---> single precision         "
echo " ---> orig                     "
echo " ---> serial                   "
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
make serial GNU=1 BFS=1 
#
cd -
cp ../../../RUN/$EXE  .
cp ../bgk.input .
#
# step 2: running test
echo "step 2: running test"
./$EXE >& out.log
if (-e "bgk.perf") then
   echo "run ended succesfully..."
else
   echo "running test fails..."
   exit 1
fi

