.PHONY:run,clean

run:
	make clean && make disk && bochs

disk:
	@bximage -mode="create" -hd=60M -imgmode="flat" -q hd60M.img

clean:
	@$(RM) -r *.txt *.o *.bin hd60M.img