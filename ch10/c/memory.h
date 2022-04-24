#pragma once


#include "bitmap.h"
#include "stdint.h"

#define PG_SIZE 4096

/***************  位图地址 ********************
 * 因为0xc009f000是内核主线程栈顶，0xc009e000是内核主线程的pcb.
 * 一个页框大小的位图可表示128M内存, 位图位置安排在地址0xc009a000,
 * 这样本系统最大支持4个页框的位图,即512M */
#define MEM_BITMAP_BASE 0xc009a000

/* 0xc0000000是内核从虚拟地址3G起. 0x100000意指跨过低端1M内存,
使虚拟地址在逻辑上连续 */
#define K_HEAP_START 0xc0100000

#define PDE_IDX(addr) ((addr & 0xffc00000) >> 22)
#define PTE_IDX(addr) ((addr & 0x003ff000) >> 12)

enum pool_flags {
  PF_KERNEL = 1,  // 内核内存池
  PF_USER = 2     // 用户内存池
};

#define	 PG_P_1	  1	// 页表项或页目录项存在属性位
#define	 PG_P_0	  0	// 页表项或页目录项存在属性位
#define	 PG_RW_R  0	// R/W 属性位值, 读/执行
#define	 PG_RW_W  2	// R/W 属性位值, 读/写/执行
#define	 PG_US_S  0	// U/S 属性位值, 系统级
#define	 PG_US_U  4	// U/S 属性位值, 用户级

/* 内存池结构,生成两个实例用于管理内核内存池和用户内存池 */
struct pool {
  struct bitmap pool_bitmap;  // 本内存池用到的位图结构,用于管理物理内存
  uint32_t phy_addr_start;  // 本内存池所管理物理内存的起始地址
  uint32_t pool_size;       // 本内存池字节容量
};

struct virtual_addr {
  struct bitmap vaddr_bitmap;
  uint32_t vaddr_start;
};

struct pool kernel_pool, user_pool;  // 生成内核内存池和用户内存池
struct virtual_addr kernel_vaddr;  // 此结构是用来给内核分配虚拟地址

void mem_init(void);

void* get_kernel_pages(uint32_t pg_cnt);
void* malloc_page(enum pool_flags pf, uint32_t pg_cnt);
void malloc_init(void);
uint32_t* pte_ptr(uint32_t vaddr);
uint32_t* pde_ptr(uint32_t vaddr);
