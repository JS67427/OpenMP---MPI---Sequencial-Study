## Flags
CC = gcc
CFLAGS = -Wall -std=gnu99
OPENMPFLAG = -fopenmp
MPICC = mpicc
MPIRUN = mpirun
## def processing elements
NP2 = -np 2
NP3 = -np 3
NP4 = -np 4
NP5 = -np 5
NP6 = -np 6
OMP_NUM_THREADS_2 = OMP_NUM_THREADS=2
OMP_NUM_THREADS_3 = OMP_NUM_THREADS=3
OMP_NUM_THREADS_4 = OMP_NUM_THREADS=4
EXPORT = export
## src + exec files
SRC = generatematrix_N.c
SRC0 = multmatrix_N.c
SRC1 = multmatrix_N_MPI.c
SRC2 = multmatrix_N_OpenMP.c
SRC3 = multmatrix_N_hybrid.c
EXEC = gen_matrix
EXEC0 = mult_matrix
EXEC1 = mult_matrix_mpicc
EXEC2 = mult_matrix_openmp
EXEC3 = mult_matrix_hybrid
## args
MAT_A = matA.dat
MAT_B = matB.dat
MAT_C = matC.dat
## N + Iterations
POWERS = 2 4 8 16 32 64 128 256 512 1024
ITER = 51
## servers info
AVAL = 10.4.0.118
LINUX = 10.4.0.110
USER = 67427@
HOST = --hostfile
## always linux to aval
HOST_1to1 = "/home/a67427/project1/host_1to1"
HOST_2to1 = "/home/a67427/project1/host_2to1"
HOST_3to1 = "/home/a67427/project1/host_3to1"
HOST_4to1 = "/home/a67427/project1/host_4to1"
HOST_1to2 = "/home/a67427/project1/host_1to2"
HOST_2to2 = "/home/a67427/project1/host_2to2"
HOST_3to2 = "/home/a67427/project1/host_3to2"
HOST_4to2 = "/home/a67427/project1/host_4to2"
## results context + cpu info
SYS_CONTEXT = sys_context.txt
CPU_INFO = cpu_info.txt
## results seq
CSV_OUTPUT = resultado_seq.csv
## resuls mpi linux
CSV_OUTPUT_nproc2_fct_linux = resultado_mpi_nproc2_fct_linux.csv
CSV_OUTPUT_nproc3_fct_linux = resultado_mpi_nproc3_fct_linux.csv
CSV_OUTPUT_nproc4_fct_linux = resultado_mpi_nproc4_fct_linux.csv
## results aval
CSV_OUTPUT_nproc2_aval = resultado_mpi_nproc2_aval.csv
## results for linux + aval
CSV_OUTPUT_nproc2_linux_aval_1to1 = resultado_mpi_nproc2_linux_aval_1to1.csv
CSV_OUTPUT_nproc3_linux_aval_2to1 = resultado_mpi_nproc3_linux_aval_2to1.csv
CSV_OUTPUT_nproc4_linux_aval_3to1 = resultado_mpi_nproc4_linux_aval_3to1.csv
CSV_OUTPUT_nproc5_linux_aval_4to1 = resultado_mpi_nproc5_linux_aval_4to1.csv
CSV_OUTPUT_nproc3_linux_aval_1to2 = resultado_mpi_nproc3_linux_aval_1to2.csv
CSV_OUTPUT_nproc4_linux_aval_2to2 = resultado_mpi_nproc4_linux_aval_2to2.csv
CSV_OUTPUT_nproc5_linux_aval_3to2 = resultado_mpi_nproc5_linux_aval_3to2.csv
CSV_OUTPUT_nproc6_linux_aval_4to2 = resultado_mpi_nproc6_linux_aval_4to2.csv
## results openMP
CSV_OUTPUT_nproc2_openmp = resultado_openmp_nproc2.csv
CSV_OUTPUT_nproc3_openmp = resultado_openmp_nproc3.csv
CSV_OUTPUT_nproc4_openmp = resultado_openmp_nproc4.csv
## results linux hybrid 

## results aval hybrid 
## results linux + aval hybrid 
#N = 2

all: execution_order_fct_linux execution_order_aval execution_order_linux_aval_N_to_1 execution_order_linux_aval_N_to_2 execution_order_openmp
.PHONY: all clean

execution_order_fct_linux: cpu_info gen_executable sys_context run_multiple_N_csv_seq sys_context run_multiple_N_csv_nproc2 sys_context run_multiple_N_csv_nproc3 sys_context run_multiple_N_csv_nproc4 sys_context

