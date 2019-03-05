#include <string.h>
#include <stdint.h>

#include "list.h"
#include "tgtd.h"
#include "util.h"
#include "log.h"
#include "scsi.h"
#include "bs_thread.h"
#include "target.h"
#include "vaai.h"

int get_cdb_length(uint8_t *cdb)
{
	uint8_t group_code = cdb[0] >> 5;

	/* See spc-4 4.2.5.1 operation code */
	switch (group_code) {
	case 0: /*000b for 6 bytes commands */
		return 6;
	case 1: /*001b for 10 bytes commands */
	case 2: /*010b for 10 bytes commands */
		return 10;
	case 3: /*011b Reserved ? */
		if (cdb[0] == 0x7f)
			return 8 + cdb[7];
		return -EINVAL;
	case 4: /*100b for 16 bytes commands */
		return 16;
	case 5: /*101b for 12 bytes commands */
		return 12;
	case 6: /*110b Vendor Specific */
	case 7: /*111b Vendor Specific */
	default:
		/* TODO: */
		return -EINVAL;
	}
}

uint64_t get_lba(uint8_t *cdb)
{
	uint16_t val;

	switch (get_cdb_length(cdb)) {
	case 6:
		val = be16toh(*((uint16_t *)&cdb[2]));
		return ((cdb[1] & 0x1f) << 16) | val;
	case 10:
		return be32toh(*((u_int32_t *)&cdb[2]));
	case 12:
		return be32toh(*((u_int32_t *)&cdb[2]));
	case 16:
		return be64toh(*((u_int64_t *)&cdb[2]));
	default:
		return -EINVAL;
	}
}

uint32_t get_xfer_length(uint8_t *cdb)
{
	switch (get_cdb_length(cdb)) {
	case 6:
		return cdb[4];
	case 10:
		return be16toh(*((uint16_t *)&cdb[7]));
	case 12:
		return be32toh(*((u_int32_t *)&cdb[6]));
	case 16:
		return be32toh(*((u_int32_t *)&cdb[10]));
	default:
		return -EINVAL;
	}
}
/*
int serialize_xcopy(struct xcopy *xc, char **buf) {
	char *p = *buf;
    if (xc == NULL || buf == NULL) {
        return 0;
    }

	//uint32_t src_tid
    *(uint32_t *)p = xc->src_tid;
	p += 4;

	//uint32_t src_lunid
	*(uint32_t *)p = xc->src_lunid;
	p += 4;

	//uint32_t dst_tid
	*(uint32_t *)p = xc->dst_tid;
	p += 4;

	//uint32_t dst_lunid
	*(uint32_t *)p = xc->dst_lunid;
	p += 4;

	//uint64_t src_lba
	*(uint64_t *)p = xc->src_lba;
	p += 8;

	//uint64_t dst_lba
	*(uint64_t *)p = xc->dst_lba;
	p += 8;

	//uint32_t lba_cnt
	*(uint32_t *)p = xc->lba_cnt;

   
	return 36;
}
*/

