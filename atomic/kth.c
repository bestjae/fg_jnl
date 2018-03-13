/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : kth.c
 * Purpose : 
 * Creation Date : 2018-03-12
 * Last Modified : 2018-03-12 14:19:48
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */
#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/completion.h>
#include <linux/delay.h>
#include <linux/kthread.h>

int flag=0;
struct task_struct *th_id;

static int kernel_thread_thr_wait(void *arg)
{
	  int i = 0;
	    char *text = (char *)arg;
	      while(flag)
		        {
				    printk(KERN_ALERT "KERNEL_THREAD. %d [ %s ]\n", i, text);
				        ++i;
					    udelay(1000);
					      }
	        printk(KERN_ALERT "KERNEL_THREAD. Stoped\n");
		  return 0;
} 

static void DONE(void)
{
	  flag = 0;
}  

static int __init kernel_thread_init(void)
{
	  flag = 1;
	    th_id = (struct task_struct *)kernel_thread(kernel_thread_thr_wait, "TEST", CLONE_KERNEL);
	      if(IS_ERR(th_id)){
		          printk(KERN_ALERT "Fail to create the thread\n");
			      return -1;
			        }
	        udelay(5000);
		  DONE();
		    로 udelay(5000);
		      return 0;
} 

static void kernel_thread_release(void)
{
	  printk(KERN_ALERT "Exit %s()\n", __FUNCTION__);
} 

module_init(kernel_thread_init);
module_exit(kernel_thread_release);
MODULE_LICENSE("Dual BSD/GPL"); 

