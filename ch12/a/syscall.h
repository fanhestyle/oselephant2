#pragma once

#include "stdint.h"

enum SYSCALL_NR {
   SYS_GETPID
};

uint32_t getpid(void);
