#----------------------------------------------
# makefile per BGK-DRIVEN
# Giorgio Amati, CINECA 2021
#----------------------------------------------
# notes:
#
# 	1) ...
#	2) ....
#		Intel/AMD
#
#----------------------------------------------
# targets:
#
#		serial ---> serial code
#		openmp ---> openmp
#		openacc ---> openacc
# 
# flags
#----------------------------------------------
DATE = $(shell date +%d%m%y)
#----------------------------------------------
FINE = "********** Fine Compilazione *********"
#----------------------------------------------
#
# generic option
FOPT = -O3
COPT = -O3
OPT = -O3
CUDA = cc70
OPENMP = -qopenmp
#
# generic compiler
SCC = icc
SFC = ifort 
#
# option for AMD with intel compiler (from prace doc)
ifdef AMD
 CC = mpiicc
 FC = mpiifort 
 SCC = icc
 OPENMP = -qopenmp
 SFC = ifort -march=core-avx2 -align array64byte -fma -ftz 
endif
#
ifdef MI100
 SFC = /home/userinternal/sorland2/gcc-install-omp11/bin/gfortran
 SCC = /home/userinternal/sorland2/gcc-install-omp11/bin/gcc
 OPENMP = -fopenmp
 OPENACC = -fopenacc -foffload=-march=gfx908 
 FOPT = -Ofast -ftree-vectorize
 FOPT = -ftree-loop-distribution -fopenmp-simd -ftree-vectorize -fvect-cost-model=unlimited -march=native -mtune=native -Ofast
 COPT = 
 OPT = -Ofast -ftree-vectorize
endif
#
ifdef DGX
 SCC = nvcc
 SFC = nvfortran
 CC = mpicc
 FC = mpifort
 FIX = -DPGI -Minfo
 OPENMP = -mp
 OPENACC = -acc -Minfo=acc -ta=tesla:cc80,managed
 OPENACC = -acc -Minfo=acc -ta=tesla:cc80
 FOPT = -fast -Mnodepchk 
 FOPT = -fast -Mnodepchk -Mcontiguous
 COPT = 
 OPT = -fast -Mnodepchk
endif
#
ifdef NV
 SCC = pgcc
 SFC = pgf90
 CC = mpicc
 FC = mpifort
# FC = mpipgifort
 OPENMP = -mp
 OPENACC = -acc -Minfo=acc -ta=tesla:$(CUDA),managed
 OPENACC = -acc -Minfo=acc -ta=tesla:$(CUDA)
 OFFLOAD = -mp=gpu -DOFFLOAD  -Minfo=accel
 OPENACC = -acc -Minfo=acc -ta=tesla:$(CUDA)
 FIX = -DPGI 
 FOPT = -fast -Mnodepchk  -Mcontiguous
 COPT = -fast 
 OPT = -O3  -Mnodepchk  -Mcontiguous
endif
#
ifdef FUGAKU
 SFC = frtpx
 SCC = FCCpx
 FC = mpifrtpx
 CC = mpiFCCpx
endif
#
ifdef GNU
 CC = mpicc
 FC = mpif90
 SFC = gfortran 
 SCC = gcc 
 OPENMP = -fopenmp
 OPENACC = -fopenacc
# DGX...
 OPENACC = -fopenacc -foffload=-misa=sm_35
 OPENACC = -fopenacc -foffload=nvptx-none
 OFFLOAD = -fopenmp  -foffload=nvptx-none -DOFFLOAD
 FOPT =  -O3
# FOPT = -ftree-vectorize -Ofast
# FOPT = -ftree-loop-distribution -fopenmp-simd -ftree-vectorize -fvect-cost-model=unlimited -mtune=native -Ofast
 COPT =  -O3
 OPT =   -O3
endif
#
ifdef ARM
 CC = mpicc
 FC = mpif90
 SFC = armflang
 SCC = armclang
# CC = gcc
# FC = gfortran
# SFC = gfortran
# SCC = gcc
# FOPT = -O3 -mcpu=native  -march=armv8-a+sve 
 FOPT = -Ofast -fno-stack-arrays -mcpu=native
 LIB = -L/opt/arm/gcc-8.2.0_Generic-AArch64_RHEL-7_aarch64-linux/lib64/
# FOPT = -Ofast -march=armv8-a+sve
endif
#
ifdef BDW
 FOPT = -O3 -xCORE-AVX2 
 COPT = -O3 -xCORE-AVX2
 OPENMP = -qopenmp
endif
#
ifdef KNL
 FOPT = -O3 -xMIC-AVX512 -qopt-prefetch=5 
 COPT = -O3 -xMIC-AVX512 -qopt-prefetch=5
 OPENMP = -qopenmp
endif
#
ifdef SKL
 FOPT = -O3 -xCORE-AVX512 -mtune=skylake-avx512 
 FOPT = -O3 -xCORE-AVX512 -mtune=skylake-avx512 -assume contiguous_pointer
 COPT = -O3 -xCORE-AVX512 -mtune=skylake-avx512
 OPENMP = -qopenmp
# FOPT = -O3 -mtune=skylake-avx512
# COPT = -O3 -mtune=skylake-avx512
endif
#
ifdef PWR
 SCC = xlc_r  
 SFC = xlf_r 
 OPENMP = -qsmp=omp
 OFFLOAD = -qsmp=omp -qoffload -DOFFLOAD
 FIX = -DPGI
 FOPT = -O3 -qassert=contig
 COPT = -O3 -qassert=contig
 OPT = -O3 -qassert=contig
endif
#

ifdef A100
 CUDA = cc80
