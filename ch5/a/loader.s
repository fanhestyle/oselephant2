.code16

.include "boot.inc"

.section .text
LOADER_STACK_TOP = LOADER_BASE_ADDR

GDT_BASE:  
    .long 0x0
    .long 0x0

CODE_DESC:
    .long 0x0000FFFF
    .long DESC_CODE_HIGH4

DATA_STACK_DESC:
    .long 0x0000FFFF
    .long DESC_DATA_HIGH4

//显存段的段基址是0xb8000
//显存段的段界限是 0xbffff-0xb8000 = 0x7fff 粒度是4k
//所以计算出的低位数字是 0x7fff/4k = 7
VIDEO_DESC:
    .long 0x80000007
    .long DESC_VIDEO_HIGH4

GDT_SIZE = .-GDT_BASE
GDT_LIMIT = GDT_SIZE - 1

.fill 60, 8, 0

//定义3个选择子
//相当于(CODE_DESC - GDT_BASE)/8 + TI_GDT + RPL0
.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO, (0x0003 << 3) + TI_GDT + RPL0

/*
total_mem_bytes的偏移地址是512字节
32（4个段描述符）+ (60*8)480的预留空间一共是512字节
= 0x200,由于loader会被加载到内存的0x900处，因此
记录内存大小的total_mem_bytes字段所在的位置是0x900+0x200
= 0xb00
*/
total_mem_bytes:
    .long 0

gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE

//用来存储 0x15号中断获取的内存地址信息（0x15中的E820号中断得到的结果是一个大的结构体）
//因此预留一定空间来存储（为什么留244？完全是强迫症为了凑整，让loader_start地址从一个整16倍数地址开始）
ards_buf:
    .fill 244

ards_nr:
    .word 0

loader_start:
   xorl %ebx, %ebx
   movl $0x534d4150, %edx
   movw $ards_buf, %di

//调用中断0x15中e820号中断获取内存
e820_mem_get_loop:
    movl $0x0000e820, %eax
    movl $20, %ecx
    int $0x15
    jc e820_failed_so_try_e801

    addw %cx, %di
    incw ards_nr

    cmpl $0, %ebx
    jnz e820_mem_get_loop

    movw ards_nr, %cx
    movl $ards_buf, %ebx
    xorl %edx,%edx

find_max_mem_area:
    movl (%ebx), %eax
    addl 8(%ebx), %eax
    addl $20, %ebx
    cmpl %eax, %edx
    jge next_ards
    movl %eax, %edx
next_ards:
    loop find_max_mem_area
    jmp mem_get_ok

e820_failed_so_try_e801:
    movw $0xe801, %ax
    int $0x15
    jc e801_failed_so_try88

    movw $0x400, %cx
    mulw %cx
    shll $16, %edx
    andl $0x0000FFFF, %eax
    orl %eax, %edx
    addl $0x100000, %edx
    movl %edx, %esi

    xorl %eax, %eax
    movw %bx, %ax
    movl $0x10000, %ecx
    mull %ecx
    addl %eax, %esi
    movl %esi, %edx
    jmp mem_get_ok

e801_failed_so_try88:
    movb $0x88, %ah
    int $0x15
    jc err_hlt
    andl $0x0000FFFF, %eax

    movw $0x400, %cx
    mulw %cx
    shll $16, %edx
    orl %eax, %edx
    addl $0x100000, %edx

mem_get_ok:
    movl %edx, total_mem_bytes


//开启A20地址线

inb $0x92, %al
orb $0x2, %al
outb %al, $0x92

//加载GDT
lgdt gdt_ptr

//开启保护模式标记
movl %cr0, %eax
orl $0x1, %eax
movl %eax, %cr0

ljmp $SELECTOR_CODE, $p_mode_start

err_hlt:
    hlt

.code32

p_mode_start:
    movw $SELECTOR_DATA, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %ss
    movl $LOADER_STACK_TOP, %esp
    movw $SELECTOR_VIDEO, %ax
    movw %ax, %gs

    movb $'P', %gs:160

jmp .
