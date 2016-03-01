#ifdef __cplusplus
extern "C"{
#endif

#include <stdint.h> /*定义了 uint64_t等*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "xor_op.h"

#define talloc(type, num) (type *) malloc(sizeof(type)*(num))

void
region_xor(unsigned char** src, unsigned char* parity, int src_size, unsigned size);

int32_t main(int32_t argc, char **argv)
{
    const int fragments = 4;
    //const int redundancy = 1;
    int i,j;
    uint8_t * out;
    uint64_t block = 4*1024*1024;
    uint64_t frag_size = block / fragments;
    uint64_t filesize = 1024*1024*1024;
    filesize = filesize * 50;
    
    uint8_t * in[fragments] ;
    for (i=0; i<fragments; i++)
    {
       in[i] = talloc(uint8_t, frag_size);
       memset(in[i], '1' , frag_size);
    }

    
    
    out = talloc(uint8_t, frag_size);
    memset(out, 0 , frag_size);

    printf("%ld\n",filesize/block); 
    for (j=0; j< (filesize/block); j++ )
    {
        for (i=0; i<fragments; i++)
        {
           in[i] = talloc(uint8_t, frag_size);
           memset(in[i], '1' , frag_size);
        }
        //模拟有多次memcpy
        for (i=0; i< 8; i++)
        {  
           memcpy(in[1], in[2] , frag_size);
        }
        
        out = talloc(uint8_t, frag_size);
        //memset(out, 0 , frag_size);
        region_xor(in, out, fragments, frag_size);
        free(out);
        //printf("%s\n",out);
        for (i=0; i<fragments; i++)
        {
           free(in[i]) ;
           
        }
    }

    return 0;
}

#ifdef __cplusplus
}
#endif