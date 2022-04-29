.code32

//统一处理中断压入错误代码和不压入错误代码的情况
.macro ERROR_CODE
    nop
.endm

.macro ZERO
    push $0
.endm

//引入C语言中定义的中断相应数组(其实GNU as可以不写这一行)
.extern idt_table

.section .data
.globl intr_entry_table
intr_entry_table:

//定义宏
.macro VECTOR idx, err_code
.section .text
intr\idx\()entry:
    \err_code

    //准备调用C语言编写的相应函数
    push %ds
    push %es
    push %fs
    push %gs
    pushal

    //如果是从片上进入的中断,除了往从片上发送EOI外,还要往主片上发送EOI 
    movb $0x20, %al
    outb %al, $0xa0
    outb %al, $0x20

    push $\idx
    //间接绝对近转移
    calll *idt_table + \idx * 4
    jmp intr_exit
    
.section .data
    .long intr\idx\()entry
.endm

.section .text
.globl intr_exit
intr_exit:
    addl $4, %esp
    popal
    pop %gs
    pop %fs
    pop %es
    pop %ds
    addl $4, %esp
    iretl


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
VECTOR 0x21,ZERO	
VECTOR 0x22,ZERO	
VECTOR 0x23,ZERO
VECTOR 0x24,ZERO	
VECTOR 0x25,ZERO	
VECTOR 0x26,ZERO
VECTOR 0x27,ZERO	
VECTOR 0x28,ZERO
VECTOR 0x29,ZERO
VECTOR 0x2a,ZERO
VECTOR 0x2b,ZERO
VECTOR 0x2c,ZERO
VECTOR 0x2d,ZERO
VECTOR 0x2e,ZERO
VECTOR 0x2f,ZERO


/*
0x80号中断
*/

.code32
.extern syscall_table

.section .text
.globl syscall_handler
syscall_handler:
    pushl $0

    pushl %ds
    pushl %es
    pushl %fs
    pushl %gs
    pushal

    pushl $0x80

    pushl %edx
    pushl %ecx
    pushl %ebx

    call syscall_table(,%eax,4)
    addl $12, %esp

    movl %eax, 32(%esp)
    jmp intr_exit

