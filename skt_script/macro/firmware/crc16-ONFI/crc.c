/**********************************************************************
 * $Id: crc.c 13520 2013-08-26 18:47:29Z raphaelo $
 * 
 * Filename:    crc.c
 * 
 * Description: Implementation of the CRC standards.
 *
 * Notes:  Modifications to the original by Michael Barr were made to 
 *         reduce the size of the image as much as possible as a 
 *         tradeoff for speed.
 * 
 *         The algorithms selected match the ONFI specification.
 * 
 * 		@todo FIXME, need to re-write mathmatical operations to take
 *            advantage of new TIE operations when they are available.
 * 
 * Copyright (c) 2000 by Michael Barr.  This software is placed into
 * the public domain and may be used for any purpose.  However, this
 * notice must not be changed or removed and no warranty is either
 * expressed or implied by its publication or distribution.
 **********************************************************************/
#include "crc.h"

/**
 * @brief CRC lookup table
 */
static crc crcTable[256];

/**
 * @brief Indicates whether the CRC table initialized.
 */
static int crcTableInit = 0;

/**
 * @brief Initialize the CRC table.
 */
void crcInit(void)
{
    crc  remainder;
    int dividend;
    unsigned char bit;


    /*
     * Compute the remainder of each possible dividend.
     */
    for (dividend = 0; dividend < 256; ++dividend)
    {
        /*
         * Start with the dividend followed by zeros.
         */
        remainder = dividend << (CRC_WIDTH - 8);

        /*
         * Perform modulo-2 division, a bit at a time.
         */
        for (bit = 8; bit > 0; --bit)
        {
            /*
             * Try to divide the current data bit.
             */			
            if (remainder & CRC_TOPBIT)
            {
                remainder = (remainder << 1) ^ CRC_POLYNOMIAL;
            }
            else
            {
                remainder = (remainder << 1);
            }
        }

        /*
         * Store the result into the table.
         */
        crcTable[dividend] = remainder;
    }

    /*
     * Update that the CRC table initialized.
     */
    crcTableInit = 1;

}   /* crcInit() */

/******************************************************************//**
 * @brief  Compute the CRC of a given message.
 * 
 * @param message   Pointer to the start of the message to calculate CRC on.
 * @param nBytes    Length of the message in bytes to caculate CRC on.
 * @param remainder Starting remainder for CRC calculation.
 * 
 * @return          This function returns the CRC of the message.
 *********************************************************************/
crc crcONFI(unsigned char const message[], int nBytes, crc remainder)
{

    int byte;
    unsigned char data;

    /**
     * Check whether the CRC table is initialized.
     */
    if (!crcTableInit)
    {
    	crcInit();
    }
    
    /**
     * Divide the message by the polynomial, a byte at a time.
     */
    for (byte = 0; byte < nBytes; ++byte)
    {
        /**
         * Bring the next byte into the remainder.
         */
        data = message[byte] ^ (remainder >> (CRC_WIDTH - 8));
        remainder = crcTable[data] ^ (remainder << 8);
    }
    
    /**
     * The final remainder is the CRC result.
     */
    return (remainder);

}

/******************************************************************//**
 * @brief  Compute the Initial CRC of a given message. (no remainder)
 * 
 * @param message   Pointer to the start of the message to calculate CRC on.
 * @param nBytes    Length of the message in bytes to caculate CRC on.
 * 
 * @return          This function returns the first CRC of the message.
 *********************************************************************/
crc crcInitONFI(unsigned char const message[], int nBytes)
{
    return (crcONFI(message, nBytes, (crc) CRC_INITIAL_REMAINDER));
}

