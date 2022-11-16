!====================================================
!     ****** LBE/coll_FlipFlop
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       coll
!     DESCRIPTION
!       Collision according to bgk style (\omega(f_f^(eq)))
!       forcing is included and is proportional to u_0
!       MOVE + COLLIDE version (flipflop)
!     INPUTS
!       itime --> timestep 
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,k,itime
!       real variables used: x02,x04,x05,x06,x11,x13,x14,x15,x19
!                            e02,e04,e05,e06,e11,e13,e14,e15,e19
!                            rho,rhoinv,vx,vz,vx2,vz2,vsq
!                            vxpz,vxmz,rp1,rp2
!                            qxpz,qxmz,qx,qz
!                            forcex,pi
!
!
!     *****
!====================================================
!
        subroutine col_FlipFlop(itime)
!
        use storage
        use real_kinds
        use timing
!
        implicit none
!
        integer:: i,j,itime
!
        real(mykind) :: x01,x02,x03,x04,x05,x06,x07,x08,x09,x10
        real(mykind) :: x11,x12,x13,x14,x15,x16,x17,x18,x19
        real(mykind) :: e01,e02,e03,e04,e05,e06,e07,e08,e09,e10
        real(mykind) :: e11,e12,e13,e14,e15,e16,e17,e18,e19
        real(mykind) :: rho,rhoinv,vx,vy,vz,vx2,vy2,vz2,vsq
        real(mykind) :: vxpy,vxmy,vxpz,vxmz,vypz,vymz,rp1,rp2,rp0
        real(mykind) :: qxpy,qxmy,qxpz,qxmz,qypz,qymz,qx,qy,qz,q0
        real(mykind) :: forcex, forcey
        real(mykind) :: pi,cte1,cte0
!
        parameter(pi=3.14159265358979)
!
#ifdef FLIPFLOP
!
# ifdef DEBUG_3
        real(mykind) :: cte
        character*17 file_nameD
        file_nameD = 'debug.xxx.xxx.log'
        write(file_nameD(7:9),3300) itime
        write(file_nameD(11:13),3300) myrank
        open(41,file=file_nameD, status='unknown')        ! debug file
!
        call probe_global(itime,(3*lx/4),(ly/2))
# endif
!
# ifdef NOSHIFT
        cte1 = zero
# else
        cte1 = uno
# endif
        cte0 = uno - cte1
!
!
!         call time(tcountG0)
!
!        do k = 1,n
! works (fine) with intel compiler!!!
! works (quite well) with IBM compiler !!!
!!IBM* ASSERT (NODEPS)
! works (?) with pgf compiler !!!
!!!!$acc do vector(256)
!!!!pgi$l nodepchk
!!$OMP PARALLEL DEFAULT(NONE)  &
!!$OMP PRIVATE(i,j)  &
!!$OMP PRIVATE(x01,x03,x05,x08,x10)  &
!!$OMP PRIVATE(x12,x14,x17,x19)  &
!!$OMP PRIVATE(e01,e03,e05,e08,e10)  &
!!$OMP PRIVATE(e12,e14,e17,e19)  &
!!$OMP PRIVATE(rho,rhoinv,vx,vy,vx2,vy2,vsq)  &
!!$OMP PRIVATE(vxpy,vxmy,rp0,rp1,rp2)  &
!!$OMP PRIVATE(qxpy,qxmy,q0,qx,qy)  &
!!$OMP PRIVATE(forcex,forcey)  &
!!$OMP SHARED(omega,fgrad,l,m,itime)  &
!!$OMP SHARED(cte0,cte1)  &
!!$OMP SHARED(current,next)  &
!!$OMP SHARED(f01,f03,f05,f08,f10)  &
!!$OMP SHARED(f12,f14,f17,f19)  
!!$OMP DO
!
#ifdef _OPENACC
!$acc parallel present(f01,f03,f05,f08,f10,f12,f14,f17,f19)
!$acc loop independent collapse(2)
#endif
!        
#ifdef OFFLOAD
!$OMP target teams distribute parallel do simd collapse(2)
#endif 
        do j = 1,m
!DIR$ IVDEP
!pgi$ IVDEP
!GNU$ IVDEP
           do i = 1,l
!
              x01 = f01(i-1,j+1,current)
              x03 = f03(i-1,j-1,current)
              x05 = f05(i-1,j  ,current)
              x08 = f08(i  ,j-1,current)
              x10 = f10(i+1,j+1,current)
              x12 = f12(i+1,j-1,current)
              x14 = f14(i+1,j  ,current)
              x17 = f17(i  ,j+1,current)
              x19 = f19(i  ,j  ,current)
!
! natural way of expressing rho
!              rho = (x01+x03+x05+x08+x10+x12+x14+x17+x19)+cte1
!
! better for half precision
              rho = (((x01+x03+x10+x12)+(x05+x08+x14+x17))+x19)+cte1
!
              rhoinv = uno/rho
!
              vx = ((x03-x12)+(x01-x10)+(x05-x14))*rhoinv
              vy = ((x03-x01)+(x12-x10)+(x08-x17))*rhoinv
!
# ifdef DEBUG_3
        write(41,3131) i+offset(1),j+offset(2), obs(i,j),   & 
                        vx,vy,rho
!                       x01,x03,x05,x08,x10,x12,x14,x17,x19
# endif
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
! it is only correct for driven cavity/TG  (no forcing at all)
! loop on populations
              f01(i,j,next) = x01 - omega*(x01-e01)
              f03(i,j,next) = x03 - omega*(x03-e03)
              f05(i,j,next) = x05 - omega*(x05-e05)
              f08(i,j,next) = x08 - omega*(x08-e08)
              f10(i,j,next) = x10 - omega*(x10-e10)
              f12(i,j,next) = x12 - omega*(x12-e12)
              f14(i,j,next) = x14 - omega*(x14-e14)
              f17(i,j,next) = x17 - omega*(x17-e17)
              f19(i,j,next) = x19 - omega*(x19-e19)
!
           end do
        end do
!$acc end parallel
#ifdef OFFLOAD
!$OMP end target teams distribute parallel do simd
#endif
!
!# ifdef _OPENMP
!        write(6,*) "OpenMP is on...", itime
!# endif
!!$OMP END PARALLEL
! swap timestep
        current = next
        next = 1 - next
!
!        call time(tcountG1)
!        write(6,*) tcountG1,tcountG0, tcountG1-tcountG0
!        write(6,*) "end sub. coll, ", itime
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
!
!#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. coll_FlipFlop", & 
                       current, next
        endif
!#endif
!
        return 
        end subroutine col_FlipFlop
