#pragma once

#include "global.h"

#define bool int

#define BITMAP_MASK 1

struct bitmap {
  uint32_t btmp_bytes_len;
  /* 在遍历位图时,整体上以字节为单位,细节上是以位为单位,所以此处位图的指针必须是单字节
   */

  /*bitmap中的bits标识着bitmap的起始内存地址，使用的是虚拟地址*/
  uint8_t* bits;
};

void bitmap_init(struct bitmap* btmp);
bool bitmap_scan_test(struct bitmap* btmp, uint32_t bit_idx);
int bitmap_scan(struct bitmap* btmp, uint32_t cnt);
void bitmap_set(struct bitmap* btmp, uint32_t bit_idx, int8_t value);
