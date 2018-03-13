/*
 * Simple Block Device Driver
 * reference : Linux Device Drivers 3rd edition
 */

#include <linux/module.h>
#include <linux/moduleparam.h>
#include <linux/init.h>

#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/types.h>
#include <linux/vmalloc.h>
#include <linux/genhd.h>
#include <linux/blkdev.h>
#include <linux/hdreg.h>

#include <asm/uaccess.h>

MODULE_LICENSE("Dual BSD/GPL");
static char *Version = "1.0";

static int major_num = 0;
module_param(major_num, int, 0);
static int logical_block_size = 512;
module_param(logical_block_size, int, 0);
static int nsectors= 2*1024*1024;	/* 1GB */
module_param(nsectors, int, 0);

#define KERNEL_SECTOR_SIZE 512
#define VM_NODE 1	/* total size : VM_NODE * 1GB */

#define KERNEL3X
#define INJECT_ERROR

static struct request_queue *Queue;

static struct rdk_device {
	unsigned long size;
	spinlock_t lock;
	u8 *data[VM_NODE];
	struct gendisk *gd;
}Device;

int logging_enable = 0;

#define INJECT_DEFINED_ERROR	(0)
#define INJECT_ERROR_START		(1)
#define INJECT_ERROR_RELEASE	(2)
#define ERASE_ALL_DATA			(3)

enum {
	BIT_CORRUPTION = 0,
	SHORN_WRITE,
	FLYING_WRITE,
	UNSERIALIZABILITY,
	NO_WRITTEN_DATA,

	ERROR_TYPE_MAX,
};
/*
 * how to inject errors.
 * 
 * 1) BIT CORRUPTION
 *    change some bits of target page randomly
 * 2) SHORN WRITE
 *    a) reset some sectors by zero
 *    b) remain some old data of target page
 * 3) FLYING WRITE
 *    data of target page is copied to new target sector
 *    and, target page is reset by zero
 * 4) UNSERIALIZABILITY
 *    do nothing...
 */

/* shorn error type = 1 */
long shorn_write_lbn = -1;

struct list_head error_head;

struct inject_error_list_t {
	struct list_head list;
	struct inject_error_t *error;
};

struct inject_error_t {
	int error_type;

	unsigned long page_idx;
	union {
		unsigned long new_page_idx;		/* for flying_write */
		int shorn_error_type;			/* for shorn_write */
	};
};

//#define DEBUG_LOGGING

#ifdef DEBUG_LOGGING
#define GET_LOGGING_DATA		(10)
#define SET_LOGGING_DATA		(11)

struct rdk_log_data{
	char pname[12];
	sector_t sector;
	unsigned long nsect;
	int write;
};

#define DATA_COUNT	100000
struct rdk_log_data log_list[DATA_COUNT];
unsigned long log_idx = 0;
unsigned long send_idx = 0;

static void init_log_list(void)
{
	memset(log_list, 0x0, sizeof(struct rdk_log_data)*DATA_COUNT);
	log_idx = 0;
	send_idx = 0;
}

static int logging_rdk_transfer(sector_t sector, 
		unsigned long nsect, char *buffer, int write)
{
	if(log_idx >= DATA_COUNT)
		return 0;

	memcpy(log_list[log_idx].pname, current->comm, sizeof(current->comm));
	log_list[log_idx].sector = sector;
	log_list[log_idx].nsect = nsect;
	log_list[log_idx].write = write;

	//printk("<%s> < %ld > %s sector (%ld), nsect (%ld), write (%d)\n", __FUNCTION__, log_idx, current->comm, sector, nsect, write);
	if(!(strncmp(current->comm, "por_analyzer", 12)))
		printk(KERN_ERR "(%s) lbn = %ld, size = %ld\n", (write)?"WRITE":"READ", sector * 512, nsect * 512);

	log_idx++;
	return 1;
}

static int send_rdk_logging(struct rdk_log_data *log)
{
	if(send_idx >= log_idx)
		return 0;
	if(send_idx >= DATA_COUNT)
		return 0;

	memcpy(log, &log_list[send_idx], sizeof(struct rdk_log_data));
	send_idx++;

	return 1;
}
#endif


