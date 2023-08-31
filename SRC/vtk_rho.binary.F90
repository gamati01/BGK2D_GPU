!=======================================================================
!     ****** LBE/vtk_rho_binary
!
!     COPYRIGHT
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       vtk_rho_bin
!     DESCRIPTION
!       Graphic subroutine:
!       write binary output for VTK with pressure field
!       write on unit 5? (vtk_rho.yyyy.xxxxxxx.dat, 
!                         where yyyy is the task id number,
!                         where xxxxxxx is the timestep)
!       the file is closed at the end of the subroutine
!     INPUTS
!       itime   ---> timestep
!     OUTPUT
!       none
!     TODO
!       
!     NOTES
!       character used:  file_name (25)
!       integer variables used: itime
!       max time allowed  99'999'999
!
!     BUGS
!
!     *****
!=======================================================================
!
        subroutine vtk_rho_bin(itime)
!
        use storage
        implicit none
!
        integer i,j, k,itime
!	
        character*25 file_name
!
        real(sp) :: u,v,w,den
        real(sp) :: cte1
!
        file_name = 'tec_rho.xxxxxxxx.vtk'
!
#ifdef SERIAL
        myrank = 0
#endif
!
#ifdef NOSHIFT
       cte1 = zero
#else
       cte1 = uno
#endif
!
        write(file_name(9:16),4000) itime
!
! first write legal header (ASCII)
        open(51,file=file_name,status='unknown')
!
!
        write(51,'(A26)')'# vtk DataFile Version 2.0'
        write(51,'(A5)') 'Campo'
        write(51,'(A6)') 'BINARY'
        write(51,'(A25)')'DATASET STRUCTURED_POINTS'
        write(51,'(A11,I10,A1,I10,A1,I10)') 'DIMENSIONS ',l,' ',m
        write(51,'(A7,I10,A1,I10,A1,I10)')  'ORIGIN ',offset(1)+1,' ' &
                                                     ,offset(2)+1
        write(51,'(A8,I10,A1,I10,A1,I10)') 'SPACING ',1,' ',1
        write(51,'(A10,I10)')'POINT_DATA ',l*m
        write(51,'(A23)')'SCALARS rho float'
        write(51,'(A20)')'LOOKUP_TABLE default'
        close(51)
!
! then write output (binary)
        open(51,file=file_name,status='old', position='append', &
                form='unformatted',access='STREAM',CONVERT="BIG_ENDIAN")
!
        do j = 1,m
           do i = 1,l

              den =( a01(i,j)+a03(i,j)+a05(i,j)+a08(i,j) & 
                   +a10(i,j)+a12(i,j)+a14(i,j)+a17(i,j)+a19(i,j)) + cte1
!
              write(51) den
           end do
        end do
!
        close(51)
        write(16,*) "rho (vtk,binary) done"
        write(6,*)  "rho (vtk,binary) done"
!
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. vtk_rho_bin"
        endif
#endif
!
4000    format(i8.8)
!
       end subroutine vtk_rho_bin

