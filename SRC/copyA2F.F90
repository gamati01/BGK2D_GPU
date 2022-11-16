!====================================================
!     ****** LBE/copyA2F
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       movef
!     DESCRIPTION
!       copy data from A to F (FlipFlop) version (utility)
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,j
!
!     *****
!====================================================
!
subroutine copyA2F
!
        use storage
!
        implicit none
!
        integer i,j
!
#ifdef FLIPFLOP
        do j = 0, m+1
           do i = 0, l+1
              f01(i,j,current) = a01(i,j)
              f03(i,j,current) = a03(i,j)
              f05(i,j,current) = a05(i,j)
              f08(i,j,current) = a08(i,j)
              f10(i,j,current) = a10(i,j)
              f12(i,j,current) = a12(i,j)
              f14(i,j,current) = a14(i,j)
              f17(i,j,current) = a17(i,j)
              f19(i,j,current) = a19(i,j)
           enddo
        enddo

        write(6,*) " CHECK: ",a01(l/2,m/2),   a03(l/2,m/2),   a19(l/2,m/2)
        write(6,*) " CHECK: ",f01(l/2,m/2,0), f03(l/2,m/2,0), f19(l/2,m/2,0)
        write(6,*) " CHECK: ",f01(l/2,m/2,1), f03(l/2,m/2,1), f19(l/2,m/2,1)
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. copaA2F", current
        endif
#endif
!
        return
        end subroutine copyA2F
