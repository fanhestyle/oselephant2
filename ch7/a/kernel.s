.code32

.macro ERROR_CODE
    nop
.endm

.macro ZERO
    push 0
.endm

.extern put_str

.section .data
intr_str:
    .asciz "interrupt occur!\n"

.globl intr_entry_table
intr_entry_table:

.macro VECTOR idx, err_code
.section .text
intr\idx\()entry:
    \err_code
    push $intr_str
    call put_str
    addl $4, %esp

    //如果是从片上进入的中断,除了往从片上发送EOI外,还要往主片上发送EOI 
    movb $0x20, %al
    outb %al, $0xa0
    outb %al, $0x20

    addl $4, %esp
    iret
.section .data
    .long intr\idx\()entry
.endm

VECTOR 0x00,ZERO
VECTOR 0x01,ZERO
VECTOR 0x02,ZERO
VECTOR 0x03,ZERO 
VECTOR 0x04,ZERO
VECTOR 0x05,ZERO
VECTOR 0x06,ZERO
VECTOR 0x07,ZERO 
VECTOR 0x08,ERROR_CODE
VECTOR 0x09,ZERO
VECTOR 0x0a,ERROR_CODE
VECTOR 0x0b,ERROR_CODE 
VECTOR 0x0c,ZERO
VECTOR 0x0d,ERROR_CODE
VECTOR 0x0e,ERROR_CODE
VECTOR 0x0f,ZERO 
VECTOR 0x10,ZERO
VECTOR 0x11,ERROR_CODE
VECTOR 0x12,ZERO
VECTOR 0x13,ZERO 
VECTOR 0x14,ZERO
VECTOR 0x15,ZERO
VECTOR 0x16,ZERO
VECTOR 0x17,ZERO 
VECTOR 0x18,ERROR_CODE
VECTOR 0x19,ZERO
VECTOR 0x1a,ERROR_CODE
VECTOR 0x1b,ERROR_CODE 
VECTOR 0x1c,ZERO
VECTOR 0x1d,ERROR_CODE
VECTOR 0x1e,ERROR_CODE
VECTOR 0x1f,ZERO 
VECTOR 0x20,ZERO
