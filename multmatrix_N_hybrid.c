#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include <omp.h>

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
    #pragma omp parallel for collapse(2)
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            matC[i * n + j] = 0;
            for (int k = 0; k < n; k++) {
                matC[i * n + j] += matA[i * n + k] * matB[k * n + j];
            }
        }
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
        if (argc != 5) {
            fprintf(stderr, "Usage: <matA> <matB> <matC> <n>\n");
            MPI_Abort(MPI_COMM_WORLD, 1);
        }
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

    begin_Bcast1 = MPI_Wtime();
    MPI_Bcast(matB, n * n, MPI_INT, 0, MPI_COMM_WORLD);
    end_Bcast1 = MPI_Wtime();

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

    end_exec = MPI_Wtime();

    if (rank == 0) {
        double elapsed = end_exec - begin_exec;
        double mult_elapsed = end_mult - begin_mult;
        double total_comm_elapsed = (end_comm - begin_comm) + (end_Bcast - begin_Bcast) + (end_Bcast1 - begin_Bcast1) + (end_sync - begin_sync);
        double other_instructions = elapsed - mult_elapsed;
        
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
