#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int **matrix_new(int n) {
    int **matrix = (int **)malloc(n * sizeof(int *));
    for (int i = 0; i < n; i++) {
        matrix[i] = (int *)malloc(n * sizeof(int));
    }
    return matrix;
}

void matrix_print(int **matrix, int n) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            printf("%d ", matrix[i][j]);
        }
        printf("\n");
    }
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

void matrix_free(int **matrix, int n) {
    for (int i = 0; i < n; i++) {
        free(matrix[i]);
    }
    free(matrix);
}

int **matrix_multiply(int **A, int **B, int n) {
    int **C = matrix_new(n);
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            C[i][j] = 0;
            for (int k = 0; k < n; k++) {
                C[i][j] += A[i][k] * B[k][j];
            }
        }
    }
    return C;
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

void check_argc(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: <matA> <matB> <matC> <n>\n");
        exit(1);
    }

    FILE *fileA = fopen(argv[1], "r");
    if (fileA == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matA.\n", argv[1]);
        exit(1);
    }
    fclose(fileA);

    FILE *fileB = fopen(argv[2], "r");
    if (fileB == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matB.\n", argv[2]);
        exit(1);
    }
    fclose(fileB);

    FILE *fileC = fopen(argv[3], "w");
    if (fileC == NULL) {
        fprintf(stderr, "Error: Could not open matrix file '%s' for matC.\n", argv[3]);
        exit(1);
    }
    fclose(fileC);

    int n = atoi(argv[4]);
    if (n <= 0) {
        fprintf(stderr, "Error: The value of N must be a positive integer.\n");
        exit(1);
    }
}


int main(int argc, char *argv[]) {
    check_argc(argc, argv);

	struct timespec begin, end, begin_mult, end_mult;
	clock_gettime(CLOCK_MONOTONIC, &begin);

    int n = atoi(argv[4]);

    int **matA = matrix_new(n);
    int **matB = matrix_new(n);

    matrix_get(argv[1], matA, n);
    matrix_get(argv[2], matB, n);

    //matrix_print(matA, n);
    //matrix_print(matB, n);

    clock_gettime(CLOCK_MONOTONIC, &begin_mult);

    //multiply matrix

    int **matC = matrix_multiply(matA, matB, n);
    //matrix_print(matC, n);

    clock_gettime(CLOCK_MONOTONIC, &end_mult);

    //write into file
    matrix_write(argv[3], matC, n);

    //free memory
    matrix_free(matA, n);
    matrix_free(matB, n);
    matrix_free(matC, n);

    clock_gettime(CLOCK_MONOTONIC, &end);

    double elapsed = (end.tv_sec - begin.tv_sec) * 1e9 + (end.tv_nsec - begin.tv_nsec);
    //total_execution_time_nsec = total_e_nsec
    //total_execution_time_sec = total_e_sec
    //printf("total_e_nsec: %.9f nsec\n", elapsed);
    printf("total_e_sec: %.9f sec\n", elapsed / 1e9);
    double mult_elapsed = (end_mult.tv_sec - begin_mult.tv_sec) * 1e9 + (end_mult.tv_nsec - begin_mult.tv_nsec);
    //mult_execution_time_nsec = mult_e_nsec
    //mult_execution_time_sec = mult_e_sec
    //printf("mult_e_nsec: %.9f nsec\n", mult_elapsed);
    printf("mult_e_sec: %.9f sec\n", mult_elapsed / 1e9);
    
    return 0;
}
