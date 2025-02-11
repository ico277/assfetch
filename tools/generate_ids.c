#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <ctype.h>
#include <stdint.h>

bool is_valid_hex_n(char* str, uint64_t n) {
    for (uint64_t i = 0; i < n; i++) {
        char c = str[i];
        if (!isxdigit(c)) {
            return false;
        }
    }

    return true;
}

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

    char buf[4096] = {0};

    char vendor_id[5] = {0};
    char vendor_name[4096] = {0};

    char device_id[5] = {0};
    char device_name[4096] = {0};

    while (fgets(buf, 4096, in_fp)) {
        if (buf[0] == '#') continue;
        // TODO stuffies
        if (buf[0] != '\t' && is_valid_hex_n(buf, 4)) {
            fprintf(out_fp, "vendor: %s\n", buf);
        } else if (buf[0] == '\t' && buf[1] != '\t' && is_valid_hex_n(buf + 1, 4)) {
            fprintf(out_fp, "device: %s\n", buf);
        } else {
            fprintf(stderr, "Unmatched line: %s", buf);
        }
    }

    fclose(in_fp);
    fclose(out_fp);
   
    return 0;
}