execution_order_aval: cpu_info gen_executable  sys_context run_multiple_N_csv_seq sys_context run_multiple_N_csv_nproc2_aval

execution_order_linux_aval_N_to_1: run_multiple_N_csv_linux_aval_1to1 run_multiple_N_csv_linux_aval_2to1 run_multiple_N_csv_linux_aval_3to1 run_multiple_N_csv_linux_aval_4to1

execution_order_linux_aval_N_to_2: run_multiple_N_csv_linux_aval_1to2 run_multiple_N_csv_linux_aval_2to2 run_multiple_N_csv_linux_aval_3to2 run_multiple_N_csv_linux_aval_4to2

execution_order_openmp: run_multiple_N_csv_OpenMP_2threads run_multiple_N_csv_OpenMP_3threads run_multiple_N_csv_OpenMP_4threads

#execution_order_hybrid: 

gen_executable: $(SRC)
	$(CC) $(CFLAGS) $(SRC) -o $(EXEC)

create_MatA:
	@rm -f $(MAT_A)
	@./$(EXEC) $(N) $(MAT_A)

create_MatB:
	@rm -f $(MAT_B)
	@./$(EXEC) $(N) $(MAT_B)

run0:
	$(CC) $(CFLAGS) $(SRC0) $(LDFLAGS) -o $(EXEC0)

run1:
	$(MPICC) $(SRC1) -o $(EXEC1)

run2:
	$(CC) $(OPENMPFLAG) $(SRC2) -o $(EXEC2)	

run3:
	$(MPICC) $(OPENMPFLAG) $(SRC3) -o $(EXEC3)		

###################### sequencial fct-linux / aval ###########################

run_multiple_N_csv_for_N_seq: run0
	@echo "N=$$N sequencial fct-linux" >> $(CSV_OUTPUT)
	@echo "iter,total_e_sec,mult_e_sec" >> $(CSV_OUTPUT)
	@for i in $(shell seq 1 $(ITER)); do \
		./$(EXEC0) $(MAT_A) $(MAT_B) $(MAT_C) $$N | awk -v iter=$$i '{ \
			if($$1=="total_e_sec:"){a=$$2} \
			else if($$1=="mult_e_sec:"){b=$$2; \
				printf "%d,%.9f,%.9f\n", iter, a, b} \
		}' >> $(CSV_OUTPUT); \
	done	

run_multiple_N_csv_seq: 
	@for N in $(POWERS); do \
		echo "Running for N=$$N sequencial fct-linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_seq N=$$N; \
		echo "Done for N=$$N"; \
	done

###################### only fct-linux mpi ###########################

run_multiple_N_csv_for_N_nproc2: run1
	@echo "N=$$N mpi nproc = 2 fct-linux">> $(CSV_OUTPUT_nproc2_fct_linux)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc2_fct_linux)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc2_fct_linux)

run_multiple_N_csv_for_N_nproc3: run1
	@echo "N=$$N mpi nproc = 3 fct-linux">> $(CSV_OUTPUT_nproc3_fct_linux)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc3_fct_linux)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP3) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc3_fct_linux)

run_multiple_N_csv_for_N_nproc4: run1
	@echo "N=$$N mpi nproc = 4 fct-linux">> $(CSV_OUTPUT_nproc4_fct_linux)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc4_fct_linux)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP4) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc4_fct_linux)

run_multiple_N_csv_nproc2:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with nproc = 2 fct-linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_nproc2 N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_nproc3:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with nproc = 3 fct-linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_nproc3 N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_nproc4:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with nproc = 4 fct-linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_nproc4 N=$$N; \
		echo "Done for N=$$N"; \
	done

######################### only aval mpi ######################
connect:
	@scp $(EXEC) $(USER)$(AVAL)
	@scp $(EXEC0) $(USER)$(AVAL)
	@scp $(EXEC1) $(USER)$(AVAL)
	@ssh $(USER)$(AVAL)

run_multiple_N_csv_for_N_nproc2_aval: run1
	@echo "N=$$N mpi nproc = 2 aval">> $(CSV_OUTPUT_nproc2_aval)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc2_aval)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc2_aval)

run_multiple_N_csv_nproc2_aval:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with nproc = 2 fct-linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_nproc2_aval N=$$N; \
		echo "Done for N=$$N"; \
	done
	
######################### linux + aval -  N_to_1 mpi ######################

