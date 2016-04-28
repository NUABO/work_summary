#############################################################################
# 											The platform makefile   													  #
#                                                                           #
#  ------------------------------------------------------------------------ #
#  Modification History                                                     #
#  DATE          NAME              DESCRIPTION                              #
#  ------------------------------------------------------------------------ #
#  2010-11-04    chenbo 07066      Created                                  #
#																																						#
#############################################################################
#
#		specify the root of project
#
ROOT	:= ./..

#
#		include the public symbol file
#
include Makefile.in

#
#		indicate that we are global make
#
GLOBAL_MAKE := y

export GLOBAL_MAKE


#
#		compile steps:
#		1. create install folder
#		2. compile kernel then lib, and bin last
#
default: inc dir mod lib bin gui

inc:

ifeq (y,$(NAS_OPT))
	@echo "				ALERT: Complie with NAS module!"
else
	@echo "				ALERT: Complie without NAS module!"
	
endif

dir:
	@install -d $(INSTALLPATH)
	@install -d $(LIB_INSTALL)
	@install -d $(BIN_INSTALL)
	@install -d $(ETC_INSTALL)
	@install -d $(MIB_INSTALL)
	@install -d $(MONITOR_INSTALL)
	@install -d $(KDUMP_INSTALL)
mod:
	@for n in $(KMOD_SUB_DIR); 	do $(MAKE) -C $$n 2>>error|| exit 1; done
	@for n in $(KMOD_SUB_DIR); 	do $(MAKE) -C $$n install > /dev/null || exit 1; done
	@echo compile module successfully!	
lib:
	@for n in $(LIB_SUB_DIR); 	do $(MAKE) -C $$n 2>>error|| exit 1; done
	@for n in $(LIB_SUB_DIR); 	do $(MAKE) -C $$n install > /dev/null || exit 1; done
	@echo compile lib successfully!

bin:
	@for n in $(BIN_SUB_DIR); 	do $(MAKE) -C $$n 2>>error|| exit 1; done
	@for n in $(BIN_SUB_DIR); 	do $(MAKE) -C $$n install > /dev/null || exit 1; done
	@install -c $(DIR_SCRIPTS)/smb.conf.default $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/*.sh $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/smb $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/auto_ftp $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/bond.conf $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/nmb $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/winbind $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/40.vsftpd $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/40.vsftpd.2.5.3 $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/50.samba $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/functions $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/expect_exec $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/clusterd $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/proftpd $(ETC_INSTALL)
	@install -c $(DIR_SCRIPTS)/tzset $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/cfgmgt_mgt.sh $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/$(PRO_TYPE)/cfgmgt_impl.conf $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/$(PRO_TYPE)/*.sh $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/$(PRO_TYPE)/*.txt $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/srvguidaemon $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/sshd_config  $(BIN_INSTALL)
	@install -c $(DIR_SCRIPTS)/set_parameter.sh  $(BIN_INSTALL)

ifeq (n,$(NAS_OPT))
	@rm -f $(BIN_INSTALL)/nas_model_config.sh
endif

ifeq ($(PRO_TYPE), VX1600)
	@rm -f $(LIB_INSTALL)/libalarm.so
endif

	@echo compile bin successfully!

gui:
	@sed "s/STORWARE_VERSION = \".*\"/STORWARE_VERSION = \"$(PRO_VER)\"/" $(DIR_GUI)/jgui/com/storware/ipsan/console/rpc/SWGlobalConstant.java > $(DIR_GUI)/jgui/com/storware/ipsan/console/rpc/tmpConstant.java
	@mv $(DIR_GUI)/jgui/com/storware/ipsan/console/rpc/tmpConstant.java $(DIR_GUI)/jgui/com/storware/ipsan/console/rpc/SWGlobalConstant.java
	$(MAKE) -C $(DIR_GUI) > /dev/null || exit 1;
	@echo compile guicluster successfully!

clean:
	@for n in $(LIB_SUB_DIR);		do $(MAKE) -C $$n clean; done
	@for n in $(BIN_SUB_DIR);		do $(MAKE) -C $$n clean; done
	@rm -f error
	@rm -rf lint_report
	@-find $(INSTALLPATH) -type f -exec rm -f {} \;
	@echo clean successfully!
