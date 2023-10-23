#----------------------------------------------
# makefile BGK2D_GPU
# Giorgio Amati, CINECA 2021-202?
#----------------------------------------------
# targets:
#
#		<none> default ---> GPU code with do concurrent (nvfortran)
#		offload ---> GPU code with openmp offload
#		openacc ---> GPU code with openACC
#		serial  ---> Serial CPU code
#		mulitcore -> Multicore CPU code 
# 
#----------------------------------------------
DATE = $(shell date +%d%m%y)
FINE = "******** End Compilation step  *******"
CHECK1 = NVIDIA
CHECK2 = SINGLE
#----------------------------------------------
# Compilers & Flags
#----------------------------------------------
# flags
# default (nvfortran)
SCC = nvcc 
SFC = nvfortran -DPGI
OFFLOAD = -mp=gpu -DOFFLOAD  -Minfo=accel 
OPENACC = -Minfo=acc -O2 -acc -DOPENACC -ta=tesla:cc80,managed
MULTI = -stdpar=multicore -Minfo=all -DMULTICORE
DC  = -stdpar=gpu
FOPT = -O2 -Mnodepchk  -Mcontiguous
COPT = -O2
OPT  = -O2  -Mnodepchk  -Mcontiguous
CHECK1=NVIDIA
#
ifdef NVIDIA
# do nothing	
endif
#
ifdef AMD
 SFC = flang -DPGI
 SCC = clang -DPGI
 OFFLOAD = -fopenmp --offload-arch=gfx90a -DOFFLOAD
 OPENACC = not yet supported
 DC = not yet supported
 FOPT =  -O3
 COPT =  -O3
 OPT =   -O3
 CHECK1=AMD
endif
#
ifdef CRAY
 SCC = cc
 SFC = ftn
 OFFLOAD = -DPGI -h omp -DOFFLOAD -DCRAY
 OPENACC = -DPGI -h acc -DNOMANAGED -DOPENACC
 DC = not yet supported
 FOPT = -O3
 COPT =
 OPT = -O3
 CHECK1=CRAY
endif
#
ifdef GNU
 SFC = gfortran 
 SCC = gcc 
 OFFLOAD = -fopenmp  -foffload=nvptx-none -DOFFLOAD
 MULTI =   -fopenmp -DMULTICORE -ftree-parallelize-loops=4
 DC = not yet supported
 FOPT =  -O3
 COPT =  -O3
 OPT =   -O3
 DEBUG = -Wuninitialized -DDEBUG_1
 CHECK1=GNU
endif
#
ifdef INTEL
 SFC = ifort
 SCC = icc
 SFC = ifx
 SCC = icx
# FOPT = -O3 -xCORE-AVX512 -mtune=skylake-avx512 -assume contiguous_pointer
# COPT = -O3 -xCORE-AVX512 -mtune=skylake-avx512
 OPENACC = not yet supported
 OFFLOAD = 
 DC = 
 FOPT = -O3 
 COPT = -O3 
 OPT =  -O3
 OPENMP = -qopenmp
 MULTI =  -Qparallel
 MULTI =  -qopenmp -DMULTICORE
 INFO = -warn all
 CHECK1=INTEL
endif
#
ifdef PWR
 SCC = xlc_r  
 SFC = xlf_r 
 OFFLOAD = -qsmp=omp -qoffload -DOFFLOAD
 FOPT = -O3 -qassert=contig
 COPT = -O3 -qassert=contig
 OPT = -O3 -qassert=contig
 CHECK1=PWR
endif
#
#----------------------------------------------
# precision used
#----------------------------------------------
#
# default
ifdef SINGLE
 PREC =
 CHECK2=SINGLE
endif
#
ifdef MIXED1
 PREC =-DHALF_P -DMIXEDPRECISION 
 CHECK2=MIXED1
endif
#
ifdef MIXED2
 PREC =-DMIXEDPRECISION 
 CHECK2=MIXED2
endif
#
ifdef DOUBLE
 PREC =-DDOUBLE_P
 CHECK2=DOUBLE
endif
#
#----------------------------------------------
# implementations 
#----------------------------------------------
#
# default, ORIGINAL
ifdef ORIG
 IMPL = 
 CHECK3=ORIG
endif
#
ifdef FUSED
 IMPL = -DFUSED
 CHECK3=FUSED
endif
#
#
#----------------------------------------------
# test case
#----------------------------------------------
#
# default, Lid Driven Cavity
ifdef LDC
 PREPROC = -DLDC
 CHECK4=LDC
endif
#
# Poiseulle Flow
ifdef POF
 PREPROC = -DCHANNEL -DPOF
 CHECK4=POF
endif
#
# Taylor Green Vortex
ifdef TGV
 PREPROC = -DPERIODIC -DTGV
 CHECK4=TGV