run_multiple_N_csv_for_N_linux_aval_1to1: run1
	@echo "N=$$N mpi nproc = 2 1linux+1aval">> $(CSV_OUTPUT_nproc2_linux_aval_1to1)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc2_linux_aval_1to1)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP2) $(HOST) $(HOST_1to1) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc2_linux_aval_1to1)

run_multiple_N_csv_linux_aval_1to1:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 1to1 = 1linux+1aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_1to1 N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_for_N_linux_aval_2to1: run1
	@echo "N=$$N mpi nproc = 3 2linux+1aval">> $(CSV_OUTPUT_nproc3_linux_aval_2to1)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc3_linux_aval_2to1)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP3) $(HOST) $(HOST_2to1) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc3_linux_aval_2to1)

run_multiple_N_csv_linux_aval_2to1:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 2to1 = 2linux+1aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_2to1 N=$$N; \
		echo "Done for N=$$N"; \
	done
	
run_multiple_N_csv_for_N_linux_aval_3to1: run1
	@echo "N=$$N mpi nproc = 4 3linux+1aval">> $(CSV_OUTPUT_nproc4_linux_aval_3to1)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc4_linux_aval_3to1)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP4) $(HOST) $(HOST_3to1) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc4_linux_aval_3to1)

run_multiple_N_csv_linux_aval_3to1:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 3to1 = 3linux+1aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_3to1 N=$$N; \
		echo "Done for N=$$N"; \
	done
	
run_multiple_N_csv_for_N_linux_aval_4to1: run1
	@echo "N=$$N mpi nproc = 5 4linux+1aval">> $(CSV_OUTPUT_nproc5_linux_aval_4to1)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc5_linux_aval_4to1)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP5) $(HOST) $(HOST_4to1) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc5_linux_aval_4to1)

run_multiple_N_csv_linux_aval_4to1:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 4to1 = 4linux+1aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_4to1 N=$$N; \
		echo "Done for N=$$N"; \
	done
	
######################### linux + aval -  N_to_2 mpi ######################

run_multiple_N_csv_for_N_linux_aval_1to2: run1
	@echo "N=$$N mpi nproc = 3 1linux+2aval">> $(CSV_OUTPUT_nproc3_linux_aval_1to2)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc3_linux_aval_1to2)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP3) $(HOST) $(HOST_1to2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc3_linux_aval_1to2)

run_multiple_N_csv_linux_aval_1to2:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 1to2 = 1linux+2aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_1to2 N=$$N; \
		echo "Done for N=$$N"; \
	done
	
run_multiple_N_csv_for_N_linux_aval_2to2: run1
	@echo "N=$$N mpi nproc = 4 2linux+2aval">> $(CSV_OUTPUT_nproc4_linux_aval_2to2)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc4_linux_aval_2to2)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP4) $(HOST) $(HOST_2to2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc4_linux_aval_2to2)

run_multiple_N_csv_linux_aval_2to2:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 2to2 = 2linux+2aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_2to2 N=$$N; \
		echo "Done for N=$$N"; \
	done
	
run_multiple_N_csv_for_N_linux_aval_3to2: run1
	@echo "N=$$N mpi nproc = 5 3linux+2aval">> $(CSV_OUTPUT_nproc5_linux_aval_3to2)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc5_linux_aval_3to2)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP5) $(HOST) $(HOST_3to2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc5_linux_aval_3to2)

run_multiple_N_csv_linux_aval_3to2:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 3to2 = 3linux+2aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_3to2 N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_for_N_linux_aval_4to2: run1
	@echo "N=$$N mpi nproc = 6 4linux+2aval">> $(CSV_OUTPUT_nproc6_linux_aval_4to2)
	@echo "iter,total_e_sec,mult_e_sec,comm_e_sec,aux_instructions" >> $(CSV_OUTPUT_nproc6_linux_aval_4to2)
	@for i in $(shell seq 1 $(ITER)); do \
		$(MPIRUN) $(NP6) $(HOST) $(HOST_4to2) $(EXEC1) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6,8,10 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec,$$comm_e_sec,$$aux_instructions; \
		done; \
	done >> $(CSV_OUTPUT_nproc6_linux_aval_4to2)

run_multiple_N_csv_linux_aval_4to2:
	@for N in $(POWERS); do \
		echo "Running for N=$$N mpi with 4to2 = 4linux+2aval"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_linux_aval_4to2 N=$$N; \
		echo "Done for N=$$N"; \
	done

######################### fct-linux OpenMP ######################

