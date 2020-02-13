CC = gcc
GXX = g++
CFLAGS = 
INCPATH = -I. -I./include -I./include/asm -I./include/litmus
LIBS = -pthread
LFLAGS = #-Wl,-O1

TARGET = mt_task

OBJ_FILES = mt_task.o clocks.o common.o cycles.o kernel_iface.o migration.o syscalls.o task.o 

mt_task:mt_task.o $(OBJ_FILES)
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -o $(TARGET) mt_task.o $(OBJ_FILES)

mt_task.o:src/mt_task.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/mt_task.c

clocks.o:src/clocks.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/clocks.c

common.o:src/common.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/common.c

cycles.o:src/cycles.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/cycles.c

kernel_iface.o:src/kernel_iface.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/kernel_iface.c

migration.o:src/migration.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/migration.c

syscalls.o:src/syscalls.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/syscalls.c

task.o:src/task.c
	$(CC) $(CFLAGS) $(INCPATH) $(LIBS) $(LFLAGS) -c src/task.c



