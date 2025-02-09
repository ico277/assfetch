#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

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
        fprintf(stderr, "Processing: %s", buf);

        if (buf[0] == '\t' && buf[1] != '\t' &&  sscanf(buf, "%4s  %4095[^\n]", vendor_id, vendor_name) == 2) {
            fprintf(stderr, "VendorID: %s | VendorName: %s\n", vendor_id, vendor_name);
        }
        else if (sscanf(buf, "\t%4s  %4095[^\n]", device_id, device_name) == 2) {
            fprintf(stderr, "DeviceID: %s | DeviceName: %s\n", device_id, device_name);
            fprintf(out_fp, "0x%s 0x%s %s %s\n", vendor_id, device_id, vendor_name, device_name);
        }
        /*else if (buf[0] == '\t' && buf[1] == '\t') {
            // This is a subdevice line, so we skip it
            continue;
        }*/
        else {
            fprintf(stderr, "Unmatched line: %s", buf);
        }
    }

    fclose(in_fp);
    fclose(out_fp);
   
    return 0;
}
