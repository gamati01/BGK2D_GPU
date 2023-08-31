!=====================================================================
!     ****** LBE/build_bcond
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       set BC flags (for multiblock & mpi)
!       if flag == 0 periodic b.c.
!               == 1 solid wall
!               == 2 moving wall
!               == 3 no-slip wall
!               == 4 inflow
!               == 5 outflow
!               == other --> error
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
      subroutine build_bcond
!
      use timing
      use storage
!
      implicit none
!
      integer:: uni, len, ierr, i
!
      character*15 hname
!
#ifdef CHANNEL
      u00 = 0.0            ! boundary condition
      u0  = u0             ! volume force
#else
      u00 = u0             ! boundary condition
      u0  = 0.0            ! volume force
#endif
!
      write(16,*) "INFO: reference velocities --->", u0, u00
!
#  ifdef _OPENACC
      write(38,*) "#", myrank, ":my GPU  is ------>", mydev, ndev
#  endif
!
#ifdef DEBUG_1
      if(myrank == 0) then
         write(6,*) "DEBUG1: Exiting from sub. build_bcond"
      endif
#endif
      return
      end subroutine build_bcond
