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
 * Description                  : crc16-ONFI calculator.
 * 
 * $Revision: 23691 $
 * $Date: 2015-03-10 19:00:27 -0700 (Tue, 10 Mar 2015) $
 * $Author: hackneyc $
 * Release $Name: PMC_EFC_2_2_0 $
 *
 ****************************************************************************/
#include <stdio.h>
#include "crc.h"

/**
 *  @brief Get lower 8 bits
 */
#define GET_LOW8(X)                     (X&0xFF)

/**
 *  @brief Get upper 8 bits
 */
#define GET_UP8(X)                      ((X&0xFF00) >> 8)

/**
 * @brief File read buffer.
 */
static unsigned char buffer[1024];

/**
 * @brief Application entry point.
 * 
 * @param[in] argc Command line argument count.
 * @param[in] argv Array of command line arguments.
 * 
 * @retval 0 Execution completed successfully.
 * @retval -1 An error occurred.
 */
int main(int argc, char *argv[])
{
    crc remainder;
    int bytesRead;
    int n;
    FILE *filePtr;
    char *fileName = NULL;
    int noCR = 0;
    unsigned int remainder32;
    int binFlag = 0;

    /*
     * Check for the correct number of arguments.
     */
    if (argc < 2)
    {
        printf("Usage: %s [OPTIONS] <filename>\n", argv[0]);
        printf("Calculate and display the CRC16-ONFI checksum for the specified file.\n\n");
        printf("OPTIONS:\n");
        printf("\t -n\tdo not output the trailing newline\n");
        printf("\t -b\toutput binary value\n");
        printf("\n");
        return (-1);
    }

    for (n=1; n<argc; n++)
    {
        if (argv[n][0] == '-')
        {
            switch (argv[n][1])
            {
            case 'n':
                noCR = 1;
                break;
            case 'b':
                binFlag = 1;
                break;                
            default:
                fprintf(stderr, "Error: unrecognized parameter %s\n", argv[n]);
                return (-1);
                break;
            }
        }
        else
            fileName = argv[n];
    }

    /*
     * Try to open the input file and report an error if
     * it can't be opened.
     */
    if ((filePtr = fopen(fileName, "r")) == NULL)
    {
        fprintf(stderr, "Error: Unable to open input file %s\n", argv[1]);
        return (-1);
    }

    /*
     * Read in the first chunk from the file.
     */
    bytesRead = fread(buffer, 1, sizeof(buffer), filePtr);
    /*
     * Calculate the CRC on the first chunk and remember the remainder.
     */
    remainder = crcInitONFI(buffer, bytesRead);

    /*
     * Process the rest of the file.
     */
    while ((bytesRead = fread(buffer, 1, sizeof(buffer), filePtr)))
        remainder = crcONFI(buffer, bytesRead, remainder);

    /*
     * Close the input file.
     */
    fclose(filePtr);

#if 0
    /*
     * Write remainder to the end of the tar file
     */
    filePtr = fopen(fileName, "ab");
    fwrite(&remainder32, 1, sizeof(unsigned int), filePtr);
    fclose(filePtr);    
#endif
    
    /*
     * Display the calculated CRC in hex.
     */
    if(binFlag == 1)
    {
        remainder32 = remainder;
        for(n=0; n<4; n++)
        {
            printf("%c", GET_LOW8(remainder32));
            remainder32 = remainder32 >> 8;
        }
    }
    else
    {
        remainder32 = remainder;
        printf("%8x", remainder32);
        if (!noCR)
            printf("\n");
    }
   
    return (0);
}
