echo "Poiseuille Flow with differen code"
echo "------------------------------"
echo "run #1 of 3: serial (single CPU)"
sleep 5
./run.single.serial.fused.nv.x
echo "------------------------------"
echo "run #2 of 3: multicore (CPU)"
sleep 5
./run.single.multicore.fused.nv.x
echo "------------------------------"
echo "run #3 of 3: GPU (do concurrent) "
sleep 5 
./run.single.gpu.fused.nv.x
echo "------------------------------"
echo "to plot: use gnuplot and load 'plot.gnu'"

