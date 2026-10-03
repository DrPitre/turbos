/*
 * RLE encoder.
 *
 * For the worst case, the dst buffer needs to be twice as large as the src.
 *
 * Example 1:
 *  8 bytes of input:  ABACCCABA
 * 12 bytes of output: [1]A[1]B[1]A[3]C[1]A[1]B
 *
 * Example 2:
 * 16 bytes of input:  DDDDDACDBBBBBDDD
 * 12 bytes of output: [5]D[1]A[1]C[1]D[5]B[3]D
 */

int rlenc(unsigned char *src, unsigned char *dst, int src_size)
{
    if (src_size <= 0)
        return 0;

    unsigned char rle_count = 1;
    unsigned char rle_byte = src[0];
    int dst_size = 0;
    for (int i = 1; i < src_size; i++) {
        if (src[i] == rle_byte && rle_count < 255) {
            rle_count++;
        } else {
            dst[dst_size++] = rle_count;
            dst[dst_size++] = rle_byte;
            rle_count = 1;
            rle_byte = src[i];
        }
    }
    dst[dst_size++] = rle_count;
    dst[dst_size++] = rle_byte;
    return dst_size;
}
