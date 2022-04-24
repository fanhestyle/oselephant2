LDFLAGS+=-m elf_i386 -T
ASFLAGS+=--32 -o
CFLAGS+=-m32 -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes  -fno-stack-protector -c -o

kernel.bin: main.o \
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
	console.o

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
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=hd60M.img seek=9 bs=512 count=200 conv=notrunc

clean:
	@$(RM) -r *.txt *.o *.bin hd60M.img
