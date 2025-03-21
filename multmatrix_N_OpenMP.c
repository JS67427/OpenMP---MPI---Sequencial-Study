#include <stdio.h>
#include <stdlib.h>
#include <omp.h>
#include <time.h>

int **matrix_new(int n) {
    int **matrix = (int **)malloc(n * sizeof(int *));
    for (int i = 0; i < n; i++) {
        matrix[i] = (int *)malloc(n * sizeof(int));
    }
    return matrix;
}

void matrix_get(const char *filename, int **matrix, int n) {
    FILE *file = fopen(filename, "r");
    if (file == NULL) {
        perror("fopen failed!");
        exit(1);
    }
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            fscanf(file, "%d", &matrix[i][j]);
        }
    }
    fclose(file);
}

void matrix_write(const char *filename, int **matrix, int n) {
    FILE *file = fopen(filename, "w");
    if (file == NULL) {
        perror("fopen failed!");
        exit(1);
    }
    
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            fprintf(file, "%d ", matrix[i][j]);
        }
        fprintf(file, "\n");
    }
    fclose(file);
}

void matrix_free(int **matrix, int n) {
    for (int i = 0; i < n; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

void matrix_multiply(int **A, int **B, int **C, int n) {
    #pragma omp parallel for collapse(2)
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            C[i][j] = 0;
            for (int k = 0; k < n; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <matA> <matB> <matC> <n>\n", argv[0]);
        exit(1);
    }

    struct timespec begin, end, begin_mult, end_mult;
    clock_gettime(CLOCK_MONOTONIC, &begin);

    int n = atoi(argv[4]);
    if (n <= 0) {
        fprintf(stderr, "Error: The value of N must be a positive integer.\n");
        exit(1);
    }

    int **matA = matrix_new(n);
    int **matB = matrix_new(n);
    int **matC = matrix_new(n);

    matrix_get(argv[1], matA, n);
    matrix_get(argv[2], matB, n);

    double start_time = omp_get_wtime();
    matrix_multiply(matA, matB, matC, n);
    double end_time = omp_get_wtime();

    matrix_write(argv[3], matC, n);

    clock_gettime(CLOCK_MONOTONIC, &end);

    matrix_free(matA, n);
    matrix_free(matB, n);
    matrix_free(matC, n);

    double elapsed = (end.tv_sec - begin.tv_sec) * 1e9 + (end.tv_nsec - begin.tv_nsec);
    double mult_elapsed = end_time - start_time;

    printf("total_e_sec: %.9f mult_e_sec: %.9f \n", elapsed / 1e9 ,mult_elapsed);
    
    return 0;
}
