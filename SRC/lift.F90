!=====================================================================
!     ****** LBE/lift
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       computing lift according Gauss Theorem
!     INPUTS
!       itime
!       delta
!       iunit
!     OUTPUT
!       lift
!     TODO
!       
!     NOTES
!        the center and the radius of the cylinder are hardwritten
!
!     *****
!=====================================================================
!
        subroutine lift(itime,delta,iunit)
!
        use storage
        use timing
        implicit none
!
        integer:: itime
        integer:: iunit
        integer:: istart,istop
        integer:: jstart,jstop
        integer:: icoord,jcoord,delta
!
        real(mykind) :: liftX, liftY
!
! lift section (still to fix)
!
! cylinder center
        icoord = int(2.0*l/5.0)
        jcoord = int(m/2.0)
! 
! cylinder radius           
        if (m.gt.256) then
           radius = 32
        else
           radius = ly/8
        endif
!
! Gauss Th bounding box
        istart = icoord - radius - delta
        istop  = icoord + radius + delta
        jstart = jcoord - radius - delta
        jstop  = jcoord + radius + delta
!           
        liftX = zero
        liftY = zero
!           
! compute lift
        call fluxY_y(itime,istart,istop,jstart,jstop,liftX)
        call fluxY_x(itime,istart,istop,jstart,jstop,liftY)

        write(iunit,*) itime, liftX, liftY
!
        call flush(iunit)            ! flush for drag
!
! stop timing
        call time(tcountA1)
        call SYSTEM_CLOCK(countA1, count_rate, count_max)
        time_dg = time_dg + real(countA1-countA0)/(count_rate)
        time_dg1 = time_dg1 + (tcountA1-tcountA0)
!
!
#ifdef DEBUG_2
        if(myrank == 0) then
              write(6,*) "DEBUG2: Exiting from sub. lift", itime
!              write(6,*) "DEBUG2", int(2.0*l/5.0),int(m/2.0)
!              write(6,*) "DEBUG2", icoord, jcoord
!              write(6,*) "DEBUG2", radius, delta
!              write(6,*) "DEBUG2", istart, istop 
!              write(6,*) "DEBUG2", jstart, jstop 
!              write(6,*) "DEBUG2", liftX, liftY
        endif
#endif
!
        return
        end subroutine lift
