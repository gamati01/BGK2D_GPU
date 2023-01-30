!=====================================================================
!     ****** LBE/check_case
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       Simple check of the configuration...
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!
!     *****
!=====================================================================
!
        subroutine check_case
!
        use storage
        use timing
!
        implicit none
!
        integer:: ierr
        real(mykind) :: a
!
! Warning section  (run will proceed...) 
        if((u0.GT.0).AND.(u_inflow.GT.0)) then
           write(16,*) "WARNING: inflow ad volume force & 
                        at the same time", myrank, u0, u_inflow 
        endif
!
! Info section  
#ifdef PERIODIC
        write(6 ,*) "INFO: The test case has periodic bc" 
        write(16,*) "INFO: The test case has periodic bc" 
#else
# ifdef CHANNEL
        write(6 ,*) "INFO: The test case has channel bc" 
        write(16,*) "INFO: The test case has channel bc" 
#  ifdef INFLOW
        write(6 ,*) "INFO: The test case has inflow bc" 
        write(16,*) "INFO: The test case has inflow bc" 
#  else
        write(6 ,*) "INFO: The test case is driven cavity" 
        write(16,*) "INFO: The test case is driven cavity" 
#  endif
# endif
#endif
!
#ifdef OBSTACLE
        write(6 ,*)  "INFO: The test case has an obstacle in the flow"
        write(16,*)  "INFO: The test case has an obstacle in the flow"
#endif
!
#ifdef MULTICORE
        write(6 ,*)  "INFO: multicore (CPU) parallelization "
        write(16,*)  "INFO: multicore (CPU) parallelization "
#endif
!
#ifdef NOSHIFT
        write(6,*)  "INFO: using NOSHIFT preprocessing flag"
        write(16,*) "INFO: using NOSHIFT preprocessing flag"
#endif
!
#ifdef DRAG
        write(6,*)  "INFO: using DRAG preprocessing flag"
        write(16,*) "INFO: using DRAG preprocessing flag"
#endif
!
#ifdef QUAD_P
        write(16,*) "INFO: using quad precision"
#else
# ifdef DOUBLE_P
        write(16,*) "INFO: using double precision"
# else
#  ifdef HALF_P
        write(16,*) "INFO: using half precision"
        write(6,*)  "WARNING: pure half precision has some problem"
#  else
        write(16,*) "INFO: using single precision"
#  endif
# endif
#endif
!
#ifdef MIXEDPRECISION
       write(16,*) "INFO: using mixed precision"
#endif
!
       write(16,*) "INFO: mykind=   ", mykind, "range  =", range(u0)
       write(16,*) "INFO: mykind=   ", mykind, "huge   =", huge(u0)
       write(16,*) "INFO: mykind=   ", mykind, "epsilon=", epsilon(u0)
       write(16,*) "INFO: mystorage=", mystorage, "range  =", & 
                                       range(a01(1,1))
       write(16,*) "INFO: mystorage=", mystorage, "huge   =", &
                                       huge(a01(1,1))
       write(16,*) "INFO: mystorage=", mystorage, "epsilon=", &
                                       epsilon(a01(1,1))
!
       write(16,*) "INFO: using RAW I/O"
!
#ifdef PGI
       write(16,*) "INFO: using PGI compiler"
       write(16,*) "      quad precision not supported"
#endif
!
#ifdef SERIAL
       write(16,*) "INFO: serial version"
#endif

#ifdef FUSED
       write(16,*) "INFO: using Fused version"
#else
       write(16,*) "INFO: using Move & collide (Original) version"
#endif
!
#ifdef DEBUG_3
       if(myrank == 0) then
          write(6,*) "INFO: DEBUG3 mode enabled"
       endif
#endif
!
#ifdef DEBUG_2
       if(myrank == 0) then
          write(6,*) "INFO: DEBUG2 mode enabled"
       endif
#endif
!
#ifdef DEBUG_1
       if(myrank == 0) then
          write(6,*) "INFO: DEBUG1 mode enabled"
          write(6,*) "DEBUG1: Exiting from sub. check_case"
       endif
#endif
!
#ifdef MEM_CHECK
       if(myrank == 0) then
          mem_stop = get_mem();
          write(6,*) "MEM_CHECK: after sub check_case mem =", mem_stop
       endif
#endif
!
#ifdef TRICK1
       write(6,*) "WARNING: square box mandatory (TRICK1)!"
       write(16,*) "WARNING: square box mandatory (TRICK1)!"
       if(l.ne.m) then
          write(6,*) "ERROR: box not squared (TRICK1)!"
          write(16,*) "ERROR: box not squared (TRICK1)!"
          stop
       endif
#endif
!
#ifdef TRICK2
       write(6,*) "WARNING: forced offload num_threads(TRICK2)!"
       write(16,*) "WARNING: forced offload num_threads(TRICK2)!"
       endif
#endif
!
#ifdef DEBUG_1
       if(myrank == 0) then
          write(6,*) "DEBUG1: Exiting from sub. check_case"
       endif
#endif
        end subroutine check_case
