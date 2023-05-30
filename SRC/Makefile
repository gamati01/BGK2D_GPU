#----------------------------------------------
# makefile per BGK-DRIVEN
# Giorgio Amati, CINECA 2021
#----------------------------------------------
# notes:
#
# 	1) ...
#	2) ....
#
#----------------------------------------------
# targets:
#
#		deault ---> GPU code with do concurrent
#		            (nvfortran)
#		offload ---> GPU code with openmp offload
# 
# flags
#----------------------------------------------
DATE = $(shell date +%d%m%y)
#----------------------------------------------
FINE = "********** Fine Compilazione *********"
#----------------------------------------------
#
# default (nvfortran)
SCC = nvcc
SFC = nvfortran
CC = mpicc
FC = mpifort
OFFLOAD = -mp=gpu -DOFFLOAD  -Minfo=accel -DPGI
DC  = -DPGI -stdpar=gpu
FOPT = -O2 -Mnodepchk  -Mcontiguous
COPT = -O2
OPT  = -O2  -Mnodepchk  -Mcontiguous
#
#
ifdef FLANG
 SFC = flang -DPGI
 SCC = clang -DPGI
 DC  =
 OFFLOAD = -fopenmp --offload-arch=gfx90a -DOFFLOAD
 FOPT =  -O3
 COPT =  -O3
 OPT =   -O3
endif
#
ifdef GNU
 CC = mpicc
 FC = mpif90
 SFC = gfortran 
 SCC = gcc 
 DC  = 
 OFFLOAD = -fopenmp  -foffload=nvptx-none -DOFFLOAD
 FOPT =  -O3
 COPT =  -O3
 OPT =   -O3
endif
#
ifdef BDW
 FOPT = -O3 -xCORE-AVX2 
 COPT = -O3 -xCORE-AVX2
 OPENMP = -qopenmp
endif
#
ifdef SKL
 SFC = ifx
 SCC = icc
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
 OFFLOAD = -qsmp=omp -qoffload -DOFFLOAD
 DC  = -DPGI
 FOPT = -O3 -qassert=contig
 COPT = -O3 -qassert=contig
 OPT = -O3 -qassert=contig
endif
#
ifdef DOUBLE
 DBL = -DDOUBLE_P
endif
#
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
       bcond.driven.o \
       bcond.periodic.o \
       bcond.channel.o \
       bcond.inflow.o \
       bcond.obs.o \
       build.bcond.o \
       build.obs.o \
       restore_raw.o \
       init.o\
       hencol.o \
       outdat.o \
       vtk_rho.binary.o \
       vtk_obstacle.o \
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
       fluxX_x.o \
       fluxX_y.o \
       fluxY_x.o \
       fluxY_y.o \
       draglift.o \
       lift.o \
       dealloca.o

# 3rd level subroutine
OBJ3 = get_mem.o \
       collision.o \
       col_MC.o \
       col.o 

OBJ = $(OBJ1) $(OBJ0) $(OBJ2) $(OBJ3)

#----------------------------------------------
#
all: VER := doconcurrent
all: FC := $(SFC) $(DC) 
all: CC := $(SCC)
all: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(DC) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(LIB) -o ../RUN/bgk2d.$(VER).x 
	@echo $(FINE)

#----------------------------------------------
offload: FOPT += $(OFFLOAD)
offload: OPT  += $(OFFLOAD)
offload: VER := offload
offload: FC := $(SFC)
offload: CC := $(SCC)
offload:$(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x

#----------------------------------------------
serial: VER:= serial
serial: DC := -DPGI
serial: FC := $(SFC)
serial: CC := $(SCC)
serial: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -DSERIAL -o ../RUN/bgk2d.$(VER).x

#----------------------------------------------
multicore: VER:= multicore
multicore: DC := -DPGI
	# nvidia
multicore: FC := $(SFC) -stdpar=multicore -Minfo=all -DMULTICORE
	# intel
multicore: FC := $(SFC) -fopenmp -DMULTICORE 
multicore: FC := $(SFC) -fopenmp -DMULTICORE   -ftree-parallelize-loops=4
multicore: CC := $(SCC)
multicore: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x
#	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(TRY) $(FIX) $(LIB) -stdpar=multicore -DSERIAL -o ../RUN/bgk2d.$(VER).x


#----------------------------------------------

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
	@echo "Compiler         =  "$(SFC);
	@echo "Compiler flags   =  "$(OPT);
	@echo "Preproc  flags   =  "$(PREPROC);
	@echo "Fix      flags   =  "$(FIX);
	@echo "Other    flags   =  "$(TRY);
	@echo "Double   flags   =  "$(DBL);
	@echo "DC       flags   =  "$(DC);
	@echo "Version          =  "$(VER);

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

