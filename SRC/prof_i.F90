!=======================================================================
!     ****** LBE/prof_i
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       prof_i
!     DESCRIPTION
!       Diagnostic subroutine:
!       istantaneous profile along x-direction (j, k fixed)
!       write on unit 61 (prof_i.dat)
!     INPUTS
!       itime   -->  timestep
!       icoord  -->  x coordinate
!       jcoord  -->  y coordinate
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
        subroutine prof_i(itime,jcoord)
!
        use storage
        implicit none
!
        integer:: itime,i
        integer:: jcoord
!
        real(mykind) :: u(1:l),w(1:l),v(1:l)      ! istantaneous velocity fields
        real(mykind) :: den(1:l)                  ! istantaneous density field
        real(mykind) :: cte1
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
        do i = 1,l         ! density
           den(i) = (+a01(i,jcoord)+a03(i,jcoord)+a05(i,jcoord) &
                     +a08(i,jcoord)+a10(i,jcoord)+a12(i,jcoord) &
                     +a14(i,jcoord)+a17(i,jcoord)+a19(i,jcoord)) + cte1
        enddo
 
        do i = 1,l         ! streamwise velocity
           u(i) = +( a01(i,jcoord)+a03(i,jcoord)+a05(i,jcoord) &
                    -a10(i,jcoord)-a12(i,jcoord)-a14(i,jcoord)) / den(i)
        end do

        do i = 1,l         ! spanwise velocity
           w(i) = +( a03(i,jcoord)+a08(i,jcoord)+a12(i,jcoord) &
                    -a01(i,jcoord)-a10(i,jcoord)-a17(i,jcoord)) / den(i)
        end do
!
        write(61,1005) itime
!
        do i=1,l
           write(61,1002) i+(offset(1)), u(i), w(i), den(i)
        end do
        write(61,'(a1)') 
        write(61,'(a1)') 
!
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. prof_i"
        endif
#endif
!
!	format
1002    format(i5,3(e14.6,1x))
1005    format("# t=",i7)
1111    format("#pause")
        return
        end subroutine prof_i