int handle_receive_copy_result(struct scsi_cmd *cmd) {
	uint16_t val16;
	uint32_t val32;

	uint8_t *buf = scsi_get_in_buffer(cmd);
	uint32_t length = scsi_get_in_length(cmd);

	memset(buf, 0, length);
	/*
	 * From spc4r31, section 6.18.4 OPERATING PARAMETERS service
	 * action
	 */

	/*
	 * SNLID = 1: the copy manager will support an EXTENDED COPY
	 * command parameter list in which the LIST ID USAGE field is
	 * set to 11b
	 */
	buf[4] = 0x01;

	/*
	 * MAXIMUM TARGET COUNT: the max number of target descriptors
	 * that the copy manager allows in a single EXTENDED COPY
	 * target descriptor list.
	 */
	val16 = htobe16(RCR_OP_MAX_TARGET_DESC_COUNT);
	memcpy(&buf[8], &val16, 2);

	/*
	 * MAXIMUM SEGMENT COUNT: the max number of segment descriptors
	 * that the copy manager allows in a single EXTENDED COPY
	 * segment descriptor list.
	 */
	val16 = htobe16(RCR_OP_MAX_SEGMENT_DESC_COUNT);
	memcpy(&buf[10], &val16, 2);

	/*
	 * MAXIMUM DESCRIPTOR LIST LENGTH: the max length, in bytes,
	 * of the target descriptor list and segment descriptor list.
	 */
	val32 = htobe32(RCR_OP_MAX_DESC_LIST_LEN);
	memcpy(&buf[12], &val32, 4);

	/*
	 * MAXIMUM SEGMENT LENGTH: the length, in bytes, of the largest
	 * amount of data that the copy manager supports writing via a
	 * single segment.
	 */
	val32 = htobe32(RCR_OP_MAX_SEGMENT_LEN);
	memcpy(&buf[16], &val32, 4);

	/*
	 * MAXIMUM CONCURRENT COPIES: the max number of EXTENDED COPY
	 * commands with the LIST ID USAGE field set to 00b or 10b that
	 * are supported for concurrent processing by the copy manager.
	 */
	val16 = htobe16(RCR_OP_TOTAL_CONCURR_COPIES);
	memcpy(&buf[34], &val16, 2);

	/*
	 * MAXIMUM CONCURRENT COPIES: the max number of EXTENDED COPY
	 * commands with the LIST ID USAGE field set to 00b or 10b that
	 * are supported for concurrent processing by the copy manager.
	 */
	buf[36] = RCR_OP_MAX_CONCURR_COPIES;

	/*
	 * DATA SEGMENT GRANULARITY: the length of the smallest data
	 * block that copy manager permits in a non-inline segment
	 * descriptor. In power of two.
	 */
	buf[37] = RCR_OP_DATA_SEG_GRAN_LOG2;

	/*
	 * INLINE DATA GRANULARITY: the length of the of the smallest
	 * block of inline data that the copy manager permits being
	 * written by a segment descriptor containing the 04h descriptor
	 * type code (see 6.3.7.7). In power of two.
	 */
	buf[38] = RCR_OP_INLINE_DATA_GRAN_LOG2;

	/*
	 * HELD DATA GRANULARITY: the length of the smallest block of
	 * held data that the copy manager shall transfer to the
	 * application client in response to a RECEIVE COPY RESULTS
	 * command with RECEIVE DATA service action (see 6.18.3).
	 * In power of two.
	 */
	buf[39] = RCR_OP_HELD_DATA_GRAN_LOG2;

	/*
	 * IMPLEMENTED DESCRIPTOR LIST LENGTH: the length, in bytes, of
	 * the list of implemented descriptor type codes.
	 */
	buf[43] = RCR_OP_IMPLE_DES_LIST_LENGTH;

	/*
	 * The list of implemented descriptor type codes: one byte for
	 * each segment or target DESCRIPTOR TYPE CODE value (see 6.3.5)
	 * supported by the copy manager,
	 */
	buf[44] = XCOPY_SEG_DESC_TYPE_CODE_B2B; /* block --> block */
	buf[45] = XCOPY_TARGET_DESC_TYPE_CODE_ID; /* Identification descriptor */

	/* AVAILABLE DATA (n-3)*/
	val32 = htobe32(42);
	memcpy(&buf[0], &val32, 4);

    return SAM_STAT_GOOD;
}

