!=======================================================================
!     ****** LBE/init
!
!     COPYRIGHT
!       (c) 2000-2011 by CASPUR/G.Amati
!       (c) 2013-20?? by CINECA/G.Amati
!     NAME
!       init
!     DESCRIPTION
!       initial condition for 2d bgk simulation
!       you can choose: poiseuille flow	(OK)
!                       taylor vortices	(OK)
!                       rest flow	(OK)
!       write on unit 76 (fort.76) x & z coordinates for check
!     INPUTS
!       opt ---> 0	rest flow  (default)
!           ---> 1	poiseuille flow
!           ---> 2	decayng flow
!           ---> 3	Kida vortices
!           ---> 4	couette flow
!           ---> 5	double periodic shear flow
!           ---> other	stop simluation
!     OUTPUT
!       none
!     TODO
!
!     NOTES
!       integer variables used: i,k,opt
!       real variables used: x,z,xj,zj,vsq,rho,pi
!                            x02,x04,x05,x06,x11,x13,x14,x15,x19
!                            kappa,delta
!       u = velocity along x direction (i, streamwise)
!       v = velocity along z direction (k, normal-to-wall)
!
!     *****
!=======================================================================
!
        subroutine init(opt)
!
        use storage
        implicit none
!
        integer i,j,opt,ierr
!
#ifdef HALF_P
        real(sp) ::  xj,yj,x,y
        real(sp) ::  cvsq,crho,pi,rho
        real(sp) ::  cx01,cx03,cx05
        real(sp) ::  cx08,cx10,cx12
        real(sp) ::  cx14,cx17
        real(sp) ::  cx19
        real(sp) ::  kappa, delta
        real(sp) ::  zstart, ystart, xstart
        real(sp) ::  cte1
#else
        real(mykind) ::  xj,yj,x,y
        real(mykind) ::  cvsq,crho,pi,rho
        real(mykind) ::  cx01,cx03,cx05
        real(mykind) ::  cx08,cx10,cx12
        real(mykind) ::  cx14,cx17
        real(mykind) ::  cx19
        real(mykind) ::  kappa, delta
        real(mykind) ::  zstart, ystart, xstart
        real(mykind) ::  cte1
#endif
        
!
        integer      :: ll, mm
!
        parameter(pi=3.141592653589793238462643383279)
        parameter(kappa=80)
        parameter(delta=0.05)
!
! check parameter opt
        if((opt.lt.0).or.(opt.gt.5)) then
           write(6,*) "Initial condition out of range[0,5]",opt
           stop
        endif
!
#ifdef NOSHIFT
       cte1=uno
#else
       cte1=zero
#endif
!
        ll = l
        mm = m
        xstart = 0
        ystart = 0
!
! builds the populations
        crho = 1.0_mykind
!
        do j = 1, m
           y = (real(j+ystart) - 0.5 - 0.5*real(mm))/(0.5*real(mm))
!           write(76,*) j, y
        enddo
!	write(76,*) " "
        do i = 1, l
           x = (real(i+xstart) - 0.5 - 0.5*real(ll))/(0.5*real(ll))
!           write(76,*) i, x
        enddo
!
! rest flow 
        xj = 0.0
        yj = 0.0
!
!
!!$OMP PARALLEL DEFAULT(NONE)                                      & 
!!$OMP PRIVATE(i,j,k)                                              &
!!$OMP PRIVATE(xj,yj,zj)                                           &
!!$OMP PRIVATE(cx01,cx02,cx03,cx04,cx05,cx06,cx07,cx08,cx09,cx10)  &
!!$OMP PRIVATE(cx11,cx12,cx13,cx14,cx15,cx16,cx17,cx18,cx19)       &
!!$OMP PRIVATE(cvsq,crho)                                          & 
!!$OMP PRIVATE(x,y,z)                                              &
!!$OMP SHARED(opt,u0,u00)                                          &
!!$OMP SHARED(l1,m1,n1,ll,mm,nn)                                   &
!!$OMP SHARED(xstart,ystart,zstart)                                &
!!$OMP SHARED(a01,a02,a03,a04,a05,a06,a07,a08,a09)                 &
!!$OMP SHARED(a10,a11,a12,a13,a14,a15,a16,a17,a18,a19)             
!!$OMP DO
!
        do j = 0, m1
#ifdef PERIODIC
           y = (real(j+ystart,mykind)-0.5d0)/real(mm,mykind)  ! 0<x<1 (taylor)
#else
           y = (real(j+ystart)-0.5-0.5*real(mm))/(0.5*real(mm)) ! -1<x<1
#endif
           do i = 0, l1
#ifdef PERIODIC
              x = (real(i+xstart,mykind)-0.5d0)/real(ll,mykind)! 0<x<1 (taylor)
#else
              x = (real(i+xstart)-0.5-0.5*real(ll))/(0.5*real(ll)) ! -1<x<1
#endif
!
# ifdef PERIODIC
              xj = 0.1*sin(real(2,mykind)*pi*x)*cos(real(2,mykind)*pi*y)          !kida(?) vortices
              yj =-0.1*cos(real(2,mykind)*pi*x)*sin(real(2,mykind)*pi*y)
# endif

              cvsq=xj*xj+yj*yj
!
              cx01 = rf*( xj-yj   )+qf*(3.d0*(xj-yj)*(xj-yj)-cvsq)
              cx03 = rf*( xj+yj   )+qf*(3.d0*(xj+yj)*(xj+yj)-cvsq)
              cx05 = rf*( xj      )+qf*(3.d0*(xj   )*(xj   )-cvsq)
              cx08 = rf*(    yj   )+qf*(3.d0*(yj   )*(yj   )-cvsq)
              cx10 = rf*(-xj-yj   )+qf*(3.d0*(xj+yj)*(xj+yj)-cvsq)
              cx12 = rf*(-xj+yj   )+qf*(3.d0*(xj-yj)*(xj-yj)-cvsq)
              cx14 = rf*(-xj      )+qf*(3.d0*(xj   )*(xj   )-cvsq)
              cx17 = rf*(   -yj   )+qf*(3.d0*(yj   )*(yj   )-cvsq)
              cx19 = rf*(   0.d0  )+qf*(3.d0*( 0.d0)*( 0.d0)-cvsq)
!
              a01(i,j) = crho*p2*(cte1+cx01)
              a03(i,j) = crho*p2*(cte1+cx03)
              a05(i,j) = crho*p1*(cte1+cx05)
              a08(i,j) = crho*p1*(cte1+cx08)
              a10(i,j) = crho*p2*(cte1+cx10)
              a12(i,j) = crho*p2*(cte1+cx12)
              a14(i,j) = crho*p1*(cte1+cx14)
              a17(i,j) = crho*p1*(cte1+cx17)
              a19(i,j) = crho*p0*(cte1+cx19)
!
           end do
        end do
!!$OMP END DO
!
!!$OMP END PARALLEL
!
        if (opt == 0) then
           write(16,*) "INFO: initial condition --> rest flow"
        else
           write(6,*) "ERROR: Only rest flow is allowed", opt
           stop
        endif
!
! check
        call vtk_xy_bin(0)
!        
#ifdef DEBUG_1
        if(myrank == 0) then
           write(6,*) "DEBUG1: Exiting from sub. init"
        endif
#endif
!
        return
        end subroutine init