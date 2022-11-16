!=====================================================================
!     ****** LBE/bcond_bc_periodic
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       2D periodic bc
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!       Order of upgrading bc
!       1) front (x = l)
!       2) rear  (x = 0)
!       3) left  (y = 0)
!       4) right (y = m)
!
!     *****
!=====================================================================
!
        subroutine bcond_bc_periodic
!
        use timing
        use storage
!
        implicit none
!
        integer      :: i,j,k 
        integer      :: tag, ierr
        real(mykind) :: force
        real(mykind) :: den,xj,yj,zj,rho,vsq,y,rhoinv
        real(mykind) :: x01,x03,x05
        real(mykind) :: x08,x10,x12
        real(mykind) :: x14,x17
        real(mykind) :: cvsq,crho
        real(mykind) :: cx01,cx02,cx03,cx04,cx05
        real(mykind) :: cx10,cx11,cx12,cx13,cx14
        real(mykind) :: cte1
!
! start timing...
        call SYSTEM_CLOCK(countA0, count_rate, count_max)
        call time(tcountA0)

#ifdef PERIODIC
!
# ifdef NOSHIFT
       cte1=uno
# else
       cte1=zero
# endif
!
       force =  u00/(6.0)
!
!
# ifdef NOMANAGED
!$acc enter data copyin (force) 
!$acc data present (a01,a03,a05,a08,a10,a12,a14,a17,a19)
# endif

!$OMP PARALLEL DEFAULT(SHARED) & 
!$OMP PRIVATE(i,j) 
!
! ----------------------------------------------
! front (x = l)
! rear (x = 0)
! ----------------------------------------------
!
! noslip
!$acc parallel
!$acc loop independent
#ifdef _OPENMP
!$OMP PARALLEL DEFAULT(SHARED) &
!$OMP PRIVATE(i,j)
!$OMP DO
# ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
# endif
#endif
        do j = 0, m+1
! front (x = l)
           a01( 0,j) = a01(l,j)
           a03( 0,j) = a03(l,j)
           a05( 0,j) = a05(l,j)

! rear (x = 0)
           a10(l1,j) = a10(1,j)
           a12(l1,j) = a12(1,j)
           a14(l1,j) = a14(1,j)
        end do
!$acc end parallel
#ifdef _OPENMP
!$OMP END PARALLEL
# ifdef OFFLOAD
!$OMP end target teams distribute parallel do
# endif
#endif

!
! ----------------------------------------------
! left (y = 0)  
! right (y = m) 
! ----------------------------------------------
!
! noslip
!!$OMP DO
!$acc parallel
!$acc loop independent
#ifdef _OPENMP
!$OMP DO
# ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
# endif
#endif
        do i = 0, l+1
! left (y = 0)  
           a17(i,m1) = a17(i,1)
           a01(i,m1) = a01(i,1)
           a10(i,m1) = a10(i,1)

! right (y = m) 
           a03(i,0) = a03(i,m)
           a08(i,0) = a08(i,m)
           a12(i,0) = a12(i,m)
        enddo
!$acc end parallel
#ifdef _OPENMP
!$OMP END PARALLEL
# ifdef OFFLOAD
!$OMP end target teams distribute parallel do
# endif
#endif
!
#endif
! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_bc = time_bc + real(countA1-countA0)/(count_rate)
        time_bc1 = time_bc1 + (tcountA1-tcountA0)
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. bcond_bc_ff", current
        endif
#endif
        return
        end subroutine bcond_bc_periodic
