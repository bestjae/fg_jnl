/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : hello_mod.c
 * Purpose : 
 * Creation Date : 2018-03-12
 * Last Modified : 2018-03-12 15:31:46
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>
#include <linux/delay.h>
#include <linux/kthread.h>

struct task_struct *g_th_id=NULL;

static int kthread_example_thr_fun(void *arg)
{
	printk(KERN_ALERT "@ %s() : called\n", __FUNCTION__);
	while(!kthread_should_stop())
	{
		printk(KERN_ALERT "@ %s() : loop\n", __FUNCTION__);
		ssleep(1); 
	}
	printk(KERN_ALERT "@ %s() : kthread_should_stop() called. Bye.\n", __FUNCTION__);
	return 0;
} 

static int __init kthread_example_init(void)
{
	printk(KERN_ALERT "@ %s() : called\n", __FUNCTION__);

	printk("Hello MODULE is loaded\n");
	if(g_th_id == NULL){ 
		g_th_id = (struct task_struct *)kthread_run(kthread_example_thr_fun, NULL, "kthread_example");
	}
	return 0;
} 

static void __exit kthread_example_release(void)
{
	if(g_th_id){
		kthread_stop(g_th_id);
		g_th_id = NULL;
	}
	printk(KERN_ALERT "@ %s() : Bye.\n", __FUNCTION__);
} 


module_init(kthread_example_init);
module_exit(kthread_example_release);
MODULE_LICENSE("Dual BSD/GPL");

