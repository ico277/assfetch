#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "%s: Usage: [input] [output]\n", argv[0]);
        return 1;
    }

    FILE* in_fp = fopen(argv[1], "r");
    FILE* out_fp = fopen(argv[2], "w");
    
    if (!in_fp) {
        fprintf(stderr, "%s: Could not open '%s' for reading!\n", argv[0], argv[1]);
        return 1;
    }
    if (!out_fp) {
        fprintf(stderr, "%s: Could not open '%s' for writing!\n", argv[0], argv[2]);
        return 1;
    }

    char buf[4096];

    while (fgets(buf, 4096, in_fp)) {
        if (buf[0] == '#') continue;
        //strstr();
        puts(buf);   
    }
   
    return 0;
}
