/* Simple linker script for the JOS kernel.
   See the GNU ld 'info' manual ("info ld") to learn the syntax. */

OUTPUT_FORMAT("elf32-i386", "elf32-i386", "elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

SECTIONS
{
	/* Link the kernel at this address: "." means the current address */
	. = 0xF0100000;

	/* AT(...) gives the load address of this section, which tells
	   the boot loader where to load the kernel in physical memory */
	.text : AT(0x100000) {
		*(.text .stub .text.* .gnu.linkonce.t.*)
	}

	PROVIDE(etext = .);	/* Define the 'etext' symbol to this value */

	.rodata : {
		*(.rodata .rodata.* .gnu.linkonce.r.*)
	}

	/* Include debugging information in kernel memory */
	.stab : {
		/*bluesea
		 *.stab是一种存储调试信息的格式，放在ELF文件中。
		  把所有文件的调试信息的值都放在这儿(这应该和编译参数选取也有关)，
		  然后二分查找，读取，即可获得相应eip对应的函数名，文件名，行号
		  
		  用如下命令，生成init.s中，查找i386_init，可以看到相应的.stab信息。
	      gcc -pipe -nostdinc -O2 -fno-builtin -I. -MD -Wall -Wno-format -DJOS_KERNEL -gstabs -c -S kern/init.c
	      然后用 objdump -G obj/kern/kernel | less 察看， 查找i386_init，即可看到，在init.s中生成的.stab信息放到了.stab section
	      中对应的位置，该.stab的类型(FUN), 对应的起始地址, etc.
	      仔细察对比objdump G的输出和kern/kernel.asm i386_init函数部分以及init.c， 可以发现，的确是按照指令出现的位置顺序排列.stab的
	          
		 *
		 *PROVIDE在ld script中的作用是定义一个变量到.text中去，
		 * . 表示此处的地址
		 *所以PROVIDE(__STAB_BEGIN__) = .
		 *的效果就是定义__STAB_BEGIN的值为当前的地址的值。即*(.stab)的值。
		 *而kern/kdebug.c中用extern const Stabs __STAB_BEGIN[],
		 *即可访问到这个.stab调试信息的值。*/
		PROVIDE(__STAB_BEGIN__ = .);
		*(.stab);
		PROVIDE(__STAB_END__ = .);
		BYTE(0)		/* Force the linker to allocate space
				   for this section */
	}

	.stabstr : {
		PROVIDE(__STABSTR_BEGIN__ = .);
		*(.stabstr);
		PROVIDE(__STABSTR_END__ = .);
		BYTE(0)		/* Force the linker to allocate space
				   for this section */
	}

	/* Adjust the address for the data segment to the next page */
	. = ALIGN(0x1000);

	/* The data segment */
	.data : {
		*(.data)
	}

	PROVIDE(edata = .);

	.bss : {
		*(.bss)
	}

	PROVIDE(end = .);

	/DISCARD/ : {
		*(.eh_frame .note.GNU-stack)
	}
}
