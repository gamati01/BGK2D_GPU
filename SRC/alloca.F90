!=====================================================================
!     ****** LBE/alloca
!
!     COPYRIGHT
!       (c) 2021 by CINECA/G.Amati
!     NAME
!       alloca
!     DESCRIPTION
!
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!
!     *****
!=====================================================================
subroutine alloca()
      use storage; 
      use timing

#ifdef CUDAFOR
      use cudafor
#endif
! 
      implicit none
!
!     define unit vector 
!
      cx(  1    ) =  1
      cx(  2    ) =  1
      cx(  3    ) =  1
      cx(  4    ) =  1
      cx(  5    ) =  1
      cx(  6    ) =  0
      cx(  7    ) =  0
      cx(  8    ) =  0
      cx(  9    ) =  0
      cx( 10    ) = -1
      cx( 11    ) = -1
      cx( 12    ) = -1
      cx( 13    ) = -1
      cx( 14    ) = -1
      cx( 15    ) =  0
      cx( 16    ) =  0
      cx( 17    ) =  0
      cx( 18    ) =  0
      cx( 19    ) =  0
!
      cy(  1    ) = -1
      cy(  2    ) =  0
      cy(  3    ) =  1
      cy(  4    ) =  0
      cy(  5    ) =  0
      cy(  6    ) =  0
      cy(  7    ) =  1
      cy(  8    ) =  1
      cy(  9    ) =  1
      cy( 10    ) = -1
      cy( 11    ) =  0
      cy( 12    ) =  1
      cy( 13    ) =  0
      cy( 14    ) =  0
      cy( 15    ) =  0
      cy( 16    ) = -1
      cy( 17    ) = -1
      cy( 18    ) = -1
      cy( 19    ) =  0
!
#ifdef NOMANAGED
!acc data allocate(obs,a01,a02,a03,a04,a05,a06,a07,a08,a09,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,b01,b02,b03,b04,b05,b06,b07,b08,b09,b10,b11,b12,b13,b14,b15,b16,b17,b18,b19)
#endif
!
      allocate(obs(1:l,1:m))
      obs = 0
!
#ifdef FLIPFLOP
      allocate(f01(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f03(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f05(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f08(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f10(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f12(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f14(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f17(0:l+1+ipad,0:m+1+jpad,0:1))
      allocate(f19(0:l+1+ipad,0:m+1+jpad,0:1))
#endif
!
      allocate(a01(0:l+1+ipad,0:m+1+jpad))
      allocate(a03(0:l+1+ipad,0:m+1+jpad))
      allocate(a05(0:l+1+ipad,0:m+1+jpad))
      allocate(a08(0:l+1+ipad,0:m+1+jpad))
      allocate(a10(0:l+1+ipad,0:m+1+jpad))
      allocate(a12(0:l+1+ipad,0:m+1+jpad))
      allocate(a14(0:l+1+ipad,0:m+1+jpad))
      allocate(a17(0:l+1+ipad,0:m+1+jpad))
      allocate(a19(0:l+1+ipad,0:m+1+jpad))
!
      allocate(b01(0:l+1+ipad,0:m+1+jpad))
      allocate(b03(0:l+1+ipad,0:m+1+jpad))
      allocate(b05(0:l+1+ipad,0:m+1+jpad))
      allocate(b08(0:l+1+ipad,0:m+1+jpad))
      allocate(b10(0:l+1+ipad,0:m+1+jpad))
      allocate(b12(0:l+1+ipad,0:m+1+jpad))
      allocate(b14(0:l+1+ipad,0:m+1+jpad))
      allocate(b17(0:l+1+ipad,0:m+1+jpad))
      allocate(b19(0:l+1+ipad,0:m+1+jpad))
!
#ifdef FLIPFLOP
      f01 = huge(mykind)
      f03 = huge(mykind)
      f05 = huge(mykind)
      f08 = huge(mykind)
      f10 = huge(mykind)
      f12 = huge(mykind)
      f14 = huge(mykind)
      f17 = huge(mykind)
      f19 = huge(mykind)
#endif
!
      a01 = huge(mykind)
      a03 = huge(mykind)
      a05 = huge(mykind)
      a08 = huge(mykind)
      a10 = huge(mykind)
      a12 = huge(mykind)
      a14 = huge(mykind)
      a17 = huge(mykind)
      a19 = huge(mykind)
!      
      b01 = huge(mykind)
      b03 = huge(mykind)
      b05 = huge(mykind)
      b08 = huge(mykind)
      b10 = huge(mykind)
      b12 = huge(mykind)
      b14 = huge(mykind)
      b17 = huge(mykind)
      b19 = huge(mykind)
!
#ifdef FUSED
      c01 => null()
      c03 => null()
      c05 => null()
      c08 => null()
      c10 => null()
      c12 => null()
      c14 => null()
      c17 => null()
      c19 => null()
#endif

#ifdef PGI
! do nothing
#else
      mem_start = get_mem()
#endif

#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. alloca"
        endif
#endif
!
# ifdef MEM_CHECK
        if(myrank == 0) then
           mem_stop = get_mem();
           write(6,*) "MEM_CHECK: after sub. alloca mem =", mem_stop
        endif
# endif

end subroutine alloca

