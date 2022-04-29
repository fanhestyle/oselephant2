LDFLAGS=-m elf_i386
ASFLAGS=--32 -Iinclude
CC=gcc
CFLAGS=-m32 -Iinclude -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes  -fno-stack-protector -c -o

OBJS=main.o kernel.o interrupt.o init.o print.o timer.o debug.o string.o bitmap.o memory.o thread.o list.o switch.o sync.o console.o keyboard.o ioqueue.o tss.o process.o syscall.o syscall-init.o stdio.o stdio-kernel.o ide.o fs.o dir.o file.o inode.o fork.o shell.o assert.o buildin_cmd.o exec.o wait_exit.o pipe.o

kernel.bin:$(OBJS)
	@ld $(LDFLAGS) -T src/kernel.lds -e main -o $@ $^

%.o: src/%.c
	@$(CC) $(CFLAGS) $@ $^

%.o: src/%.s
	@as $(ASFLAGS) $^ -o $@


.PHONY:clean,all,loader,mbr,test,min

mbr:
	@as $(ASFLAGS) src/mbr.s -o mbr.o
	@ld $(LDFLAGS) -T src/linker.lds mbr.o -o mbr.bin

loader:
	@as $(ASFLAGS) src/loader.s -o loader.o
	@ld $(LDFLAGS) -T src/loaderlinker.lds  loader.o -o loader.bin

app:
	@$(CC) $(CFLAGS)  prog_no_arg.o	 src/prog_no_arg.c
	@ld $(LDFLAGS)  string.o syscall.o stdio.o assert.o prog_no_arg.o -e main -o prog_no_arg

all:
	@bximage -mode="create" -hd=60M -imgmode="flat" -sectsize=512 -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc
	@dd if=kernel.bin of=hd60M.img seek=9 bs=512 count=200 conv=notrunc
	@dd if=prog_no_arg of=hd60M.img bs=512 count=10 seek=300 conv=notrunc	

clean:
	@$(RM) -rf prog_no_arg *.imap *.o *.bin hd60M.img *.ini *.txt *.lock kernel/*.bin kernel/*.o

test:
	make clean && make && make mbr && make loader && make app && make all && bochs

min:
	make && make mbr && make loader && make app && make all && bochs

disk:
	@bximage -mode="create" -hd=80M -imgmode="flat" -sectsize=512 -q hd.img	

