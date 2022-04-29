LDFLAGS+=-m elf_i386 -T
ASFLAGS+=--32 -o
CFLAGS+=-m32 -fno-builtin -Wall -Wstrict-prototypes -Wmissing-prototypes  -fno-stack-protector -c -o

OBJS +=  main.o \
	print.o \
	interrupt.o \
	init.o \
	kernel.o \
	timer.o \
	debug.o \
	string.o \
	bitmap.o \
	memory.o \
	thread.o \
	list.o \
	switch.o \
	sync.o \
	console.o \
	keyboard.o \
	ioqueue.o \
	tss.o \
	process.o \
	syscall-init.o \
	syscall.o \
	stdio.o \
	stdio-kernel.o \
	ide.o \
	fs.o

kernel.bin: $(OBJS)
	@ld $^ $(LDFLAGS) kernel.lds -e main -o $@

%.o: %.c
	@$(CC) $(CFLAGS) $@ $^

%.o: %.s
	@as $(ASFLAGS) $@ $^

.PHONY:run,clean,boot,disk

boot:
	@as --32 mbr.s -o mbr.o
	@ld -T mbr.lds -m elf_i386 mbr.o -o mbr.bin
	@as --32 loader.s -o loader.o
	@ld -T loader.lds -m elf_i386 loader.o -o loader.bin

run:
	make clean && make && make boot && make disk && bochs

disk:
	@bximage -mode="create" -hd=60M -imgmode="flat" -q hd60M.img
	@bximage -mode="create" -hd=80M -imgmode="flat" -sectsize=512 -q hd80M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=hd60M.img seek=9 bs=512 count=200 conv=notrunc
#fdisk from util-linux 2.34
#	@[ ! -f ./hd80M.img ] && fdisk -c=dos -u=cylinders hd80M.img < ./fdisk.run
	@fdisk -c=dos -u=cylinders hd80M.img < ./fdisk.run

clean:
	@$(RM) -r *.txt *.o *.bin hd60M.img hd80M.img

test:
	@$(CC) $(CFLAGS) bitmap.o bitmap.c 
	@$(CC) $(CFLAGS) console.o console.c
	@$(CC) $(CFLAGS) debug.o debug.c
	@$(CC) $(CFLAGS) fs.o fs.c
	@$(CC) $(CFLAGS) ide.o ide.c
	@$(CC) $(CFLAGS) init.o init.c
	@$(CC) $(CFLAGS) interrupt.o interrupt.c
	@$(CC) $(CFLAGS) ioqueue.o ioqueue.c
	@$(CC) $(CFLAGS) keyboard.o keyboard.c
	@$(CC) $(CFLAGS) list.o list.c
	@$(CC) $(CFLAGS) main.o main.c
	@$(CC) $(CFLAGS) memory.o memory.c
	@$(CC) $(CFLAGS) process.o process.c
	@$(CC) $(CFLAGS) stdio.o stdio.c
	@$(CC) $(CFLAGS) stdio-kernel.o stdio-kernel.c
	@$(CC) $(CFLAGS) string.o string.c
	@$(CC) $(CFLAGS) sync.o sync.c
	@$(CC) $(CFLAGS) syscall.o syscall.c
	@$(CC) $(CFLAGS) syscall-init.o syscall-init.c
	@$(CC) $(CFLAGS) thread.o thread.c
	@$(CC) $(CFLAGS) timer.o timer.c
	@$(CC) $(CFLAGS) tss.o tss.c
	@as $(ASFLAGS) kernel.o kernel.s
	@as $(ASFLAGS) print.o print.s
	@as $(ASFLAGS) switch.o switch.s
	@ld $(OBJS) $(LDFLAGS) kernel.lds -e main -o kernel.bin
	make boot && make disk && bochs
