!=====================================================================
!     ****** LBE/boundaries
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       Simple wrapper for boundaries routine...
!       - call bcond  else
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
        subroutine boundaries
!
        use timing
        use storage
!
        implicit none
        integer:: ierr, i
        real(mykind):: temp1, temp2
!
#ifdef PERIODIC
! periodic bc
        call bcond_periodic
#else
# ifdef CHANNEL
! channel bc        
        call bcond_channel
# else
#  ifdef INFLOW
! inflow bc
        call bcond_inflow
#  else
! lid_cavity bc 
        call bcond_driven
#  endif
# endif
#endif
!
#ifdef OBSTACLE
        call bcond_obs
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. boundaries"
        endif
#endif
!
      end subroutine boundaries
