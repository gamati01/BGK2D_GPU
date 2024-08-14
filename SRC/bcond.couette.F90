!=====================================================================
!     ****** LBE/bcond_couette
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond_couette
!     DESCRIPTION
!
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!       Order of upgrading bc
!       1) front (x = l) periodic
!       2) rear  (x = 0) periodic
!       3) left  (y = 0) no-slip wall
!       4) right (y = m) moving wall
!
!     *****
!=====================================================================
!
        subroutine bcond_couette
!
        use timing
        use storage
!
        implicit none
!
        integer      :: i,j 
        real(mykind) :: force
!
! start timing...
        call SYSTEM_CLOCK(countA0, count_rate, count_max)
        call time(tcountA0)
!
        force =  u00/(6.0)
!

#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd 
        do j=1,m
#elif OPENACC
#ifdef KERNELS
 !$acc kernels
 !$acc loop independent
#else
 !$acc parallel
 !$acc loop independent 
#endif
        do j=1,m
#else
        do concurrent (j=1:m)
#endif
! front (x = l)
           a01( 0,j) = a01(l,j)
           a03( 0,j) = a03(l,j)
           a05( 0,j) = a05(l,j)
!
! rear (x = 0)
           a10(l1,j) = a10(1,j)
           a12(l1,j) = a12(1,j)
           a14(l1,j) = a14(1,j)
!
        enddo
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#elif OPENACC
#ifdef KERNELS
        !$acc end kernels
#else
        !$acc end parallel
#endif
#endif
!        
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd 
        do i=1,l
#elif OPENACC
# ifdef KERNELS
 !$acc kernels
 !$acc loop independent
# else
 !$acc parallel
 !$acc loop independent
# endif
        do i=1,l
#else
        do concurrent (i=1:l)
#endif
! left (y = 0)  
           a08(i  ,0)  = a17(i,1)
           a12(i+1,0)  = a01(i,1)
           a03(i-1,0)  = a10(i,1)

! right (y = m) lid-wall
           a10(i+1,m1) = a03(i,m) - force
           a17(i  ,m1) = a08(i,m)
           a01(i-1,m1) = a12(i,m) + force
        enddo
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#elif OPENACC
#ifdef KERNELS
        !$acc end kernels
#else
        !$acc end parallel
#endif
#endif
        
!
! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_bc = time_bc + real(countA1-countA0)/(count_rate)
        time_bc1 = time_bc1 + (tcountA1-tcountA0)
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. bcond_couette"
        endif
#endif
!        
        end subroutine bcond_couette
