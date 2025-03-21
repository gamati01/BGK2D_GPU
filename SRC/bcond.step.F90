!=====================================================================
!     ****** LBE/bcond_step
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond_step
!     DESCRIPTION
!       Backward facing step
!                      * inflow (rear)
!                      * outflow (front)
!                      * noslip b.c. (left/right)
!                      * noslip b.c. (step)
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!       remove hardwritten inflow velocity       
!       
!     NOTES
!       Order of upgrading bc
!       1) front (x = l)
!       2) rear  (x = 0)
!       3) left  (y = 0)
!       4) right (y = m)
!       5) step  (y < m/2, x < l/2)
!
!       inflow velocity  is hardwritten : 0.1       
!
!     *****
!=====================================================================
!
        subroutine bcond_step
!
        use timing
        use storage
!
        implicit none
!
        integer      :: i,j
        real(mykind) :: xj,yj
        real(mykind) :: cvsq,crho, rhoinv
        real(mykind) :: cx01,cx03,cx05
        real(mykind) :: cx10,cx12,cx14
        real(mykind) :: cte1
!
#ifdef NOSHIFT
       cte1 = uno
#else
       cte1 = zero
#endif
!
        u_inflow=0.1
!        stepy = 0
!        stepx = 0
!        
! start timing...
        call SYSTEM_CLOCK(countA0, count_rate, count_max)
        call time(tcountA0)
!
! ----------------------------------------------
! front, outflow  (x = l)
! ----------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
        do j=0,m+1
#elif OPENACC
#ifdef KERNELS
!$acc kernels
!$acc loop independent
#else
!$acc parallel
!$acc loop independent
#endif
        do j=0,m+1
#else
        do concurrent (j=0:m+1)
#endif
!         y = (real(y,mykind) -0.5 - 0.5*real(m,mykind))/(0.5*real(m,mykind))
           crho  =uno
           rhoinv=uno
!           
! front, outflow  (x = l)
           xj = ((a03(l,j)-a12(l,j)) & 
                +(a01(l,j)-a10(l,j)) & 
                +(a05(l,j)-a14(l,j)))*rhoinv
           yj = ((a03(l,j)-a01(l,j)) &
                +(a12(l,j)-a10(l,j)) &
                +(a08(l,j)-a17(l,j)))*rhoinv
!          
           cvsq=xj*xj+yj*yj
!
           cx10 = rf*(-xj-yj)+qf*(3.0*(xj+yj)*(xj+yj)-cvsq)
           cx12 = rf*(-xj+yj)+qf*(3.0*(xj-yj)*(xj-yj)-cvsq)
           cx14 = rf*(-xj   )+qf*(3.0*(xj   )*(xj   )-cvsq)
!
           a10(l1,j) = crho*p2*(cte1+cx10)
           a12(l1,j) = crho*p2*(cte1+cx12)
           a14(l1,j) = crho*p1*(cte1+cx14)
        end do
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#elif OPENACC
# ifdef KERNELS
!$acc end kernels
# else
!$acc end parallel
# endif
#endif
!
! ----------------------------------------------
! rear, inflow (x=0, parabolic profile)
! ----------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
        do j=stepy,m+1
#elif OPENACC
#ifdef KERNELS
!$acc kernels
!$acc loop independent
#else
!$acc parallel
!$acc loop independent
#endif
        do j=stepy,m+1
#else
        do concurrent (j=stepy:m+1)
#endif
           u_inflow=0.1
           crho  =uno
           rhoinv=uno

           xj = u_inflow*float(j-stepy)*float(m-j) & 
                   /float((m-stepy)*(m-stepy)/4)
           yj = zero
!           
! check, to remove
!           write(6,*) j, xj, yj
!           
           cvsq=xj*xj+yj*yj
!
           cx01 = rf*( xj-yj   )+qf*(3.d0*(xj-yj)*(xj-yj)-cvsq)
           cx03 = rf*( xj+yj   )+qf*(3.d0*(xj+yj)*(xj+yj)-cvsq)
           cx05 = rf*( xj      )+qf*(3.d0*(xj   )*(xj   )-cvsq)
!
           a01(0,j) = crho*p2*(cte1+cx01)
           a03(0,j) = crho*p2*(cte1+cx03)
           a05(0,j) = crho*p1*(cte1+cx05)
        end do
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
! ----------------------------------------------
! left (y = 0)  
! right (y = m) 
! ----------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd 
        do i=1,l+1
#elif OPENACC
#ifdef KERNELS
!$acc kernels
!$acc loop independent
#else
!$acc parallel
!$acc loop independent
#endif
        do i=1,l
#else
        do concurrent (i=1:l)
#endif
! left, noslip  (y = 0)  
           a08(i  ,0)  = a17(i,1)
           a12(i+1,0)  = a01(i,1)
           a03(i-1,0)  = a10(i,1)
!           
! right, noslip  (y = m) 
           a10(i+1,m1) = a03(i,m)
           a17(i  ,m1) = a08(i,m)
           a01(i-1,m1) = a12(i,m)
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
! ----------------------------------------------
! step  
! left, noslip  (y = m/4)
! ----------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
        do i=1,stepx
#elif OPENACC
#ifdef KERNELS
!$acc kernels
!$acc loop independent
#else
!$acc parallel
!$acc loop independent
#endif
        do i=1,stepx
#else
        do concurrent (i=1:stepx)
#endif
           a08(i  ,stepy-1)  = a17(i,stepy)
           a12(i+1,stepy-1)  = a01(i,stepy)
           a03(i-1,stepy-1)  = a10(i,stepy)
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
! ----------------------------------------------
! rear, noslip  (x = l/4)
! ----------------------------------------------
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd
        do j=1,stepy
#elif OPENACC
#ifdef KERNELS
!$acc kernels
!$acc loop independent
#else
!$acc parallel
!$acc loop independent
#endif
        do j=1,stepy
#else
        do concurrent (j=1:stepy)
#endif
           a03(stepx-1,j-1) = a10(stepx,j)
           a01(stepx-1,j+1) = a12(stepx,j)
           a05(stepx-1,j  ) = a14(stepx,j)
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
! ----------------------------------------------
! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_bc = time_bc + real(countA1-countA0)/(count_rate)
        time_bc1 = time_bc1 + (tcountA1-tcountA0)
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. bcond_step", & 
           u_inflow, stepx, stepy
        endif
#endif
!        
        end subroutine bcond_step
