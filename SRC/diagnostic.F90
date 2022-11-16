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
        integer:: kstart,kstop
!
        real(mykind) :: fluxX, fluxY, fluxZ
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
           call probe(itime,32,32)
!
           call varm(itime)
           call prof_i(itime,m/2)
           call prof_j(itime,l/2)
!
! global probe: 
! x ---> LX = 20  x_p = 8
! y ---> LX = 16  x_p = 9
            call probe_global(itime,(8*lx/20),(9*ly/16))
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
        endif
!
        if (mod(itime,itsave).eq.0) then
!
           call save(itime)
!
        endif
!
#ifdef DEBUG_2
        if(myrank == 0) then
           write(6,*) "DEBUG2: Exiting from sub. diagnostic"
        endif
#endif
!
        return
        end subroutine diagnostic
