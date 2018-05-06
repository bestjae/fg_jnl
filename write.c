/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : write.c
 * Purpose : 
 * Creation Date : 2018-04-25
 * Last Modified : 2018-05-02 23:00:45
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

#define MAX 1024

int main (int argc, char *argv[]) {

	int fd;
	int readn;
	int writen;
	char buf[MAX];
	char file_name[MAX];
	char *buf2 = "12345678";

	sprintf(file_name,"/root/mnt/test%s.txt",argv[1]);

	//Open File and Get File Descripter//
	
	if(argc < 2)
		fd = creat("/root/mnt/test.txt", O_RDWR);
	else
		fd = creat(file_name, O_RDWR);

	if (fd == -1){
		printf ("File open failed.....\n");
		return 1;
	}

	// Write buf2 into fd 
	for (int i = 0 ; i < 512 ; i++) {
		writen = write(fd, buf2, strlen(buf2));
	}
	printf ("fd is written with buf \n");

	// Set FD cursor to the starting point
	int current = lseek(fd, 0, SEEK_SET);

	memset (buf, 0x00, MAX);
	readn = read(fd, buf, sizeof(buf2));

	printf ("Readn is ..... %d\n", readn);
	printf ("buf contents is ... %s\n", buf);

	writen = fsync(fd);

	close (fd);
	return 1;

}

