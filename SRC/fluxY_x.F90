!=====================================================================
!     ****** LBE/fluxY_x
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       fluxY_x
!     DESCRIPTION
!       diagnostic subroutine:
!       Y flux along x line
!       compute sigma (see Artoli article) along 2 lines for lift 
!     INPUTS
!       itime --> timestep
!     OUTPUT
!       fluxY
!     TODO
!
!     NOTES
!       integer variables used: 
!       real variables used: 
!
!     *****
!=====================================================================
!
       subroutine fluxY_x(itime,istart,istop,jstart,jstop,fluxOut)
!
       use storage
       implicit none
!
       integer:: itime,i,j,ii,ll
       integer:: j0
       integer:: istart, istop       ! i1 < 12
       integer:: jstart, jstop       ! j1 < j2
       integer:: i1, i2       ! i1 < 12
       integer:: j1, j2       ! j1 < j2
       integer, dimension(1:2) :: face
!
       real(mykind) ::  cvsq
       real(mykind) ::  rho,xj,yj,rhoinv
       real(mykind) ::  sigma_xx,sigma_yy,sigma_xy
       real(mykind) ::  fluxOut
       real(mykind), dimension(1:19) ::  fe
       real(mykind), dimension(1:19) ::  fn
       real(mykind), dimension(1:2) ::  flux
       real(mykind), dimension(1:2) ::  norm
       real(mykind):: cte1
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
! some normalization
       norm(1)=1.0
       norm(2)=1.0
       flux(1)=0.0
       flux(2)=0.0
! 
! ------------------------- Y plane --------------------------------
       j1 = jstart
       j2 = jstop 
!
! ------------------------- X plane --------------------------------
       i1 = istart
       i2 = istop 
!
       face(1) = j1
       face(2) = j2
!
       do ii = 1,2
          j0 = face(ii)
          do i=i1,i2
!
! 1) compute rho,u,v,w
!
             rho = +a01(i,j0)+a03(i,j0)+a05(i,j0)+a08(i,j0) &
                   +a10(i,j0)+a12(i,j0)+a14(i,j0)+a17(i,j0) &
                   +a19(i,j0)+cte1
!
          rhoinv = 1.0/rho
!
             xj = +( a01(i,j0)+a03(i,j0)+a05(i,j0) & 
                    -a10(i,j0)-a12(i,j0)-a14(i,j0))*rhoinv
!
             yj = +( a03(i,j0)+a08(i,j0)+a12(i,j0) &
                    -a01(i,j0)-a10(i,j0)-a17(i,j0))*rhoinv
!
! 2) compute f_eq
!
             cvsq=xj*xj+yj*yj
!
             fe(01)=rho*p2*(1.0+ rf*( xj-yj)+qf*(3.0*(xj-yj)*(xj-yj)-cvsq))
             fe(02)=zero
             fe(03)=rho*p2*(1.0+ rf*( xj+yj)+qf*(3.0*(xj+yj)*(xj+yj)-cvsq))
             fe(04)=zero
             fe(05)=rho*p1*(1.0+ rf*( xj   )+qf*(3.0*(xj   )*(xj   )-cvsq))
             fe(06)=zero
             fe(07)=zero
             fe(08)=rho*p1*(1.0+ rf*(    yj)+qf*(3.0*(yj   )*(yj   )-cvsq))
             fe(09)=zero
             fe(10)=rho*p2*(1.0+ rf*(-xj-yj)+qf*(3.0*(xj+yj)*(xj+yj)-cvsq))
             fe(11)=zero
             fe(12)=rho*p2*(1.0+ rf*(-xj+yj)+qf*(3.0*(xj-yj)*(xj-yj)-cvsq))
             fe(13)=zero
             fe(14)=rho*p1*(1.0+ rf*(-xj   )+qf*(3.0*(xj   )*(xj   )-cvsq))
             fe(15)=zero
             fe(16)=zero
             fe(17)=rho*p1*(1.0+ rf*(   -yj)+qf*(3.0*(yj   )*(yj   )-cvsq))
             fe(18)=zero
!
! 3) compute f_neq
!
             fn(01) = a01(i,j0) - fe(01)
             fn(02) = zero
             fn(03) = a03(i,j0) - fe(03)
             fn(04) = zero
             fn(05) = a05(i,j0) - fe(05)
             fn(06) = zero
             fn(07) = zero
             fn(08) = a08(i,j0) - fe(08)
             fn(09) = zero
             fn(10) = a10(i,j0) - fe(10)
             fn(11) = zero
             fn(12) = a12(i,j0) - fe(12)
             fn(13) = zero
             fn(14) = a14(i,j0) - fe(14)
             fn(15) = zero
             fn(16) = zero
             fn(17) = a17(i,j0) - fe(17)
             fn(18) = zero
!
! 4) compute sigma
!
!!                sigma_xx = -rho/rf
!!                do ll = 1,18
!!                   sigma_xx = sigma_xx - (1-0.5*omega)*cx(ll)*cx(ll)*fn(ll)
!!                enddo
!
!!                sigma_xy = 0.0       
!!                do ll = 1,18
!!                   sigma_xy = sigma_xy - (1-0.5*omega)*cx(ll)*cy(ll)*fn(ll)
!!                enddo
!
             sigma_yy = -rho/rf 
             do ll = 1,18
                sigma_yy = sigma_yy - (1-0.5*omega)*cy(ll)*cy(ll)*fn(ll)
             enddo
!
             flux(ii) = flux(ii) + sigma_yy 
          enddo
       enddo
!
! check the flux along x is always positve
       fluxOut = -flux(1)*norm(1)+flux(2)*norm(2)
!
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. fluxY_x", itime
           write(6,*) "DEBUG0:", flux(1),flux(2)
           write(6,*) "DEBUG1:", norm(1),norm(2)
           write(6,*) "DEBUG2:", i1,i2
           write(6,*) "DEBUG3:", j1,j2
        endif
#endif
!
      return
      end subroutine fluxY_x
