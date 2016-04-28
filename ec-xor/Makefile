
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
CFLAGS += $(DBG_FLAGS)

#CFLAGS += -I$(SW_INC) -I$(USR_INC) 
#
#  the lib needed
#
LIB_FLAGS =  -ltcmalloc


#
#	 the app obj name
#
obj = test-main-2



default: $(obj)

	
test-main-2:test-main-2.c arm.c intel.c probe.cc xor_op.cc
	$(CC) $(CFLAGS) -o $@  $^  $(LIB_FLAGS)

install:
	#@install -c $(obj) $(BIN_INSTALL)	

clean: 
	@rm -f *.o $(obj)