/* For now only supports block -> block type */
static int xcopy_parse_segment_descs(uint8_t *seg_desc, struct xcopy *xcopy,
				     uint8_t sdll, uint8_t *sense) {
    uint8_t desc_len;

	/*
	 * From spc4r31, section 6.3.7.5 Block device to block device
	 * operations
	 *
	 * The segment descriptor size should be 28 bytes
	 */
	if (sdll % XCOPY_SEGMENT_DESC_B2B_LEN != 0) {
        Log_error("illegal block --> block type segment descriptor length %u\n", sdll);
		return ILLEGAL_REQUEST;
	}

	if (sdll > RCR_OP_MAX_SEGMENT_DESC_COUNT * XCOPY_SEGMENT_DESC_B2B_LEN) {
        Log_error("only %u segment descriptor(s) supported, but there are %u\n", 
			RCR_OP_MAX_SEGMENT_DESC_COUNT, sdll / XCOPY_SEGMENT_DESC_B2B_LEN);
		return ILLEGAL_REQUEST;
	}

    /* EXTENDED COPY segment descriptor type codes block --> block */
	if (seg_desc[0] != XCOPY_SEG_DESC_TYPE_CODE_B2B) {
        Log_error("unsupport segment descriptor type code 0x%x\n", seg_desc[0]);
		return ILLEGAL_REQUEST;
	}

	/*
	 * For block -> block type the length is 4-byte header + 0x18-byte
	 * data.
	 */
	desc_len = be16toh(*(uint16_t *)&seg_desc[2]);
	if (desc_len != 0x18) {
        Log_error("invalid length for block->block type 0x%x\n", desc_len);
		return ILLEGAL_REQUEST;
	}

	/*
	 * From spc4r31, section 6.3.7.1 Segment descriptors introduction
	 *
	 * The SOURCE TARGET DESCRIPTOR INDEX field contains an index into
	 * the target descriptor list (see 6.3.1) identifying the source
	 * copy target device. The DESTINATION TARGET DESCRIPTOR INDEX field
	 * contains an index into the target descriptor list (see 6.3.1)
	 * identifying the destination copy target device.
	 */
	 xcopy->stdi = be16toh(*(uint16_t *)&seg_desc[4]);
	 xcopy->dtdi = be16toh(*(uint16_t *)&seg_desc[6]);
	 Log_debug("segment descriptor: stdi: %u dtdi: %u\n", xcopy->stdi, xcopy->dtdi);

	 xcopy->lba_cnt = be16toh(*(uint16_t *)&seg_desc[10]);
	 xcopy->src_lba = be64toh(*(uint64_t *)&seg_desc[12]);
	 xcopy->dst_lba = be64toh(*(uint64_t *)&seg_desc[20]);
	 Log_debug("segment descriptor: lba_cnt: %hu src_lba: %lu dst_lba: %lu\n", xcopy->lba_cnt, 
	 	xcopy->src_lba, xcopy->dst_lba);

     return SAM_STAT_GOOD;
}

static int xcopy_parse_target_id(struct scsi_lu *lun, struct xcopy *xcopy, 
        uint8_t *tgt_desc, int32_t index, uint8_t *sense) {
    /*
	 * CODE SET: for now only binary type code is supported.
	 */
	if ((tgt_desc[4] & 0xf) != 0x1) {
        Log_error("id target CODE DET only support binary type!\n");
		return ILLEGAL_REQUEST;
	}
    Log_debug("designation descriptor CODE SET: 0x%x\n", (tgt_desc[4] & 0xf));
	/*
	 * ASSOCIATION: for now only LUN type code is supported.
	 */
    if ((tgt_desc[5] & 0x30) != 0x00) {
        Log_error("id target ASSOCIATION other than LUN not supported!\n");
		return ILLEGAL_REQUEST;
    }
	Log_debug("designation descriptor ASSOCIATION: 0x%x\n", (tgt_desc[5] & 0x30));

	/*
	 * DESIGNATOR TYPE: for now only NAA type code is supported.
	 *
	 * The designator type define please see: such as
	 * From spc4r31, section 7.8.6.1 Device Identification VPD page
	 * overview
	 */
    if ((tgt_desc[5] & 0x0f) != 0x3) {
        Log_error("id target DESIGNATOR TYPE other than NAA not supported!\n");
		return ILLEGAL_REQUEST;
    }
	Log_debug("designation descriptor DESIGNATOR TYPE: 0x%x\n", (tgt_desc[5] & 0x0f));
	/*
	 * Check for matching 8 byte length for NAA IEEE Registered Extended
	 * Assigned designator
	 */
    if (tgt_desc[7] != XCOPY_NAA_LOCALLY_LEN) {
        Log_error("id target DESIGNATOR LENGTH should be 16, but it's: %d\n", tgt_desc[7]);
		return ILLEGAL_REQUEST;
    }
	Log_debug("designation descriptor DESIGNATOR LENGTH: 0x%x\n", tgt_desc[7]);

	/*
	 * Check for NAA(Network Address Authority) IEEE Registered Extended Assigned header. 0x6
	 */
    if ((tgt_desc[8] >> 4) != 0x03) {
        Log_error("id target NAA designator type: 0x%x\n", tgt_desc[8] >> 4);
		return ILLEGAL_REQUEST;
    }

	if (index == xcopy->stdi) {
		xcopy->src_tid = (be32toh(*(uint32_t *)&tgt_desc[8]) & 0x0fffffff);
		xcopy->src_lunid = be32toh(*(uint32_t *)&tgt_desc[12]);
		Log_debug("source index: %u, stdi: %u tid: %u lunid: %u\n", index, xcopy->stdi, 
			xcopy->src_tid, xcopy->src_lunid);
	}

	if (index == xcopy->dtdi) {
		xcopy->dst_tid = (be32toh(*(uint32_t *)&tgt_desc[8]) & 0x0fffffff);
		xcopy->dst_lunid = be32toh(*(uint32_t *)&tgt_desc[12]);
		Log_debug("destination index: %u, dtdi: %u tid: %u lunid: %u\n", index, xcopy->dtdi, 
			xcopy->dst_tid, xcopy->dst_lunid);
	}

    return SAM_STAT_GOOD;
}

