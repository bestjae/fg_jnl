/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : demon.c
 * Purpose : 
 * Creation Date : 2018-02-06
 * Last Modified : 2018-03-12 15:20:43
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <fcntl.h>
#include <sys/stat.h>

int main()
{
	pid_t pid;

	if(( pid=fork()) < 0 ) {
		exit(0);
	}else if(pid == 0){
		setsid();

		while(1) {
			sleep(1);
		}
	}
	else{
		exit(0);
	}
}
