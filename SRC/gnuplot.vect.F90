!=======================================================================
!     ****** LBE/gnu_vect
!
!     COPYRIGHT
!       (c) 2009 by CASPUR/G.Amati
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       vtk_ff_bin
!     DESCRIPTION
!       Graphic subroutine:
!       write 2D acii output for gnuplot
!       write on unit 52 (gnu.xxxxxxx.dat) where 
!                                  xxxxxxx is the timestep
!       the file is closed at the end of the subroutine
!     INPUTS
!       itime   ---> timestep
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!       character used:  file_name (19)
!       integer variables used: 
!       max time allowed  99'999'999
!       single precision only, to saving space..
!
!     *****
!=======================================================================
!
        subroutine gnu_vect(itime)
!
        use storage
        implicit none
!
        integer :: i,j,itime
!	
        character(len=24) :: file_name
!
        real(sp) :: cte1
        real(sp) :: u,v,w,den
        real(sp) :: forceX, forceY
        real(sp) :: force01,force03,force05,force08
        real(sp) :: force10,force12,force14,force17
        real(sp), parameter :: zerol=0.0
!
        file_name = 'gnu.xxxxxxxx.vtk'
!
        myrank = 0
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
        write(file_name(5:12),4000) itime
!
! first write legal header (ASCII)
        open(52,file=file_name,status='unknown')
!
        do j = jmin-2,jmax+2
           do i = imin-2,imax+2

              forceX=0
              if(obs(i,j)==0) then
                 force01 = 2.0*cx(01)*a01(i,j)*obs(i+icx(01),j+icy(01))
                 force03 = 2.0*cx(03)*a03(i,j)*obs(i+icx(03),j+icy(03))
                 force05 = 2.0*cx(05)*a05(i,j)*obs(i+icx(05),j+icy(05))
                 force08 = 2.0*cx(08)*a08(i,j)*obs(i+icx(08),j+icy(08))
                 force10 = 2.0*cx(10)*a10(i,j)*obs(i+icx(10),j+icy(10))
                 force12 = 2.0*cx(12)*a12(i,j)*obs(i+icx(12),j+icy(12))
                 force14 = 2.0*cx(14)*a14(i,j)*obs(i+icx(14),j+icy(14))
                 force17 = 2.0*cx(17)*a17(i,j)*obs(i+icx(17),j+icy(17))
!
                 forceX = ( force01+force03+force05+force08  &
                           +force10+force12+force14+force17)
              endif
!
              forceY=0
              if(obs(i,j)==0) then
                 force01 = 2.0*cy(01)*a01(i,j)*obs(i+icx(01),j+icy(01))
                 force03 = 2.0*cy(03)*a03(i,j)*obs(i+icx(03),j+icy(03))
                 force05 = 2.0*cy(05)*a05(i,j)*obs(i+icx(05),j+icy(05))
                 force08 = 2.0*cy(08)*a08(i,j)*obs(i+icx(08),j+icy(08))
                 force10 = 2.0*cy(10)*a10(i,j)*obs(i+icx(10),j+icy(10))
                 force12 = 2.0*cy(12)*a12(i,j)*obs(i+icx(12),j+icy(12))
                 force14 = 2.0*cy(14)*a14(i,j)*obs(i+icx(14),j+icy(14))
                 force17 = 2.0*cy(17)*a17(i,j)*obs(i+icx(17),j+icy(17))
!
                 forceY = ( force01+force03+force05+force08  &
                           +force10+force12+force14+force17)
              endif
!
              write(52,*) i, j, forceX, forceY, obs(i,j)
           end do
        end do
        close(52)
!
        write(16,*) "I/O: force (gnuplot,ASCII) done"
        write(6,*)  "I/O: force (gnuplot,ASCII) done"
!
!#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. gnu_vect"
        endif
!#endif
!
4000    format(i8.8)
!
       end subroutine gnu_vect
