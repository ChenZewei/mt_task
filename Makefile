CC = gcc
CFLAGS = -D_GNU_SOURCE -pthread
INCPATH = -I. -I./include -I/usr/include -I./include/asm
LIB = 
OBJ_FILES = clocks.o kernel_iface.o litmus.o migration.o syscalls.o task.o

mt_task: mt_task.o $(OBJ_FILES)
	$(CC) $(CFLAGS) $(INCPATH) -o mt_task mt_task.o $(OBJ_FILES) 

rtmt: rtmt.o $(OBJ_FILES)
	$(CC) $(CFLAGS) -fopenmp $(INCPATH) -o rtmt rtmt.o $(OBJ_FILES) 

mt_task.o: src/mt_task.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/mt_task.c

rtmt.o: src/rtmt.c
	$(CC) $(CFLAGS) -fopenmp $(INCPATH) -c src/rtmt.c

clocks.o: src/clocks.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/clocks.c

kernel_iface.o: src/kernel_iface.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/kernel_iface.c

litmus.o: src/litmus.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/litmus.c

migration.o: src/migration.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/migration.c

syscalls.o: src/syscalls.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/syscalls.c

task.o: src/task.c
	$(CC) $(CFLAGS) $(INCPATH) -c src/task.c


