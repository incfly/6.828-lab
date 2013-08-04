// Called from entry.S to get us going.
// entry.S already took care of defining envs, pages, uvpd, and uvpt.

#include <inc/lib.h>

extern void umain(int argc, char **argv);

const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//
	// envs变量在lib/entry.S中已经被设置为指向virtual mem中的ENVS.
	// 即envs数组的起始地址。(pmap.c中如此映射的)
	// sys_getenvid()获取envid。而envid中的后10位刚好是该Env在
	// envs数组中的index. 用ENVS()宏即可获得index.
	thisenv = (struct Env *)envs + ENVX(sys_getenvid());

	// save the name of the program so that panic() can use it
	if (argc > 0)
		binaryname = argv[0];

	// call user main routine
	umain(argc, argv);

	// exit gracefully
	exit();
}

