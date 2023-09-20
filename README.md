# BGK2D_GPU


1) Description

This is a 2D CFD Lattice Boltzmann Method code developed to 
	1) Give a (quite) efficient implementation of LBM
 	2) Exploit mulithreading
  	3) assess performance using (different) GPUs (now AMD and NVIDIA).  

It is a "downsize" of a more complex code (3D one with mpi+openacc). Different options can be activated/decativated via preprocessing flags

Two implementations are possible
  * ORIGINAL (default)
	Classical implementation, with two different subroutine streaming + collision
  * FUSED
	Implementation with one single fused subroutine (no streaming subroutine). 
        It asks for less BW but it uses pointers.

These are the "possible" choice
  * SERIAL
  * DO_CONCURRENT
  	* CPU 
	* GPU (only NVIDIA so far)
  * OPENMP OFFLOAD 
	* GPU (NVIDIA and AMD)
  * OPENACC
   	* GPU (NVIDIA and AMD with Cray Compiler)

The code has been Tested With different compilers
  * nvfortran
  * gnu
  * xlf
  * flang
  * ftn (CRAY)
 

The code has been tested With different precision
  * single precision (default)
  * double precision
  * mixed precision1 (single/double)

3) Directory Structure

in SRC directory: all source files + Makefile
                  The exe (bgk2d.doconcurrent.x or bgk2d.offload.x) will be copied in ../RUN directory (to create)
in UTIL directory: some utilities like scripts or input file
in TEST directory: four test case
  * lid-driven cavity
  * Taylor-green vortex
  * flow around an obstacle (cylinder: von Karman streets)
  * poiseuille flow

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

To compile offload (gpu) with gnu (fused), double precision
* make offload DOUBLE=1 FLANG=1 FIX=" -DFUSED" 


4) Other stuff

Other preprocessing flags are:

* TRICK1 (to reduce the impact of BC on performance --> square box")
* TRICK2 (to force, for OpenMP offload the number of threads)
* DRAG (activate drag/lift computing, time-consuming)

5) Licence

This SW is under The MIT licence

