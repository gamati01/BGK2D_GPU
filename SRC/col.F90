!====================================================
!     ****** LBE/coll
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       coll
!     DESCRIPTION
!       Collision according to bgk style (\omega(f_f^(eq)))
!       forcing is included and is proportional to u_0
!     INPUTS
!       itime --> timestep 
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,k,itime
!       real variables used: 
!
!
!     *****
!====================================================
!
        subroutine col(itime)
!
        use storage
        use real_kinds
        use timing
!
#ifdef _OPENMP
        use omp_lib
#endif
!
        implicit none
!
        integer:: i,j,itime
!
        real(mykind) :: x01,x03,x05,x08,x10
        real(mykind) :: x12,x14,x17,x19
        real(mykind) :: e01,e03,e05,e08,e10
        real(mykind) :: e12,e14,e17,e19
        real(mykind) :: rho,rhoinv,vx,vy,vz,vx2,vy2,vz2,vsq
        real(mykind) :: vxpy,vxmy,vxpz,vxmz,vypz,vymz,rp1,rp2,rp0
        real(mykind) :: qxpy,qxmy,qxpz,qxmz,qypz,qymz,qx,qy,qz,q0
        real(mykind) :: forcex, forcey
        real(mykind) :: pi,cte1,cte0
!
        parameter(pi=3.14159265358979)
!
#ifdef DEBUG_3
        real(mykind) :: cte
        character*17 file_nameD
        file_nameD = 'debug.xxx.xxx.log'
        write(file_nameD(7:9),3300) itime
        write(file_nameD(11:13),3300) myrank
        open(41,file=file_nameD, status='unknown')        ! debug file
!
!        call probe_global(itime,(3*lx/4),(ly/2))
#endif
!
#ifdef NOSHIFT
        cte1 = zero
#else
        cte1 = uno
#endif
        cte0 = uno - cte1
!
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd collapse(2)
        do j=1,m
           do i=1,l
#elif OPENACC
!$acc kernels
!$acc loop independent
        do j = 1,m
!$acc loop independent
           do i = 1,l
#else
        do concurrent (j=1:m, i=1:l)
#endif
!
           x01 = b01(i,j)
           x03 = b03(i,j)
           x05 = b05(i,j)
           x08 = b08(i,j)
           x10 = b10(i,j)
           x12 = b12(i,j)
           x14 = b14(i,j)
           x17 = b17(i,j)
           x19 = a19(i,j)
!
! natural way of expressing rho
!           rho = (x01+x03+x05+x08+x10+x12+x14+x17+x19)+cte1
!
! better for half precision
           rho = (((x01+x03+x10+x12)+(x05+x08+x14+x17))+x19)+cte1
!
           rhoinv = uno/rho
!
           vx = ((x03-x12)+(x01-x10)+(x05-x14))*rhoinv
           vy = ((x03-x01)+(x12-x10)+(x08-x17))*rhoinv
!
#ifdef DEBUG_3
        write(41,3131) i+offset(1),j+offset(2), obs(i,j),   & 
                        vx,vy,rho
!                       x01,x03,x05,x08,x10,x12,x14,x17,x19
#endif
!
! Quadratic terms
           vx2 = vx*vx
           vy2 = vy*vy
!
           vsq = vx2+vy2
!
           vxpy = vx+vy
           vxmy = vx-vy
!              
           qxpy = cte0+qf*(tre*vxpy*vxpy-vsq)
           qxmy = cte0+qf*(tre*vxmy*vxmy-vsq)
           qx   = cte0+qf*(tre*vx2      -vsq)
           qy   = cte0+qf*(tre*vy2      -vsq)
           q0   = cte0+qf*(             -vsq)
!
! linear terms
           vx   = rf*vx
           vy   = rf*vy
           vxpy = rf*vxpy
           vxmy = rf*vxmy
!
! constant terms
           rp0 = rho*p0
           rp1 = rho*p1
           rp2 = rho*p2
!
! equilibrium distribution
           e01 = rp2*(+vxmy+qxmy)+cte1*(rp2-p2)
           e03 = rp2*(+vxpy+qxpy)+cte1*(rp2-p2)
           e05 = rp1*(+vx  +qx  )+cte1*(rp1-p1)
           e08 = rp1*(+vy  +qy  )+cte1*(rp1-p1)
           e10 = rp2*(-vxpy+qxpy)+cte1*(rp2-p2)
           e12 = rp2*(-vxmy+qxmy)+cte1*(rp2-p2)
           e14 = rp1*(-vx  +qx  )+cte1*(rp1-p1)
           e17 = rp1*(-vy  +qy  )+cte1*(rp1-p1)
           e19 = rp0*(     +q0  )+cte1*(rp0-p0)
!
! it is only correct for driven cavity/TG (no forcing at all)
! loop on populations
           a01(i,j) = x01 - omega*(x01-e01) 
           a03(i,j) = x03 - omega*(x03-e03) 
           a05(i,j) = x05 - omega*(x05-e05) 
           a08(i,j) = x08 - omega*(x08-e08) 
           a10(i,j) = x10 - omega*(x10-e10) 
           a12(i,j) = x12 - omega*(x12-e12) 
           a14(i,j) = x14 - omega*(x14-e14) 
           a17(i,j) = x17 - omega*(x17-e17) 
           a19(i,j) = x19 - omega*(x19-e19)
!
        end do
#ifdef OFFLOAD
        end do
        !$OMP end target teams distribute parallel do simd
#elif OPENACC
        end do
        !$acc end kernels
#endif

!
#ifdef DEBUG_3
!
! format
3300  format(i3.3)
!3131  format(3(i,1x),6(e14.6,1x))
3131  format(3(i,1x),3(e14.6,1x))
        close(41)
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. coll"
        endif
#endif
        return 
        end subroutine col