static int xcopy_parse_target_descs(struct scsi_lu *lun, struct xcopy *xcopy, 
        uint8_t *tgt_desc, uint16_t tdll, uint8_t *sense) {
    int i, ret;
	
	if (tdll > RCR_OP_MAX_TARGET_DESC_COUNT * XCOPY_TARGET_DESC_LEN) {
        Log_error("only %u target descriptor(s) supported, but there are %u\n", 
			RCR_OP_MAX_TARGET_DESC_COUNT, tdll / XCOPY_TARGET_DESC_LEN);
		return ILLEGAL_REQUEST;
	}

	for (i = 0; i < RCR_OP_MAX_TARGET_DESC_COUNT; i++) {
        /*
		 * Only Identification Descriptor Target Descriptor support
		 * for now.
		 */
		if (tgt_desc[0] == XCOPY_TARGET_DESC_TYPE_CODE_ID) {
            ret = xcopy_parse_target_id(lun, xcopy, tgt_desc, i, sense);
			if (ret != SAM_STAT_GOOD) {
                return ret;
			}

			tgt_desc += XCOPY_TARGET_DESC_LEN;
		} else {
            Log_error("unsupport target descriptor type code 0x%x\n", tgt_desc[0]);
		    return ILLEGAL_REQUEST;
		}
	}

	return SAM_STAT_GOOD;
}

