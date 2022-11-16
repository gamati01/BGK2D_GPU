!====================================================
!     ****** LBE/movef
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       movef
!     DESCRIPTION
!       "In place" streaming of populations
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
subroutine movef
!
        use storage
!
        implicit none
!
        integer i,j,k
!
!------------------------------------------------------
! Best (?) decompsition for BW
!------------------------------------------------------
#ifdef OFFLOAD
!!$OMP target data map(to:  a01,a03,a05,a08,a10,a12,a14,a17)  &
!!$OMP&            map(from:b01,b03,b05,b08,b10,b12,b14,b17)
!$OMP target teams distribute parallel do simd collapse(2)
        do j=1,m
        do i=1,l
#else
        do concurrent (j=1:m, i=1:l)
#endif
           b01(i,j) = a01(i-1,j+1)
           b03(i,j) = a03(i-1,j-1)
           b05(i,j) = a05(i-1,j  )
           b08(i,j) = a08(i  ,j-1)
           b10(i,j) = a10(i+1,j+1)
           b12(i,j) = a12(i+1,j-1)
           b14(i,j) = a14(i+1,j  )
           b17(i,j) = a17(i  ,j+1)
        enddo
#ifdef OFFLOAD
        enddo
!$OMP end target teams distribute parallel do simd
!!$omp end target data
#endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. move"
        endif
#endif
!
        return
        end subroutine movef
