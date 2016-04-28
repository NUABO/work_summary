#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h> /*定义了 uint64_t等*/
#include <stdio.h>
#include <string.h>

#include "ec-method.h"
#include "ec.h"

int32_t main(int32_t argc, char **argv)
{
    const int fragments = 4;
    const int redundancy = 2;
    int i, idx;
    uint8_t * out;
    uint8_t * in = talloc(uint8_t, EC_METHOD_CHUNK_SIZE*fragments);
    for (i=0; i<fragments; i++)
    {
        memset(in + i*EC_METHOD_CHUNK_SIZE, '1' + i, EC_METHOD_CHUNK_SIZE);
    }
    
    
    ec_initialize_tables(fragments, redundancy);


    uint8_t * encode_data[fragments + redundancy];
    uint8_t * in_data[fragments];
    for (idx=0; idx<(fragments + redundancy); idx++)
    {
        out = talloc(uint8_t, EC_METHOD_CHUNK_SIZE + 1);
        memset(out, 0 , EC_METHOD_CHUNK_SIZE);
        ec_method_encode(fragments, redundancy, g_tbls, idx,
                        in, out, EC_METHOD_CHUNK_SIZE*fragments);
        printf("%s\n",out);
        encode_data[idx] = out;
        
    }
    uint32_t rows[] = {0,1,2,5};
    for (i=0; i<fragments; i++)
    {
        in_data[i] = encode_data[rows[i]];
    }

    printf("\n");
    uint8_t * outdata = talloc(uint8_t, EC_METHOD_CHUNK_SIZE*fragments + 1);
    ec_method_decode(EC_METHOD_CHUNK_SIZE, fragments, g_matrix, rows,
                        in_data, outdata);
    printf("%s\n",outdata);
    return 0;
}

#ifdef __cplusplus
}
#endif