static void rdk_transfer(struct rdk_device *dev, sector_t sector,
		unsigned long nsect, char *buffer, int write)
{
	unsigned long nsectors_size = nsectors*512;
	unsigned int idx=0, nidx=0;
	unsigned long offset = sector * logical_block_size;
	unsigned long nbytes = nsect * logical_block_size, nnbytes = 0;

	if(shorn_write_lbn == offset) {
		nsect = nsect / 2;
		nbytes = nsect * logical_block_size;
	}

#ifdef DEBUG_LOGGING
	logging_rdk_transfer(sector, nsect, buffer, write);
#endif

	if ((offset + nbytes) > dev->size)	return;

	idx = offset / nsectors_size;
	offset = offset % nsectors_size;

	if ((offset + nbytes) > nsectors_size)
	{
		nidx = idx+1;
		if(nidx >= VM_NODE)		return;
		nnbytes = (offset + nbytes) - nsectors_size;
		nbytes = nbytes - nnbytes;
	}

#if 0
	if(!(strncmp(current->comm, "por_analyzer", 12)))
		printk(KERN_ERR "111. idx(%d) offset(%ld) nbytes(%ld) / nidx(%d) nnbytes(%ld)\n",
				idx, offset, nbytes, nidx, nnbytes);
#endif

	if(write)
	{
		memcpy(dev->data[idx] + offset, buffer, nbytes);
		if(nidx){
			memcpy(dev->data[nidx], buffer+nbytes, nnbytes);
		}
	}
	else
	{
		memcpy(buffer, dev->data[idx] + offset, nbytes);
		if(nidx){
			memcpy(buffer+nbytes, dev->data[nidx], nnbytes);
		}
	}
}

void counting_request_bio_number(struct request *req, int* count, int* size)
{
	int cnt = 0;
	int bi_size = 0;

	struct bio *bio_node = NULL;

	bio_node = req->bio;
	while(bio_node){
#ifdef KERNEL3X
		bi_size += bio_node->bi_iter.bi_size;	/* for kernel-3.19 */
#else
		bi_size += bio_node->bi_size;
#endif
		cnt++;
		bio_node = bio_node->bi_next;
	}
	printk("Bestjae : count = %d, bi_size = %d\n",cnt,bi_size);
	*count = cnt;
	*size = bi_size;
}

static void rdk_request(struct request_queue *q)
{
	struct request *req;
	int cnt, size;
#if 0
	int cnt, size;
#endif

	req = blk_fetch_request(q);
#if 0
	if(req != NULL)
	{
		//counting_request_bio_number(req, &cnt, &size);
		//if(strncmp(current->comm, "udevd", sizeof(char)*5)){
			printk(KERN_ERR "<%s> Info: sector: %ld, nsect: %d, rw: %d\n",
					current->comm, blk_rq_pos(req), blk_rq_cur_sectors(req), rq_data_dir(req));
		//}

	}
#endif
	while(req != NULL)
	{
		counting_request_bio_number(req, &cnt, &size);
		if(req == NULL || (req->cmd_type != REQ_TYPE_FS))
		{
			printk(KERN_ERR "Skip non-CMD request \n");
			__blk_end_request_all(req, -EIO);
			continue;
		}


#ifdef KERNEL3X
		rdk_transfer(&Device, blk_rq_pos(req), blk_rq_cur_sectors(req),
				bio_data(req->bio), rq_data_dir(req));
#else
		rdk_transfer(&Device, blk_rq_pos(req), blk_rq_cur_sectors(req),
				req->buffer, rq_data_dir(req));
#endif
		if(!__blk_end_request_cur(req, 0))
		{
			req = blk_fetch_request(q);
		}
	}
}

int rdk_getgeo(struct block_device * block_device, struct hd_geometry * geo)
{
	long size;

	size = Device.size * (logical_block_size / KERNEL_SECTOR_SIZE);
	geo->cylinders = (size & ~0x3f) >> 6;
	geo->heads = 4;
	geo->sectors = 16;
	geo->start = 0;
	return 0;
}

