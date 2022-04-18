.code16

.section .text

movw %cs, %ax
movw %ax, %ds
movw %ax, %es
movw %ax, %fs
movw %ax, %gs
movw $0x7c00, %sp

/*
清屏利用0x06号功能,上卷全部行,则可清屏
中断号：INT x10　 功能号:0x06　　
功能描述:上卷窗口
输入: 
AH 功能号= 0x06
AL 上卷行数(如果为0，表示全部)
BH 上卷行属性
(CL,CH) = 窗口左上角的(X,Y)位置
(DL,DH) = 窗口右下角的(X,Y)位置
无返回值:
*/

movw $0x600, %ax
movw $0x700, %bx
movw $0x0, %cx
/*VGA文本模式中,一行只能容纳80个字符,共25行，
下标从0开始,所以0x18=24,0x4f=79,DX=0x184f
左上角(0,0)，右下角(80,25)
*/
movw $0x184f, %dx
int $0x10

//以下3行获取光标位置
movb $0x3, %ah
movb $0x0, %bh
int $0x10

//以下6行打印字符串
movw $message, %ax
movw %ax, %bp
movw $MSG_LEN, %cx
movw $0x1301, %ax
movw $0x2, %bx
int $0x10

jmp .

message:
    .ascii "Hello,World!"
MSG_LEN = . - message

.org 510
.word 0xaa55