int xcopy_parse_parameter_list(struct scsi_cmd *cmd, struct xcopy *xc) {
	uint32_t inline_dl;
	uint16_t sdll, tdll;
    uint8_t *sense = cmd->sense_buffer;
	uint8_t *seg_desc, *tgt_desc;
	struct scsi_lu *lun = cmd->dev;
	uint8_t *buf = scsi_get_out_buffer(cmd);
	uint32_t length = scsi_get_out_length(cmd);
	int ret;
	
    /*
	 * From spc4r31, section 6.18.4 OPERATING PARAMETERS service action
	 *
	 * A supports no list identifier (SNLID) bit set to one indicates
	 * the copy manager supports an EXTENDED COPY (see 6.3) command
	 * parameter list in which the LIST ID USAGE field is set to 11b
	 * and the LIST IDENTIFIER field is set to zero as described in
	 * table 105 (see 6.3.1).
	 *
	 * From spc4r31, section 6.3.1 EXTENDED COPY command introduction
	 *
	 * LIST ID USAGE == 11b, then the LIST IDENTIFIER field should be
	 * as zero.
	 */
	 if ((buf[1] & 0x18) != 0x18 || buf[0]) {
         Log_error("LIST ID USAGE: 0x%x, LIST IDENTIFIER: 0x%x\n", (buf[1] & 0x18) >> 3, buf[0]);
		 return ILLEGAL_REQUEST;
	 }

    /*
	 * From spc4r31, section 6.3.6.1 Target descriptors introduction
	 *
	 * All target descriptors (see table 108) are 32 bytes or 64 bytes
	 * in length
	 */
	 tdll = be16toh(*(uint16_t *)&buf[2]);
	 if (tdll % 32 != 0) {
         Log_error("illegal target descriptor length: %u\n", tdll);
		 return ILLEGAL_REQUEST;
	 }

	 /*
	 * From spc4r31, section 6.3.7.1 Segment descriptors introduction
	 *
	 * Segment descriptors (see table 120) begin with an eight byte header.
	 */
	 sdll = be32toh(*(uint32_t *)&buf[8]);
	 if (sdll < 8) {
        Log_error("illegal segment descriptor length: %u\n", sdll);
		return ILLEGAL_REQUEST;
	 }

    /*
	 * The maximum length of the target and segment descriptors permitted
	 * within a parameter list is indicated by the MAXIMUM DESCRIPTOR LIST
	 * LENGTH field in the copy managers operating parameters.
	 */
	 if (tdll + sdll > RCR_OP_MAX_DESC_LIST_LEN) {
		 Log_error("descriptor list length: %u exceeds maximum %u\n", tdll + sdll, RCR_OP_MAX_DESC_LIST_LEN);
	     return ILLEGAL_REQUEST;
	 }

	 /*
	 * The INLINE DATA LENGTH field contains the number of bytes of inline
	 * data, after the last segment descriptor.
	 */
	 inline_dl = be32toh(*(uint32_t *)&buf[12]);

	 /* From spc4r31, section 6.3.1 EXTENDED COPY command introduction
	 *
	 * The EXTENDED COPY parameter list (see table 104) begins with a 16
	 * byte header.
	 *
	 * The data length in CDB should be equal to tdll + sdll + inline_dl
	 * + parameter list header length
	 */
	 if (length < (XCOPY_HDR_LEN + tdll + sdll + inline_dl)) {
         Log_error("illegal list length: length from CDB is %u,but here the length is %u\n",
			     length, tdll + sdll + inline_dl);
	     return ILLEGAL_REQUEST;
	 }
	 
    Log_debug("processing XCOPY with tdll: %hu sdll: %u inline_dl: %u\n", tdll, sdll, inline_dl);

    /*
	 * Parse the segment descripters and for now we only support block
	 * -> block type.
	 *
	 * The max seg_desc number support is 1(see RCR_OP_MAX_SG_DESC_COUNT)
	 */
	seg_desc = buf + XCOPY_HDR_LEN + tdll;
	ret = xcopy_parse_segment_descs(seg_desc, xc, sdll, sense);
	if (ret != SAM_STAT_GOOD) {
        return ret;
	}

	/*
	 * Parse the target descripter
	 *
	 * The max seg_desc number support is 2(see RCR_OP_MAX_TARGET_DESC_COUNT)
	 */
	tgt_desc = buf + XCOPY_HDR_LEN;
	ret = xcopy_parse_target_descs(lun, xc, tgt_desc, tdll, sense);
	if (ret != SAM_STAT_GOOD) {
        return ret;
	}

    return SAM_STAT_GOOD;
}

int handle_xcopy(struct scsi_cmd *cmd, struct xcopy *xc) {
    uint32_t length;

    if (cmd == NULL || xc == NULL) {
        return SAM_STAT_CHECK_CONDITION;
    }
	
	length = scsi_get_out_length(cmd);

	Log_debug("xcopy cmd length:%u offset:%lu dev_id: %lu tl:%u data direction:%d\n", 
		length, cmd->offset, cmd->dev_id, cmd->tl, cmd->data_dir);

	/*
	 * A parameter list length of zero specifies that copy manager
	 * shall not transfer any data or alter any internal state.
	 */
    if (length == 0) {
        return SAM_STAT_GOOD;
    }

    /*
	 * The EXTENDED COPY parameter list begins with a 16 byte header
	 * that contains the LIST IDENTIFIER field.
	 */
	if (length < XCOPY_HDR_LEN) {
		Log_error("illegal parameter list: length %u < hdr_len %u\n", length, XCOPY_HDR_LEN);
        return ILLEGAL_REQUEST;
	}

	return xcopy_parse_parameter_list(cmd, xc);
}

