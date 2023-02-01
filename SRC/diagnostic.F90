!=====================================================================
!     ****** LBE/diagnostic
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       bcond
!     DESCRIPTION
!       Simple wrapper for different diagnostic routines..
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
!
        subroutine diagnostic(itime,ivtim,icheck,itsave)
!
        use storage
        use timing
        implicit none
!
        integer:: itime,ivtim,icheck,itsave
        integer:: istart,istop
        integer:: jstart,jstop
        integer:: icoord, jcoord, delta
!
        real(mykind) :: fluxX, fluxY
!
! get macroscopic values
!
        if (mod(itime,ivtim).eq.0) then
!
!
! start timing...
           call SYSTEM_CLOCK(countA0, count_rate, count_max)
!           
           call time(tcountA0)
!
#ifdef OFFLOAD
!$omp target update from(a01,a03,a05,a08,a10,a12,a14,a17,a19)
#endif
           call vtk_xy_bin(itime)
           call vtk_om_bin(itime)
!
! stop timing
           call time(tcountA1)
           call SYSTEM_CLOCK(countA1, count_rate, count_max)
           time_dg = time_dg + real(countA1-countA0)/(count_rate)
           time_dg1 = time_dg1 + (tcountA1-tcountA0)
!
        end if
!
        if (mod(itime,icheck).eq.0) then
!
! start timing...
           call SYSTEM_CLOCK(countA0, count_rate, count_max)
!           
           call time(tcountA0)
!
#ifdef OFFLOAD
!$omp target update from(a01,a03,a05,a08,a10,a12,a14,a17,a19)
#endif
           call diagno(itime)
           call probe(itime,l,m/2)
!
           call varm(itime)
           call prof_i(itime,m/2)
           call prof_j(itime,l/2)
!
! global probe:  Set value for VonKarman streets check with OF
           call probe_global(itime,(32*lx/50),(ly/2))

#ifdef DRAG
           call drag2(itime,333)
!
! Drag section (still to fix)
           call drag(itime, 5,666)
           call drag(itime,10,667)
           call drag(itime,15,668)
           call drag(itime,20,669)
           call drag(itime,25,670)
           call drag(itime,30,671)
           call drag(itime,40,672)
           call drag(itime,50,673)
           call drag(itime,60,674)
           call drag(itime,70,675)
           call drag(itime,80,676)
!
! Lift section (still to fix)           
           call lift(itime, 5,766)
           call lift(itime,10,767)
           call lift(itime,15,768)
           call lift(itime,20,769)
           call lift(itime,25,770)
           call lift(itime,30,771)
           call lift(itime,40,772)
           call lift(itime,50,773)
           call lift(itime,60,774)
           call lift(itime,70,775)
           call lift(itime,80,776)
#endif
!
!           call flush(61)            ! flush prof_i.dat
!           call flush(68)            ! flush probe.dat
!           call flush(88)            ! flush fort.88 (convergence)
!
! stop timing
           call time(tcountA1)
           call SYSTEM_CLOCK(countA1, count_rate, count_max)
           time_dg = time_dg + real(countA1-countA0)/(count_rate)
           time_dg1 = time_dg1 + (tcountA1-tcountA0)
!
        endif   ! closing if with icheck 
!
        if (mod(itime,itsave).eq.0) then
!
           call save(itime)
!
        endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           if (mod(itime,icheck).eq.0) then
!              write(6,*) "DEBUG2: Exiting from sub. diagnostic", itime
!              write(6,*) "DEBUG2", int(2.0*l/5.0),int(m/2.0)
!              write(6,*) "DEBUG2", icoord, jcoord
!              write(6,*) "DEBUG2", radius, delta
!              write(6,*) "DEBUG2", istart, istop 
!              write(6,*) "DEBUG2", jstart, jstop 
!              write(6,*) "DEBUG2", fluxX, fluxY
           else
              write(6,*) "DEBUG2: Exiting from sub. diagnostic", itime
           endif
        endif
#endif
!
        return
        end subroutine diagnostic
