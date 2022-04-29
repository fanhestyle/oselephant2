.code16
.include "boot.inc"

.section .text

//GTD Descriptor

GDT_BASE:  
    .long 0x0
    .long 0x0

CODE_DESC:
    .long 0x0000FFFF
    .long DESC_CODE_HIGH4

DATA_STACK_DESC:
    .long 0x0000FFFF
    .long DESC_DATA_HIGH4

VIDEO_DESC:
    .long 0x80000007	
    .long DESC_VIDEO_HIGH4

.equ GDT_SIZE, .-GDT_BASE
.equ GDT_LIMIT, GDT_SIZE - 1

.fill 60, 8, 0

.equ SELECTOR_CODE, (0x0001 << 3) + TI_GDT + RPL0
.equ SELECTOR_DATA, (0x0002 << 3) + TI_GDT + RPL0
.equ SELECTOR_VIDEO, (0x0003 << 3) + TI_GDT + RPL0

//保存内存容量（字节为单位），它相对于文件头的偏移是0x200 字节
//我们的loader.bin会被加载在内存中的 0x900处，因此这个
//total_mem_bytes加载之后的内存地址是 0x900 + 0x200 = 0xb00

total_mem_bytes:
    .long 0


//gdt加载的内存 低16位是段描述符的界限，高32位是gdt表的初始内存地址
gdt_ptr:
    .word GDT_LIMIT
    .long GDT_BASE

//用来存储 0x15号中断获取的内存地址信息（0x15中的E820号中断得到的结果是一个大的结构体）
//因此预留一定空间来存储（为什么留244？完全是强迫症为了凑整，让loader_start地址从一个整16倍数地址开始）
ards_buf:
    .fill 244

//保存0x15号中断E820号中断返回结构体的个数
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

//ljmpw $SELECTOR_CODE, $p_mode_start
ljmpl $SELECTOR_CODE, $p_mode_start

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

//加载kernel
//备注：kernel首先被加载到0x70000的地址处，之后
//初始化到0x1500的地址处，加载是用的非页地址的方式进行的
//（也可以开启页后加载），初始化是在加载页之后进行的初始化，因此
//虚拟地址是 0xc0001500

movl $KERNEL_START_SECTOR, %eax
movl $KERNEL_BIN_BASE_ADDR, %ebx
//kernel的总大小小于200个扇区，拷贝的时候把多余部分拷贝过去不影响
//我们kernel的功能，只要kernel拷全了就行
movl $200, %ecx

call rd_disk_m_32


call setup_page

//从GDT寄存器把值写回gdt_ptr内存处，为了是修改它并重新加载
sgdt gdt_ptr

movl (gdt_ptr+2), %ebx
orl $0xc0000000, 0x1c(%ebx)
addl $0xc0000000, (gdt_ptr+2)

addl $0xc0000000, %esp

//设置页目录表到cr3寄存器
movl $PAGE_DIR_TABLE_POS, %eax
movl %eax, %cr3

movl %cr0, %eax
orl $0x80000000, %eax
movl %eax, %cr0

lgdt gdt_ptr

ljmpl $SELECTOR_CODE, $enter_kernel

enter_kernel:

    // movb $'k', %gs:320
    // movb $'e', %gs:322

    call kernel_init

    movl $0xc009f000, %esp
    jmp KERNEL_ENTRY_POINT


// 0x70000处的kernel.bin解析到虚拟地址0xc0001500

kernel_init:
    xorl %eax,%eax
    xorl %ebx,%ebx
    xorl %ecx, %ecx
    xorl %edx,%edx

    movw KERNEL_BIN_BASE_ADDR + 42, %dx
    movl KERNEL_BIN_BASE_ADDR + 28, %ebx

    addl $KERNEL_BIN_BASE_ADDR, %ebx
    movw KERNEL_BIN_BASE_ADDR + 44, %cx

    //处理每一个段（因为段才是可以运行的程序或使用的数据）
each_segment:
    cmpb $PT_NULL, (%ebx)
    je PTNULL_LABEL

    pushl 16(%ebx)
    movl 4(%ebx), %eax
    add $KERNEL_BIN_BASE_ADDR, %eax
    pushl %eax
    pushl 8(%ebx)
    call mem_cpy
    addl $12, %esp

PTNULL_LABEL:
    addl %edx, %ebx
    loop each_segment
    ret


//拷贝函数

mem_cpy:
    cld
    pushl %ebp
    movl %esp, %ebp
    pushl %ecx
    movl 8(%ebp), %edi
    movl 12(%ebp), %esi
    movl 16(%ebp), %ecx
    rep movsb

    popl %ecx
    popl %ebp
    ret
    


//创建页目录及页表

setup_page:

//页目录表设置的物理地址是 PAGE_DIR_TABLE_POS
//即 1M内存之后的下一个字节 FFFFF + 1
//清空页目录表

movl $4096, %ecx
movl $0, %esi

clear_page_dir_table:
    movb $0, PAGE_DIR_TABLE_POS(%esi)
    incl %esi
    loop clear_page_dir_table

//创建页目录项(PDE)

//ebx初始化是供后续PTE使用
movl $PAGE_DIR_TABLE_POS, %eax
addl $0x1000, %eax
movl %eax, %ebx

orl $PDE_PTE_FLAG, %eax
movl %eax, (PAGE_DIR_TABLE_POS)
movl %eax, (PAGE_DIR_TABLE_POS+0xc00)

subl $0x1000, %eax

//让目录项的最后一个指向目录表自身
movl %eax, (PAGE_DIR_TABLE_POS+4092)


//创建PTE

    movl $256, %ecx
    movl $0, %esi
    movl $PDE_PTE_FLAG, %edx

create_pte:
    movl %edx, (%ebx,%esi,4)
    addl $4096, %edx
    incl %esi
    loop create_pte

movl $PAGE_DIR_TABLE_POS, %eax
addl $0x2000, %eax
or $PDE_PTE_FLAG, %eax
movl $PAGE_DIR_TABLE_POS, %ebx
movl $254, %ecx
movl $769, %esi

create_kernel_pde:
    movl %eax, (%ebx,%esi,4)
    inc %esi
    addl $0x1000, %eax
    loop create_kernel_pde

    ret

/*
rd_disk_m_32
读取硬盘n个扇区到指定的内存地址
eax = LBA扇区号
ebx = 将数据写入的内存地址
ecx = 读取的扇区数
*/

rd_disk_m_32:
    movl %eax, %esi
    movw %cx, %di

    //端口0x1f2 给出读取的扇区数

    movw $0x1f2, %dx
    movb %cl, %al
    outb %al, %dx

    movl %esi, %eax

//0-7位写入0x1f3端口

    movw $0x1f3, %dx
    outb %al, %dx
    
//8-15位写入0x1f4端口
    movb $8, %cl
    shr %cl, %eax
    movw $0x1f4, %dx
    outb %al, %dx

// 16-23

    shr %cl, %eax
    movw $0x1f5, %dx
    outb %al, %dx


// 24-27

    shr %cl, %eax
    and $0x0f, %al
    or $0xe0, %al
    movw $0x1f6, %dx
    out %al, %dx

    movw $0x1f7, %dx
    movb $0x20, %al
    out %al, %dx

not_ready:
    nop
    in %dx, %al
    and $0x88, %al
    cmpb $0x8, %al
    jnz not_ready

    movw %di, %ax
    movw $256, %dx
    mul %dx
    movw %ax, %cx

    movw $0x1f0, %dx

go_on_read:
    in %dx, %ax
    movw %ax, (%ebx)
    addl $2, %ebx
    loop go_on_read

    ret
