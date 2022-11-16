!=====================================================================
!     ****** LBE/bcond_bc_ff
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
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
!       1) front (x = l)
!       2) rear  (x = 0)
!       3) left  (y = 0)
!       4) right (y = m)
!
!     *****
!=====================================================================
!
        subroutine bcond_bc_ff
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

#ifdef FLIPFLOP
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

!!$OMP PARALLEL DEFAULT(SHARED) & 
!!$OMP PRIVATE(i,j) 
!
! ----------------------------------------------
! front (x = l)
! rear (x = 0)
! ----------------------------------------------
!
! noslip
!!$OMP DO
!$acc parallel
!$acc loop independent
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
#endif
        do j = 1, m
! front (x = l)
           f12(l1,j-1,current) = f01(l,j,current)
           f10(l1,j+1,current) = f03(l,j,current)
           f14(l1,j  ,current) = f05(l,j,current)

! rear (x = 0)
           f03( 0,j-1,current) = f10(1,j,current)
           f01( 0,j+1,current) = f12(1,j,current)
           f05( 0,j  ,current) = f14(1,j,current)
        end do
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#endif
!$acc end parallel
!!$OMP END PARALLEL
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
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
#endif
        do i = 1, l
! left (y = 0)  
           f08(i  ,0,current)  = f17(i,1,current)
           f12(i+1,0,current)  = f01(i,1,current)
           f03(i-1,0,current)  = f10(i,1,current)

! right (y = m) lid-wall
           f10(i+1,m1,current) = f03(i,m,current) - force
           f17(i  ,m1,current) = f08(i,m,current)
           f01(i-1,m1,current) = f12(i,m,current) + force
        enddo
!$acc end parallel
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#endif
!!$OMP END PARALLEL
!
#endif

! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_bc = time_bc + real(countA1-countA0)/(count_rate)
        time_bc1 = time_bc1 + (tcountA1-tcountA0)
!

!#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. bcond_bc_ff", current
        endif
!#endif
        return
        end subroutine bcond_bc_ff
