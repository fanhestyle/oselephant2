
int main(void) {
  asm("\
       movw $0x18, %ax; \
        movw %ax, %gs; \
        movb $'A', %gs:320; \
    ");
  while (1)
    ;
  return 0;
}
