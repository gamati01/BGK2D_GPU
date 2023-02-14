!=====================================================================
!     ****** LBE/drag3
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       computing drag in "easy way" 
!     INPUTS
!       itime
!       iunit
!     OUTPUT
!       drag on file iunit
!     TODO
!       
!     NOTES
!        the center and the radius of the cylinder are hardwritten
!
!     *****
!=====================================================================
!
        subroutine drag3(itime,iunit)
!
        use storage
        use timing
        implicit none
!
        integer:: i,j
        integer:: itime
        integer:: iunit
        integer:: istart,istop
        integer:: jstart,jstop
        integer:: icoord, jcoord, delta
!
        real(mykind) :: forceX, forceY
        real(mykind) :: force01, force03, force05, force08
        real(mykind) :: force10, force12, force14, force17
!
! Drag section (still to fix)
!
! cylinder center
        icoord = int(2.0*l/5.0)
        jcoord = int(m/2.0)
! 
! cylinder radius           
        if (m.gt.256) then
           radius =32
        else
           radius = ly/8
        endif
!
! border 
        delta = 3
!
! bounding box
        istart = icoord - radius - delta
        istop  = icoord + radius + delta
        jstart = jcoord - radius - delta
        jstop  = jcoord + radius + delta
!           
        forceX = zero
        do j = jstart, jstop
           do i = istart, istop
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
                 forceX = forceX + ( force01+force03+force05+force08  & 
                                    +force10+force12+force14+force17)
             endif 
           enddo
        enddo
!
        forceY = zero
        do j = jstart, jstop
           do i = istart, istop
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
                 forceY = forceY + ( force01+force03+force05+force08  &
                                    +force10+force12+force14+force17)
             endif
           enddo
        enddo

        write(iunit,*) itime, forceX, forceY
!
        call flush(iunit)            ! flush for drag
!
#ifdef DEBUG_2
        if(myrank == 0) then
              write(6,*) "DEBUG2: Exiting from sub. drag2", itime
              write(6,*) "DEBUG2", forceX, forceY
        endif
#endif
!
        end subroutine drag3
