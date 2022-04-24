#pragma once

#include "stdint.h"
#include "list.h"

typedef void thread_func(void*);

#define THREAD_MAGIC_NUM 0x19870916

enum task_status
{
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_WAITING,
    TASK_HANGING,
    TASK_DIED 
};


/*
    保存中断信息的区域
    备注：在《操作系统真相还原》一书中说此处是栈，并且
    在后续中引用大量的栈类型，初次阅读的时候被整的一头雾水
    此处的目的是保存中断时候的信息，充其量来说只是一块保存
    中断信息的区域，说是栈有点牵强
*/

//这块内存区域在PCB的最高地址处
struct intr_stack
{
    uint32_t vec_no;   //低地址，表示后入栈的元素

    uint32_t edi;
    uint32_t esi;
    uint32_t ebp;
    uint32_t esp_dummy;	 // 虽然pushad把esp也压入,但esp是不断变化的,所以会被popad忽略
    uint32_t ebx;
    uint32_t edx;
    uint32_t ecx;
    uint32_t eax;
    uint32_t gs;
    uint32_t fs;
    uint32_t es;
    uint32_t ds;

    uint32_t err_code;
    void (*eip)(void);
    uint32_t cs;
    uint32_t eflags;
    void *esp;
    uint32_t ss;
};


/*
这个结构又被称为栈，这就很凌乱，起始它是用来标识
线程上下文的结构体而已
*/

struct thread_stack
{
    //以下寄存器是由于ABI的约定，被调方必须备份
    //因为主调方可能使用了这些寄存器
    //主要包括寄存器：%ebx、%esi和%edi，以及%ebp和%esp
    uint32_t ebp;
    uint32_t ebx;
    uint32_t edi;
    uint32_t esi;

    void (*eip)(thread_func *func, void *func_arg);


    void (*unused_retaddr);
    thread_func* function;
    void *func_arg;
};


/*
真正记录进程属性的结构体变量
*/
struct task_struct
{
    uint32_t *self_kstack;
    enum task_status status;
    char name[16];
    uint8_t priority;

   uint8_t  ticks; 
   uint32_t elapsed_ticks;

   struct list_elem general_tag;
   struct list_elem all_list_tag;

   uint32_t* pgdir;

    uint32_t stack_magic;  //魔数
};


void thread_create(
struct task_struct* pthread, thread_func function, void* func_arg
);

void init_thread(
struct task_struct* pthread, char* name, int prio
);

struct task_struct* thread_start(
char* name, int prio, thread_func function, void* func_arg
);

struct task_struct* running_thread(void);

void schedule(void);
void thread_init(void);

void thread_block(enum task_status stat);
void thread_unblock(struct task_struct * pThread);

