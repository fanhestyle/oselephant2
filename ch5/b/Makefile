.PHONY:run,clean,boot

boot:
	@as --32 mbr.s -o mbr.o
	@ld -T mbr.lds -m elf_i386 mbr.o -o mbr.bin
	@as --32 loader.s -o loader.o
	@ld -T loader.lds -m elf_i386 loader.o -o loader.bin

run:
	make clean && make && make disk && bochs

disk:
	@bximage -mode="create" -hd=60M -imgmode="flat" -q hd60M.img
	@dd if=mbr.bin of=hd60M.img conv=notrunc
	@dd if=loader.bin of=hd60M.img seek=2 bs=512 conv=notrunc

clean:
	@$(RM) -r *.txt *.o *.bin hd60M.img
