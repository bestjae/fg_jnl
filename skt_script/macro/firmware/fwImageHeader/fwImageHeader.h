/****************************************************************************
 *
 * Copyright (c) 2010 - 2015 PMC-Sierra, Inc.
 *      All Rights Reserved
 *
 * Distribution of source code or binaries derived from this file is not
 * permitted except as specifically allowed for in the PMC-Sierra
 * Software License agreement.  All copies of this source code
 * modified or unmodified must retain this entire copyright notice and
 * comment as is.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.
 *
 * Description                  : Firmware Image Header header file
 *
 * $Revision: 23675 $
 * $Date: 2015-03-10 18:48:30 -0700 (Tue, 10 Mar 2015) $
 * $Author: hackneyc $
 * Release $Name: PMC_EFC_2_2_0 $
 *
 ****************************************************************************/
#ifndef FW_IMAGE_HEADER_H_
#define FW_IMAGE_HEADER_H_

/**
 * @brief Firmware revision size
 */
#define FW_REVISION_SIZE                8

/**
 * @brief Firmware header data structure
 */
typedef struct
{
    /**
     * @brief This field indicates the byte size of the firmware image. The size
     *        includes all the elf files with tar headers and 2x512 zero padding 
     *        data at the end of the tar file.The header file and its tar header 
     *        are not included.
     *
     *        Byte [03:00]
     */
    unsigned int length;
    /**
     * @brief Number of elf files in this firmware image.
     *
     *        Byte [07:04]
     */
    unsigned int numOfFiles;
    /**
     * @brief Reserved
     * 
     *        Byte [23:8]
     */
    char rsvd23_08[16];
    /**
     * @brief This field indicates the firmware revision of this firmware image. 
     *        This field should meet ASCII string requirement.
     *
     *        Byte [31:24]
     */
    char fwRevision[FW_REVISION_SIZE];
    /**
     * @brief Reserved
     *
     *        Byte [63:32]
     */
    char rsvd63_32[32];
    
}fw_header_t;

#endif // FW_IMAGE_HEADER_H_
