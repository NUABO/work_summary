/*
 * VeSpace block device backing store routine
 *
 * Copyright (C) 2016 chaolu zhang <finals@126.com>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, version 2 of the
 * License.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
 */

#include <errno.h>
#include <fcntl.h>
#include <inttypes.h>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <pthread.h>
#include <limits.h>
#include <ctype.h>
#include <sys/un.h>

#include "list.h"
#include "tgtd.h"
#include "util.h"
#include "log.h"
#include "scsi.h"
#include "bs_thread.h"

#include "viou.h"

struct viou_info {
    struct viou_connection *conn;
    size_t size;
};

#define LOCATE_VIO_INFO(lu)	((struct viou_info *) \
			((char *)lu + \
			 sizeof(struct scsi_lu) + \
			 sizeof(struct bs_thread_info)) \
                )


static void set_medium_error(int *result, uint8_t *key, uint16_t *asc)
{
    *result = SAM_STAT_CHECK_CONDITION;
    *key = MEDIUM_ERROR;
    *asc = ASC_READ_ERROR;
}

static int get_cdb_length_internal(uint8_t *cdb)
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

static uint64_t get_lba_internal(uint8_t *cdb)
{
	uint16_t val;

	switch (get_cdb_length_internal(cdb)) {
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


static void bs_viou_request(struct scsi_cmd *cmd)
{
    char *buf;
    int ret = 0;
    uint32_t length = 0;
    int result = SAM_STAT_GOOD;
	uint64_t offset = cmd->offset;
	uint32_t block_size;
    uint8_t  key = 0;
    uint16_t asc = 0;
	struct xcopy *xc = NULL;
	int i = 0;
    struct viou_info *viou = LOCATE_VIO_INFO(cmd->dev);

    switch (cmd->scb[0]) {
    case WRITE_6:
    case WRITE_10:
    case WRITE_12:
    case WRITE_16:
        length = scsi_get_out_length(cmd);
        //Log_debug("write command length:%u, offset:%lu", length, cmd->offset);
        ret = write_at_unix(viou->conn, scsi_get_out_buffer(cmd), length, cmd->offset);
        if (ret) {
            eprintf("fail to write at %lx for %u\n", cmd->offset, length);
            set_medium_error(&result, &key, &asc);
        }
        break;
    case READ_6:
	case READ_10:
	case READ_12:
	case READ_16:
	    length = scsi_get_in_length(cmd);
	    //Log_debug("read command length:%u, offset:%lu", length, cmd->offset);
	    ret = read_at_unix(viou->conn, scsi_get_in_buffer(cmd), length, cmd->offset);
	    if (ret) {
            eprintf("fail to read at %lx for %u\n", cmd->offset, length);
            set_medium_error(&result, &key, &asc);
	    }
	    break;
    case SYNCHRONIZE_CACHE:
        Log_debug("cmd->scb[0]: %x(SYNCHRONIZE_CACHE)\n", cmd->scb[0]);
        break;
    case WRITE_SAME:
    case WRITE_SAME_16:
        Log_debug("cmd->scb[0]: %x(WRITE_SAME) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
        result = handle_writesame(cmd);
	    if (SAM_STAT_GOOD != result) {
			key = result;
			asc = ASC_MEDIUM_NOT_PRESENT;
		    result = SAM_STAT_CHECK_CONDITION;
            Log_error("WRITE_SAME result: %u", result);
			break;
		}

		/* WRITE_SAME used to punch hole in file */
		if (cmd->scb[1] & 0x08) {
			Log_debug("WRITE_SAME set UNMAP bit, length:%u, offset:%lu\n",cmd->tl, cmd->offset);
			ret = unmap_at_unix(viou->conn, cmd->tl, cmd->offset);
		    if (ret) {
                result = SAM_STAT_CHECK_CONDITION;
				key = HARDWARE_ERROR;
				asc = ASC_INTERNAL_TGT_FAILURE;
				Log_error("WRITE_SAME length:%u, offset: %lu, ret: %d\n", cmd->tl, cmd->offset, ret);
				break;
			}
			break;
		}

		block_size = 1 << cmd->dev->blk_shift;
		buf = scsi_get_out_buffer(cmd);

		switch (cmd->scb[1] & 0x06) {
		case 0x02: // PBDATA==0 LBDATA==1 
			put_unaligned_be32(offset, buf);
			break;
		case 0x04: // PBDATA==1 LBDATA==0 
			// physical sector format 
			put_unaligned_be64(offset, buf);
		    break;
		}

		ret = write_same_at_unix(viou->conn, buf, block_size, cmd->tl, offset);
		if (ret) {
			Log_error("WRITE_SAME fail to write at %lx for %u\n", cmd->offset, length);
			set_medium_error(&result, &key, &asc);
		}

        break;
	case UNMAP:
		Log_debug("cmd->scb[0]: %x(UNMAP) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
		struct unmap_state *umap_state = malloc(sizeof(struct unmap_state));
	    if (umap_state == NULL) {
			set_medium_error(&result, &key, &asc);
			break;
	    }
		result = handle_unmap(cmd, umap_state);
	    if (SAM_STAT_GOOD != result) {
            Log_error("UNMAP handle_unmap return result: %u\n", result);
            key = result;
			asc = ASC_MEDIUM_NOT_PRESENT;
		    result = SAM_STAT_CHECK_CONDITION;
			if (umap_state->nlbas != NULL) free(umap_state->nlbas);
			if (umap_state->lba != NULL) free(umap_state->lba);
			if (umap_state != NULL) free(umap_state);
			break;
		}

        for (i = 0; i < umap_state->count; i++) {
            ret = unmap_at_unix(viou->conn, ((uint64_t)(umap_state->nlbas[i]) << 9), (umap_state->lba[i] << 9));
			if (ret) {
                result = SAM_STAT_CHECK_CONDITION;
				key = HARDWARE_ERROR;
				asc = ASC_INTERNAL_TGT_FAILURE;
				Log_error("UNMAP state nlbas: %u length:%u, lba: %lu offset: %lu, ret: %d\n", umap_state->nlbas[i], 
				    (umap_state->nlbas[i] << 9), umap_state->lba[i], (umap_state->lba[i] << 9), ret);
				break;
			}
        }

		if (umap_state->nlbas != NULL) free(umap_state->nlbas);
		if (umap_state->lba != NULL) free(umap_state->lba);
		if (umap_state != NULL) free(umap_state);
        break;
	case COMPARE_AND_WRITE:
		Log_debug("cmd->scb[0]: %x(COMPARE_AND_WRITE) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
		block_size = 1 << cmd->dev->blk_shift;
		result = handle_caw(cmd, block_size);
	    if (result != SAM_STAT_GOOD) {
			Log_error("COMPARE_AND_WRITE handle_caw return result: %u\n", result);
		    key = result;
			asc = ASC_INTERNAL_TGT_FAILURE;
			result = SAM_STAT_CHECK_CONDITION;
			break;
	    }

		ret = caw_at_unix(viou->conn, scsi_get_out_buffer(cmd), scsi_get_out_length(cmd), block_size*get_lba_internal(cmd->scb));
		if (ret) {
            result = SAM_STAT_CHECK_CONDITION;
		    key = MISCOMPARE;
			asc = ASC_MISCOMPARE_DURING_VERIFY_OPERATION;
			Log_error("COMPARE_AND_WRITE read length:%u, offset:%lu, ret: %d\n", cmd->tl, cmd->offset, ret);
			break;
		}

        break;
	case EXTENDED_COPY:
	    Log_debug("cmd->scb[0]: %x(EXTENDED_COPY) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
		xc = malloc(sizeof(struct xcopy));
		result = handle_xcopy(cmd, xc);
		if (SAM_STAT_GOOD != result) {
			key = ILLEGAL_REQUEST;
			asc = ASC_MEDIUM_NOT_PRESENT;
		    result = SAM_STAT_CHECK_CONDITION;
            Log_error("EXTENDED_COPY handle_xcopy return result: %u", result);
			free(xc);
			break;
		}

		ret = xcopy_at_unix(viou->conn, xc);
		if (ret) {
            Log_error("EXTENDED_COPY xcopy_at src_tid: %u, src_lunid: %u, dst_tid: %u, dst_lunid: %u," 
				"src_lba: %lu, dst_lba: %lu, lba_cnt: %u, ret: %d\n", xc->src_tid, xc->src_lunid, xc->dst_tid, 
				xc->dst_lunid, xc->src_lba, xc->dst_lba, xc->lba_cnt, ret);
			set_medium_error(&result, &key, &asc);
			result = SAM_STAT_CHECK_CONDITION;
		    key = HARDWARE_ERROR;
			asc = ASC_INTERNAL_TGT_FAILURE;
			free(xc);
			break;
		}

		free(xc);
		break;
	case RECEIVE_COPY_RESULTS:
		Log_debug("cmd->scb[0]: %x(RECEIVE_COPY_RESULTS) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
		length = scsi_get_in_length(cmd);
    	//scsi cmd中的命令如果小于50, 下面的buf操作将会溢出
		if (length < 50) {
			key = ILLEGAL_REQUEST;
			asc = ASC_MEDIUM_NOT_PRESENT;
		    result = SAM_STAT_CHECK_CONDITION;
		} else {
			result = handle_receive_copy_result(cmd);
		}
		
		break;
	case MAINT_PROTOCOL_IN:
        if ((cmd->scb[1] & 0x1f) == MPI_REPORT_TARGET_PGS) {
			Log_debug("cmd->scb[0]: %x(REPORT_TARGET_PGS) length:%u, offset:%lu\n", cmd->scb[0], cmd->tl, cmd->offset);
			result = process_request_unix(viou->conn, NULL, 0, 0, TypeRtpg);
        }
		break;
    default:
        Log_info("cmd->scb[0]: %x\n", cmd->scb[0]);
        break;
    }

    dprintf("io done %p %x %d %u\n", cmd, cmd->scb[0], ret, length);

    scsi_set_result(cmd, result);
    if (result != SAM_STAT_GOOD) {
		eprintf("io error %p %x %d %d %" PRIu64 ", %m\n",
			cmd, cmd->scb[0], ret, length, cmd->offset);
		sense_data_build(cmd, key, asc);
	}
}

static int viou_open(struct viou_info *viou, char *socket_path)
{
	//eprintf("viou_open socket path: %s\n", socket_path);

    viou->conn = new_viou_connection(socket_path);
    if (NULL == viou->conn) {
        eprintf("Cannot estibalish connection");
        return -1;
    }

    start_response_processing_unix(viou->conn);
    return 0;
}

static int bs_viou_open(struct scsi_lu *lu, char *path, int *fd, uint64_t *size)
{
    struct viou_info *viou = LOCATE_VIO_INFO(lu);
    int ret = viou_open(viou, path);
    if (ret) {
        return ret;
    }

    *size = viou->size;
    return 0;
}

static void bs_viou_close(struct scsi_lu *lu)
{
    if (LOCATE_VIO_INFO(lu)->conn) {
        shutdown_viou_connection(LOCATE_VIO_INFO(lu)->conn);
    }
}

static char *slurp_to_semi(char **p)
{
	char *end = index(*p, ';');
	char *ret;
	int len;

	if (end == NULL)
		end = *p + strlen(*p);
	len = end - *p;
	ret = malloc(len + 1);
	strncpy(ret, *p, len);
	ret[len] = '\0';
	*p = end;
	/* Jump past the semicolon, if we stopped at one */
	if (**p == ';')
		*p = end + 1;
	return ret;
}

static char *slurp_value(char **p)
{
	char *equal = index(*p, '=');
	if (equal) {
		*p = equal + 1;
		return slurp_to_semi(p);
	} else {
		return NULL;
	}
}

static int is_opt(const char *opt, char *p)
{
	int ret = 0;
	if ((strncmp(p, opt, strlen(opt)) == 0) &&
		(p[strlen(opt)] == '=')) {
		ret = 1;
	}
	return ret;
}

static tgtadm_err bs_viou_init(struct scsi_lu *lu, char *bsopts)
{
    struct bs_thread_info *info = BS_THREAD_I(lu);
    char *ssize = NULL;
    size_t size = 0;

    while (bsopts && strlen(bsopts)) {
        if (is_opt("size", bsopts)) {
            ssize = slurp_value(&bsopts);
            size = atoll(ssize);
        }
    }

    LOCATE_VIO_INFO(lu)->size = size;

    return bs_thread_open(info, bs_viou_request, nr_iothreads);
}

static void bs_viou_exit(struct scsi_lu *lu)
{
    struct bs_thread_info *info = BS_THREAD_I(lu);

    bs_thread_close(info);
}

static struct backingstore_template viou_bst = {
    .bs_name              = "viou",
    .bs_datasize          = sizeof(struct bs_thread_info) + sizeof(struct viou_info),
    .bs_open              = bs_viou_open,
    .bs_close             = bs_viou_close,
    .bs_init              = bs_viou_init,
    .bs_exit              = bs_viou_exit,
    .bs_cmd_submit        = bs_thread_cmd_submit,
    .bs_oflags_supported  = O_SYNC | O_DIRECT | O_RDWR,
};

__attribute__((constructor)) static void register_bs_module(void)
{
    register_backingstore_template(&viou_bst);
}

