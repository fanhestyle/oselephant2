#include "init.h"
#include "print.h"
#include "debug.h"

void main(void) {
  put_str("I am kernel\n");
  init_all();
  ASSERT(1==2);
  while (1);
}
