!=====================================================================
!     ****** LBE/diagno
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       diagno
!     DESCRIPTION
!       diagnostic subroutine:
!       check of conserved quantities and mean value
!       write on unit 63 (diagno.dat)
!       write on unit 16 (bgk.log)
!     INPUTS
!       itime --> timestep
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,j
!       real variables used: rtot,xtot,stot
!                            xj, rho, rhoinv, rdv
!
!     *****
!=====================================================================
!
       subroutine diagno(itime)
!
       use storage
       implicit none
!
       integer:: itime,i,j
       integer:: ierr
!
#ifdef MIXEDPRECISION
# ifdef DOUBLE_P
       real(qp):: rtot,xtot,ytot,stot
       real(qp):: xj, yj, rho, rhoinv, rdv
       real(qp):: loctot(5), glotot(5)
       real(qp):: cte1
# else
       real(dp):: rtot,xtot,ytot,stot
       real(dp):: xj, yj, rho, rhoinv, rdv
       real(dp):: loctot(5), glotot(5)
       real(dp):: cte1
# endif
#else
       real(mykind):: rtot,xtot,ytot,stot
       real(mykind):: xj, yj, rho, rhoinv, rdv
       real(mykind):: loctot(5), glotot(5)
       real(mykind):: cte1
#endif
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
       rdv = uno/(real(l,mykind)*real(m,mykind))
!
       glotot(1) = 0.
       glotot(2) = 0.
       glotot(3) = 0.
       glotot(4) = 0.
       glotot(5) = 0.
!
       rtot = 0.
       xtot = 0.
       ytot = 0.
       stot = 0.
!
       do j=1,m
          do i=1,l
! standard form
!                   rho = (+a01(i,j)+a03(i,j)+a05(i,j) &
!                          +a08(i,j)+a10(i,j)+a12(i,j) &
!                          +a14(i,j)+a17(i,j)+a19(i,j)) + cte1
!
! better for half precision????
              rho =(((+a01(i,j)+a03(i,j)+a10(i,j)+a12(i,j)) + &
                     (+a05(i,j)+a08(i,j)+a14(i,j)+a17(i,j)))+ & 
                      a19(i,j)) + cte1
!
              rhoinv = uno/rho
!
              xj = ((a03(i,j)-a12(i,j))+(a01(i,j)-a10(i,j)) & 
                   +(a05(i,j)-a14(i,j)))*rhoinv
              yj = ((a03(i,j)-a01(i,j))+(a12(i,j)-a10(i,j)) & 
                   +(a08(i,j)-a17(i,j)))*rhoinv
!
              rtot = rtot+rho
              xtot = xtot+xj
              ytot = ytot+yj
              stot = stot+(xj*xj+yj*yj)
!
          enddo
       enddo
!
       rtot = (rtot/float(l))/float(m)
       xtot = (xtot/float(l))/float(m)
       ytot = (ytot/float(l))/float(m)
       stot = (stot/float(l))/float(m)

       if(myrank.eq.0) then
          write(16,1001) itime
          write(16,1002) rtot
          write(16,1003) xtot,ytot,stot
          write(63,1004) itime, xtot, ytot, rtot, stot
          flush(16)
          flush(63)
       endif
!
#ifdef DEBUG_1
       if (myrank == 0) then
          write(6,*) "DEBUG1: Exiting from sub. diagno"
       endif
#endif
!
! formats...
!
1001   format(" Timestep ",i8)
1002   format("       mean rho ",1(e14.6,1x))
1003   format("       mean vel ",3(e14.6,1x))
1004   format(i8,4(e14.6,1x))
!
       return
       end subroutine diagno
