/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : hello_mod.c
 * Purpose : 
 * Creation Date : 2018-03-12
 * Last Modified : 2018-03-22 13:04:04
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */
#include <linux/proc_fs.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/backing-dev.h>
#include <linux/bio.h>
#include <linux/blkdev.h>
#include <linux/blk-mq.h>
#include <linux/highmem.h>
#include <linux/mm.h>
#include <linux/kernel_stat.h>
#include <linux/string.h>
#include <linux/init.h>
#include <linux/completion.h>
#include <linux/slab.h>
#include <linux/swap.h>
#include <linux/writeback.h>
#include <linux/task_io_accounting_ops.h>
#include <linux/fault-inject.h>
#include <linux/list_sort.h>
#include <linux/delay.h>
#include <linux/ratelimit.h>
#include <linux/pm_runtime.h>
#include <linux/blk-cgroup.h>
#include <linux/debugfs.h>
#include <linux/kthread.h> 

#include <trace/events/block.h>

#include "blk.h"
#include "blk-mq.h"
#include "blk-mq-sched.h"
#include "blk-wbt.h"

struct task_struct *g_th_id=NULL;

static int kthread_example_thr_fun(void *arg)
{
	struct bio* bb;
	printk(KERN_ALERT "@ %s() : called\n", __FUNCTION__);
	while(!kthread_should_stop())
	{
		printk(KERN_ALERT "@ %s() : loop\n", __FUNCTION__);
		
		submit_bio_wait(bb);


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

