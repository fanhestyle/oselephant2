//bootloader加载的起始内存地址
LOADER_BASE_ADDR = 0x900

//bootloader在硬盘中的LBS扇区号
LOADER_START_SECTOR = 0x2

/*
描述符字段
高32位

31--24          基址31-24位
23 G            G位(段界限按4k/1B计算)
22 D/B          操作数大小（IP和SP是16位取址0还是32位取址1）        
21 L            64位/32位处理器
20 AVL          Avaliable保留给应用程序
19--16             段界限19-16位
15  P               存在段，可以置换到硬盘
14--13 DPL          描述符特权级(0-4)
12 S                S位（标记是系统段0/非系统段1）
11--8 TYPE          段的属性描述
7--0                段基址23~16位

低32位
31---16             段基址 15~0位
15---0              段界限 15~0位
*/

//GDT描述符属性

//G位
DESC_G_4K = (1 << 23)
DESC_G_Byte = (0 << 23)

//D/B位
DESC_D_32 = (1 << 22)

//L位(标识32位还是64位CPU)
DESC_L = (0<<21)

//AVL位
DESC_AVL = (0 << 20)

//段界限16-19位
DESC_LIMIT_CODE2 = (1<<16) & (1<<17) & (1<<18) & (1<<19) 
DESC_LIMIT_DATA2 = DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 = (0<<16) & (0<<17) & (0<<18) & (0<<19)  

//P位
DESC_P = (1<<15)

//DPL位
DESC_DPL_0 = (0<<13)&(0<<14)
DESC_DPL_1 = (1<<13)&(0<<14)
DESC_DPL_2 = (0<<13)&(1<<14)
DESC_DPL_3 = (1<<13)&(1<<14)

//S位
DESC_S_CODE = (1<<12)
DESC_S_DATA = DESC_S_CODE
DESC_S_SYS = (0<<12)

//type位
//代码段可执行，非一致性，不可读(访问位清0)
DESC_TYPE_CODE = 0x800

// 数据段,向上扩展，可写(访问位清0)
DESC_TYPE_DATA = 0x200


DESC_CODE_HIGH4 = (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4 = (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 = (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

//选择子属性

RPL0=0x0
RPL1=0x1
RPL2=0x2
RPL3=0x3

TI_GDT=0x0
TI_LDT=0x4
