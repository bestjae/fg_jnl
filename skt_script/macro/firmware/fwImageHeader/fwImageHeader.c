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
 * Description                  : Create firmware image header.
 * 
 * $Revision: 23691 $
 * $Date: 2015-03-10 19:00:27 -0700 (Tue, 10 Mar 2015) $
 * $Author: hackneyc $
 * Release $Name: PMC_EFC_2_2_0 $
 *
 ****************************************************************************/
#include <stdtypes.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <crc.h>
#include <fwImageHeader.h>

/**
 * @brief Command status
 */
#define GEN_SC                          (0)
#define GEN_ERR                         (-1)

/**
 * @brief Number of elf files in tar file
 */
#define NUM_ELF_FILES                   16

/**
 * @brief Create firmware image header
 *
 * @return N/A
 */
int createFwHeader(void)
{
    FILE * filePtr;
    fw_header_t * fwHeaderPtr;

    /* 
     * Prepare data 
     */
    fwHeaderPtr = (fw_header_t *) malloc(sizeof(fw_header_t));
    memset(fwHeaderPtr, 0, sizeof(fw_header_t));

    /*
     * Number of elf files
     * todo Use code to find out number of elf files
     */
    fwHeaderPtr->numOfFiles = NUM_ELF_FILES;

    //getFwRevision(&(fwHeaderPtr->fwRevision[0]), FW_REV_LEN);

    /* 
     * Save buffer to firmeare header file
     */
    filePtr = fopen("fwHeader.bin", "wb+");
    if(filePtr == NULL)
    {
        printf("Can not open fwHeader.bin!\n");
        return GEN_ERR;
    }
    //fwrite(fwHeaderPtr, 1, sizeof(fw_header_t), filePtr);
    fwrite(fwHeaderPtr, 1, 24, filePtr); // Only write 8 bytes

    fclose(filePtr);
    free(fwHeaderPtr);

    return GEN_SC;
}

/**
 * @brief Set firmware image size
 *
 * @return N/A
 */
int setFwImageSize(void)
{
    FILE * filePtr;
    unsigned int fileSize;
    

    /* Find out length of elf file */
    filePtr = fopen("firmware.tar", "r");
    if(filePtr == NULL)
    {
        printf("Can not open firmware.tar!\n");
        return GEN_ERR;
    }

    /*
     * Obtain file size 
     */
    fseek (filePtr , 0 , SEEK_END);
    fileSize = ftell (filePtr);
    printf("tar file length=%d\n", fileSize);
    fclose (filePtr);

    /* 
     * Save buffer to firmeare header file
     */
    filePtr = fopen("firmware.tar", "rb+");
    if(filePtr == NULL)
    {
        printf("Can not open fwHeader.txt!\n");
        return GEN_ERR;
    }
    fseek(filePtr, 512, SEEK_SET);
    fwrite(&fileSize, 4, 1, filePtr);

    fclose(filePtr);

    return GEN_SC;
}


/**
 * @brief Authorization firmware image
 */
void setAuthorizationFwImage(fw_header_t* fwHeaderPtr)
{
	char signature[] = FW_SIGNATURE;
	char internalKey[] = FW_INTERNAL_KEY;
	int i = 0;

	for (i = 0; i < (int)sizeof(signature); i++)
	{
		fwHeaderPtr->fwSignature[i] = signature[i];
	}

	for (i = 0; i < FW_REVISION_SIZE; i++)
	{
		fwHeaderPtr->fwXorInfo[i] = (fwHeaderPtr->fwRevision[i] ^ internalKey[i]);
	}
}

int setFwAuthorization()
{
	FILE * filePtr;
	fw_header_t * fwHeaderPtr;

	/*
	 * Prepare data
	 */
	fwHeaderPtr = (fw_header_t *) malloc(sizeof(fw_header_t));

	// read fwHeader.bin
	filePtr = fopen("fwHeader.bin", "rb+");
	if(filePtr == NULL)
	{
		printf("Can not open fwHeader.bin!\n");
		return GEN_ERR;
	}
	fread(fwHeaderPtr, 1, sizeof(fw_header_t), filePtr);
	fclose(filePtr);

	// write fwheader.bin for authorization
	filePtr = fopen("fwHeader.bin", "wb+");

	setAuthorizationFwImage(fwHeaderPtr);

	fwrite(fwHeaderPtr, 1, sizeof(fw_header_t), filePtr);
	fclose(filePtr);

	free(fwHeaderPtr);

	return GEN_SC;
}

/**
 * @brief Application entry point.
 *
 * @param[in] argc Command line argument count.
 * @param[in] argv Array of command line arguments.
 *
 * @return N/A
 */
int main(int argc, char * argv[])
{
    int status;
    
    if(argc != 2)
    {
        printf("Have to be one parameter %s!\n", argv[1]);
        return GEN_ERR;
    }

    if(*argv[1] == '1')
    {
        /* Create firmware image header */
        status = createFwHeader();
    }
    else if(*argv[1] == '0')
    {
        /* Set firmware image size */
        status = setFwImageSize();
    }
    else if(*argv[1] == '2')
    {
    	status = setFwAuthorization();
    }

    return GEN_SC;
}
