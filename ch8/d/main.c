#include "init.h"
#include "print.h"
#include "debug.h"

void main(void) {
  put_str("I am kernel\n");
  init_all();
  while (1);
}
