#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/types.h>

#define INJECT_ERROR

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

struct inject_error_t {
	int error_type;

	unsigned long page_idx;
	union {
		unsigned long new_page_idx;		/* for flying_write */
		int shorn_error_type;					/* for shorn_write */
	};
};

#define GET_LOGGING_DATA		(10)
#define SET_LOGGING_DATA		(11)
struct sbd_log_data{
	char pname[16];
	unsigned long sector;
	unsigned long nsect;
	int write;
};
unsigned long data_count = 0;
unsigned long total_size = 0;

char *dev_name = NULL;
int err_type = -1;
unsigned long page_idx = 0;
unsigned long new_page_idx = 0;
int shorn_error_type = 0;
int command = 0;
int set_logging = 0;
char *get_logging_output = NULL;

FILE *fp = NULL;
void init_write_log(void)
{
	fp = fopen(get_logging_output, "w+");
}
void output_write(struct sbd_log_data *log)
{
	if(!fp)
		return;

	fprintf(fp, "[%s] lba = %lu\t size = %lu\n",
			(log->write)?"WRITE":"READ", (log->sector * 512), (log->nsect * 512));
}

void close_write_log(void)
{
	if(!fp)
		return;

	fclose(fp);
}

void help(void)
{
	printf("\n"
			"Options\n"
			"\t-d, --device         [device file]   target device file\n"
			"\t-e, --err_type       [type idx]      error type\n"
			"\t                                     0: BIT CORRUPTION\n"
			"\t                                     1: SHORN WRITE\n"
			"\t                                     2: FLYING WRITE\n"
			"\t                                     3: UNSERIALIZABILITY\n"
			"\t                                     4: NO WRITTEN DATA\n"
			"\t-p, --page_idx       [page idx]      page index for error injection\n"
			"\t-n, --new_page_idx   [page idx]      new page index for flying write\n"
			"\t-s, --shorn_type     [type idx]      error type for shorn write\n"
			"\t                                     0: last 1KB is zero(0x0)\n"
			"\t                                     1: only 2KB is written\n"
			"\t-c, --command        [command]       Command Number(default: 0)\n"
			"\t                                     0: INJECT_DEFINED_ERROR\n"
			"\t                                     1: INJECT_ERROR_START\n"
			"\t                                     2: INJECT_ERROR_RELEASE\n"
			"\t                                     3: ERASE_ALL_DATA\n"
			"\n");
}
	//ret = ioctl(fd, STATUS_LOGGING_DATA, &status);
int main(int argc, char** argv)
{
	int fd;
	int ret;
	int i;
	int opt = 0;
	struct inject_error_t error = {0,};
	unsigned long size = 0;

	struct option lopts[] = {
		{"device",			required_argument,	NULL,	'd'},
		{"err_type",		required_argument,	NULL,	'e'},
		{"page_idx",		required_argument,	NULL,	'p'},
		{"new_page_idx",	required_argument,	NULL,	'n'},
		{"command",			required_argument,	NULL,	'c'},
		{"shorn_type",		required_argument,	NULL,	's'},
		{"set_log_state",	required_argument,	NULL,	'S'},
		{"get_log_output",	required_argument,	NULL,	'G'},
		{"help",			no_argument,		NULL,	'h'},
	};

	const char *sopts = "d:e:p:n:c:s:S:G:h";

	while ((opt = getopt_long(argc, argv, sopts, lopts, &optind)) != -1) {
		switch (opt) {
			case 'd':
				dev_name = optarg;
				break;
			case 'e':
				err_type = atoi(optarg);
				break;
			case 'p':
				page_idx = strtoul(optarg, NULL, 10);
				break;
			case 'n':
				new_page_idx = strtoul(optarg, NULL, 10);
				break;
			case 's':
				shorn_error_type = atoi(optarg);
				break;
			case 'c':
				command = atoi(optarg);
				break;
			case 'S':
				set_logging = atoi(optarg);
				break;
			case 'G':
				get_logging_output = optarg;
				break;
			case 'h':
			default:
				help();
				return 0;
		}
	}

	if(dev_name == NULL) {
		fprintf(stderr, "device name is NULL.\n");
		return 0;
	}

	if(!command) {
		if(err_type == -1) {
			fprintf(stderr, "error type is NULL.\n");
			return 0;
		}
		else if(err_type >= ERROR_TYPE_MAX) {
			fprintf(stderr, "wrong error type (%d)\n", err_type);
			return 0;
		}
	}

	fd = open(dev_name, O_RDWR);
	if(fd < 0) {
		printf("%s\n", strerror(errno));
		return 0;
	}
	size = lseek(fd, 0L, SEEK_END);

	if(command == INJECT_DEFINED_ERROR) {
		error.error_type = err_type;
		error.page_idx = page_idx;
		if(err_type == FLYING_WRITE) 
			error.new_page_idx = new_page_idx;
		else if(err_type == SHORN_WRITE)
			error.shorn_error_type = shorn_error_type;

		if((ret = ioctl(fd, INJECT_DEFINED_ERROR, &error)) < 0)
			fprintf(stderr, "INJECT_DEFINED_ERROR command is failed.\n");
	}
	else if(command == ERASE_ALL_DATA) {
		if((ret = ioctl(fd, ERASE_ALL_DATA, &command)) < 0)
			fprintf(stderr, "ERASE_ALL_DATA command is failed.\n");
	}
	else if(command == INJECT_ERROR_START){
		if((ret = ioctl(fd, INJECT_ERROR_START, &command)) < 0)
			fprintf(stderr, "INJECT_ERROR_START command is failed.\n");
	}
	else if(command == INJECT_ERROR_RELEASE){
		if((ret = ioctl(fd, INJECT_ERROR_RELEASE, &command)) < 0)
			fprintf(stderr, "INJECT_ERROR_RELEASE Command is failed.\n");
	}
	else if(command == SET_LOGGING_DATA) {
		if((ret = ioctl(fd, SET_LOGGING_DATA, &set_logging)) < 0)
			fprintf(stderr, "SET_LOGGING_DATA command is failed.\n");
	}
	else if(command == GET_LOGGING_DATA) {
		struct sbd_log_data log;
		if(get_logging_output == NULL) {
			fprintf(stderr, "output file name is NULL.\n");
			close(fd);
			return 0;
		}

		init_write_log();

		while(1) {
			memset(&log, 0x0, sizeof(struct sbd_log_data));
			if((ret = ioctl(fd, GET_LOGGING_DATA, &log)) < 0) {
				fprintf(stderr, "GET_LOGGING_DATA command is failed.\n");
				break;
			}

			output_write(&log);

		}
		close_write_log();

	}

	close(fd);


	return 0;
}
