#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

void generate_matrix(int n, const char *filename){
		//xor between time since 1970 and process id in execution
		srand(time(NULL) ^ getpid());
        //w -> write mode
        FILE* file = fopen(filename, "w");
        if (file == NULL) {
                perror("fopen failed!");
                exit(1);
		}
        for(int i = 0; i < n; i++){
                for(int j = 0; j < n; j++){
                        //values between -5 and 5
                        int value = (rand() % 11) - 5;
                        fprintf(file, "%d ", value);
                }
                fprintf(file, "\n");
        }
        fclose(file);
}

int main(int argc, char *argv[]){
        //test n
        int n = atoi(argv[1]);
        if(n <= 0){
                perror("Matrix can't be <= 0!");
                exit(1);
        }
        //test arguments on cmd
        if(argc != 3){
                perror("invalid arguments! <n> or <filename>");
                exit(1);
        }
        generate_matrix(n,argv[2]);
        return 0;
}
