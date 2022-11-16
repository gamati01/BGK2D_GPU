# BGK2D

2D LBM using
  * DO_CONCURRENT
  * OPEMMP OFFLOAD 

With different HW & SW




To compile do-concurrent (cpu) with nvfortran
* make NV=1 FIX="-DPGI -stdpar=multicore "

To compile do-concurrent (gpu) with nvfortran (original)
* make NV=1 FIX="-DPGI -stdpar=gpu "

To compile do-concurrent (gpu) with nvfortran (fused)
* make NV=1 FIX="-DPGI -stdpar=gpu -DFUSED "

To compile offload (gpu) with nvfortran (original)
*  make offload NV=1 

To compile offload (gpu) with nvfortran (fused)
* make offload NV=1 FIX="-DPGI -DFUSED" 

To compile offload (gpu) with xl (fused)
* make offload PWR=1 FIX="-DPGI -DFUSED" 

To compile offload (gpu) with gnu (fused)
* make offload GNU=1 FIX=" -DFUSED" 


Other preprocessing flags are

* TRICK1 (to reduce impact of BC on performance --> square box" 


