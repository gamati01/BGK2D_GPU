!====================================================
!     ****** LBE/copyF2A
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       movef
!     DESCRIPTION
!       copy data from F (FlipFlop) to A (original) (utility)
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,k
!
!     *****
!====================================================
!
subroutine copyF2A
!
        use storage
!
        implicit none
!
        integer i,j,k
!
#ifdef FLIPFLOP
!$acc update host(f01,f03,f05,f08,f10,f12,f14,f17,f19)
            do j = 0, m+1
               do i = 0, l+1
                  a01(i,j) = f01(i,j,current)
                  a03(i,j) = f03(i,j,current)
                  a05(i,j) = f05(i,j,current)
                  a08(i,j) = f08(i,j,current)
                  a10(i,j) = f10(i,j,current)
                  a12(i,j) = f12(i,j,current)
                  a14(i,j) = f14(i,j,current)
                  a17(i,j) = f17(i,j,current)
                  a19(i,j) = f19(i,j,current)
               enddo
            enddo
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. copaFA2", current
        endif
#endif
!
        return
        end subroutine copyF2A
