cmake_minimum_required(VERSION 3.6)
project(target)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=gnu99")
include_directories( "F:\\code\\github\\Costor-micro-service\\Target\\usr\\" )
include_directories( "F:\\code\\usr_include\\" )
include_directories( "F:\\code\\usr_include\\x86_64-linux-gnu\\" )

set(SOURCE_FILES
        ./bs.c
        ./bs_aio.c
        ./bs_glfs.c
        ./bs_null.c
        ./bs_rbd.c
        ./bs_rdwr.c
        ./bs_sg.c
        ./bs_sheepdog.c
        ./bs_ssc.c
        ./bs_vio.c
        ./bs_viou.c
        ./concat_buf.c
        ./driver.c
        ./iscsi/chap.c
        ./iscsi/conn.c
        ./iscsi/iscsid.c
        ./iscsi/iscsi_tcp.c
        ./iscsi/iser.c
        ./iscsi/iser_text.c
        ./iscsi/isns.c
        ./iscsi/md5.c
        ./iscsi/param.c
        ./iscsi/session.c
        ./iscsi/sha1.c
        ./iscsi/target.c
        ./iscsi/transport.c
        ./libcrc32c.c
        ./libssc.c
        ./log.c
        ./mgmt.c
        ./mmc.c
        ./osd.c
        ./parser.c
        ./ring.c
        ./ring_bak.c
        ./sbc.c
        ./scc.c
        ./scsi.c
        ./smc.c
        ./spc.c
        ./ssc.c
        ./target.c
        ./tgtadm.c
        ./tgtd.c
        ./tgtimg.c
        ./util.c
        ./vio.c
        ./viou.c
        ./vio_bak.c
        ./work.c

        )
add_executable(cpp ${SOURCE_FILES})