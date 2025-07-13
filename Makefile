ATF_DIR := $(CURDIR)/01_atf
LINUX_DIR := $(CURDIR)/02_linux
BUILDROOT_DIR := $(CURDIR)/03_buildroot
VIRT_IMAGES_DIR := $(CURDIR)/virt_images

ATF_OUTPUT_DIR = $(ATF_DIR)/build/qemu/debug
ATF_OUTPUT_FILE += bl1.bin
ATF_OUTPUT_FILE += bl2.bin
ATF_OUTPUT_FILE += bl31.bin

LINUX_OUTPUT_DIR = $(LINUX_DIR)/arch/arm64/boot
LINUX_OUTPUT_FILE += Image

BUILDROOT_OUTPUT_DIR = $(BUILDROOT_DIR)/output/images
BUILDROOT_OUTPUT_FILE += rootfs.cpio.gz

ATF_SCRIPT := build_compile_command.sh
LINUX_SCRIPT := build_qemu_linux.sh
BUILDROOT_SCRIPT := qemu_build.sh

# Makefile 타겟 정의
.PHONY: all atf linux buildroot virt_image clean

all: atf linux buildroot

atf:
	@echo "Building Arm Trusted Firmware (ATF)..."
	cd $(ATF_DIR) && ./$(ATF_SCRIPT)
	cd $(ATF_OUTPUT_DIR) && cp $(ATF_OUTPUT_DIR)/$(ATF_OUTPUT_FILE) $(CURDIR)/virt_images

	@echo "Generating disassembly files..."
	mkdir -p $(VIRT_IMAGES_DIR)/deassemble	
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl31/bl31.elf > $(VIRT_IMAGES_DIR)/deassemble/bl31.s
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl2/bl2.elf > $(VIRT_IMAGES_DIR)/deassemble/bl2.s
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl1/bl1.elf > $(VIRT_IMAGES_DIR)/deassemble/bl1.s

linux:
	@echo "Building Linux kernel for QEMU..."
	cd $(LINUX_DIR) && ./$(LINUX_SCRIPT)
	cp $(LINUX_OUTPUT_DIR)/$(LINUX_OUTPUT_FILE) $(CURDIR)/virt_images

buildroot:
	@echo "Building Buildroot..."
	cd $(BUILDROOT_DIR) && ./$(BUILDROOT_SCRIPT)
	cp $(BUILDROOT_OUTPUT_DIR)/$(BUILDROOT_OUTPUT_FILE) $(CURDIR)/virt_images

virt_image:
	@echo "Copy boot image to virt_images directory..."
	cd $(ATF_OUTPUT_DIR) && cp $(ATF_OUTPUT_FILE) $(CURDIR)/virt_images

	mkdir -p $(VIRT_IMAGES_DIR)/deassemble	
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl31/bl31.elf > $(VIRT_IMAGES_DIR)/deassemble/bl31.s
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl2/bl2.elf > $(VIRT_IMAGES_DIR)/deassemble/bl2.s
	llvm-objdump -d -C -S $(ATF_OUTPUT_DIR)/bl1/bl1.elf > $(VIRT_IMAGES_DIR)/deassemble/bl1.s

	cp $(LINUX_OUTPUT_DIR)/$(LINUX_OUTPUT_FILE) $(CURDIR)/virt_images

	cp $(BUILDROOT_OUTPUT_DIR)/$(BUILDROOT_OUTPUT_FILE) $(CURDIR)/virt_images

clean:
	@echo "Nothing to clean in atf"