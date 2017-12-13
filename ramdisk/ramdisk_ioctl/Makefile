CC = gcc
OBJS = inject_error.o

TARGET = inject_error 

CFLAGS += -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D__USE_FILE_OFFSET64

.SUFFIXES : .c .o

all : $(TARGET)

$(TARGET): $(OBJS)
	 $(CC) $(CFLAGS) -o $@ $(OBJS)

clean :
	rm -f $(OBJS) $(TARGET)