static inline int check_lbas(struct scsi_lu *lun, uint64_t start_lba, uint64_t lba_cnt) {
    if (start_lba + lba_cnt > lun->size || start_lba + lba_cnt < start_lba) {
        Log_error("cmd exceeds last lba %lu (lba %lu, xfer len %lu)\n", lun->size, start_lba, lba_cnt);
		return ILLEGAL_REQUEST;
    }
    return SAM_STAT_GOOD;
}

int handle_unmap(struct scsi_cmd *cmd, struct unmap_state *umap_state) {
	uint32_t length;
	uint16_t offset = 0;
    uint8_t *cdb = cmd->scb;
	uint8_t *buf = scsi_get_out_buffer(cmd);
	uint16_t dl, bddl;
	uint64_t lba, nlbas;
	int i = 0, ret;

	length = scsi_get_out_length(cmd);

	Log_debug("unmap cmd out length:%u offset:%lu dev_id: %lu tl:%u data direction:%d\n", 
		length, cmd->offset, cmd->dev_id, cmd->tl, cmd->data_dir);

	/*
	 * ANCHOR bit check
	 *
	 * The ANCHOR in the Logical Block Provisioning VPD page is not
	 * supported, so the ANCHOR bit shouldn't be set here.
	 */
	if (cdb[1] & 0x1) {
        Log_error("illegal request: anchor is not supported for now!\n");
		return ILLEGAL_REQUEST;
	}

	/*
	 * PARAMETER LIST LENGTH field.
	 *
	 * The PARAMETER LIST LENGTH field specifies the length in bytes of
	 * the UNMAP parameter data that shall be sent from the application
	 * client to the device server.
	 *
	 * A PARAMETER LIST LENGTH set to zero specifies that no data shall
	 * be sent.
	 */
	if (length == 0) {
        Log_error("data out buffer length is zero, just return okay\n");
		return SAM_STAT_GOOD;
	}

	/*
	 * From sbc4r13, section 5.32.1 UNMAP command overview.
	 *
	 * The PARAMETER LIST LENGTH should be greater than eight,
	 */
	if (length < 8) {
        Log_error("illegal parameter list length %u and it should be >= 8\n", length);
		return ILLEGAL_REQUEST;
	}

    /*
	 * If any UNMAP block descriptors in the UNMAP block descriptor
	 * list are truncated due to the parameter list length in the CDB,
	 * then that UNMAP block descriptor shall be ignored.
	 *
	 * So it will allow dl + 2 != data_length and bddl + 8 != data_length.
	 */
	dl = be16toh(*((uint16_t *)&buf[0]));
	bddl = be16toh(*((uint16_t *)&buf[2]));

	Log_debug("data out buffer length: %u, dl: %hu, bddl: %hu\n", length, dl, bddl);

	/*
	 * If the unmap block descriptor data length is not a multiple
	 * of 16, then the last unmap block descriptor is incomplete
	 * and shall be ignored.
	 */
	bddl &= ~0xf;

	/*
	 * If the UNMAP BLOCK DESCRIPTOR DATA LENGTH is set to zero, then
	 * no unmap block descriptors are included in the UNMAP parameter
	 * list.
	 */
	if (bddl == 0) {
        return SAM_STAT_GOOD;
	}
	umap_state->count = bddl / 16;
	if (umap_state->count > VPD_MAX_UNMAP_BLOCK_DESC_COUNT) {
        Log_error("illegal parameter list count %hu exceeds :%u\n", bddl / 16, VPD_MAX_UNMAP_BLOCK_DESC_COUNT);
		return ILLEGAL_REQUEST;
	}
    if (bddl % 16 != 0) {
        umap_state->count++;
    }
	if (umap_state->count > 0) {
		umap_state->nlbas = calloc(umap_state->count, sizeof(uint32_t));
        umap_state->lba = calloc(umap_state->count, sizeof(uint64_t));
	}

	/* The first descriptor list offset is 8 in Data-Out buffer */
	buf += 8;

	while (bddl) {
        lba = be64toh(*((uint64_t *)&buf[offset]));
		nlbas = be32toh(*((uint32_t *)&buf[offset + 8]));

		if (nlbas >= VPD_MAX_UNMAP_LBA_COUNT) {
            Log_error("illegal parameter list LBA count %lu exceeds:%u\n", nlbas, VPD_MAX_UNMAP_LBA_COUNT);
			return ILLEGAL_REQUEST;
		}

		ret = check_lbas(cmd->dev, lba, nlbas);
		if (ret != SAM_STAT_GOOD) {
            return ret;    
		}

        Log_info("unmap section length: %lu offset: %ld\n", nlbas<<9, lba<<9);
        umap_state->lba[i] = lba;
		umap_state->nlbas[i] = nlbas;
		
		/*
        //组装并下发请求，参数为nlbas和lba, 如果nlbas大于VPD_MAX_UNMAP_LBA_COUNT_ONCE，将请求切片
		while (nlbas > 0) {
            if (nlbas > VPD_MAX_UNMAP_LBA_COUNT_ONCE) {
				umap_state->count++;
				umap_state->nlbas = realloc(umap_state->nlbas, sizeof(uint32_t)*umap_state->count);
                umap_state->lba = realloc(umap_state->lba, sizeof(uint64_t)*umap_state->count);
				umap_state->lba[i] = lba;
				umap_state->nlbas[i] = VPD_MAX_UNMAP_LBA_COUNT_ONCE;
			    nlbas -= VPD_MAX_UNMAP_LBA_COUNT_ONCE;
				lba += VPD_MAX_UNMAP_LBA_COUNT_ONCE;
            } else {
				umap_state->lba[i] = lba;
				umap_state->nlbas[i] = nlbas;
                nlbas = 0;
            }
			i++;
		}
		*/
		
		
		/* The unmap block descriptor data length is 16 */
		offset += 16;
		bddl -= 16;
		
	}

    return SAM_STAT_GOOD;
}

