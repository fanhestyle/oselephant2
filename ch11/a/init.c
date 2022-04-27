#include "init.h"

#include "interrupt.h"
#include "memory.h"
#include "print.h"
#include "timer.h"
#include "thread.h"
#include "console.h"
#include "keyboard.h"
#include "tss.h"

void init_all() {
  put_str("init_all\n");
  idt_init();     // 初始化中断
  mem_init();     // 初始化内存管理系统
  thread_init();  // 初始化线程相关结构
  timer_init();   // 初始化PIT
  console_init();
  keyboard_init();
  tss_init();
}