static void apply_error_injections(struct rdk_device *dev, struct inject_error_t *error)
{
	sector_t sector = error->page_idx * (PAGE_SIZE / 512);
	sector_t new_sector = error->page_idx * (PAGE_SIZE / 512);
	unsigned long nsect = PAGE_SIZE / 512;
	char *buffer = vmalloc(PAGE_SIZE);

	/* read */
	rdk_transfer(&Device, sector, nsect, buffer, 0);

	if(error->error_type == BIT_CORRUPTION) {
		/*
		 * 타겟 LBN의 1KB 위치에서 10byte를 0xA5로 채운다
		 * 예상 결과: bit corruption
		 */
		memset(buffer + (KERNEL_SECTOR_SIZE * 2), 0xA5, 10);
	}
	else if(error->error_type == SHORN_WRITE) {
		/*
		 * shorn error type 0 : 타켓 LBN의 마지막 1KB데이터를 0x0으로 리셋한다.
		 * shorn error type 1 : 타켓 LBN을 기록할 때 2KB 데이터만 기록한다.
		 * 예상 결과: shorn write error
		 */
		if(error->shorn_error_type == 0) {
			printk(KERN_ERR "shorn error: type 0\n");
			memset(buffer + (KERNEL_SECTOR_SIZE * 6), 0x0, (KERNEL_SECTOR_SIZE * 2));
		}
		else if(error->shorn_error_type == 1) {
			printk(KERN_ERR "shorn error: type 1\n");
			shorn_write_lbn = sector * KERNEL_SECTOR_SIZE;
		}
	}
	else if(error->error_type == FLYING_WRITE) {
		/* 
		 * 타겟 위치의 4KB 데이터를 새로운 위치로 복사한다.
		 * 그리고 타겟 위치의 데이터는 0x0으로 리셋한다.
		 * 예상결과: (타겟LBN)No Written Data, (새로운LNB)flying write, Unserializability
		 */
		new_sector = error->new_page_idx * (PAGE_SIZE / KERNEL_SECTOR_SIZE);
		rdk_transfer(&Device, new_sector, nsect, buffer, 1);
		memset(buffer, 0x0, PAGE_SIZE);
	}
	else if(error->error_type == UNSERIALIZABILITY) {
		printk(KERN_ERR "UNSERIALIZABILITY.\n");
	}
	else if(error->error_type == NO_WRITTEN_DATA) {
		/*
		 * 타겟 LBN의 4KB 데이터를 0x0으로 Reset한다.
		 * 예상 결과: no written data
		 */
		memset(buffer, 0x0, PAGE_SIZE);
	}
	else {
		printk(KERN_ERR "unknown error type (%d)\n", error->error_type);
	}

	rdk_transfer(&Device, sector, nsect, buffer, 1);	/* write */

}

static void release_error_lists_one(struct inject_error_list_t *node)
{
	list_del(&node->list);

	if(node->error)
		vfree(node->error);
	vfree(node);
}

static void release_error_lists(void)
{
	struct list_head *pos = NULL, *n = NULL, *head = NULL;
	head = &error_head;

	list_for_each_safe(pos, n, head) {
		struct inject_error_list_t * node = list_entry(pos, struct inject_error_list_t, list);
		release_error_lists_one(node);
	}
}

void erase_all_data(struct rdk_device *dev)
{
	int idx = 0;

	for(idx = 0; idx < VM_NODE; idx++) {
		memset(dev->data[idx], 0x0, nsectors * logical_block_size);
	}
}

