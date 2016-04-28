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
    const int redundancy = 1;
    int i, idx;
    uint8_t * out;
    uint64_t block = 4*1024*1024;
    uint64_t filesize = 1024*1024*1024;
    filesize = filesize * 50;
    
    uint8_t * in = talloc(uint8_t, block);

    memset(in, '1' , block);
   
    
    
    ec_initialize_tables(fragments, redundancy);
    
    out = talloc(uint8_t, block/fragments);
    memset(out, 0 , block/fragments);

    printf("%ld\n",filesize/block); 
    for (i=0; i< (filesize/block); i++ )
    {
        for (idx=4; idx<(fragments + redundancy); idx++)
        {
            out = talloc(uint8_t, block/fragments);
            //memset(out, 0 , block/fragments);
            ec_method_encode(fragments, redundancy, g_tbls, idx,
                            in, out, block);
            free(out);
            //printf("%s\n",out);      
        }
    }

    return 0;
}

#ifdef __cplusplus
}
#endif