run_multiple_N_csv_for_N_OpenMP_2threads: run2
	@echo "N=$$N openmp nproc = 2 2linux">> $(CSV_OUTPUT_nproc2_openmp)
	@echo "iter,total_e_sec,mult_e_sec" >> $(CSV_OUTPUT_nproc2_openmp)
	@for i in $(shell seq 1 $(ITER)); do \
		$(OMP_NUM_THREADS_2) ./$(EXEC2) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec; \
		done; \
	done >> $(CSV_OUTPUT_nproc2_openmp)

run_multiple_N_csv_OpenMP_2threads:
	@for N in $(POWERS); do \
		echo "Running for N=$$N openmp = 2linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_OpenMP_2threads N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_for_N_OpenMP_3threads: run2
	@echo "N=$$N openmp nproc = 3 3linux">> $(CSV_OUTPUT_nproc3_openmp)
	@echo "iter,total_e_sec,mult_e_sec" >> $(CSV_OUTPUT_nproc3_openmp)
	@for i in $(shell seq 1 $(ITER)); do \
		$(OMP_NUM_THREADS_3) ./$(EXEC2) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec; \
		done; \
	done >> $(CSV_OUTPUT_nproc3_openmp)

run_multiple_N_csv_OpenMP_3threads:
	@for N in $(POWERS); do \
		echo "Running for N=$$N openmp = 3linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_OpenMP_3threads N=$$N; \
		echo "Done for N=$$N"; \
	done

run_multiple_N_csv_for_N_OpenMP_4threads: run2
	@echo "N=$$N openmp nproc = 4 4linux">> $(CSV_OUTPUT_nproc4_openmp)
	@echo "iter,total_e_sec,mult_e_sec" >> $(CSV_OUTPUT_nproc4_openmp)
	@for i in $(shell seq 1 $(ITER)); do \
		$(OMP_NUM_THREADS_4) ./$(EXEC2) $(MAT_A) $(MAT_B) $(MAT_C) $$N | \
		cut -d ' ' -f 2,4,6 | \
		while read total_e_sec mult_e_sec comm_e_sec aux_instructions; do \
			echo $$i,$$total_e_sec,$$mult_e_sec; \
		done; \
	done >> $(CSV_OUTPUT_nproc4_openmp)

run_multiple_N_csv_OpenMP_4threads:
	@for N in $(POWERS); do \
		echo "Running for N=$$N openmp = 4linux"; \
		$(MAKE) create_MatA N=$$N; \
		$(MAKE) create_MatB N=$$N; \
		$(MAKE) run_multiple_N_csv_for_N_OpenMP_4threads N=$$N; \
		echo "Done for N=$$N"; \
	done

######################### fct-linux hybrid ######################

#run 3 prepared 
#falta os ficheiros de output
#falta definir quais e como vão ser as execuções com o cores/threads

######################### aval hybrid ######################

######################### fct-linux + aval hybrid ######################

sys_context:
	@sleep 5
	@uptime >> $(SYS_CONTEXT)
	@sleep 5

cpu_info:
	@echo "Número de núcleos:" >> $(CPU_INFO)
	@nproc >> $(CPU_INFO)
	@echo "" >> $(CPU_INFO)
	@echo "Detalhes do CPU:" >> $(CPU_INFO)
	@lscpu >> $(CPU_INFO)

clean:
	@rm -f $(MAT_A) $(MAT_B) $(MAT_C) $(SYS_CONTEXT) $(CPU_INFO) $(CSV_OUTPUT)
	@rm -f $(CSV_OUTPUT_nproc2_fct_linux) $(CSV_OUTPUT_nproc3_fct_linux) $(CSV_OUTPUT_nproc4_fct_linux) $(CSV_OUTPUT_nproc2_aval) $(CSV_OUTPUT_nproc2_linux_aval)
	@rm -f $(CSV_OUTPUT_nproc2_linux_aval_1to1) $(CSV_OUTPUT_nproc3_linux_aval_2to1) $(CSV_OUTPUT_nproc4_linux_aval_3to1) $(CSV_OUTPUT_nproc5_linux_aval_4to1)
	@rm -f $(CSV_OUTPUT_nproc3_linux_aval_1to2) $(CSV_OUTPUT_nproc4_linux_aval_2to2) $(CSV_OUTPUT_nproc5_linux_aval_3to2) $(CSV_OUTPUT_nproc6_linux_aval_4to2)
	@rm -f $(CSV_OUTPUT_nproc2_openmp) $(CSV_OUTPUT_nproc3_openmp) $(CSV_OUTPUT_nproc4_openmp)
	@rm -f $(EXEC) $(EXEC0) $(EXEC1) $(EXEC2) $(EXEC3)