#ifdef KERNEL3X
int rdk_ioctl(struct block_device * block_device, fmode_t fmode, unsigned int cmd, unsigned long arg)
#else
int rdk_ioctl(struct inode* inode, struct file *filp, unsigned int cmd, unsigned long arg)
#endif
{
	int err = 0;

	switch(cmd){
		case INJECT_DEFINED_ERROR:
			{
				struct inject_error_list_t *node = vmalloc(sizeof(struct inject_error_list_t));
				struct inject_error_t *inject_error = vmalloc(sizeof(struct inject_error_t));

				if(inject_error == NULL) {
					printk(KERN_ERR "failed to vmalloc for inject error.\n");
					return -EFAULT;
				}
				if(copy_from_user(inject_error, (struct inject_error_t*)arg, sizeof(struct inject_error_t)))
				{
					printk(KERN_ERR "failed to copy from user.\n");
					return -EFAULT;
				}

				node->error = inject_error;
				list_add_tail(&node->list, &error_head);

				printk(KERN_ERR "Add Error Lists (error type = %d)\n", inject_error->error_type);
			}
			break;
		case INJECT_ERROR_START:
			{
				struct list_head *pos = NULL, *n = NULL, *head = NULL;

				head = &error_head;
				list_for_each_safe(pos, n, head) {
					struct inject_error_list_t *node = list_entry(pos, struct inject_error_list_t, list);
					struct inject_error_t *error = node->error;
					apply_error_injections(&Device, error);
				}

			}
			break;
		case INJECT_ERROR_RELEASE:
			release_error_lists();
			shorn_write_lbn = -1;
			break;
		case ERASE_ALL_DATA:
			erase_all_data(&Device);
			printk(KERN_ERR "WARNING: All data is erased.\n");
			break;

#ifdef DEBUG_LOGGING
		case GET_LOGGING_DATA:
			if(arg != 0)
			{
				struct rdk_log_data log;
				memset(&log, 0x0, sizeof(struct rdk_log_data));

				if((send_rdk_logging(&log)))
				{
					if(copy_to_user((struct rdk_log_data*)arg, &log, sizeof(struct rdk_log_data)))
					{
						printk("(GET_LOGGING_DATA) failed to copy to user.\n");
						return -EFAULT;
					}
				}
				else
				{
					printk(KERN_ERR "Not log!!!\n");
					return -EFAULT;
				}
			}
			else
				printk(KERN_ERR "log is NULL !!!\n");
			break;
		case SET_LOGGING_DATA:
			if(copy_from_user(&logging_enable, (int*)arg, sizeof(int))) {
				printk("(SET_LOGGING_DATA) failed to copy from user.\n");
				return -EFAULT;
			}
			break;
#endif

		default:
			return -EFAULT;
			break;
	};
	return err;
}

static struct block_device_operations rdk_ops = {
	.owner = THIS_MODULE,
	.getgeo = rdk_getgeo,
	.ioctl = rdk_ioctl,
};

static int __init rdk_init(void)
{
	int i = 0;
	unsigned long size = nsectors * logical_block_size;
	Device.size = size * VM_NODE;
	printk(KERN_ERR "Simple Block Device Ver. %s\n", Version);
	printk(KERN_ERR "Device total sectors : %d, total size : %ld MB (%ld KB)\n", 
			nsectors * VM_NODE, Device.size/1024/1024, Device.size/1024);

	spin_lock_init(&Device.lock);
	for(i = 0; i < VM_NODE; i++)
	{
		Device.data[i] = vmalloc(size);
		if(Device.data[i] == NULL)
			goto out;
		memset(Device.data[i], 0x0, size);
	}

	Queue = blk_init_queue(rdk_request, &Device.lock);
	if(Queue == NULL)
		goto out;

	blk_queue_logical_block_size(Queue, logical_block_size);

	major_num = register_blkdev(major_num, "rdk");
	if(major_num < 0)
	{
		printk(KERN_ERR "rdk: unable to get major number\n");
		goto out;
	}

	Device.gd = alloc_disk(16);
	if(!Device.gd)
		goto out_unregister;
	Device.gd->major = major_num;
	Device.gd->first_minor = 0;
	Device.gd->fops = &rdk_ops;
	Device.gd->private_data = &Device;
	strcpy(Device.gd->disk_name, "rdk");
	set_capacity(Device.gd, nsectors * VM_NODE);
	Device.gd->queue = Queue;
	add_disk(Device.gd);

#ifdef DEBUG_LOGGING
	init_log_list();
#endif

	INIT_LIST_HEAD(&error_head);

	printk(KERN_ERR "ramdisk initialization success.\n");
	return 0;

out_unregister:
	unregister_blkdev(major_num, "rdk");
out :
#if 0
	vfree(Device.data);
#else
	for(i = 0; i < VM_NODE; i++)
	{
		printk(KERN_ERR "BY_SWKIM) data %d : %p\n", i, Device.data[i]);
		if(Device.data[i])
			vfree(Device.data[i]);
	}
#endif
	return -ENOMEM;
}

static void __exit rdk_exit(void)
{
	int i = 0;

	del_gendisk(Device.gd);
	put_disk(Device.gd);
	unregister_blkdev(major_num, "rdk");
	blk_cleanup_queue(Queue);
#if 0
	vfree(Device.data);
#else
	for(i = 0; i < VM_NODE; i++)
		if(Device.data[i])
			vfree(Device.data[i]);
#endif
	release_error_lists();
	printk(KERN_ERR "ramdisk exit.\n");

}

module_init(rdk_init);
module_exit(rdk_exit);





