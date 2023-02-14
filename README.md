# BGK2D_GPU


This is a 2D CFD lattice-boltzmann based code to assess performance using GPU.
It is a "downsize" of a more complex code (3D one with mpi+openacc). 
Now it performs
	* lid-driven cavity
	* taylor-green vortex
	* flow around a obstacle (cylinder)
	
in SRC directory: all source files + Makefile
in UTIL directory: some utilities like scripts or input file

	

2D LBM using
  * SERIAL
  * DO_CONCURRENT
  	* CPU 
	* GPU (NVIDIA)
  * OPEMMP OFFLOAD 

With different HW & SW
  	* nvfortran
	* gnu (GPU enabled)
	* xlf




To compile do-concurrent (cpu) with nvfortran
* make FIX="-DPGI -stdpar=multicore "

To compile do-concurrent (gpu) with nvfortran (original)
* make FIX="-DPGI -stdpar=gpu "

To compile do-concurrent (gpu) with nvfortran (fused)
* make FIX="-DPGI -stdpar=gpu -DFUSED "

To compile offload (gpu) with nvfortran (original)
*  make offload 

To compile offload (gpu) with nvfortran (fused)
* make offload FIX="-DFUSED" 

To compile offload (gpu) with xl (fused)
* make offload PWR=1 FIX="-DFUSED" 

To compile offload (gpu) with gnu (fused)
* make offload GNU=1 FIX=" -DFUSED" 


Other preprocessing flags are

* TRICK1 (to reduce impact of BC on performance --> square box")
* TRICK2 (to force, for openmp offload the number of threads)


