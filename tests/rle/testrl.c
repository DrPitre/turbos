#include <stdio.h>
#include <string.h>
#include "rlenc.c"
#include "rldec.c"

static int roundtrip(unsigned char *input, int size)
{
    unsigned char encoded[1024];
    unsigned char decoded[512];
    int encoded_size = rlenc(input, encoded, size);
    int decoded_size = rldec(encoded, decoded, encoded_size);
    return decoded_size == size && memcmp(input, decoded, size) == 0;
}

int main(void)
{
    unsigned char sample[] = "DDDDDACDBBBBBDDD";
    unsigned char expected[] = {5, 'D', 1, 'A', 1, 'C', 1, 'D', 5, 'B', 3, 'D'};
    unsigned char encoded[32];
    unsigned char repeated[512];
    unsigned char alternating[512];
    memset(repeated, 0xff, sizeof repeated);
    for (int i = 0; i < 512; i++)
        alternating[i] = (unsigned char)(i % 2);
    if (rlenc(sample, encoded, 16) != sizeof expected ||
        memcmp(encoded, expected, sizeof expected) != 0 ||
        !roundtrip(sample, 16) || !roundtrip(sample, 0) ||
        !roundtrip(sample, 1) || !roundtrip(repeated, 255) ||
        !roundtrip(repeated, 256) || !roundtrip(repeated, 512) ||
        !roundtrip(alternating, 512) || rldec(encoded, sample, 1) != -1) {
        fputs("RLE test failed\n", stderr);
        return 1;
    }
    puts("RLE tests passed");
    return 0;
}
