!====================================================================
!     ****** LBE/setup
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       setup
!     DESCRIPTION
!       Simple wrapper for different initializations routines..
!     INPUTS
!       
!     OUTPUT
!       
!     TODO
!       
!     NOTES
!
!     *****
!=====================================================================
!
      subroutine setup(itfin,ivtim,isignal,itsave,icheck,itrestart, & 
                       init_v)
!
      use storage
      use timing
! 
      implicit none
!
      INTEGER:: itfin, itstart, ivtim
      INTEGER:: itime, itsave, icheck, itrestart, init_v
      INTEGER:: isignal
      INTEGER:: ierr
      INTEGER:: provided
      INTEGER:: idev
      character*19 file_name2
      character*19 file_name3
      character*23 file_name4
      character*15 file_name5
      character*19 file_name6
      character*21 file_name7
      character*21 file_name8   ! draglift
!
! set values for serial version...
      myrank = 0
      nprocs = 0
      mpicoords(1) = 0
      mpicoords(2) = 0
      mpicoords(3) = 0
!
      call system("date       > time.log")
!
! probe
      file_name3 = 'probe.xxxx.dat'
      write(file_name3(7:10),4000) myrank
!
! probe_g
      file_name7 = 'probe_g.xxxx.dat'
      write(file_name7(9:12),4000) myrank
!
! draglift
      file_name8 = 'drag.lift.dat'
!
! lift
!
! prof_j
      file_name6 = 'prof_j.xxxx.dat'
      write(file_name6(8:11),4000) myrank
!
! prof_i
      file_name2 = 'prof_i.xxxx.dat'
      write(file_name2(8:11),4000) myrank
!
! task
      file_name5 = 'task.xxxxxx.log'
      write(file_name5(6:11),3100) myrank
!
      open(16,file='bgk.log',  status='unknown')
!        
      open(61,file=file_name2, status='unknown')        ! prof_i
      open(64,file=file_name6, status='unknown')        ! prof_j
      open(66,file=file_name8, status='unknown')        ! drag
      open(67,file=file_name7, status='unknown')        ! probe_gb
      open(68,file=file_name3, status='unknown')        ! probe
      open(38,file=file_name5, status='unknown')        ! task.XXXXXX.log
!
      open(63,file='diagno.dat',status='unknown')       ! diagno.dat
!
      if(myrank==0) then 
         write(6,*) "================================"
         write(6,*) " Uniform LBE...          "
! 
! implementation
#ifdef FUSED
         write(6,*) " Implementation: FUSED   "
#else
         write(6,*) " Implementation: ORIGINAL"
#endif
! 
! parallelization
#ifdef SERIAL
         write(6,*) " Serial"
#elif OFFLOAD
         write(6,*) " Parallelization: OpenMP offload"
#elif OPENACC 
         write(6,*) " Parallelization: OpenACC"
#else  
         write(6,*) " Parallization: DO concurrent   "
#endif
! 
! test case
#ifdef PERIODIC
         write(6,*) " Test Case: Taylor-Green Vortices"
#else  
         write(6,*) " Test Case: Lid-Driven Cavity "
#endif
!
         write(6,*) "================================"
      endif
!
! check, read input data and data allocation
!
      call check_case
!
      call input(itfin,ivtim,isignal,itsave,icheck, & 
                   itrestart,init_v)
!
      file_name4 = 'u_med.xxx.xxx.xxx.dat'
      write(file_name4(7:9),4100) mpicoords(1)
      write(file_name4(11:13),4100) mpicoords(2)
      write(file_name4(15:17),4100) mpicoords(3)

      open(62,file=file_name4, status='unknown')
!
      current = 0
      next = 1
!      
      call alloca()

#ifdef DEBUG_1
      if(myrank == 0) then
         write(6,*) "DEBUG1: Exiting from sub. setup"
      endif
#endif

# ifdef MEM_CHECK
      if(myrank == 0) then
         mem_stop = get_mem();
         write(6,*) "MEM_CHECK: after sub. setup mem =", mem_stop
      endif
# endif
!
! format
4000  format(i4.4)
4100  format(i3.3)
3100  format(i6.6)
!
      end subroutine setup