int handle_writesame(struct scsi_cmd *cmd) {
    uint8_t *cdb = cmd->scb;
    uint32_t lba_cnt = get_xfer_length(cdb);
	uint64_t start_lba = get_lba(cdb);
	int ret;

    /*
	 * From sbc4r13, section 5.50 WRITE SAME (16) command
	 *
	 * A write same (WSNZ) bit has beed set to one, so the device server
	 * won't support a value of zero here.
	 */   
    if (!lba_cnt) {
        Log_error("the WSNZ = 1 & WRITE_SAME blocks = 0 is not supported!\n");
		return ILLEGAL_REQUEST;
    }

    /*
	 * The MAXIMUM WRITE SAME LENGTH field in Block Limits VPD page (B0h)
	 * limit the maximum block number for the WRITE SAME.
	 */
	if (lba_cnt > VPD_MAX_WRITE_SAME_LENGTH) {
        Log_error("blocks: %u exceeds maxinum writesame length: %u\n", lba_cnt, VPD_MAX_WRITE_SAME_LENGTH);
		return ILLEGAL_REQUEST;
	}

	/*
	 * The logical block address plus the number of blocks shouldn't
	 * exceeds the capacity of the medium
	 */
	ret = check_lbas(cmd->dev, start_lba, lba_cnt);
	if (ret) {
        return ILLEGAL_REQUEST;
	}

	Log_debug("writesame start lba: %lu, number of lba:: %hu, last lba: %lu\n", start_lba, lba_cnt, start_lba + lba_cnt - 1);

	return SAM_STAT_GOOD;
};

int handle_caw(struct scsi_cmd *cmd, uint32_t block_size) {
	uint8_t *cdb = cmd->scb;
    uint32_t length = scsi_get_out_length(cmd);
	uint32_t sectors = cdb[13] * 2;
	uint32_t lba_cnt = get_xfer_length(cdb);
	uint64_t start_lba = get_lba(cdb);
	int ret;

    if (length != sectors * block_size) {
        return HARDWARE_ERROR;
    }

	ret = check_lbas(cmd->dev, start_lba, lba_cnt);
	if (ret) {
		return ILLEGAL_REQUEST;
	}
    
    return SAM_STAT_GOOD;
}

