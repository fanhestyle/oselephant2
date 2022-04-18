mbr.bin: mbr.o
	@ld -T mbr.lds -m elf_i386 mbr.o -o mbr.bin

mbr.o: mbr.s
	@as --32 mbr.s -o mbr.o

.PHONY:run,clean

run:
	make clean && make && make disk && bochs

disk:
	@bximage -mode="create" -hd=60M -imgmode="flat" -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc

clean:
	@$(RM) -r *.txt *.o *.bin hd60M.img mbr.bin: mbr.o
	