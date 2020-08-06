# Poky Linux build Makefile #
# This serves as build entry point for automated builds and average Joe.
#
# author: jrucker@altera.com
#

###################################################################################
###	Command aliases	
###################################################################################
SHELL=/bin/bash
CAT	:= cat
CD	:= cd
CP	:= cp
CHMOD	:= chmod
TAR	:= tar
LN	:= ln -s
ECHO 	:= echo -e
BITBAKE := bitbake 
DATE 	:= $(shell date +%Y-%m-%d)
RSYNC   := rsync -az --delete
RM 	:= rm -rf
SED	:= sed
MD5SUM	:= md5sum
SHA256SUM := sha256sum
MKDIR 	:= mkdir -p
GIT 	:= git

###################################################################################
### 	Variables
###################################################################################

ifeq ($(LINUX_VERSION),)
LINUX_VERSION := 3.8
endif

ifeq ($(UBOOT_VERSION),)
UBOOT_VERSION ?= 2013.01
endif

ifeq ($(POKY_VER),)
POKY_VER=8.0
endif

ifeq ($(__RELEASE_NUMBER__),)
__RELEASE_NUMBER__=1210
endif

ifneq (,$(findstring 8.,$(POKY_VER)))
POKY_VER_NAME=danny
else
POKY_VER_NAME=dylan
endif

POKY_VER_FULL=poky-$(POKY_VER_NAME)-$(POKY_VER)
GIT_SERVER := gitolite@at-git
SOCFPGA_LINUX_VERSION ?= 13.07

LINUX_TAR_NAME := linux-socfpga
UBOOT_TAR_NAME := uboot-socfpga

SILENT := @
ifeq ($(VERBOSE),1)
SILENT :=
endif


#############  BRANCH VERSIONS ################

LINUX_BRANCH := socfpga-$(LINUX_VERSION)
UBOOT_BRANCH := socfpga_v$(UBOOT_VERSION)
POKY_BRANCH := $(POKY_VER_NAME)-altera

ifeq ("$(UBOOT_VERSION)","2013.01")
UBOOT_BRANCH := socfpga_v$(UBOOT_VERSION).01
endif

ifeq ("$(UBOOT_VERSION)","2012.04")
UBOOT_BRANCH := socfpga5xs1_v$(UBOOT_VERSION).01
endif

ifeq ("$(LINUX_VERSION)","3.4")
LINUX_BRANCH := socfpga5xs1-$(LINUX_VERSION)
endif

ifeq ("$(LINUX_VERSION)","3.5")
LINUX_BRANCH := socfpga5xs1-$(LINUX_VERSION)
endif


###################################################################################
###	Directory & File Locations
###################################################################################

# DIRECTORIES
YOCTO_SRC_PAYLOAD := ~/yocto/tarballs/$(POKY_VER)
ifeq ($(BUILD_DIR),)
BUILD_DIR := ~/yocto/$(DATE)
endif

# expand BUILD_DIR in case of a relative path
override BUILD_DIR := $(shell realpath -s $(BUILD_DIR))

#	Files retreived from git
ifeq ($(GITDIR),)
GITDIR			:= ~/yocto/build-git
endif

ROOT_INSTALL		:= $(BUILD_DIR)/install
YOCTO_ROOT_DIR		:= $(ROOT_INSTALL)/yocto
YOCTO_BUILD_DIR 	:= $(YOCTO_ROOT_DIR)/build
YOCTO_OUTPUT 		:= $(YOCTO_BUILD_DIR)/tmp/deploy/images
STAGE_AREA 		:= $(BUILD_DIR)
YOCTO_WORKSPACE 	:= $(STAGE_AREA)/workspace
VALIDATE_DIR		:= $(STAGE_AREA)/validate
YOCTO_SRC_STAGE_AREA 	:= $(STAGE_AREA)/release
YOCTO_BIN_STAGE_AREA 	:= $(STAGE_AREA)/release

BUILD_SOURCES 		:= $(YOCTO_WORKSPACE)/sources

POKY_DIR		:= $(GITDIR)/$(POKY_VER_FULL)
LINUX_INFRA 		:= $(GITDIR)/linux-infra
LINUX_DIR 		:= $(GITDIR)/$(LINUX_TAR_NAME)
UBOOT_DIR 		:= $(GITDIR)/$(UBOOT_TAR_NAME)

