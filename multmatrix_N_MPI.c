#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

int* matrix_new(int n) {
    return (int*)malloc(n * n * sizeof(int));
}

void matrix_get(const char *filename, int *matrix, int n) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("fopen failed!");
        exit(1);
    }
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            fscanf(file, "%d", &matrix[i * n + j]);
        }
    }
    fclose(file);
}

void matrix_write(const char *filename, int *matrix, int n) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("fopen failed!");
        exit(1);
    }
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            fprintf(file, "%d ", matrix[i * n + j]);
        }
        fprintf(file, "\n");
    }
    fclose(file);
}

void ParcialMultiply(int* matA, int* matB, int* matC, int n, int m) {
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            matC[i * n + j] = 0;
            for (int k = 0; k < n; k++) {
                matC[i * n + j] += matA[i * n + k] * matB[k * n + j];
            }
        }
    }
}

void print_matrix(int *matrix, int n, int rank, const char *name) {
    printf("Process %d - %s:\n", rank, name);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", matrix[i * n + j]);
        }
        printf("\n");
    }
    printf("\n");
}

void check_argc(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: <matA> <matB> <matC> <n>\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }

    FILE *fileA = fopen(argv[1], "r");
    if (fileA == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matA.\n", argv[1]);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
    fclose(fileA);

    FILE *fileB = fopen(argv[2], "r");
    if (fileB == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matB.\n", argv[2]);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
    fclose(fileB);

    FILE *fileC = fopen(argv[3], "w");
    if (fileC == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matC.\n", argv[3]);
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
    fclose(fileC);

    int n = atoi(argv[4]);
    if (n <= 0) {
        fprintf(stderr, "Error: The value of N must be a positive integer.\n");
        MPI_Abort(MPI_COMM_WORLD, 1);
    }
}

int main(int argc, char* argv[]) {
    int size, rank, n;
    int *matA = NULL, *matB = NULL, *matC = NULL;
    int *send_counts = NULL, *displacements = NULL;

    MPI_Init(&argc, &argv);

    double begin_exec, end_exec, begin_mult, end_mult, begin_comm, end_comm, begin_Bcast, end_Bcast, begin_Bcast1, end_Bcast1, begin_sync, end_sync;
    begin_exec = MPI_Wtime();

    MPI_Comm_size(MPI_COMM_WORLD, &size);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);

    if (rank == 0) {
        check_argc(argc, argv);
        n = atoi(argv[4]);

        matA = matrix_new(n);
        matB = matrix_new(n);
        matC = matrix_new(n);
        matrix_get(argv[1], matA, n);
        matrix_get(argv[2], matB, n);
    }

    begin_Bcast = MPI_Wtime();
    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);
    end_Bcast = MPI_Wtime();

    if (rank != 0) {
        matB = matrix_new(n);
    }

    // Enviar `matB` para todos os processos
    begin_Bcast1 = MPI_Wtime();
    MPI_Bcast(matB, n * n, MPI_INT, 0, MPI_COMM_WORLD);
    end_Bcast1 = MPI_Wtime();

    /*
    //--------------DEBUG-------------------//
    //sync before print
    MPI_Barrier(MPI_COMM_WORLD);

    print_matrix(matB, n, rank, "Received matB");
    */

    int chunk = n / size;
    int remainder_chunk = n % size;
    
    send_counts = (int*)malloc(size * sizeof(int));
    displacements = (int*)malloc(size * sizeof(int));

    int offset = 0;
    for (int i = 0; i < size; i++) {
        send_counts[i] = chunk * n;
        if (i < remainder_chunk) {
            send_counts[i] += n;
        }
        displacements[i] = offset;
        offset += send_counts[i];
    }

    //lines per process
    int local_rows = send_counts[rank] / n;
    int *submatA = (int*)malloc(local_rows * n * sizeof(int));
    int *submatC = (int*)malloc(local_rows * n * sizeof(int));

    begin_comm = MPI_Wtime();
    MPI_Scatterv(matA, send_counts, displacements, MPI_INT, submatA, local_rows * n, MPI_INT, 0, MPI_COMM_WORLD);

    begin_mult = MPI_Wtime();
    ParcialMultiply(submatA, matB, submatC, n, local_rows);
    end_mult = MPI_Wtime();

    begin_sync = MPI_Wtime();
    MPI_Barrier(MPI_COMM_WORLD);
    end_sync = MPI_Wtime();

    MPI_Gatherv(submatC, local_rows * n, MPI_INT, matC, send_counts, displacements, MPI_INT, 0, MPI_COMM_WORLD);
    end_comm = MPI_Wtime();

    /*
    //--------------DEBUG-------------------//
    //sync before print
    MPI_Barrier(MPI_COMM_WORLD);

    // Debugging: imprimir as linhas que este processo recebeu
    printf("Process %d - Received %d rows:\n", rank, local_rows);
    for (int i = 0; i < local_rows; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", submatA[i * n + j]);
        }
        printf("\n");
    }
    */

    end_exec = MPI_Wtime();

    if (rank == 0) {
        //total execution time
        double elapsed = end_exec - begin_exec;
        //printf("total_e_sec: %.9f\n",elapsed);
        
        //matrix calc
        double mult_elapsed = end_mult - begin_mult;
        //printf("mult_e_sec: %.9f\n",mult_elapsed);

        //scatterv, gatherv, barrier, bcast
        double total_comm_elapsed = (end_comm - begin_comm) + (end_Bcast - begin_Bcast) + (end_Bcast1 - begin_Bcast1) + (end_sync - begin_sync);
        //printf("comm_e_sec: %.9f\n",total_comm_elapsed);

        //read - write - memory aloc & free memory- internal procedures (calc distribution & calc lines per process & verifications)
        double other_instructions = elapsed - mult_elapsed;
        //printf("aux_instructions %.9f\n", other_instructions);

        matrix_write(argv[3], matC, n);
        printf("total_e_sec %.9f mult_e_sec %.9f comm_e_sec %.9f aux_instructions %.9f\n", elapsed, mult_elapsed, total_comm_elapsed, other_instructions);

    }

    free(submatA);
    free(submatC);
    free(matB);
    free(send_counts);
    free(displacements);
    if (rank == 0) {
        free(matA);
        free(matC);
    }

    MPI_Finalize();
    return 0;
}
