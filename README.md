# BGK2D_GPU


1) Description

This is a 2D CFD Lattice Boltzmann Method code developed to assess performance using GPU.  It is a "downsize" of a more complex code (3D one with mpi+openacc). 

Two implementation are possible
  * ORIGINAL (default)
	Classical implementation, with two different subroutine streaming + collision
  * FUSED
	Implementation with one single fused subroutine (no streaming subroutine). i
        It asks for less BW but it uses pointers.

These are the "possible" choice
  * SERIAL
  * DO_CONCURRENT
  	* CPU 
	* GPU (only NVIDIA so far)
  * OPEMMP OFFLOAD 
	* GPU (NVIDIA and AMD)

Tested With different compiler (GPU)
  	* nvfortran
	* gnu 
	* xlf
	* flang

3) Directory Structure

in SRC directory: all source files + Makefile
                  The exe (bgk2d.doconcurrent.x or bgk2d.offload.x) will be copied in ../RUN directory (to create)
in UTIL directory: some utilities like scripts or input file
in TEST directory: three test case
        * lid-driven cavity
        * taylor-green vortex
        * flow around a obstacle (cylindera: von karman streets)

3) How to compile
	
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

To compile offload (gpu) with gnu (fused)
* make offload FLANG=1 FIX=" -DFUSED" 


4) Other stuff

Other preprocessing flags are:

* TRICK1 (to reduce impact of BC on performance --> square box")
* TRICK2 (to force, for openmp offload the number of threads)
* DRAG (activate drag/lift computing, time consuming)


