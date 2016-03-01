#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <inttypes.h>

#include "ec-method.h"
#include "erasure_code.h"

uint8_t *g_matrix; 
uint8_t *g_tbls;


int32_t ec_initialize_tables(int fragments, int redundancy)
{
    
	int k, m;
    uint8_t *matrix; 
    uint8_t *p_tbls;

    
    k = fragments;
    m = redundancy;
    
    p_tbls = talloc(uint8_t, 32*k*m);
    if (NULL == p_tbls)
    {
        printf("Failed to init ec tables.");
        return -1;
    }

    matrix = talloc(uint8_t, (k+m)*k);
    if (NULL == matrix)
    {
        printf("Failed to init ec matrix.");
        return -1;
    }

    //# ¿ÂÎ÷¾ØÕó
    gf_gen_cauchy1_matrix(matrix, m+k, k);
    int i, j;
    for  (i=0; i<m+k; i++)
    {
        for(j=0; j<k; j++)
        {
            printf("%d ", *(matrix+i*(m+k)+j));
        }
        printf("\n");
    }
            
    
    ec_init_tables(k, m, &matrix[k*k], p_tbls);

    for  (i=0; i<32*k; i++)
    {
        for(j=0; j<k; j++)
        {
            printf("%d ", *(p_tbls+i*(32*k)+j));
        }
        printf("\n");
    }
    
    g_matrix = matrix;
    g_tbls = p_tbls;

    return 0;
}


