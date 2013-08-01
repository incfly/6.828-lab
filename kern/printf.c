// Simple implementation of cprintf console output for the kernel,
// based on printfmt() and the kernel console's cputchar().

#include <inc/types.h>
#include <inc/stdio.h>
#include <inc/stdarg.h>


//bluesea
/*
 * printf系列函数实现的综述：
 *
 * 涉及实现的文件有: kern/printf.c, lib/printfmt.c, kern/console.c
 *
 * va_list, va_start, va_end之类的函数在xv6中用__builtin_va_list类似宏define的
 * 其作用还是一样，在stack上往回走，根据C calling convention, 依次获取各个参数的值
 *
 * cprintf, vcprintf只是简单封装，实现printf。
 * 真正处理printf的format string(第一个参数)的是, lib/printfmt.c中的vprintfmt
 * 完成对各个不同的转义符号，数字，字符串等的处理，并且用vcprintf传递过去的putch函数
 * 打印.即边处理，边答应。
 *
 * vprintfmt的第一个参数putch的作用是，打印一个字符。可以是真的io上的打印也可以时fprintf.
 * 
 * 该文件中(printf.c）的putch的cnt参数是记录打印字符的个数(printf的返回值）
 *
 * console.c利用outb, inb等底层IO细节，实现了提供cputchar(ch): 往parallel IO, serial IO, VGA上打印字符。
 * */
static void
putch(int ch, int *cnt)
{
	cputchar(ch);
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
	int cnt = 0;

	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
	va_end(ap);

	return cnt;
}

