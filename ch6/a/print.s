TI_GDT = 0
RPL0 = 0
SELECTOR_VIDEO = (0x0003<<3) + TI_GDT + RPL0

.code32
.section .text

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

//获取栈中的参数，因为栈中压入了8个寄存器32+4
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
    movl $0xb80a0, %esi
    movl $0xb8000, %edi
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
