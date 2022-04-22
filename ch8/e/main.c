#include "init.h"
#include "print.h"
#include "debug.h"
#include "memory.h"
#include "string.h"

void main(void) {
   put_str("I am kernel\n");
   init_all();

   void* addr = get_kernel_pages(3);
   put_str("\n get_kernel_page start vaddr is ");
   put_int((uint32_t)addr);
   put_str("\n");
   void* addr2 = get_kernel_pages(2);
   put_str("\n get_kernel_page start vaddr2 is ");
   put_int((uint32_t)addr2);
   put_str("\n");
   while(1);
   return 0;
}
