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
        fprintf(stderr, "%s: Usage: <input> <output> [--cut-brackets,--verbose]\n", argv[0]);
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

    bool cutbrackets = false;
    bool verbose = false;

    for (int i = 3; i < argc; i++) {
        char* arg = argv[i];
        if (strcmp(arg, "--cut-brackets") == 0) {
            cutbrackets = true;
        } else if (strcmp(arg, "--verbose") == 0) {
            verbose = true;
        } else {
            fprintf(stderr, "Invalid argument: %s\n", arg);
            return 1;
        }
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
            strncpy(vendor_id, buf, 4);
            strncpy(vendor_name, buf + 6, 4096);
            uint64_t vendor_name_size = strlen(vendor_name);
            // remove newline at the end
            if (vendor_name[vendor_name_size - 1] == '\n') {
                vendor_name[vendor_name_size - 1] = '\0';
            }
            //fprintf(out_fp, "vendor[%s]:%s\n", vendor_id, vendor_name);
        } else if (buf[0] == '\t' && buf[1] != '\t' && is_valid_hex_n(buf + 1, 4)) {
            strncpy(device_id, buf + 1, 4);
            strncpy(device_name, buf + 7, 4096);
            uint64_t device_name_size = strlen(device_name);
            // remove newline at the end
            if (device_name[device_name_size - 1] == '\n') {
                device_name[device_name_size - 1] = '\0';
                device_name_size -= 1;
            }
            uint64_t device_offset = 0;
            if (cutbrackets) {
                char* bracket_open = strstr(device_name, "[");
                char* bracket_close = strstr(device_name, "]");
                if (bracket_open) {
                    device_offset = bracket_open - device_name + 1;
                }
                if (bracket_close) {
                    *(bracket_close) = '\0';
                }

            }
            uint64_t vendor_offset = 0;
            if (cutbrackets) {
                char* bracket_open = strstr(vendor_name, "[");
                char* bracket_close = strstr(vendor_name, "]");
                if (bracket_open) {
                    vendor_offset = bracket_open - vendor_name + 1;
                }
                if (bracket_close) {
                    *(bracket_close) = '\0';
                }

            }
            fprintf(out_fp, "0x%s0x%s:%s %s", vendor_id, device_id, vendor_name + vendor_offset, device_name + device_offset);
            fputc(0x00, out_fp);
        } else if (verbose) {
            fprintf(stderr, "unmatched line: %s", buf);
        }
    }

    fclose(in_fp);
    fclose(out_fp);
   
    return 0;
}
