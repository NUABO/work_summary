
DEBUG := y

CC = gcc

ifeq ($(DEBUG), y)
  DBG_FLAGS := -O0 -Wall -g -DDEBUG 
else
  DBG_FLAGS := -O2 -Wall 
endif

#
#  	add compile flags
#
CFLAGS += $(DBG_FLAGS)  -std=gnu++11 -I /home/zhong/ceph-9.2.0/src/

#CFLAGS += -I$(SW_INC) -I$(USR_INC) 
#
#  the lib needed
#
LIB_FLAGS =  \
	/home/ceph_lib-9.2.0/libos.a \
	/home/ceph_lib-9.2.0/libglobal.a \
	/home/ceph_lib-9.2.0/libcommon.a \
	-laio -lleveldb -lsnappy -ldl -lboost_thread-mt -latomic_ops -lboost_random-mt -lblkid -lpthread -lcryptopp -lm -lrt -lboost_system-mt -pthread  -lstdc++


#
#	 the app obj name
#
obj = test_filestore test_objectstore test_workqueue test_heartbeat_map test_timers test_journal test_journal2 \
	test_Throttle



default: $(obj)


test_filestore:test_filestore.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_objectstore:test_objectstore.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_workqueue:test_workqueue.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_heartbeat_map:test_heartbeat_map.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_timers:test_timers.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_journal:test_journal.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_journal2:test_journal2.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

test_Throttle:test_Throttle.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)
	
install:
	#@install -c $(obj) $(BIN_INSTALL)	

clean: 
	@rm -f *.o $(obj)
