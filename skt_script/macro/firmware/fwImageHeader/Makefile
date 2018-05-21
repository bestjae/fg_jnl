#****************************************************************************
#
# Copyright (c) 2010 - 2015 PMC-Sierra, Inc.
#     All Rights Reserved
#
# Distribution of source code or binaries derived from this file is not
# permitted except as specifically allowed for in the PMC-Sierra
# Software License agreement.  All copies of this source code
# modified or unmodified must retain this entire copyright notice and
# comment as is.
#
# THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
# Description : fwImageHeader Makefile.
# $Revision: 23691 $
# $Date: 2015-03-10 19:00:27 -0700 (Tue, 10 Mar 2015) $
# $Author: hackneyc $
# Release : $Name: PMC_EFC_2_2_0 $
#
#****************************************************************************/
CFLAGS := -m32 -W -Wall -MD -D _NATIVE_ -I../../include 
LDFLAGS := -m32
CSRC := $(wildcard *.c)
OBJS := $(CSRC:.c=.o)
EXE_NAME := fwImageHeader

.PHONY: all clean

all: $(EXE_NAME)

clean:
	rm -f $(EXE_NAME) *.[od]

$(EXE_NAME): $(OBJS)
	@echo "Linking $@"
	@$(CC) $(LDFLAGS) $(OBJS) -o $@

%.o: %.c Makefile
	@echo "Compiling $<"
	@$(CC) $(CFLAGS) -c $< -o $@

DEPS := $(OBJS:.o=.d)
-include $(DEPS)
