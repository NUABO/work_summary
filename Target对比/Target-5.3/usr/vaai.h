#ifndef __XCOPY_H__
#define __XCOPY_H__

#define XCOPY_HDR_LEN                   16
#define XCOPY_TARGET_DESC_LEN           32
#define XCOPY_SEGMENT_DESC_B2B_LEN      28
#define XCOPY_NAA_LOCALLY_LEN           8
#define XCOPY_MAX_SECTORS               1024

#define VPD_MAX_UNMAP_LBA_COUNT            (32 * 1024 * 1024) //32MB * 512 = 16GB
#define VPD_MAX_UNMAP_LBA_COUNT_ONCE       (4 * 1024 * 1024)  //4MB * 512 = 2GB
#define VPD_MAX_UNMAP_BLOCK_DESC_COUNT     0x04

#define VPD_MAX_WRITE_SAME_LENGTH 0xFFFFFFFF

#pragma pack(1)
struct xcopy {
	uint32_t src_tid;
	uint32_t src_lunid;
	uint32_t dst_tid;
	uint32_t dst_lunid;

	uint64_t src_lba;
	uint64_t dst_lba;
	uint32_t stdi;
	uint32_t dtdi;
	uint32_t lba_cnt;
};
#pragma pack()

struct unmap_state {
   uint32_t count;
   uint32_t *nlbas;  //unmap的lba数量
   uint64_t *lba;    //起始位置的lba
};

int handle_receive_copy_result(struct scsi_cmd *cmd);
int handle_xcopy(struct scsi_cmd *cmd, struct xcopy *xc);
int serialize_xcopy(struct xcopy *xc, char **buf);
int handle_unmap(struct scsi_cmd *cmd, struct unmap_state *umap_state);
int handle_writesame(struct scsi_cmd *cmd);
int handle_caw(struct scsi_cmd *cmd, uint32_t block_size);

#endif /* __XCOPY_H__ */
