!=====================================================================
!     ****** LBE/bcond_channel
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond_channel: simple channel flow with
!                      * inflow (rear)
!                      * outflow (front)
!                      * no slip (left/right)
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
        subroutine bcond_channel
!
        use timing
        use storage
!
        implicit none
!
        integer      :: i,j
        real(mykind) :: den,xj,yj,rho
        real(mykind) :: x01,x03,x05
        real(mykind) :: x10,x12,x14
        real(mykind) :: cvsq,crho, rhoinv
        real(mykind) :: cx01,cx03,cx05
        real(mykind) :: cx10,cx12,cx14
        real(mykind) :: cte1
!
#ifdef CHANNEL
!
# ifdef NOSHIFT
       cte1 = uno
# else
       cte1 = zero
# endif

!
! start timing...
        call SYSTEM_CLOCK(countA0, count_rate, count_max)
        call time(tcountA0)
!
        u_inflow=0.1
!
! ----------------------------------------------
! loop foused for performance reason (for GPU)
! -------------------------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
        do j=0,m+1
#else
        do concurrent (j=0:m+1)
#endif
           crho  =uno
           rhoinv=uno
!           
! rear, periodic bc  (x = l)
!
           a10(l1,j) = a10(1,j)
           a12(l1,j) = a12(1,j)
           a14(l1,j) = a14(1,j)
!
! -------------------------------------------------------------
! front, inflow (x = 0)
!           
           a01( 0,j) = a01(l,j)
           a03( 0,j) = a03(l,j)
           a05( 0,j) = a05(l,j)
        end do
!
! ----------------------------------------------
! left (y = 0)  
! right (y = m) 
! ----------------------------------------------
!
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd 
        do i=0,l+1
#else
        do concurrent (i=0:l+1)
#endif
! left, noslip  (y = 0)  
           a08(i  ,0)  = a17(i,1)
           a12(i+1,0)  = a01(i,1)
           a03(i-1,0)  = a10(i,1)

! right, noslip  (y = m) 
           a10(i+1,m1) = a03(i,m)
           a17(i  ,m1) = a08(i,m)
           a01(i-1,m1) = a12(i,m) 
        enddo
!
! ----------------------------------------------
! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_bc = time_bc + real(countA1-countA0)/(count_rate)
        time_bc1 = time_bc1 + (tcountA1-tcountA0)
!
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. bcond_channel", & 
           u_inflow
        endif
#endif
        return
        end subroutine bcond_channel