endif
#
#
ifdef DOUBLE
 DBL = -DDOUBLE_P
endif
#
ifdef COMM
 COMM1 = -DNOBLOCK
else
 COMM1 = -DSENDRECV
endif
#
ifdef IOMPI
 FIX = -DMPIIO
endif
#
ifdef IOHDF5
 FIX =
endif
# include file
INC = 
#----------------------------------------------
# module
MOD0 = get_mem_mod.o \

MOD1 = precision.o \
      storage.o \
      mod_tools.o \


# 0th level subroutine
OBJ0 = bgk2d.o \

# 1st level subroutine
OBJ1 = setup.o \
       initialize.o \
       diagnostic.o \
       boundaries.o \
       propagation.o \
       save.o\
       finalize.o \

# 2nd level subroutine
OBJ2 = check_case.o \
       input.o \
       alloca.o \
       bcond.bc.o \
       build.bcond.o \
       bcond.bc.flipflop.o \
       bcond.bc.periodic.o \
       restore_raw.o \
       init.o\
       hencol.o \
       outdat.o \
       vtk_rho.binary.o \
       vtk_xy.o \
       vtk_xy.binary.o \
       vtk_om.o \
       vtk_om.binary.o \
       varm.o \
       prof_j.o \
       prof_i.o \
       diagno.o \
       probe.o \
       probe_global.o \
       movef.o\
       save_raw.o\
       profile.o\
       copyA2F.o\
       copyF2A.o\
       dealloca.o

# 3rd level subroutine
OBJ3 = get_mem.o \
       collision.o \
       col_MC.o \
       col_FlipFlop.o \
       col.o 

OBJ = $(OBJ1) $(OBJ0) $(OBJ2) $(OBJ3)

#----------------------------------------------
#
all: VER := serial
all: FC := $(SFC)
all: CC := $(SCC)
all: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x 
	@echo $(FINE)

#----------------------------------------------
openacc: FC := $(SFC)
openacc: CC := $(SCC)
# gnu stuff
#openacc: FOPT += $(OPENACC) -Ofast -ftree-vectorize
#openacc: OPT  += $(OPENACC) -Ofast -ftree-vectorize
openacc: FOPT += $(OPENACC) 
openacc: OPT  += $(OPENACC) 
openacc: VER = openacc
openacc: FINE = "Under development: works only with pgi/gnu compiler!!!"
openacc: $(MOD0) $(MOD1) $(OBJ) $(OBJ5)
	$(FC) $(OPT) $(DBL) $(MOD1) $(OBJ) $(OBJ5) $(TRY) $(FIX) -o ../RUN/bgk2d.openacc.x
	@echo $(FINE)

#----------------------------------------------
openmp: FOPT += $(OPENMP)
openmp: OPT  += $(OPENMP) 
openmp: VER := openmp
openmp: FC := $(SFC)
openmp: CC := $(SCC)
openmp: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x 

#----------------------------------------------
offload: FOPT += $(OFFLOAD)
offload: OPT  += $(OFFLOAD)
offload: VER := offload
offload: FC := $(SFC)
offload: CC := $(SCC)
offload: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x


%.o %.mod: $(INC) %.f90
	$(FC) $(FOPT) $(DBL) $(PREPROC) $(TRY) $(FIX) -c $<

%.o: $(INC) %.F90
	$(FC) $(FOPT) $(DBL) $(PREPROC) $(TRY) $(FIX) -c $<

%.o: $(INC) %.f
	$(FC) $(FOPT) $(DBL) $(PREPROC) $(TRY) $(FIX) -c $<

%.o: $(INC) %.c
	$(CC) $(COPT)                          -c $<


#----------------------------------------------
clean:
	rm -f *.o;
	rm -f *.mod;
	rm -f core;
#----------------------------------------------
info:  $(INC)
	@echo "Modules          =  "$(MOD);
	@echo "Objects          =  "$(OBJ);
	@echo "Compiler         =  "$(FC);
	@echo "Compiler flags   =  "$(OPT);
	@echo "Compiler openmp  =  "$(OPENMP);
	@echo "Preproc  flags   =  "$(PREPROC);
	@echo "Fix      flags   =  "$(FIX);
	@echo "Other    flags   =  "$(TRY);
	@echo "Double   flags   =  "$(DBL);
	@echo "Architecture     =  "$(HOSTTYPE);
	@echo "Version          =  "$(VER);
	@echo "Libraries        =  "$(LIB);

#----------------------------------------------
test:
	make clean;
	make mpi;
	make clean;
	make serial
	make clean;
	make hdf5;
	make clean;
	make openmp;
	make clean;
	make hybrid;
	make clean;
	make mic;
	make clean;
	make openacc;
#----------------------------------------------
tar:
	make clean
	rm -rf ../RUN/*.vtk
	rm -rf ../RUN/*.bin
	rm -rf ../RUN/*.h5
#	cd ../TEST/
#	./clean.x
#	cd -
	tar -cvf ../../archive.bgk2d.$(DATE).tar ../../BGK_3D/*
#----------------------------------------------
help:
	@echo "different target available"
	@echo "mpi (default)"
	@echo "serial (raw I/O)"
	@echo "hdf5  (paralle+hdf5)"
	@echo "openmp (serial+openmp)"
	@echo "hybrid (mpi+openmp)"
	@echo "openacc (serial+openac)"
	@echo "mic (mpi for intel MIC)"
	@echo "couette"
	@echo "try (regularized, not working"
	@echo "cudaf"
	@echo "mb (multiblock, not working)"
#----------------------------------------------