### Files
VALIDATE_SCRIPT		:= $(LINUX_INFRA)/tools/validate-release
YOCTO_INSTALL_SCRIPTNAME := install_altera_socfpga_src.sh
YOCTO_INSTALL_SCRIPT 	:= $(ROOT_INSTALL)/bin/$(YOCTO_INSTALL_SCRIPTNAME)
SRC_INSTALL_SCRIPT	:= $(YOCTO_WORKSPACE)/bin/$(YOCTO_INSTALL_SCRIPTNAME)
MAKE_SDCARD_SCRIPTNAME	:= make_sdimage.sh
SRC_MAKE_SD_CARD_SCRIPT := $(YOCTO_WORKSPACE)/bin/$(MAKE_SDCARD_SCRIPTNAME)
MAKE_PRELOADER_NAME	:= make_preloader_img.sh
SRC_MAKE_PRELOADER	:= $(YOCTO_WORKSPACE)/bin/$(MAKE_PRELOADER_NAME)
POKY_SITE_CONF		:= $(BUILD_SOURCES)/site.conf.sample

POKY_TAR 		:= $(BUILD_SOURCES)/$(POKY_VER_FULL).tar.gz
YOCTO_SRC_PKG_NAME 	:= linux-socfpga-$(SOCFPGA_LINUX_VERSION)-$(RC_ID)src
YOCTO_SRC_PKG 		:= $(YOCTO_SRC_STAGE_AREA)/$(YOCTO_SRC_PKG_NAME).bsx
YOCTO_SRC_PKG_MD5 	:= $(YOCTO_SRC_PKG).md5

YOCTO_BIN_AV_PKG_NAME  := linux-socfpga-$(SOCFPGA_LINUX_VERSION)-av-bin
YOCTO_BIN_AV_PKG_DIR   := $(YOCTO_BIN_STAGE_AREA)/$(YOCTO_BIN_AV_PKG_NAME)
YOCTO_BIN_AV_PKG       := $(YOCTO_BIN_STAGE_AREA)/$(YOCTO_BIN_AV_PKG_NAME).tar.gz
YOCTO_BIN_AV_PKG_MD5   := $(YOCTO_BIN_AV_PKG).md5

YOCTO_BIN_CV_PKG_NAME  := linux-socfpga-$(SOCFPGA_LINUX_VERSION)-cv-bin
YOCTO_BIN_CV_PKG_DIR   := $(YOCTO_BIN_STAGE_AREA)/$(YOCTO_BIN_CV_PKG_NAME)
YOCTO_BIN_CV_PKG       := $(YOCTO_BIN_STAGE_AREA)/$(YOCTO_BIN_CV_PKG_NAME).tar.gz
YOCTO_BIN_CV_PKG_MD5   := $(YOCTO_BIN_CV_PKG).md5

ENV_SET = BUILD_DIR=$(BUILD_DIR) YOCTO_BUILD_DIR=$(YOCTO_BUILD_DIR)

PAYLOAD_FILES := $(SRC_INSTALL_SCRIPT) $(SRC_MAKE_SD_CARD_SCRIPT) $(SRC_MAKE_PRELOADER)\
	$(YOCTO_WORKSPACE)/EULA $(YOCTO_WORKSPACE)/manifest.txt $(POKY_TAR)

###################################################################################
###	Set up some defaults
###################################################################################

### Targets

.PHONY: default
default: all

.PHONY: all
all: installer-clean installer build bin-release validate-bin

# Generic Directory Creation Rule
$(STAGE_AREA) $(YOCTO_SRC_STAGE_AREA) $(BUILD_SOURCES) $(YOCTO_WORKSPACE)/tmp $(VALIDATE_DIR):
	$(SILENT)$(MKDIR) $@

###################################################################################
# 		Rules for Yocto Building
###################################################################################

###### build rules
# Run bitbake, this target should only be called from the build machine

.PHONY: build
build: $(YOCTO_OUTPUT)

$(YOCTO_OUTPUT): build-builddir
	@$(ECHO) "### build: Building Yocto ###\n" 
	@$(ECHO) "*** Yocto Build Dir = $(YOCTO_BUILD_DIR)\n"
	$(SILENT)cd $(YOCTO_ROOT_DIR) && \
		source altera-init $(YOCTO_BUILD_DIR) && \
		umask a+rx u+rwx && \
		$(BITBAKE) "virtual/kernel virtual/bootloader altera-image" && \
		$(SED) -i 's/MACHINE ??= "socfpga_cyclone5"/MACHINE ??= "socfpga_arria5"/' conf/local.conf && \
		$(BITBAKE) "virtual/bootloader"

##### Create the yocto build director
.PHONY: build-builddir
build-builddir: $(YOCTO_BUILD_DIR)

.PHONY: build-builddir-clean
build-builddir-clean:
	$(SILENT)$(RM) -r $(YOCTO_BUILD_DIR)

$(YOCTO_BUILD_DIR): build-yocto
	@$(ECHO) "### Creating yocto build directory ###"
	$(SILENT) cd $(YOCTO_ROOT_DIR) && \
		source altera-init $@

##### Create the yocto directory
.PHONY: build-yocto
build-yocto: $(YOCTO_ROOT_DIR)

.PHONY: build-yocto-clean
build-yocto-clean:
	$(SILENT)$(RM) -r $(BUILD_DIR)/yocto