endif
#
# Von Karman Streets 
ifdef VKS
 PREPROC =-DINFLOW -DOBSTACLE -DDRAG -DVKS
 CHECK4=VKS
endif
#
#----------------------------------------------
# module & subroutines
#----------------------------------------------
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
       movef.o\
       save_raw.o\
       profile.o\
       draglift.o \
       dealloca.o

# 3rd level subroutine
OBJ3 = get_mem.o \
       collision.o \
       col_MC.o \
       col.o 

OBJ = $(OBJ1) $(OBJ0) $(OBJ2) $(OBJ3)

#----------------------------------------------
# targets
#----------------------------------------------
#
#
doconcurrent: all
#
#----------------------------------------------
all: VER := doconcurrent
all: FC := $(SFC) $(DC) 
all: CC := $(SCC)
all: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(DC) $(MOD1) $(OBJ) $(OBJ4) $(IMPL) $(LIB) $(FIX) -o ../RUN/bgk2d.$(VER).x 
	@echo "-------------------------------------------------"
	@echo "options: "$(CHECK1) $(CHECK2) $(CHECK3) $(CHECK4) 
	@echo $(FINE)
	@echo "-------------------------------------------------"
#
#----------------------------------------------
offload: FOPT += $(OFFLOAD)
offload: OPT  += $(OFFLOAD)
offload: VER := offload
offload: FC := $(SFC)
offload: CC := $(SCC)
offload:$(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(IMPL) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x
	@echo "-------------------------------------------------"
	@echo "options: "$(CHECK1) $(CHECK2) $(CHECK3) $(CHECK4) 
	@echo $(FINE)
	@echo "-------------------------------------------------"
#
#----------------------------------------------
openacc: FOPT += $(OPENACC)
openacc: OPT  += $(OPENACC)
openacc: VER := openacc
openacc: FC := $(SFC)
openacc: CC := $(SCC)
openacc:$(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(IMPL) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x
	@echo "-------------------------------------------------"
	@echo "options: "$(CHECK1) $(CHECK2) $(CHECK3) $(CHECK4) 
	@echo $(FINE)
	@echo "-------------------------------------------------"
#
#----------------------------------------------
serial: VER:= serial
serial: FC := $(SFC) -DSERIAL
serial: CC := $(SCC)
serial: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(IMPL) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x
	@echo "-------------------------------------------------"
	@echo "options: "$(CHECK1) $(CHECK2) $(CHECK3) $(CHECK4) 
	@echo $(FINE)
	@echo "-------------------------------------------------"
#
#----------------------------------------------
multicore: VER:= multicore
multicore: FC := $(SFC) $(MULTI)
multicore: CC := $(SCC)
multicore: $(MOD0) $(MOD1) $(OBJ) $(OBJ4)
	$(FC) $(OPT) $(MOD1) $(OBJ) $(OBJ4) $(IMPL) $(FIX) $(LIB) -o ../RUN/bgk2d.$(VER).x
	@echo "-------------------------------------------------"
	@echo "options: "$(CHECK1) $(CHECK2) $(CHECK3) $(CHECK4)
	@echo $(FINE)
	@echo "-------------------------------------------------"
#
#----------------------------------------------
# rules 
#----------------------------------------------

%.o %.mod: $(INC) %.f90
	$(FC) $(FOPT) $(PREC) $(PREPROC) $(IMPL) $(FIX) -c $<

%.o: $(INC) %.F90
	$(FC) $(FOPT) $(PREC) $(PREPROC) $(IMPL) $(FIX) -c $<

%.o: $(INC) %.f
	$(FC) $(FOPT) $(PREC) $(PREPROC) $(IMPL) $(FIX) -c $<

%.o: $(INC) %.c
	$(CC) $(COPT)                          -c $<
#
#----------------------------------------------
# utilities
#----------------------------------------------
clean:
	rm -f *.o;
	rm -f *.mod;
	rm -f core;
#----------------------------------------------
info:  $(INC)
	@echo "Modules          =  "$(MOD0) $(MOD1);
	@echo "Objects          =  "$(OBJ);
	@echo "Compiler         =  "$(SFC);
	@echo "Compiler  flags  =  "$(OPT);
	@echo "Preproc   flags  =  "$(PREPROC);
	@echo "Fix       flags  =  "$(FIX);
	@echo "Implemet. flags  =  "$(IMPL);
	@echo "Precision flags  =  "$(PREC);
	@echo "Version          =  "$(VER);

#----------------------------------------------
test:
	make clean;
	make serial;
	make clean;
	make multicore;
	make clean;
	make doconcurrent;
	make clean;
	make openacc;
	make clean;
	make offload;
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
	@echo "do concurrent (default, GPU) "
	@echo "serial (CPU)"
	@echo "multicore (CPU)"
	@echo "offload (GPU)"
	@echo "openacc (GPU)"
#----------------------------------------------

