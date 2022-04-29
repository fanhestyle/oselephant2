TI_GDT = 0
RPL0 = 0
SELECTOR_VIDEO = (0x0003<<3) + TI_GDT + RPL0

.section .data
put_int_buffer:
    .quad 0x0

.code32
.section .text

.globl put_str
put_str:
    pushl %ebx
    pushl %ecx
    xorl %ecx, %ecx
    movl 12(%esp), %ebx

put_str.goon:
    movb (%ebx), %cl
    cmpb $0, %cl
    jz put_str.str_over
    pushl %ecx
    call put_char
    addl $4, %esp
    incl %ebx
    jmp put_str.goon
put_str.str_over:
    popl %ecx
    popl %ebx
    ret


.globl put_char
put_char:
    pushal
    movw $SELECTOR_VIDEO, %ax
    movw %ax, %gs


//获取当前光标位置

//首先使用端口号选择某个寄存器组
movw $0x03d4, %dx
movb $0x0e, %al
outb %al, %dx

//接着选择寄存器的索引号
movw $0x03d5, %dx
inb %dx, %al
movb %al, %ah

//同样的方式获取低8位光标位置
movw $0x03d4, %dx
movb $0x0f, %al
outb %al, %dx
movw $0x03d5, %dx
inb %dx, %al


movw %ax, %bx

movl 36(%esp), %ecx

cmpb $0xd, %cl
jz put_char.is_carriage_return

cmpb $0xa, %cl
jz put_char.is_line_feed

cmpb $0x8, %cl
jz put_char.is_backspace
jmp put_char.put_other


put_char.is_backspace:
    decw %bx
    shlw $1, %bx
    movb $0x20, %gs:(%bx)
    incw %bx
    //字符颜色设置：黑屏白字
    movb $0x07, %gs:(%bx)
    shrw $1, %bx
    jmp put_char.set_cursor


put_char.put_other:
    shlw $1, %bx
    movb %cl, %gs:(%bx)
    incw %bx
    movb $0x07, %gs:(%bx)
    shrw $1, %bx
    incw %bx
    cmpw $2000, %bx
    jl put_char.set_cursor


put_char.is_line_feed:
put_char.is_carriage_return:

    xor %dx, %dx
    movw %bx, %ax
    movw $80, %si
    div %si
    subw %dx, %bx

put_char.is_carriage_return_end:
    addw $80, %bx
    cmpw $2000, %bx
    
put_char.is_line_feed_end:
    jl put_char.set_cursor

put_char.roll_screen:
    cld
    movl $960, %ecx
    movl $0xc00b80a0, %esi
    movl $0xc00b8000, %edi
    rep movsd

    movl $3840, %ebx
    movl $80, %ecx

put_char.cls:
    movw $0x0720, %gs:(%ebx)
    addl $2, %ebx
    loop put_char.cls
    movw $1920, %bx


put_char.set_cursor:
    movw $0x03d4, %dx
    movb $0x0e, %al
    outb %al, %dx
    movw $0x03d5, %dx
    movb %bh, %al
    outb %al, %dx
    
    movw $0x03d4, %dx
    movb $0x0f, %al
    outb %al, %dx
    movw $0x03d5, %dx
    movb %bl,%al
    outb %al, %dx
    
put_char.put_char_done:
    popal
    ret


/*
打印整数
将小端字节序的数字变成对应的ascii后，倒置
输入：栈中参数为待打印的数字
输出：在屏幕上打印16进制数字,
并不会打印前缀0x,如打印10进制15时，
只会直接打印f，不会是0xf
*/

.globl put_int

put_int:
    pushal
    movl %esp, %ebp
    movl 36(%ebp), %eax
    movl %eax, %edx
    movl $7, %edi
    movl $8, %ecx
    movl $put_int_buffer, %ebx

put_int.16based_4bits:	
    andl $0x0000000F, %edx
    cmpl $9, %edx
    jg put_int.is_A2F
    add $'0', %edx
    jmp put_int.store

put_int.is_A2F:
    subl $10, %edx
    addl $'A', %edx

put_int.store:
    movb %dl, (%ebx,%edi)
    decl %edi
    shr $4, %eax
    movl %eax, %edx
    loop put_int.16based_4bits

put_int.ready_to_print:
    incl %edi

put_int.skip_prefix_0:
        cmpl $8, %edi
        je put_int.full0
    
put_int.go_on_skip:
    movb put_int_buffer(%edi), %cl
    incl %edi
    cmpb $'0', %cl
    je put_int.skip_prefix_0
    decl %edi
    jmp put_int.put_each_num

put_int.full0:
    movb $'0', %cl

put_int.put_each_num:
    pushl %ecx
    call put_char
    addl $4, %esp
    incl %edi
    movb put_int_buffer(%edi), %cl
    cmpl $8, %edi
    jl put_int.put_each_num
    popal
    ret


.globl set_cursor
set_cursor:
    pushal
    movw 36(%esp), %bx
    movw $0x03d4, %dx
    movb $0x0e, %al
    outb %al, %dx
    movw $0x03d5, %dx
    movb %bh, %al
    outb %al, %dx

    movw $0x03d4, %dx
    movb $0x0f, %al
    outb %al, %dx
    movw $0x03d5, %dx
    movb %bl, %al
    outb %al, %dx
    popal

    ret
