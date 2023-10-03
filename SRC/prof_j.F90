!=======================================================================
!     ****** LBE/prof_j
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       prof_j
!     DESCRIPTION
!       Diagnostic subroutine:
!       istantaneous profile along y-direction (i, k fixed)
!       write on unit 64 (prof_j.dat)
!     INPUTS
!       itime   -->  timestep
!       icoord  -->  x coordinate
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!       integer variables used: 
!       real variables used: 
!                            
!
!     *****
!=======================================================================
!
        subroutine prof_j(itime,icoord)
!
        use storage
        implicit none
!
        integer:: itime,j
        integer:: icoord
!
        real(mykind) :: u(1:m),w(1:m),v(1:m)      ! istantaneous velocity fields
        real(mykind) :: den(1:m)           ! istantaneous density field
        real(mykind) :: cte1
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
!        do j = 1,m         ! density
        do concurrent (j=1:m)

           den(j) = ((+a01(icoord,j)+a03(icoord,j) & 
                      +a05(icoord,j)+a08(icoord,j) &
                      +a10(icoord,j)+a12(icoord,j) & 
                      +a14(icoord,j)+a17(icoord,j))&
                                    +a19(icoord,j)) + cte1
        enddo
! 
!        do j = 1,m         ! streamwise velocity
        do concurrent (j=1:m)
           u(j) =  ( (a01(icoord,j)-a10(icoord,j)) &
                    +(a03(icoord,j)-a12(icoord,j)) &
                    +(a05(icoord,j)-a14(icoord,j)))/den(j)
        end do
!
!        do j = 1,m         ! spanwise velocity
        do concurrent (j=1:m)
           w(j) =  ( (a03(icoord,j)-a01(icoord,j)) &
                    +(a08(icoord,j)-a17(icoord,j)) &
                    +(a12(icoord,j)-a10(icoord,j)))/den(j)
        end do
!
        write(64,1005) itime
!
        do j=1,m
           write(64,1002) (j-0.5), u(j),w(j),den(j)
        end do
        write(64,'(a1)') 
        write(64,'(a1)') 
!
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. prof_j"
        endif
#endif
!
!	format
1002    format(4(e14.6,1x))
1005    format("# t=",i7)
!       
        end subroutine prof_j