$(YOCTO_ROOT_DIR): $(YOCTO_INSTALL_SCRIPT)
	@$(ECHO) "### Using Yocto Install Script"
	bash $(YOCTO_INSTALL_SCRIPT) $(YOCTO_ROOT_DIR)


##### Unpack the installer
.PHONY: install
install: $(YOCTO_INSTALL_SCRIPT)

.PHONY: install-clean
install-clean:
	$(SILENT)$(RM) $(ROOT_INSTALL)

$(YOCTO_INSTALL_SCRIPT): $(YOCTO_SRC_PKG_MD5)
	@$(ECHO) "### Using Install Script"
	$(SILENT)$(RM) $(ROOT_INSTALL)
	@$(ECHO) "\n" | $(YOCTO_SRC_PKG) $(ROOT_INSTALL)
	

##### Clean Rules
.PHONY: build-clean
build-clean: build-builddir-clean build-yocto-clean install-clean

###################################################################################
# 		Rules for Binary Release
###################################################################################
.PHONY: validate-bin
validate-bin: $(VALIDATE_DIR)
	$(CD) $(VALIDATE_DIR) && \
		$(TAR) -xzf $(YOCTO_BIN_PKG) && \
		$(CD) $(YOCTO_BIN_PKG_NAME) && \
		$(VALIDATE_SCRIPT)
	

###################################################################################
# 		Rules for Binary Release
###################################################################################

SHIP_AV_FILES :=   $(YOCTO_BIN_AV_PKG_DIR)/zImage \
		$(YOCTO_BIN_AV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_AV_PKG_DIR)/socfpga.dtb \
		$(YOCTO_BIN_AV_PKG_DIR)/altera-image.ext3 \
		$(YOCTO_BIN_AV_PKG_DIR)/altera-image.tar.gz \
		$(YOCTO_BIN_AV_PKG_DIR)/altera-image.cpio \
		$(YOCTO_BIN_AV_PKG_DIR)/altera-image.jffs2 \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-spl-socfpga_arria5.bin \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-socfpga_arria5.img \
		$(YOCTO_BIN_AV_PKG_DIR)/sd_image_arria5.bin.gz

SHIP_CV_FILES :=   $(YOCTO_BIN_CV_PKG_DIR)/zImage \
		$(YOCTO_BIN_CV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_CV_PKG_DIR)/socfpga.dtb \
		$(YOCTO_BIN_CV_PKG_DIR)/altera-image.ext3 \
		$(YOCTO_BIN_CV_PKG_DIR)/altera-image.tar.gz \
		$(YOCTO_BIN_CV_PKG_DIR)/altera-image.cpio \
		$(YOCTO_BIN_CV_PKG_DIR)/altera-image.jffs2 \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-spl-socfpga_cyclone5.bin \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-socfpga_cyclone5.img \
		$(YOCTO_BIN_CV_PKG_DIR)/sd_image_cyclone5.bin.gz


.PHONY: bin-release
bin-release: $(YOCTO_BIN_AV_PKG_MD5) $(YOCTO_BIN_CV_PKG_MD5)

.PHONY: sd_images
sd_images: $(YOCTO_BIN_CV_PKG_DIR)/sd_image_cyclone5.bin $(YOCTO_BIN_AV_PKG_DIR)/sd_image_arria5.bin

.PHONY: bin-release-clean
bin-release-clean:
	$(SILENT)$(RM) $(YOCTO_BIN_AV_PKG_DIR) $(YOCTO_BIN_AV_PKG) $(YOCTO_BIN_AV_PKG_MD5) \
		$(YOCTO_BIN_CV_PKG_DIR) $(YOCTO_BIN_CV_PKG) $(YOCTO_BIN_CV_PKG_MD5)

$(YOCTO_BIN_AV_PKG_DIR) $(YOCTO_BIN_CV_PKG_DIR):
	@$(ECHO) "Creating release binary directory, copying files and creating image"
	$(SILENT)$(MKDIR) $@

# Arria 5 files

