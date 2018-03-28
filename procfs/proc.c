/*
 * Copyright(c) 2016 All rights reserved by Yongjae Choi. 
 *  
 * File Name : hello_mod.c
 * Purpose : 
 * Creation Date : 2018-03-12
 * Last Modified : 2018-03-27 20:08:44
 * Created By : Yongjae Choi <bestjae@naver.com>
 *  
 */
#include <linux/proc_fs.h>
#include <linux/sched.h>
#include <linux/sched.h>
#include <asm/uaccess.h>

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

#define procfs_name "bestjae_proc"
#define COUNT_MAX 16
int len;
char *msg;

struct task_struct *g_th_id=NULL;
extern atomic_t bestjae_atomic;
ssize_t read_proc(struct file *filp, char *buf, size_t count, loff_t *offp)
{
	char buf_read[COUNT_MAX];
	ssize_t len;

	len = scnprintf(buf_read, COUNT_MAX, "%d\n",atomic_read(&bestjae_atomic));

	return simple_read_from_buffer(buf, count, offp, buf_read, len);
}

ssize_t write_proc(struct file *filp, const char *buf, size_t count, loff_t *offp)
{
	char buf_write[COUNT_MAX];
	long temp_write;
	size_t len_written;

	if(count > COUNT_MAX)
		count = COUNT_MAX;
	memset(buf_write,0,COUNT_MAX);
	
	len_written = simple_write_to_buffer(buf_write,COUNT_MAX,offp,buf,count);
	if(!kstrtol(buf_write,0,&temp_write)){
		if( temp_write > 0)
			atomic_set(&bestjae_atomic,1);
		else if(temp_write == 0)	
			atomic_set(&bestjae_atomic,0);
		else
			printk("bestjae : bestjae_atomic = %d",atomic_read(&bestjae_atomic));
	}
	return len_written;
}
static const struct file_operations proc_fops = {
	.read = read_proc,
	.write = write_proc,
	.llseek = generic_file_llseek
};

void create_new_proc_entry(void)
{
	proc_create("bestjae_proc",0,NULL,&proc_fops);
}

static int __init kthread_example_init(void)
{
	printk(KERN_ALERT "@ %s() : called\n", __FUNCTION__);

	printk("bestjae : proc.c MODULE is loaded\n");

	create_new_proc_entry();
	msg = kmalloc(COUNT_MAX,GFP_KERNEL);

	printk("bestjae : /proc/%s created\n",procfs_name);
	/*
	   if(g_th_id == NULL){ 
	   g_th_id = (struct task_struct *)kthread_run(kthread_example_thr_fun, NULL, "kthread_example");
	   }
	   */
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

