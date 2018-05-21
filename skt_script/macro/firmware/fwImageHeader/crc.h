/**********************************************************************
 * $Revision: 15096 $
 * $Date: 2014-01-22 16:06:03 -0800 (Wed, 22 Jan 2014) $
 * $Author: hackneyc $
 * Release $Name: PMC_EFC_2_2_0 $
 * 
 * Filename:    crc.h
 * 
 * Description: Implementation of the CRC standards.
 *
 * Notes:  Modifications to the original by Michael Barr were made to 
 *         reduce the size of the image as much as possible as a 
 *         tradeoff for speed.
 * 
 *         The algorithms selected match the ONFI specification.
 * 
 * Copyright (c) 2000 by Michael Barr.  This software is placed into
 * the public domain and may be used for any purpose.  However, this
 * notice must not be changed or removed and no warranty is either
 * expressed or implied by its publication or distribution.
 **********************************************************************/
#ifndef CRC_H_
#define CRC_H_

typedef unsigned short crc;


#define CRC_POLYNOMIAL          0x8005
#define CRC_INITIAL_REMAINDER   0x4F4E
    
/*
 * Derive parameters from the standard-specific parameters.
 */
#define CRC_WIDTH    (8 * sizeof(crc))
#define CRC_TOPBIT   (1 << (CRC_WIDTH - 1))

/*
 * @brief  Compute the CRC of a given message.
 * 
 * @param message   Pointer to the start of the message to calculate CRC on.
 * @param nBytes    Length of the message in bytes to caculate CRC on.
 * @param remainder Starting remainder for CRC calculation.
 * 
 * @return          This function returns the CRC of the message.
 */ 
crc crcONFI(unsigned char const message[], int nBytes, crc remainder);


/*
 * @brief  Compute the Initial CRC of a given message. (no remainder)
 * 
 * @param message   Pointer to the start of the message to calculate CRC on.
 * @param nBytes    Length of the message in bytes to caculate CRC on.
 * 
 * @return          This function returns the first CRC of the message.
 */ 
crc crcInitONFI(unsigned char const message[], int nBytes);


#endif  /* CRC_H_ */