$(YOCTO_BIN_AV_PKG_DIR)/zImage \
		$(YOCTO_BIN_AV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-socfpga_arria5.img \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-spl-socfpga_arria5.bin: $(YOCTO_BIN_AV_PKG_DIR)
	$(SILENT)$(CP) $(realpath -s $(YOCTO_OUTPUT)/$(notdir $@)) $@

$(YOCTO_BIN_AV_PKG_DIR)/u-boot-spl-socfpga_arria5.img: \
	$(YOCTO_BIN_AV_PKG_DIR)/u-boot-spl-socfpga_arria5.bin
	sudo /home/root/bin/linux-infra/tools/make_preloader_img.sh \
		-p $< -o $@

$(YOCTO_BIN_AV_PKG_DIR)/altera-image.ext3 \
	$(YOCTO_BIN_AV_PKG_DIR)/altera-image.tar.gz \
	$(YOCTO_BIN_AV_PKG_DIR)/altera-image.jffs2 \
	$(YOCTO_BIN_AV_PKG_DIR)/altera-image.cpio: $(YOCTO_BIN_AV_PKG_DIR)
	$(SILENT)$(CP) $(YOCTO_OUTPUT)/`echo $(notdir $@) | $(SED) -e 's/\./-socfpga_cyclone5\./'` $@

$(YOCTO_BIN_AV_PKG_DIR)/socfpga.dtb:
	$(SILENT)$(CP) $(YOCTO_OUTPUT)/socfpga_arria5.dtb $@

$(YOCTO_BIN_AV_PKG_DIR)/sd_image_arria5.bin.gz: $(YOCTO_BIN_AV_PKG_DIR)/sd_image_arria5.bin
	$(SILENT)gzip -f $<

$(YOCTO_BIN_AV_PKG_DIR)/sd_image_arria5.bin: \
		$(YOCTO_BIN_AV_PKG_DIR)/zImage \
		$(YOCTO_BIN_AV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_AV_PKG_DIR)/socfpga.dtb \
		$(YOCTO_BIN_AV_PKG_DIR)/altera-image.tar.gz \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-spl-socfpga_arria5.img \
		$(YOCTO_BIN_AV_PKG_DIR)/u-boot-socfpga_arria5.img 
	$(SILENT)$(CD) $(YOCTO_BIN_AV_PKG_DIR) && \
		sudo /home/root/bin/linux-infra/nightlybuild/makeimages.sh \
			altera-image.tar.gz \
			u-boot-spl-socfpga_arria5.img u-boot-socfpga_arria5.img \
			socfpga_arria5.dtb $@

$(YOCTO_BIN_AV_PKG): $(SHIP_AV_FILES)
	@$(ECHO) "Creating Arria binary package"
	$(SILENT)$(CD) $(YOCTO_BIN_STAGE_AREA) && \
		$(TAR) -czf $(YOCTO_BIN_AV_PKG) $(YOCTO_BIN_AV_PKG_NAME)
	$(SILENT)$(CHMOD) 644 $(YOCTO_BIN_AV_PKG)

$(YOCTO_BIN_AV_PKG_MD5): $(YOCTO_BIN_AV_PKG)
	$(SILENT)$(CD) $(YOCTO_BIN_STAGE_AREA) && \
		$(MD5SUM) $(YOCTO_BIN_AV_PKG_NAME).tar.gz > $@

# Cyclone 5 files
$(YOCTO_BIN_CV_PKG_DIR)/zImage \
		$(YOCTO_BIN_CV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-socfpga_cyclone5.img \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-spl-socfpga_cyclone5.bin: $(YOCTO_BIN_CV_PKG_DIR)
	$(SILENT)$(CP) $(realpath -s $(YOCTO_OUTPUT)/$(notdir $@)) $@

$(YOCTO_BIN_CV_PKG_DIR)/u-boot-spl-socfpga_cyclone5.img: \
	$(YOCTO_BIN_CV_PKG_DIR)/u-boot-spl-socfpga_cyclone5.bin
	sudo /home/root/bin/linux-infra/tools/make_preloader_img.sh \
		-p $< -o $@

$(YOCTO_BIN_CV_PKG_DIR)/altera-image.ext3 \
	$(YOCTO_BIN_CV_PKG_DIR)/altera-image.tar.gz \
	$(YOCTO_BIN_CV_PKG_DIR)/altera-image.jffs2 \
	$(YOCTO_BIN_CV_PKG_DIR)/altera-image.cpio: $(YOCTO_BIN_CV_PKG_DIR)
	$(SILENT)$(CP) $(YOCTO_OUTPUT)/`echo $(notdir $@) | $(SED) -e 's/\./-socfpga_cyclone5\./'` $@

$(YOCTO_BIN_CV_PKG_DIR)/preloader-mkpimage_cyclone5.bin: $(YOCTO_BIN_CV_PKG_DIR)
	$(SILENT)$(RSYNC) $(FILE_SERVER):$(CYCLONE_EDS_BASE)/software/preloader/preloader-mkpimage.bin $@

$(YOCTO_BIN_CV_PKG_DIR)/socfpga.dtb:
	$(SILENT)$(CP) $(YOCTO_OUTPUT)/socfpga_cyclone5.dtb $@

$(YOCTO_BIN_CV_PKG_DIR)/sd_image_cyclone5.bin.gz: $(YOCTO_BIN_CV_PKG_DIR)/sd_image_cyclone5.bin
	$(SILENT)gzip -f $<

$(YOCTO_BIN_CV_PKG_DIR)/sd_image_cyclone5.bin: \
		$(YOCTO_BIN_CV_PKG_DIR)/zImage \
		$(YOCTO_BIN_CV_PKG_DIR)/vmlinux \
		$(YOCTO_BIN_CV_PKG_DIR)/socfpga.dtb \
		$(YOCTO_BIN_CV_PKG_DIR)/altera-image.tar.gz \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-spl-socfpga_cyclone5.img \
		$(YOCTO_BIN_CV_PKG_DIR)/u-boot-socfpga_cyclone5.img 
	$(SILENT)$(CD) $(YOCTO_BIN_CV_PKG_DIR) && \
		sudo /home/root/bin/linux-infra/nightlybuild/makeimages.sh \
			altera-image.tar.gz \
			u-boot-spl-socfpga_cyclone5.img u-boot-socfpga_cyclone5.img \
			socfpga_cyclone5.dtb $@ 

$(YOCTO_BIN_CV_PKG): $(SHIP_CV_FILES)
	@$(ECHO) "Creating Cyclone binary package"
	$(SILENT)$(CD) $(YOCTO_BIN_STAGE_AREA) && \
		$(TAR) -czf $(YOCTO_BIN_CV_PKG) $(YOCTO_BIN_CV_PKG_NAME)
	$(SILENT)$(CHMOD) 644 $(YOCTO_BIN_CV_PKG)

$(YOCTO_BIN_CV_PKG_MD5): $(YOCTO_BIN_CV_PKG)
	$(SILENT)$(CD) $(YOCTO_BIN_STAGE_AREA) && \
		$(MD5SUM) $(YOCTO_BIN_CV_PKG_NAME).tar.gz > $@

###################################################################################
# 		Rules for Installer Packages
###################################################################################

####################### LINUX TAR
LINUX_TAR := $(BUILD_SOURCES)/$(LINUX_TAR_NAME).tgz

# Rule to insure that it is up-to-date with the git repository
.PHONY: update-linux
update-linux: $(LINUX_DIR)
	@$(ECHO) "### Updating Linux to $(LINUX_BRANCH) ###"
	$(SILENT)$(CD) $(LINUX_DIR) && \
		$(GIT) fetch origin && \
		$(GIT) reset --keep $(LINUX_BRANCH) && \
		$(GIT) checkout $(LINUX_BRANCH)

# Check it out if it doesn't exist
$(LINUX_DIR):
	@$(ECHO) "### git'ing Linux"
	$(SILENT)$(GIT) clone -b $(LINUX_BRANCH) $(GIT_SERVER):linux-socfpga.git $@

# This rule is here to force an update of the tar is git was updated
$(LINUX_DIR)/.git: $(LINUX_DIR)

# Create the archive based on current Linux Directory
$(LINUX_TAR): $(LINUX_DIR)/.git $(BUILD_SOURCES)
	@$(ECHO) "### Creating linux archive ###"
	$(SILENT)$(CD) $(LINUX_DIR)/.. && \
		$(TAR) --exclude=.gitignore -czf $@ $(LINUX_TAR_NAME)/*

# Update Linux if necessary, then recreate tar if necessary
.PHONY: linux-tar
linux-tar: update-linux $(LINUX_TAR)

.PHONY: linux-tar-clean
linux-tar-clean:
	$(SILENT)$(RM) $(LINUX_DIR) $(LINUX_TAR)

###################### UBOOT TAR
UBOOT_TAR := $(BUILD_SOURCES)/$(UBOOT_TAR_NAME).tgz

# Rule to insure that it is up-to-date with the git repository
.PHONY: update-uboot
update-uboot: $(UBOOT_DIR)
	@$(ECHO) "### updating u-boot to $(UBOOT_BRANCH) ###"
	$(SILENT)$(CD) $(UBOOT_DIR) && \
		$(GIT) fetch origin && \
		$(GIT) reset --keep $(UBOOT_BRANCH) && \
		$(GIT) checkout $(UBOOT_BRANCH)

# This rule is here to force an update of the tar is git was updated
$(UBOOT_DIR):
	@$(ECHO) "### git'ing u-boot ###"
	$(SILENT)$(GIT) clone -b $(UBOOT_BRANCH) $(GIT_SERVER):uboot-socfpga.git $@

$(UBOOT_DIR)/.git: $(UBOOT_DIR)

$(UBOOT_TAR): $(UBOOT_DIR)/.git $(BUILD_SOURCES)
	@$(ECHO) "### Creating u-boot archive ###"
	$(SILENT)$(CD) $(UBOOT_DIR)/.. && \
		$(TAR) --exclude=.gitignore -czf $@ $(UBOOT_TAR_NAME)/*
	
.PHONY: uboot-tar
uboot-tar: update-uboot $(UBOOT_TAR)

.PHONY: uboot-tar-clean
uboot-tar-clean: 
	$(SILENT)$(RM) $(UBOOT_DIR) $(UBOOT_TAR)

########### linux-infra (from git)
INFRA_DOCS := $(LINUX_INFRA)/release/docs
INFRA_SCRIPTS := $(LINUX_INFRA)/release/scripts
LINUX_INFRA_BRANCH := master

# Update linux-infra if necessary
.PHONY: update-linux-infra
update-linux-infra: $(LINUX_INFRA)
	@$(ECHO) "### Updating linux-Infra to $(LINUX_INFRA_BRANCH) ###"
	$(SILENT)$(CD) $(LINUX_INFRA) && \
		$(GIT) fetch origin && \
		$(GIT) reset --keep $(LINUX_INFRA_BRANCH) && \
		$(GIT) checkout $(LINUX_INFRA_BRANCH)

.PHONY: linux-infra-clean
linux-infra-clean:
	$(RM) $(LINUX_INFRA)

# Create if it doesn't exist
$(LINUX_INFRA):
	@$(ECHO) "### git'ing linux-infra ###"
	$(SILENT)$(GIT) clone $(GIT_SERVER):linux-infra.git $(LINUX_INFRA)


###################### POKY TAR

# Rule to insure that it is up-to-date with the git repository
.PHONY: update-poky
update-poky: $(POKY_DIR)
	@$(ECHO) "### Updating Poky to $(POKY_BRANCH) ###"
	$(SILENT)$(CD) $(POKY_DIR) && \
		$(GIT) fetch origin && \
		$(GIT) reset --keep $(POKY_BRANCH) && \
		$(GIT) checkout $(POKY_BRANCH)

$(POKY_DIR):
	@$(ECHO) "### git'ing Poky ###"
	$(SILENT)$(GIT) clone $(GIT_SERVER):poky $@

# This rule is here to force an update of the tar is git was updated
$(POKY_DIR)/.git: $(POKY_DIR)

$(POKY_TAR): $(BUILD_SOURCES) $(POKY_DIR)/.git 
	@$(ECHO) "### Building Poky Tar ###"
	$(SILENT)$(CD) $(POKY_DIR) && \
		$(TAR) --exclude=.gitignore -czf $@ *

$(POKY_SITE_CONF): $(POKY_CONF_DIR) $(LINUX_TAR) $(UBOOT_TAR)
	@$(ECHO) 'SCONF_VERSION = "1"' > $@
	@$(ECHO) '' >> $@
	@$(ECHO) '# Premirrors reduces download time and bandwidth usage by downloading files from' >> $@
	@$(ECHO) '# alternate locations, especially from internal file/web servers.' >> $@
	@$(ECHO) 'SOURCE_MIRROR_URL = "file://__INSTALL_PATH__/sources/"' >> $@
	@$(ECHO) 'INHERIT += "own-mirrors"' >> $@
	@$(ECHO) '' >> $@
ifeq ($(POKY_VER_NAME),danny)
	@$(ECHO) 'TCLIBC = "external-linaro-toolchain"' >> $@
	@$(ECHO) 'TCMODE = "external-linaro"' >> $@
	@$(ECHO) 'EXTERNAL_TOOLCHAIN = "__INSTALL_PATH__/linaro/gcc-linaro-arm-linux-gnueabihf-4.7-2012.11-20121123_linux"' >> $@
	@$(ECHO) '' >> $@
endif
ifeq ($(POKY_VER_NAME),dylan)
	@$(ECHO) 'GCCVERSION="linaro-4.7"' >> $@
	@$(ECHO) 'SDKGCCVERSION="linaro-4.7"' >> $@
	@$(ECHO) '' >> $@
endif
	@$(ECHO) 'ALTERA_LINUX_MD5SUM="$(shell $(MD5SUM) ${LINUX_TAR} | head -c 32)"' >> $@
	@$(ECHO) 'ALTERA_LINUX_SHA256SUM="$(shell $(SHA256SUM) ${LINUX_TAR} | head -c 64)"' >> $@
	@$(ECHO) 'ALTERA_UBOOT_MD5SUM="$(shell $(MD5SUM) ${UBOOT_TAR} | head -c 32)"' >> $@
	@$(ECHO) 'ALTERA_UBOOT_SHA256SUM="$(shell $(SHA256SUM) ${UBOOT_TAR} | head -c 64)"' >> $@
	@$(ECHO) '' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_virtual/kernel = "linux-altera-dist"' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_linux = "linux-altera-dist"' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_linux-libc-headers = "linux-libc-headers-altera-dist"' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_linux-libc-headers-dev = "linux-libc-headers-altera-dist"' >> $@
	@$(ECHO) '' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_virtual/bootloader = "u-boot-altera-dist"' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_u-boot = "u-boot-altera-dist"' >> $@
	@$(ECHO) 'PREFERRED_PROVIDER_u-boot-mkimage = "u-boot-mkimage-altera-dist"' >> $@

.PHONY: poky-tar
poky-tar: $(POKY_TAR)

.PHONY: poky-git-clean
poky-git-clean: 
	$(SILENT)$(RM) $(POKY_DIR)

.PHONY: update-all
update-all: update-linux-infra update-linux update-uboot update-poky

########### 	Main Installer Rules
.PHONY: installer-clean
installer-clean:
	@$(ECHO) "Cleaning install directory"
	$(SILENT)$(RM) $(STAGE_AREA)
	$(SILENT)$(RM) $(BUILD_SOURCES)

# Build installer using the linux and uboot packages that are currently on your system
#	*installs these on your system if they're not there

# Build the installer using the linux and uboot tot
.PHONY: installer
installer: $(YOCTO_SRC_PKG_MD5)
	@$(ECHO) "Installer Package available at $(YOCTO_SRC_PKG)"

# The following will likely change at some point. We need a good way to work with big tars
YOCTO_BIG_BALL_OF_TAR := $(YOCTO_SRC_PAYLOAD)/big_tar.tgz
YOCTO_SRC_PKG_PAYLOAD := $(YOCTO_WORKSPACE)/decompress_src.sh $(INFRA_DOCS)/EULA $(INFRA_SCRIPTS)/payload-marker $(YOCTO_WORKSPACE)/tmp/payload.tar

.PHONY: big_tar
big-tar: $(YOCTO_BIG_BALL_OF_TAR)

$(YOCTO_BIG_BALL_OF_TAR): $(YOCTO_SRC_PAYLOAD)/sources
	@$(ECHO) "### Creating base tar of packages"
	$(SILENT)$(CD) $(YOCTO_SRC_PAYLOAD) && \
		$(TAR) -cf $@ ./sources/* && \
		$(CHMOD) a+r $@

###	EULA and manifest
$(YOCTO_WORKSPACE)/EULA: $(LINUX_INFRA) $(INFRA_DOCS)/EULA
	@$(ECHO) "### Copying EULA into place"
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE) 
	$(SILENT)$(RSYNC) $(INFRA_DOCS)/EULA $(YOCTO_WORKSPACE)/

$(YOCTO_WORKSPACE)/manifest.txt: $(LINUX_INFRA) $(INFRA_DOCS)/manifest.txt
	@$(ECHO) "### Copying manifest into place"
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE) 
	$(SILENT)$(RSYNC) $(INFRA_DOCS)/manifest.txt $(YOCTO_WORKSPACE)/

###	Install scripts
$(SRC_INSTALL_SCRIPT): $(LINUX_INFRA) $(INFRA_SCRIPTS)/$(YOCTO_INSTALL_SCRIPTNAME) $(LINUX_TAR) $(UBOOT_TAR)
	@$(ECHO) "### Copying Yocto Install Script to workspace/bin"
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE)/bin
	$(SILENT)$(RSYNC) $(INFRA_SCRIPTS)/$(YOCTO_INSTALL_SCRIPTNAME) $@
	$(SILENT)$(SED) -i "s/__RELEASE_NUMBER__/${SOCFPGA_LINUX_VERSION}/" $@
	$(SILENT)$(SED) -i "s/__YOCTO_RELEASE__/${POKY_VER_FULL}/" $@
	$(SILENT)$(SED) -i "s/__LINUX_VERSION__/${LINUX_VERSION}/" $@
	$(SILENT)$(SED) -i "s/__UBOOT_VERSION__/${UBOOT_VERSION}/" $@
	
$(SRC_MAKE_SD_CARD_SCRIPT): $(LINUX_INFRA)/tools/$(MAKE_SDCARD_SCRIPTNAME)
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE)/bin
	$(SILENT)$(RSYNC) $< $@

$(SRC_MAKE_PRELOADER): $(LINUX_INFRA)/tools/$(MAKE_PRELOADER_NAME)
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE)/bin
	$(SILENT)$(RSYNC) $< $@

$(YOCTO_WORKSPACE)/decompress_src.sh: $(INFRA_INFRA) $(INFRA_SCRIPTS)/decompress_src.sh
	@$(ECHO) "### Copying Decompress Script to workspace/bin"
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE)
	$(SILENT)$(RSYNC) $(INFRA_SCRIPTS)/decompress_src.sh $@
	$(SILENT)$(SED) -i "s/__RELEASE_NUMBER__/${SOCFPGA_LINUX_VERSION}/" $@

.PHONY: payload
payload: $(YOCTO_WORKSPACE)/tmp/payload.tar

.PHONY: payload-clean
payload-clean:
	$(SILENT)$(RM) $(YOCTO_WORKSPACE)/tmp/payload.tar

$(YOCTO_WORKSPACE)/tmp/payload.tar: $(YOCTO_BIG_BALL_OF_TAR) $(PAYLOAD_FILES) $(LINUX_TAR) $(UBOOT_TAR) $(POKY_TAR) $(POKY_SITE_CONF)
	@$(ECHO) "### Building new payload tar file"
	$(SILENT)$(MKDIR) $(YOCTO_WORKSPACE)/tmp 
	$(SILENT)$(RM) $@
	$(SILENT)$(CP) $(YOCTO_BIG_BALL_OF_TAR) $@
	$(SILENT)$(TAR) -C $(YOCTO_WORKSPACE) -uf $@ ./EULA ./manifest.txt ./bin ./sources

#### Create the self-extracting archive
$(YOCTO_SRC_PKG): $(LINUX_INFRA) $(YOCTO_SRC_STAGE_AREA) $(YOCTO_SRC_PKG_PAYLOAD)
	@$(ECHO) "### Creating Release package" 
	$(SILENT)$(CD) $(YOCTO_SRC_STAGE_AREA) && \
		$(CAT) $(YOCTO_SRC_PKG_PAYLOAD) > $@ && \
		$(CHMOD) 755 $@

#### Create the md5sum for self-extracting archive
$(YOCTO_SRC_PKG_MD5): $(YOCTO_SRC_PKG)
	@$(ECHO) "### Creating MD5"
	$(SILENT)$(CD) $(YOCTO_SRC_STAGE_AREA) && \
		$(MD5SUM) $(YOCTO_SRC_PKG_NAME).bsx > $@

.PHONY: clean
clean: build-clean install-clean
	$(SILENT)$(RM) $(BUILD_DIR)

###################################################################################
# 		Rules for help
###################################################################################

.PHONY: installer-help
help-installer:
	@$(ECHO) "\tinstaller - build installer bsx"
	@$(ECHO)
	@$(ECHO) "\tlinux-tar - creates/updates linux archive (used by installer)"
	@$(ECHO) "\tuboot-tar - creates/updates uboot archive (used by installer)"
	@$(ECHO)
	@$(ECHO) "\tpayload - includes big-tar, poky, some scripts, eula, etc"
	@$(ECHO) "\tpayload-clean"
	@$(ECHO) "\tbig-tar - creates the big tar next to sources"
	@$(ECHO) "\tupdate-linux-uboot - add the updated linux and uboot tars to payload"

.PHONY: git-help
git-help:
	@$(ECHO) "\tupdate-linux - LINUX_DIR=$(LINUX_DIR), LINUX_BRANCH=$(LINUX_BRANCH)"
	@$(ECHO) "\tupdate-uboot - UBOOT_DIR=$(UBOOT_DIR), UBOOT_BRANCH=$(UBOOT_BRANCH)"
	@$(ECHO) "\tupdate-linux-infra - LINUX_INFRA=$(LINUX_INFRA)"
	@$(ECHO) "\tupdate-poky - POKY_DIR=$(POKY_DIR), POKY_BRANCH=$(POKY_BRANCH)"

.PHONY: help
help:
	@$(ECHO) "Rules:"
	@$(ECHO) "\tall (default) - calls update-all, installer, build, bin-release, validate-bin"
	@$(ECHO) "\tupdate-all - updates linux/uboot from git"
	@$(ECHO) "\tinstaller - builds installer the source code"
	@$(ECHO) "\tbuild - compiles from already build installer"
	@$(ECHO) "\tbin-release - builds binary tar from built binaries"
	@$(ECHO)
	@$(ECHO) "Variables:"
	@$(ECHO) "\tLINUX_VERSION=$(LINUX_VERSION) (can be set to 3.4, 3.5)"
	@$(ECHO) "\tUBOOT_VERSION=$(UBOOT_VERSION) (2012.04,2012.07, 2012.10)"
	@$(ECHO) "\tPOKY_VER=$(POKY_VER) (can be set to 6.0, 6.0.2, or 7.0.1)"
	@$(ECHO) "\tYOCTO_SRC_PKG - This allows you to use a previously created source install package"
	@$(ECHO)
	@$(ECHO) "DIRECTORIES:"
	@$(ECHO) "\tBUILD_DIR - Where on the build machine the compiling happens"
	@$(ECHO) "\t\t = $(BUILD_DIR)"
	@$(ECHO) "\tYOCTO_BUILD_DIR = $(YOCTO_BUILD_DIR)"
	@$(ECHO) "\tSTAGE_AREA = $(STAGE_AREA)"
	@$(ECHO) "\tInstaller Output = $(YOCTO_SRC_STAGE_AREA)"
	@$(ECHO) "\tBuild Output = $(YOCTO_BIN_STAGE_AREA)"
	@$(ECHO)
	@$(ECHO) "Other help:"
	@$(ECHO) "\thelp-installer- for creating a self extracting archive release"
	@$(ECHO) "\tgit-help - list of targets for giting and updating source"

