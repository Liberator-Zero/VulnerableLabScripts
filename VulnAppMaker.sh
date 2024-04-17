#!/bin/bash

# Create the source file for the stack buffer overflow vulnerability
cat << 'EOF' > stackroot.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void secretFunction() {
    printf("stackroot-flag\n");
    system("/bin/sh");  // This will give a shell if exploited
}

void echoInput() {
    char buffer[64];
    read(STDIN_FILENO, buffer, 200);  // Read more than buffer size to overflow
}

int main() {
    echoInput();
    return 0;
}
EOF

# Compile the stack buffer overflow program with root privileges and set suid bit
gcc -fno-stack-protector -z execstack -o stackroot stackroot.c
sudo chown root:root stackroot
sudo chmod 4755 stackroot

# Create the source file for the heap buffer overflow vulnerability
cat << 'EOF' > heaproot.c
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void secretFunction() {
    printf("heaproot-flag\n");
    system("/bin/sh"); // Dangerous: gives shell access
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <input>\n", argv[0]);
        return 0;
    }

    char *buffer = malloc(64); // Allocate buffer on the heap
    char *control = malloc(8); // Next allocation, could control flow
    strcpy(buffer, argv[1]); // Vulnerable: no buffer size check

    free(control); // Free control block
    free(buffer); // Free buffer

    return 0;
}
EOF

# Compile the heap buffer overflow program with root privileges and set suid bit
gcc -fno-stack-protector -o heaproot heaproot.c
sudo chown root:root heaproot
sudo chmod 4755 heaproot

echo "Both vulnerable applications are compiled and set with appropriate permissions."
