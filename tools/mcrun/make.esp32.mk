#
# Copyright (c) 2016-2017  Moddable Tech, Inc.
#
#   This file is part of the Moddable SDK Tools.
# 
#   The Moddable SDK Tools is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
# 
#   The Moddable SDK Tools is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
# 
#   You should have received a copy of the GNU General Public License
#   along with the Moddable SDK Tools.  If not, see <http://www.gnu.org/licenses/>.
#

ESP32_BASE ?= $(HOME)/esp32
IDF_PATH ?= $(ESP32_BASE)/esp-idf
export IDF_PATH
ESPTOOL = $(IDF_PATH)/components/esptool_py/esptool/esptool.py
UPLOAD_PORT ?= /dev/cu.SLAB_USBtoUART

BUILDCLUT = $(BUILD_DIR)/bin/mac/release/buildclut
COMPRESSBMF = $(BUILD_DIR)/bin/mac/release/compressbmf
IMAGE2CS = $(BUILD_DIR)/bin/mac/release/image2cs
MCLOCAL = $(BUILD_DIR)/bin/mac/release/mclocal
MCREZ = $(BUILD_DIR)/bin/mac/release/mcrez
PNG2BMP = $(BUILD_DIR)/bin/mac/release/png2bmp
RLE4ENCODE = $(BUILD_DIR)/bin/mac/release/rle4encode
SERIAL2XSBUG = $(MODDABLE)/build/bin/mac/release/serial2xsbug
XSC = $(MODDABLE)/build/bin/mac/release/xsc
XSL = $(MODDABLE)/build/bin/mac/release/xsl

ARCHIVE = $(BIN_DIR)/$(NAME).xsa

ifeq ($(DEBUG),1)
	LAUNCH = debug
else
	LAUNCH = release
endif

all: $(LAUNCH)
	
debug: $(ARCHIVE)
	$(shell pkill serial2xsbug)
	$(ESPTOOL) --port $(UPLOAD_PORT) --after no_reset erase_region 0x3D0000 0x010000
	$(ESPTOOL) --port $(UPLOAD_PORT) write_flash 0x3D0000 $(ARCHIVE)
	$(SERIAL2XSBUG) $(UPLOAD_PORT) 921600 8N1

release: $(ARCHIVE)
	$(ESPTOOL) --port $(UPLOAD_PORT) --after no_reset erase_region 0x3D0000 0x010000
	$(ESPTOOL) --port $(UPLOAD_PORT) write_flash 0x3D0000 $(ARCHIVE)

$(ARCHIVE): $(DATA) $(MODULES) $(RESOURCES)
	@echo "# xsl "$(NAME)".xsa"
	$(XSL) -a -b $(MODULES_DIR) -o $(BIN_DIR) -r $(NAME) $(DATA) $(MODULES) $(RESOURCES)

ifneq ($(VERBOSE),1)
MAKEFLAGS += --silent
endif
