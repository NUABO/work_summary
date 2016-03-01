#ifndef __EC_H__
#define __EC_H__

extern uint8_t *g_matrix; 
extern uint8_t *g_tbls;

int32_t ec_initialize_tables(int fragments, int redundancy);

#endif /* __EC_H__ */
