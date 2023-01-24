!=====================================================================
!     ****** LBE/fluxY_y
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       fluxY_yz
!     DESCRIPTION
!       diagnostic subroutine:
!       Y flux along y line
!       compute sigma (see Artoli article) along 1 planes for drag 
!     INPUTS
!       itime --> timestep
!     OUTPUT
!       fluxOut
!     TODO
!
!     NOTES
!       integer variables used: 
!       real variables used: 
!
!     *****
!=====================================================================
!
       subroutine fluxY_y(itime,istart,istop,jstart,jstop,fluxOut)
!
       use storage
       implicit none
!
       integer:: itime,i,j,ii,ll
       integer:: i0
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
! ------------------------- X plane --------------------------------
       i1 = istart
       i2 = istop 
!
! ------------------------- Y plane --------------------------------
       j1 = jstart
       j2 = jstop 
!
       face(1) = i1
       face(2) = i2
!
       do ii  = 1,2
          i0 =face(ii)
          do j=j1,j2
!
! 1) compute rho,u,v,w
!
             rho = +a01(i0,j)+a03(i0,j)+a05(i0,j)+a08(i0,j) &
                   +a10(i0,j)+a12(i0,j)+a14(i0,j)+a17(i0,j) &
                   +a19(i0,j)+cte1
!
             rhoinv = 1.0/rho
!
             xj = +( a01(i0,j)+a03(i0,j)+a05(i0,j) & 
                    -a10(i0,j)-a12(i0,j)-a14(i0,j))*rhoinv
!
             yj = +( a03(i0,j)+a08(i0,j)+a12(i0,j) &
                    -a01(i0,j)-a10(i0,j)-a17(i0,j))*rhoinv
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
             fn(01) = a01(i0,j) - fe(01)
             fn(02) = zero
             fn(03) = a03(i0,j) - fe(03)
             fn(04) = zero
             fn(05) = a05(i0,j) - fe(05)
             fn(06) = zero
             fn(07) = zero
             fn(08) = a08(i0,j) - fe(08)
             fn(09) = zero
             fn(10) = a10(i0,j) - fe(10)
             fn(11) = zero
             fn(12) = a12(i0,j) - fe(12)
             fn(13) = zero
             fn(14) = a14(i0,j) - fe(14)
             fn(15) = zero
             fn(16) = zero
             fn(17) = a17(i0,j) - fe(17)
             fn(18) = zero
!
! 4) compute sigma
!
!!                sigma_xx = -rho/rf
!!                do ll = 1,18
!!                   sigma_xx = sigma_xx - (1-0.5*omega)*cx(ll)*cx(ll)*fn(ll)
!!                enddo
!
             sigma_xy = 0.0       
             do ll = 1,18
                sigma_xy = sigma_xy - (1-0.5*omega)*cx(ll)*cy(ll)*fn(ll)
!                write(6,*) "DEBUG+", ll, fn(ll)
             enddo
!
!!                sigma_yy = -rho/rf 
!!                do ll = 1,18
!!                   sigma_yy = sigma_yy - (1-0.5*omega)*cy(ll)*cy(ll)*fn(ll)
!!                enddo
!
!                flux(ii) = flux(ii)+(sigma_xx + sigma_xy + sigma_xz)
! ask why!!!!
             flux(ii) = flux(ii)+sigma_xy 
          enddo
       enddo
!
       fluxOut = +flux(1)*norm(1)-flux(2)*norm(2)
!
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. fluxY_y", itime
           write(6,*) "DEBUG0:", flux(1),flux(2)
           write(6,*) "DEBUG1:", norm(1),norm(2)
           write(6,*) "DEBUG2:", i1,i2
           write(6,*) "DEBUG3:", j1,j2
        endif
#endif

      return
      end subroutine fluxY_y
