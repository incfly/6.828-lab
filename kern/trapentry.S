/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */

/*把TRAPHANDLER和TRAPHANDLER_NOEC两个宏改了一下，自动填写hanlder数组
  实现方式:在.text和.data之间切换即可. 注意.text后面要有';'*/
#define TRAPHANDLER(name, num)						\
	.text;		\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps;		\
	.data;		\
	.long name;				\

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.text;			\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps;						\
	.data;								\
	.long handler##num			\


/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

/*cpu不产生error code的interrupt handler; 9, 15 is reserved*/

.data
.globl handlers
handlers:
TRAPHANDLER_NOEC(handler0, 0)
TRAPHANDLER_NOEC(handler1, 1)
TRAPHANDLER_NOEC(handler2, 2)
TRAPHANDLER_NOEC(handler3, 3)
TRAPHANDLER_NOEC(handler4, 4)
TRAPHANDLER_NOEC(handler5, 5)
TRAPHANDLER_NOEC(handler6, 6)
TRAPHANDLER_NOEC(handler7, 7)
TRAPHANDLER(handler8, 8)
TRAPHANDLER(handler9, 9)
TRAPHANDLER(handler10, 10)
TRAPHANDLER(handler11, 11)
TRAPHANDLER(handler12, 12)
TRAPHANDLER(handler13, 13)
TRAPHANDLER(handler14, 14)
TRAPHANDLER(handler15, 15)
TRAPHANDLER_NOEC(handler16, 16)


TRAPHANDLER_NOEC(handler17, 17)
TRAPHANDLER_NOEC(handler18, 18)
TRAPHANDLER_NOEC(handler19, 19)
TRAPHANDLER_NOEC(handler20, 20)
TRAPHANDLER_NOEC(handler21, 21)
TRAPHANDLER_NOEC(handler22, 22)
TRAPHANDLER_NOEC(handler23, 23)
TRAPHANDLER_NOEC(handler24, 24)
TRAPHANDLER_NOEC(handler25, 25)
TRAPHANDLER_NOEC(handler26, 26)
TRAPHANDLER_NOEC(handler27, 27)
TRAPHANDLER_NOEC(handler28, 28)
TRAPHANDLER_NOEC(handler29, 29)
TRAPHANDLER_NOEC(handler30, 30)
TRAPHANDLER_NOEC(handler31, 31)
TRAPHANDLER_NOEC(handler32, 32)
TRAPHANDLER_NOEC(handler33, 33)
TRAPHANDLER_NOEC(handler34, 34)
TRAPHANDLER_NOEC(handler35, 35)
TRAPHANDLER_NOEC(handler36, 36)
TRAPHANDLER_NOEC(handler37, 37)
TRAPHANDLER_NOEC(handler38, 38)
TRAPHANDLER_NOEC(handler39, 39)
TRAPHANDLER_NOEC(handler40, 40)
TRAPHANDLER_NOEC(handler41, 41)
TRAPHANDLER_NOEC(handler42, 42)
TRAPHANDLER_NOEC(handler43, 43)
TRAPHANDLER_NOEC(handler44, 44)
TRAPHANDLER_NOEC(handler45, 45)
TRAPHANDLER_NOEC(handler46, 46)
TRAPHANDLER_NOEC(handler47, 47)
TRAPHANDLER_NOEC(handler48, 48)


/*
 * Lab 3: Your code here for _alltraps
 */

.text
_alltraps:
pushl %ds
pushl %es
/*不需要pushl fs, gs! 和xv6里的trapframe构造不一样！
 *----------------太坑了!!!!----------------------*/
pushal

/*GD_KD需要加$, 汇编里的立即数需要加$, 栽在这儿了*/
movl $GD_KD, %eax
movw %ax, %es
movw %ax, %ds

/*function trap(struct trapframe *)接受一个trapframe指针作为参数。
  而%esp当前的值刚好就是需要的trapframe的地址 */
pushl %esp
/*无需返回，trap()中最后调用env_run(), env_run()最后会用env_pop_tf()
  将trapframe弹出，恢复寄存器 */
call trap

