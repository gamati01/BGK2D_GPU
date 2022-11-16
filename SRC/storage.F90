! =====================================================================
!     ****** LBE/storage.f90
!
!     COPYRIGHT
!       (c) 2000-2008 by CASPUR/G.Amati
!     NAME
!       storage
!     DESCRIPTION
!       module for storage
!     INPUTS
!       none
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!
!       integer variables defined:  l,n,l1,n1
!       real variables defined: lx, ly, dt, p0, p1, p2, rf, qf
!                               svisc, u0, omega,fgrad
!
!     *****
! =====================================================================
!
        module storage
!
        use real_kinds
!
        integer:: lx, ly              ! global size        (MPI stuff)
        integer:: proc_x, proc_y  ! task decomposition (MPI stuff)
!
        integer:: l, m                    ! local (task) size
        integer:: l1, m1
        integer:: left(2), right(2)
        integer:: front(2), rear(2)
!
        integer, parameter::  mpid=2      ! mpi dimension
        integer, parameter::  zeroi=0      ! hint to help compiler...
        integer, parameter::  unoi=1       ! hint to help compiler...
!
        integer, parameter::  border=32    ! hint to help compiler...
!
! PGI doesn't support quad precision
#if defined PGI || defined ARM
        real(dp), parameter::  zero_qp=0.d0     ! hint to help compiler...
        real(dp), parameter::  uno_qp=1.d0      ! hint to help compiler...
        real(dp), parameter::  tre_qp=3.d0      ! hint to help compiler...
!
        real(dp), parameter :: rf_qp = 3.d0
        real(dp), parameter :: qf_qp = 1.5d0
!
! 4/9
        real(dp), parameter :: p0_qp = 4.d0/9.d0
! 1/9
        real(dp), parameter :: p1_qp = 1.d0/9.d0
! 1/36
        real(dp), parameter :: p2_qp = uno_qp/(rf_qp*rf_qp*(uno_qp+tre_qp)) 
#else
        real(qp), parameter::  zero_qp=0.d0     ! hint to help compiler...
        real(qp), parameter::  uno_qp=1.d0      ! hint to help compiler...
        real(qp), parameter::  tre_qp=3.d0      ! hint to help compiler...
!
        real(qp), parameter :: rf_qp = 3.d0
        real(qp), parameter :: qf_qp = 1.5d0
!
! 4/9
        real(qp), parameter :: p0_qp = 4.d0/9.d0
! 1/9
        real(qp), parameter :: p1_qp = 1.d0/9.d0
! 1/36
        real(qp), parameter :: p2_qp = uno_qp/(rf_qp*rf_qp*(uno_qp+tre_qp))
#endif
!
        integer:: nprocs, myrank, lbecomm, localcomm
        integer:: rear_task, front_task
        integer:: left_task, right_task
        integer:: imax, imin                    ! obstacle stuff
        integer:: jmax, jmin                    ! obstacle stuff
        integer:: nobs                          ! #of obstacles per task
        integer:: xyplane, myxrank
        integer:: prgrid(mpid)
        integer:: mpicoords(0:3)
        integer:: gsizes(2),lsizes(2),start_idx(2)
        integer:: offset(2)
        integer:: dump2d
        integer:: buffer_size
        integer:: i_shift
        integer:: ipad,jpad,kpad
        integer:: flag1, flag2, flag3
        integer:: flip, flop
        integer:: current, next
!
        real(mykind), dimension(1:19) :: cx,cy
!
        logical remdims(mpid)
        logical periodic(mpid)
        logical rreorder
!
#ifdef FLIPFLOP
        real(mystorage), dimension(:,:,:), allocatable :: f01,f03,f05
        real(mystorage), dimension(:,:,:), allocatable :: f08,f10
        real(mystorage), dimension(:,:,:), allocatable :: f12,f14
        real(mystorage), dimension(:,:,:), allocatable :: f17,f19
#endif 
!
#ifdef FUSED
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: a01,a03,a05
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: a08,a10
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: a12,a14
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: a17,a19
!
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: b01,b03,b05
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: b08,b10
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: b12,b14
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: b17,b19
!
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: c01,c03,c05
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: c08,c10
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: c12,c14
        real(mystorage), dimension(:,:), pointer, CONTIGUOUS :: c17,c19
#else
        !default (ORIGINAL)
        real(mystorage), dimension(:,:), allocatable :: a01,a03,a05
        real(mystorage), dimension(:,:), allocatable :: a08,a10
        real(mystorage), dimension(:,:), allocatable :: a12,a14
        real(mystorage), dimension(:,:), allocatable :: a17,a19
!
        real(mystorage), dimension(:,:), allocatable :: b01,b03,b05
        real(mystorage), dimension(:,:), allocatable :: b08,b10
        real(mystorage), dimension(:,:), allocatable :: b12,b14
        real(mystorage), dimension(:,:), allocatable :: b17,b19
#endif
!
        integer, dimension(:,:), allocatable :: obs
!
        real(mykind):: svisc, u0, u00, fgrad
        real(mykind):: u0x, u0y
        real(mykind):: u_inflow
        integer:: mydev, ndev              ! openacc variables
!
! correct casting
        real(mykind) :: omega
        real(mykind) :: radius
        real(mykind), parameter :: zero = zero_qp
        real(mykind), parameter :: uno  = uno_qp
        real(mykind), parameter :: tre  = tre_qp
! 
        real(mykind), parameter :: rf = rf_qp
        real(mykind), parameter :: qf = qf_qp
        real(mykind), parameter :: p0 = p0_qp
        real(mykind), parameter :: p1 = p1_qp
        real(mykind), parameter :: p2 = p2_qp

        end module  storage