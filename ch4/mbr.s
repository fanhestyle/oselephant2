.code16

.include "boot.inc"

movw %cs, %ax
movw %ax, %ds
movw %ax, %es
movw %ax, %ss
movw %ax, %fs
movw $0x7c00, %sp
movw $0xb800, %ax
movw %ax, %gs

//清屏
movw $0x600, %ax
movw $0x700, %bx
movw $0, %cx
movw $0x184f, %dx
int $0x10

movb $'1', %gs:0x0
movb $0xA4, %gs:0x1
movb $' ', %gs:0x2
movb $0xA4, %gs:0x3
movb $'M', %gs:0x4
movb $0xA4, %gs:0x5
movb $'B', %gs:0x6
movb $0xA4, %gs:0x7
movb $'R', %gs:0x8
movb $0xA4, %gs:0x9


//开始读磁盘，把bootloader加载到内存中 LOADER_BASE_ADDR=0x900处
//eax:硬盘扇区号
//bx: 拷贝到的内存地址
//cx: 拷贝多少个扇区

movl $LOADER_START_SECTOR, %eax
movw $LOADER_BASE_ADDR, %bx
movw $0x4, %cx 

call rd_disk_m_16

jmp  LOADER_BASE_ADDR


//功能：读取硬盘的n个扇区
//eax=LBA扇区号
//bx=待写入的内存起始地址
//cx=读入的扇区数

rd_disk_m_16:
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

    movb $8, %cl
    shr %cl, %eax
    movw $0x1f4, %dx
    outb %al, %dx


//8-15位写入0x1f4端口

    movb $8, %cl
    shr %cl, %eax
    movw $0x1f4, %dx
    out %al, %dx



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
    cmp $0x8, %al
    jnz not_ready

    movw %di, %ax
    movw $256, %dx
    mul %dx
    movw %ax, %cx

    movw $0x1f0, %dx

go_on_read:
    in %dx, %ax
    movw %ax, (%bx)
    addw $2, %bx
    loop go_on_read

    ret

.org 510
.word 0xaa55
