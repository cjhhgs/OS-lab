
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 10 12 f0       	mov    $0xf0121000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 62 00 00 00       	call   f01000a0 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	f3 0f 1e fb          	endbr32 
f0100044:	55                   	push   %ebp
f0100045:	89 e5                	mov    %esp,%ebp
f0100047:	56                   	push   %esi
f0100048:	53                   	push   %ebx
f0100049:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010004c:	83 3d 80 8e 23 f0 00 	cmpl   $0x0,0xf0238e80
f0100053:	74 0f                	je     f0100064 <_panic+0x24>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100055:	83 ec 0c             	sub    $0xc,%esp
f0100058:	6a 00                	push   $0x0
f010005a:	e8 b7 08 00 00       	call   f0100916 <monitor>
f010005f:	83 c4 10             	add    $0x10,%esp
f0100062:	eb f1                	jmp    f0100055 <_panic+0x15>
	panicstr = fmt;
f0100064:	89 35 80 8e 23 f0    	mov    %esi,0xf0238e80
	asm volatile("cli; cld");
f010006a:	fa                   	cli    
f010006b:	fc                   	cld    
	va_start(ap, fmt);
f010006c:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010006f:	e8 fa 60 00 00       	call   f010616e <cpunum>
f0100074:	ff 75 0c             	pushl  0xc(%ebp)
f0100077:	ff 75 08             	pushl  0x8(%ebp)
f010007a:	50                   	push   %eax
f010007b:	68 e0 67 10 f0       	push   $0xf01067e0
f0100080:	e8 2c 38 00 00       	call   f01038b1 <cprintf>
	vcprintf(fmt, ap);
f0100085:	83 c4 08             	add    $0x8,%esp
f0100088:	53                   	push   %ebx
f0100089:	56                   	push   %esi
f010008a:	e8 f8 37 00 00       	call   f0103887 <vcprintf>
	cprintf("\n");
f010008f:	c7 04 24 e0 79 10 f0 	movl   $0xf01079e0,(%esp)
f0100096:	e8 16 38 00 00       	call   f01038b1 <cprintf>
f010009b:	83 c4 10             	add    $0x10,%esp
f010009e:	eb b5                	jmp    f0100055 <_panic+0x15>

f01000a0 <i386_init>:
{
f01000a0:	f3 0f 1e fb          	endbr32 
f01000a4:	55                   	push   %ebp
f01000a5:	89 e5                	mov    %esp,%ebp
f01000a7:	53                   	push   %ebx
f01000a8:	83 ec 04             	sub    $0x4,%esp
	cons_init();
f01000ab:	e8 95 05 00 00       	call   f0100645 <cons_init>
	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b0:	83 ec 08             	sub    $0x8,%esp
f01000b3:	68 ac 1a 00 00       	push   $0x1aac
f01000b8:	68 4c 68 10 f0       	push   $0xf010684c
f01000bd:	e8 ef 37 00 00       	call   f01038b1 <cprintf>
	mem_init();
f01000c2:	e8 00 12 00 00       	call   f01012c7 <mem_init>
	env_init();
f01000c7:	e8 fa 2f 00 00       	call   f01030c6 <env_init>
	trap_init();
f01000cc:	e8 bb 38 00 00       	call   f010398c <trap_init>
	mp_init();	
f01000d1:	e8 99 5d 00 00       	call   f0105e6f <mp_init>
	lapic_init();	
f01000d6:	e8 ad 60 00 00       	call   f0106188 <lapic_init>
	pic_init();
f01000db:	e8 e6 36 00 00       	call   f01037c6 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000e0:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f01000e7:	e8 0a 63 00 00       	call   f01063f6 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000ec:	83 c4 10             	add    $0x10,%esp
f01000ef:	83 3d 88 8e 23 f0 07 	cmpl   $0x7,0xf0238e88
f01000f6:	76 27                	jbe    f010011f <i386_init+0x7f>
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f01000f8:	83 ec 04             	sub    $0x4,%esp
f01000fb:	b8 d2 5d 10 f0       	mov    $0xf0105dd2,%eax
f0100100:	2d 58 5d 10 f0       	sub    $0xf0105d58,%eax
f0100105:	50                   	push   %eax
f0100106:	68 58 5d 10 f0       	push   $0xf0105d58
f010010b:	68 00 70 00 f0       	push   $0xf0007000
f0100110:	e8 86 5a 00 00       	call   f0105b9b <memmove>
	for (c = cpus; c < cpus + ncpu; c++) {
f0100115:	83 c4 10             	add    $0x10,%esp
f0100118:	bb 20 90 23 f0       	mov    $0xf0239020,%ebx
f010011d:	eb 53                	jmp    f0100172 <i386_init+0xd2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010011f:	68 00 70 00 00       	push   $0x7000
f0100124:	68 04 68 10 f0       	push   $0xf0106804
f0100129:	6a 4c                	push   $0x4c
f010012b:	68 67 68 10 f0       	push   $0xf0106867
f0100130:	e8 0b ff ff ff       	call   f0100040 <_panic>
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100135:	89 d8                	mov    %ebx,%eax
f0100137:	2d 20 90 23 f0       	sub    $0xf0239020,%eax
f010013c:	c1 f8 02             	sar    $0x2,%eax
f010013f:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100145:	c1 e0 0f             	shl    $0xf,%eax
f0100148:	8d 80 00 20 24 f0    	lea    -0xfdbe000(%eax),%eax
f010014e:	a3 84 8e 23 f0       	mov    %eax,0xf0238e84
		lapic_startap(c->cpu_id, PADDR(code));
f0100153:	83 ec 08             	sub    $0x8,%esp
f0100156:	68 00 70 00 00       	push   $0x7000
f010015b:	0f b6 03             	movzbl (%ebx),%eax
f010015e:	50                   	push   %eax
f010015f:	e8 7e 61 00 00       	call   f01062e2 <lapic_startap>
		while(c->cpu_status != CPU_STARTED)
f0100164:	83 c4 10             	add    $0x10,%esp
f0100167:	8b 43 04             	mov    0x4(%ebx),%eax
f010016a:	83 f8 01             	cmp    $0x1,%eax
f010016d:	75 f8                	jne    f0100167 <i386_init+0xc7>
	for (c = cpus; c < cpus + ncpu; c++) {
f010016f:	83 c3 74             	add    $0x74,%ebx
f0100172:	6b 05 c4 93 23 f0 74 	imul   $0x74,0xf02393c4,%eax
f0100179:	05 20 90 23 f0       	add    $0xf0239020,%eax
f010017e:	39 c3                	cmp    %eax,%ebx
f0100180:	73 13                	jae    f0100195 <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100182:	e8 e7 5f 00 00       	call   f010616e <cpunum>
f0100187:	6b c0 74             	imul   $0x74,%eax,%eax
f010018a:	05 20 90 23 f0       	add    $0xf0239020,%eax
f010018f:	39 c3                	cmp    %eax,%ebx
f0100191:	74 dc                	je     f010016f <i386_init+0xcf>
f0100193:	eb a0                	jmp    f0100135 <i386_init+0x95>
	ENV_CREATE(TEST, ENV_TYPE_USER);
f0100195:	83 ec 08             	sub    $0x8,%esp
f0100198:	6a 00                	push   $0x0
f010019a:	68 fc db 22 f0       	push   $0xf022dbfc
f010019f:	e8 13 31 00 00       	call   f01032b7 <env_create>
	sched_yield();
f01001a4:	e8 0c 45 00 00       	call   f01046b5 <sched_yield>

f01001a9 <mp_main>:
{
f01001a9:	f3 0f 1e fb          	endbr32 
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	83 ec 08             	sub    $0x8,%esp
	lcr3(PADDR(kern_pgdir));
f01001b3:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f01001b8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001bd:	76 52                	jbe    f0100211 <mp_main+0x68>
	return (physaddr_t)kva - KERNBASE;
f01001bf:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001c4:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001c7:	e8 a2 5f 00 00       	call   f010616e <cpunum>
f01001cc:	83 ec 08             	sub    $0x8,%esp
f01001cf:	50                   	push   %eax
f01001d0:	68 73 68 10 f0       	push   $0xf0106873
f01001d5:	e8 d7 36 00 00       	call   f01038b1 <cprintf>
	lapic_init();
f01001da:	e8 a9 5f 00 00       	call   f0106188 <lapic_init>
	env_init_percpu();
f01001df:	e8 b2 2e 00 00       	call   f0103096 <env_init_percpu>
	trap_init_percpu();
f01001e4:	e8 e0 36 00 00       	call   f01038c9 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f01001e9:	e8 80 5f 00 00       	call   f010616e <cpunum>
f01001ee:	6b d0 74             	imul   $0x74,%eax,%edx
f01001f1:	83 c2 04             	add    $0x4,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f01001f4:	b8 01 00 00 00       	mov    $0x1,%eax
f01001f9:	f0 87 82 20 90 23 f0 	lock xchg %eax,-0xfdc6fe0(%edx)
f0100200:	c7 04 24 c0 33 12 f0 	movl   $0xf01233c0,(%esp)
f0100207:	e8 ea 61 00 00       	call   f01063f6 <spin_lock>
	sched_yield();
f010020c:	e8 a4 44 00 00       	call   f01046b5 <sched_yield>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100211:	50                   	push   %eax
f0100212:	68 28 68 10 f0       	push   $0xf0106828
f0100217:	6a 63                	push   $0x63
f0100219:	68 67 68 10 f0       	push   $0xf0106867
f010021e:	e8 1d fe ff ff       	call   f0100040 <_panic>

f0100223 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100223:	f3 0f 1e fb          	endbr32 
f0100227:	55                   	push   %ebp
f0100228:	89 e5                	mov    %esp,%ebp
f010022a:	53                   	push   %ebx
f010022b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010022e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100231:	ff 75 0c             	pushl  0xc(%ebp)
f0100234:	ff 75 08             	pushl  0x8(%ebp)
f0100237:	68 89 68 10 f0       	push   $0xf0106889
f010023c:	e8 70 36 00 00       	call   f01038b1 <cprintf>
	vcprintf(fmt, ap);
f0100241:	83 c4 08             	add    $0x8,%esp
f0100244:	53                   	push   %ebx
f0100245:	ff 75 10             	pushl  0x10(%ebp)
f0100248:	e8 3a 36 00 00       	call   f0103887 <vcprintf>
	cprintf("\n");
f010024d:	c7 04 24 e0 79 10 f0 	movl   $0xf01079e0,(%esp)
f0100254:	e8 58 36 00 00       	call   f01038b1 <cprintf>
	va_end(ap);
}
f0100259:	83 c4 10             	add    $0x10,%esp
f010025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010025f:	c9                   	leave  
f0100260:	c3                   	ret    

f0100261 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100261:	f3 0f 1e fb          	endbr32 
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100265:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026a:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026b:	a8 01                	test   $0x1,%al
f010026d:	74 0a                	je     f0100279 <serial_proc_data+0x18>
f010026f:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100274:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100275:	0f b6 c0             	movzbl %al,%eax
f0100278:	c3                   	ret    
		return -1;
f0100279:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f010027e:	c3                   	ret    

f010027f <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010027f:	55                   	push   %ebp
f0100280:	89 e5                	mov    %esp,%ebp
f0100282:	53                   	push   %ebx
f0100283:	83 ec 04             	sub    $0x4,%esp
f0100286:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100288:	ff d3                	call   *%ebx
f010028a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010028d:	74 29                	je     f01002b8 <cons_intr+0x39>
		if (c == 0)
f010028f:	85 c0                	test   %eax,%eax
f0100291:	74 f5                	je     f0100288 <cons_intr+0x9>
			continue;
		cons.buf[cons.wpos++] = c;
f0100293:	8b 0d 24 82 23 f0    	mov    0xf0238224,%ecx
f0100299:	8d 51 01             	lea    0x1(%ecx),%edx
f010029c:	88 81 20 80 23 f0    	mov    %al,-0xfdc7fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.wpos = 0;
f01002a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01002ad:	0f 44 d0             	cmove  %eax,%edx
f01002b0:	89 15 24 82 23 f0    	mov    %edx,0xf0238224
f01002b6:	eb d0                	jmp    f0100288 <cons_intr+0x9>
	}
}
f01002b8:	83 c4 04             	add    $0x4,%esp
f01002bb:	5b                   	pop    %ebx
f01002bc:	5d                   	pop    %ebp
f01002bd:	c3                   	ret    

f01002be <kbd_proc_data>:
{
f01002be:	f3 0f 1e fb          	endbr32 
f01002c2:	55                   	push   %ebp
f01002c3:	89 e5                	mov    %esp,%ebp
f01002c5:	53                   	push   %ebx
f01002c6:	83 ec 04             	sub    $0x4,%esp
f01002c9:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ce:	ec                   	in     (%dx),%al
	if ((stat & KBS_DIB) == 0)
f01002cf:	a8 01                	test   $0x1,%al
f01002d1:	0f 84 f2 00 00 00    	je     f01003c9 <kbd_proc_data+0x10b>
	if (stat & KBS_TERR)
f01002d7:	a8 20                	test   $0x20,%al
f01002d9:	0f 85 f1 00 00 00    	jne    f01003d0 <kbd_proc_data+0x112>
f01002df:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e4:	ec                   	in     (%dx),%al
f01002e5:	89 c2                	mov    %eax,%edx
	if (data == 0xE0) {
f01002e7:	3c e0                	cmp    $0xe0,%al
f01002e9:	74 61                	je     f010034c <kbd_proc_data+0x8e>
	} else if (data & 0x80) {
f01002eb:	84 c0                	test   %al,%al
f01002ed:	78 70                	js     f010035f <kbd_proc_data+0xa1>
	} else if (shift & E0ESC) {
f01002ef:	8b 0d 00 80 23 f0    	mov    0xf0238000,%ecx
f01002f5:	f6 c1 40             	test   $0x40,%cl
f01002f8:	74 0e                	je     f0100308 <kbd_proc_data+0x4a>
		data |= 0x80;
f01002fa:	83 c8 80             	or     $0xffffff80,%eax
f01002fd:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01002ff:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100302:	89 0d 00 80 23 f0    	mov    %ecx,0xf0238000
	shift |= shiftcode[data];
f0100308:	0f b6 d2             	movzbl %dl,%edx
f010030b:	0f b6 82 00 6a 10 f0 	movzbl -0xfef9600(%edx),%eax
f0100312:	0b 05 00 80 23 f0    	or     0xf0238000,%eax
	shift ^= togglecode[data];
f0100318:	0f b6 8a 00 69 10 f0 	movzbl -0xfef9700(%edx),%ecx
f010031f:	31 c8                	xor    %ecx,%eax
f0100321:	a3 00 80 23 f0       	mov    %eax,0xf0238000
	c = charcode[shift & (CTL | SHIFT)][data];
f0100326:	89 c1                	mov    %eax,%ecx
f0100328:	83 e1 03             	and    $0x3,%ecx
f010032b:	8b 0c 8d e0 68 10 f0 	mov    -0xfef9720(,%ecx,4),%ecx
f0100332:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100336:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100339:	a8 08                	test   $0x8,%al
f010033b:	74 61                	je     f010039e <kbd_proc_data+0xe0>
		if ('a' <= c && c <= 'z')
f010033d:	89 da                	mov    %ebx,%edx
f010033f:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100342:	83 f9 19             	cmp    $0x19,%ecx
f0100345:	77 4b                	ja     f0100392 <kbd_proc_data+0xd4>
			c += 'A' - 'a';
f0100347:	83 eb 20             	sub    $0x20,%ebx
f010034a:	eb 0c                	jmp    f0100358 <kbd_proc_data+0x9a>
		shift |= E0ESC;
f010034c:	83 0d 00 80 23 f0 40 	orl    $0x40,0xf0238000
		return 0;
f0100353:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0100358:	89 d8                	mov    %ebx,%eax
f010035a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010035d:	c9                   	leave  
f010035e:	c3                   	ret    
		data = (shift & E0ESC ? data : data & 0x7F);
f010035f:	8b 0d 00 80 23 f0    	mov    0xf0238000,%ecx
f0100365:	89 cb                	mov    %ecx,%ebx
f0100367:	83 e3 40             	and    $0x40,%ebx
f010036a:	83 e0 7f             	and    $0x7f,%eax
f010036d:	85 db                	test   %ebx,%ebx
f010036f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100372:	0f b6 d2             	movzbl %dl,%edx
f0100375:	0f b6 82 00 6a 10 f0 	movzbl -0xfef9600(%edx),%eax
f010037c:	83 c8 40             	or     $0x40,%eax
f010037f:	0f b6 c0             	movzbl %al,%eax
f0100382:	f7 d0                	not    %eax
f0100384:	21 c8                	and    %ecx,%eax
f0100386:	a3 00 80 23 f0       	mov    %eax,0xf0238000
		return 0;
f010038b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100390:	eb c6                	jmp    f0100358 <kbd_proc_data+0x9a>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 1a             	cmp    $0x1a,%edx
f010039b:	0f 42 d9             	cmovb  %ecx,%ebx
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 b4                	jne    f0100358 <kbd_proc_data+0x9a>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 ac                	jne    f0100358 <kbd_proc_data+0x9a>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 a3 68 10 f0       	push   $0xf01068a3
f01003b4:	e8 f8 34 00 00       	call   f01038b1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	b8 03 00 00 00       	mov    $0x3,%eax
f01003be:	ba 92 00 00 00       	mov    $0x92,%edx
f01003c3:	ee                   	out    %al,(%dx)
}
f01003c4:	83 c4 10             	add    $0x10,%esp
f01003c7:	eb 8f                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003c9:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003ce:	eb 88                	jmp    f0100358 <kbd_proc_data+0x9a>
		return -1;
f01003d0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01003d5:	eb 81                	jmp    f0100358 <kbd_proc_data+0x9a>

f01003d7 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003d7:	55                   	push   %ebp
f01003d8:	89 e5                	mov    %esp,%ebp
f01003da:	57                   	push   %edi
f01003db:	56                   	push   %esi
f01003dc:	53                   	push   %ebx
f01003dd:	83 ec 1c             	sub    $0x1c,%esp
f01003e0:	89 c1                	mov    %eax,%ecx
	for (i = 0;
f01003e2:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003e7:	bf fd 03 00 00       	mov    $0x3fd,%edi
f01003ec:	bb 84 00 00 00       	mov    $0x84,%ebx
f01003f1:	89 fa                	mov    %edi,%edx
f01003f3:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01003f4:	a8 20                	test   $0x20,%al
f01003f6:	75 13                	jne    f010040b <cons_putc+0x34>
f01003f8:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f01003fe:	7f 0b                	jg     f010040b <cons_putc+0x34>
f0100400:	89 da                	mov    %ebx,%edx
f0100402:	ec                   	in     (%dx),%al
f0100403:	ec                   	in     (%dx),%al
f0100404:	ec                   	in     (%dx),%al
f0100405:	ec                   	in     (%dx),%al
	     i++)
f0100406:	83 c6 01             	add    $0x1,%esi
f0100409:	eb e6                	jmp    f01003f1 <cons_putc+0x1a>
	outb(COM1 + COM_TX, c);
f010040b:	88 4d e7             	mov    %cl,-0x19(%ebp)
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010040e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100413:	89 c8                	mov    %ecx,%eax
f0100415:	ee                   	out    %al,(%dx)
	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100416:	be 00 00 00 00       	mov    $0x0,%esi
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010041b:	bf 79 03 00 00       	mov    $0x379,%edi
f0100420:	bb 84 00 00 00       	mov    $0x84,%ebx
f0100425:	89 fa                	mov    %edi,%edx
f0100427:	ec                   	in     (%dx),%al
f0100428:	81 fe ff 31 00 00    	cmp    $0x31ff,%esi
f010042e:	7f 0f                	jg     f010043f <cons_putc+0x68>
f0100430:	84 c0                	test   %al,%al
f0100432:	78 0b                	js     f010043f <cons_putc+0x68>
f0100434:	89 da                	mov    %ebx,%edx
f0100436:	ec                   	in     (%dx),%al
f0100437:	ec                   	in     (%dx),%al
f0100438:	ec                   	in     (%dx),%al
f0100439:	ec                   	in     (%dx),%al
f010043a:	83 c6 01             	add    $0x1,%esi
f010043d:	eb e6                	jmp    f0100425 <cons_putc+0x4e>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010043f:	ba 78 03 00 00       	mov    $0x378,%edx
f0100444:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100448:	ee                   	out    %al,(%dx)
f0100449:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010044e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100453:	ee                   	out    %al,(%dx)
f0100454:	b8 08 00 00 00       	mov    $0x8,%eax
f0100459:	ee                   	out    %al,(%dx)
		c |= 0x0700;
f010045a:	89 c8                	mov    %ecx,%eax
f010045c:	80 cc 07             	or     $0x7,%ah
f010045f:	f7 c1 00 ff ff ff    	test   $0xffffff00,%ecx
f0100465:	0f 44 c8             	cmove  %eax,%ecx
	switch (c & 0xff) {
f0100468:	0f b6 c1             	movzbl %cl,%eax
f010046b:	80 f9 0a             	cmp    $0xa,%cl
f010046e:	0f 84 dd 00 00 00    	je     f0100551 <cons_putc+0x17a>
f0100474:	83 f8 0a             	cmp    $0xa,%eax
f0100477:	7f 46                	jg     f01004bf <cons_putc+0xe8>
f0100479:	83 f8 08             	cmp    $0x8,%eax
f010047c:	0f 84 a7 00 00 00    	je     f0100529 <cons_putc+0x152>
f0100482:	83 f8 09             	cmp    $0x9,%eax
f0100485:	0f 85 d3 00 00 00    	jne    f010055e <cons_putc+0x187>
		cons_putc(' ');
f010048b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100490:	e8 42 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f0100495:	b8 20 00 00 00       	mov    $0x20,%eax
f010049a:	e8 38 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f010049f:	b8 20 00 00 00       	mov    $0x20,%eax
f01004a4:	e8 2e ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004a9:	b8 20 00 00 00       	mov    $0x20,%eax
f01004ae:	e8 24 ff ff ff       	call   f01003d7 <cons_putc>
		cons_putc(' ');
f01004b3:	b8 20 00 00 00       	mov    $0x20,%eax
f01004b8:	e8 1a ff ff ff       	call   f01003d7 <cons_putc>
		break;
f01004bd:	eb 25                	jmp    f01004e4 <cons_putc+0x10d>
	switch (c & 0xff) {
f01004bf:	83 f8 0d             	cmp    $0xd,%eax
f01004c2:	0f 85 96 00 00 00    	jne    f010055e <cons_putc+0x187>
		crt_pos -= (crt_pos % CRT_COLS);
f01004c8:	0f b7 05 28 82 23 f0 	movzwl 0xf0238228,%eax
f01004cf:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004d5:	c1 e8 16             	shr    $0x16,%eax
f01004d8:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004db:	c1 e0 04             	shl    $0x4,%eax
f01004de:	66 a3 28 82 23 f0    	mov    %ax,0xf0238228
	if (crt_pos >= CRT_SIZE) {
f01004e4:	66 81 3d 28 82 23 f0 	cmpw   $0x7cf,0xf0238228
f01004eb:	cf 07 
f01004ed:	0f 87 8e 00 00 00    	ja     f0100581 <cons_putc+0x1aa>
	outb(addr_6845, 14);
f01004f3:	8b 0d 30 82 23 f0    	mov    0xf0238230,%ecx
f01004f9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004fe:	89 ca                	mov    %ecx,%edx
f0100500:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100501:	0f b7 1d 28 82 23 f0 	movzwl 0xf0238228,%ebx
f0100508:	8d 71 01             	lea    0x1(%ecx),%esi
f010050b:	89 d8                	mov    %ebx,%eax
f010050d:	66 c1 e8 08          	shr    $0x8,%ax
f0100511:	89 f2                	mov    %esi,%edx
f0100513:	ee                   	out    %al,(%dx)
f0100514:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100519:	89 ca                	mov    %ecx,%edx
f010051b:	ee                   	out    %al,(%dx)
f010051c:	89 d8                	mov    %ebx,%eax
f010051e:	89 f2                	mov    %esi,%edx
f0100520:	ee                   	out    %al,(%dx)
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100521:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100524:	5b                   	pop    %ebx
f0100525:	5e                   	pop    %esi
f0100526:	5f                   	pop    %edi
f0100527:	5d                   	pop    %ebp
f0100528:	c3                   	ret    
		if (crt_pos > 0) {
f0100529:	0f b7 05 28 82 23 f0 	movzwl 0xf0238228,%eax
f0100530:	66 85 c0             	test   %ax,%ax
f0100533:	74 be                	je     f01004f3 <cons_putc+0x11c>
			crt_pos--;
f0100535:	83 e8 01             	sub    $0x1,%eax
f0100538:	66 a3 28 82 23 f0    	mov    %ax,0xf0238228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010053e:	0f b7 d0             	movzwl %ax,%edx
f0100541:	b1 00                	mov    $0x0,%cl
f0100543:	83 c9 20             	or     $0x20,%ecx
f0100546:	a1 2c 82 23 f0       	mov    0xf023822c,%eax
f010054b:	66 89 0c 50          	mov    %cx,(%eax,%edx,2)
f010054f:	eb 93                	jmp    f01004e4 <cons_putc+0x10d>
		crt_pos += CRT_COLS;
f0100551:	66 83 05 28 82 23 f0 	addw   $0x50,0xf0238228
f0100558:	50 
f0100559:	e9 6a ff ff ff       	jmp    f01004c8 <cons_putc+0xf1>
		crt_buf[crt_pos++] = c;		/* write the character */
f010055e:	0f b7 05 28 82 23 f0 	movzwl 0xf0238228,%eax
f0100565:	8d 50 01             	lea    0x1(%eax),%edx
f0100568:	66 89 15 28 82 23 f0 	mov    %dx,0xf0238228
f010056f:	0f b7 c0             	movzwl %ax,%eax
f0100572:	8b 15 2c 82 23 f0    	mov    0xf023822c,%edx
f0100578:	66 89 0c 42          	mov    %cx,(%edx,%eax,2)
		break;
f010057c:	e9 63 ff ff ff       	jmp    f01004e4 <cons_putc+0x10d>
		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100581:	a1 2c 82 23 f0       	mov    0xf023822c,%eax
f0100586:	83 ec 04             	sub    $0x4,%esp
f0100589:	68 00 0f 00 00       	push   $0xf00
f010058e:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100594:	52                   	push   %edx
f0100595:	50                   	push   %eax
f0100596:	e8 00 56 00 00       	call   f0105b9b <memmove>
			crt_buf[i] = 0x0700 | ' ';
f010059b:	8b 15 2c 82 23 f0    	mov    0xf023822c,%edx
f01005a1:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01005a7:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01005ad:	83 c4 10             	add    $0x10,%esp
f01005b0:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01005b5:	83 c0 02             	add    $0x2,%eax
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01005b8:	39 d0                	cmp    %edx,%eax
f01005ba:	75 f4                	jne    f01005b0 <cons_putc+0x1d9>
		crt_pos -= CRT_COLS;
f01005bc:	66 83 2d 28 82 23 f0 	subw   $0x50,0xf0238228
f01005c3:	50 
f01005c4:	e9 2a ff ff ff       	jmp    f01004f3 <cons_putc+0x11c>

f01005c9 <serial_intr>:
{
f01005c9:	f3 0f 1e fb          	endbr32 
	if (serial_exists)
f01005cd:	80 3d 34 82 23 f0 00 	cmpb   $0x0,0xf0238234
f01005d4:	75 01                	jne    f01005d7 <serial_intr+0xe>
f01005d6:	c3                   	ret    
{
f01005d7:	55                   	push   %ebp
f01005d8:	89 e5                	mov    %esp,%ebp
f01005da:	83 ec 08             	sub    $0x8,%esp
		cons_intr(serial_proc_data);
f01005dd:	b8 61 02 10 f0       	mov    $0xf0100261,%eax
f01005e2:	e8 98 fc ff ff       	call   f010027f <cons_intr>
}
f01005e7:	c9                   	leave  
f01005e8:	c3                   	ret    

f01005e9 <kbd_intr>:
{
f01005e9:	f3 0f 1e fb          	endbr32 
f01005ed:	55                   	push   %ebp
f01005ee:	89 e5                	mov    %esp,%ebp
f01005f0:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005f3:	b8 be 02 10 f0       	mov    $0xf01002be,%eax
f01005f8:	e8 82 fc ff ff       	call   f010027f <cons_intr>
}
f01005fd:	c9                   	leave  
f01005fe:	c3                   	ret    

f01005ff <cons_getc>:
{
f01005ff:	f3 0f 1e fb          	endbr32 
f0100603:	55                   	push   %ebp
f0100604:	89 e5                	mov    %esp,%ebp
f0100606:	83 ec 08             	sub    $0x8,%esp
	serial_intr();
f0100609:	e8 bb ff ff ff       	call   f01005c9 <serial_intr>
	kbd_intr();
f010060e:	e8 d6 ff ff ff       	call   f01005e9 <kbd_intr>
	if (cons.rpos != cons.wpos) {
f0100613:	a1 20 82 23 f0       	mov    0xf0238220,%eax
	return 0;
f0100618:	ba 00 00 00 00       	mov    $0x0,%edx
	if (cons.rpos != cons.wpos) {
f010061d:	3b 05 24 82 23 f0    	cmp    0xf0238224,%eax
f0100623:	74 1c                	je     f0100641 <cons_getc+0x42>
		c = cons.buf[cons.rpos++];
f0100625:	8d 48 01             	lea    0x1(%eax),%ecx
f0100628:	0f b6 90 20 80 23 f0 	movzbl -0xfdc7fe0(%eax),%edx
			cons.rpos = 0;
f010062f:	3d ff 01 00 00       	cmp    $0x1ff,%eax
f0100634:	b8 00 00 00 00       	mov    $0x0,%eax
f0100639:	0f 45 c1             	cmovne %ecx,%eax
f010063c:	a3 20 82 23 f0       	mov    %eax,0xf0238220
}
f0100641:	89 d0                	mov    %edx,%eax
f0100643:	c9                   	leave  
f0100644:	c3                   	ret    

f0100645 <cons_init>:

// initialize the console devices
void
cons_init(void)
{
f0100645:	f3 0f 1e fb          	endbr32 
f0100649:	55                   	push   %ebp
f010064a:	89 e5                	mov    %esp,%ebp
f010064c:	57                   	push   %edi
f010064d:	56                   	push   %esi
f010064e:	53                   	push   %ebx
f010064f:	83 ec 0c             	sub    $0xc,%esp
	was = *cp;
f0100652:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100659:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100660:	5a a5 
	if (*cp != 0xA55A) {
f0100662:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100669:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010066d:	0f 84 d4 00 00 00    	je     f0100747 <cons_init+0x102>
		addr_6845 = MONO_BASE;
f0100673:	c7 05 30 82 23 f0 b4 	movl   $0x3b4,0xf0238230
f010067a:	03 00 00 
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010067d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
	outb(addr_6845, 14);
f0100682:	8b 3d 30 82 23 f0    	mov    0xf0238230,%edi
f0100688:	b8 0e 00 00 00       	mov    $0xe,%eax
f010068d:	89 fa                	mov    %edi,%edx
f010068f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100690:	8d 4f 01             	lea    0x1(%edi),%ecx
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100693:	89 ca                	mov    %ecx,%edx
f0100695:	ec                   	in     (%dx),%al
f0100696:	0f b6 c0             	movzbl %al,%eax
f0100699:	c1 e0 08             	shl    $0x8,%eax
f010069c:	89 c3                	mov    %eax,%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010069e:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006a3:	89 fa                	mov    %edi,%edx
f01006a5:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006a6:	89 ca                	mov    %ecx,%edx
f01006a8:	ec                   	in     (%dx),%al
	crt_buf = (uint16_t*) cp;
f01006a9:	89 35 2c 82 23 f0    	mov    %esi,0xf023822c
	pos |= inb(addr_6845 + 1);
f01006af:	0f b6 c0             	movzbl %al,%eax
f01006b2:	09 d8                	or     %ebx,%eax
	crt_pos = pos;
f01006b4:	66 a3 28 82 23 f0    	mov    %ax,0xf0238228
	kbd_intr();
f01006ba:	e8 2a ff ff ff       	call   f01005e9 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006bf:	83 ec 0c             	sub    $0xc,%esp
f01006c2:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f01006c9:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ce:	50                   	push   %eax
f01006cf:	e8 70 30 00 00       	call   f0103744 <irq_setmask_8259A>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006d4:	bb 00 00 00 00       	mov    $0x0,%ebx
f01006d9:	b9 fa 03 00 00       	mov    $0x3fa,%ecx
f01006de:	89 d8                	mov    %ebx,%eax
f01006e0:	89 ca                	mov    %ecx,%edx
f01006e2:	ee                   	out    %al,(%dx)
f01006e3:	bf fb 03 00 00       	mov    $0x3fb,%edi
f01006e8:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006ed:	89 fa                	mov    %edi,%edx
f01006ef:	ee                   	out    %al,(%dx)
f01006f0:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006f5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01006fa:	ee                   	out    %al,(%dx)
f01006fb:	be f9 03 00 00       	mov    $0x3f9,%esi
f0100700:	89 d8                	mov    %ebx,%eax
f0100702:	89 f2                	mov    %esi,%edx
f0100704:	ee                   	out    %al,(%dx)
f0100705:	b8 03 00 00 00       	mov    $0x3,%eax
f010070a:	89 fa                	mov    %edi,%edx
f010070c:	ee                   	out    %al,(%dx)
f010070d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100712:	89 d8                	mov    %ebx,%eax
f0100714:	ee                   	out    %al,(%dx)
f0100715:	b8 01 00 00 00       	mov    $0x1,%eax
f010071a:	89 f2                	mov    %esi,%edx
f010071c:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010071d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100722:	ec                   	in     (%dx),%al
f0100723:	89 c3                	mov    %eax,%ebx
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100725:	83 c4 10             	add    $0x10,%esp
f0100728:	3c ff                	cmp    $0xff,%al
f010072a:	0f 95 05 34 82 23 f0 	setne  0xf0238234
f0100731:	89 ca                	mov    %ecx,%edx
f0100733:	ec                   	in     (%dx),%al
f0100734:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100739:	ec                   	in     (%dx),%al
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010073a:	80 fb ff             	cmp    $0xff,%bl
f010073d:	74 23                	je     f0100762 <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
}
f010073f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100742:	5b                   	pop    %ebx
f0100743:	5e                   	pop    %esi
f0100744:	5f                   	pop    %edi
f0100745:	5d                   	pop    %ebp
f0100746:	c3                   	ret    
		*cp = was;
f0100747:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010074e:	c7 05 30 82 23 f0 d4 	movl   $0x3d4,0xf0238230
f0100755:	03 00 00 
	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100758:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
f010075d:	e9 20 ff ff ff       	jmp    f0100682 <cons_init+0x3d>
		cprintf("Serial port does not exist!\n");
f0100762:	83 ec 0c             	sub    $0xc,%esp
f0100765:	68 af 68 10 f0       	push   $0xf01068af
f010076a:	e8 42 31 00 00       	call   f01038b1 <cprintf>
f010076f:	83 c4 10             	add    $0x10,%esp
}
f0100772:	eb cb                	jmp    f010073f <cons_init+0xfa>

f0100774 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100774:	f3 0f 1e fb          	endbr32 
f0100778:	55                   	push   %ebp
f0100779:	89 e5                	mov    %esp,%ebp
f010077b:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010077e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100781:	e8 51 fc ff ff       	call   f01003d7 <cons_putc>
}
f0100786:	c9                   	leave  
f0100787:	c3                   	ret    

f0100788 <getchar>:

int
getchar(void)
{
f0100788:	f3 0f 1e fb          	endbr32 
f010078c:	55                   	push   %ebp
f010078d:	89 e5                	mov    %esp,%ebp
f010078f:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100792:	e8 68 fe ff ff       	call   f01005ff <cons_getc>
f0100797:	85 c0                	test   %eax,%eax
f0100799:	74 f7                	je     f0100792 <getchar+0xa>
		/* do nothing */;
	return c;
}
f010079b:	c9                   	leave  
f010079c:	c3                   	ret    

f010079d <iscons>:

int
iscons(int fdnum)
{
f010079d:	f3 0f 1e fb          	endbr32 
	// used by readline
	return 1;
}
f01007a1:	b8 01 00 00 00       	mov    $0x1,%eax
f01007a6:	c3                   	ret    

f01007a7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007a7:	f3 0f 1e fb          	endbr32 
f01007ab:	55                   	push   %ebp
f01007ac:	89 e5                	mov    %esp,%ebp
f01007ae:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007b1:	68 00 6b 10 f0       	push   $0xf0106b00
f01007b6:	68 1e 6b 10 f0       	push   $0xf0106b1e
f01007bb:	68 23 6b 10 f0       	push   $0xf0106b23
f01007c0:	e8 ec 30 00 00       	call   f01038b1 <cprintf>
f01007c5:	83 c4 0c             	add    $0xc,%esp
f01007c8:	68 ac 6b 10 f0       	push   $0xf0106bac
f01007cd:	68 2c 6b 10 f0       	push   $0xf0106b2c
f01007d2:	68 23 6b 10 f0       	push   $0xf0106b23
f01007d7:	e8 d5 30 00 00       	call   f01038b1 <cprintf>
f01007dc:	83 c4 0c             	add    $0xc,%esp
f01007df:	68 35 6b 10 f0       	push   $0xf0106b35
f01007e4:	68 3b 6b 10 f0       	push   $0xf0106b3b
f01007e9:	68 23 6b 10 f0       	push   $0xf0106b23
f01007ee:	e8 be 30 00 00       	call   f01038b1 <cprintf>
	return 0;
}
f01007f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01007f8:	c9                   	leave  
f01007f9:	c3                   	ret    

f01007fa <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007fa:	f3 0f 1e fb          	endbr32 
f01007fe:	55                   	push   %ebp
f01007ff:	89 e5                	mov    %esp,%ebp
f0100801:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100804:	68 45 6b 10 f0       	push   $0xf0106b45
f0100809:	e8 a3 30 00 00       	call   f01038b1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080e:	83 c4 08             	add    $0x8,%esp
f0100811:	68 0c 00 10 00       	push   $0x10000c
f0100816:	68 d4 6b 10 f0       	push   $0xf0106bd4
f010081b:	e8 91 30 00 00       	call   f01038b1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100820:	83 c4 0c             	add    $0xc,%esp
f0100823:	68 0c 00 10 00       	push   $0x10000c
f0100828:	68 0c 00 10 f0       	push   $0xf010000c
f010082d:	68 fc 6b 10 f0       	push   $0xf0106bfc
f0100832:	e8 7a 30 00 00       	call   f01038b1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100837:	83 c4 0c             	add    $0xc,%esp
f010083a:	68 dd 67 10 00       	push   $0x1067dd
f010083f:	68 dd 67 10 f0       	push   $0xf01067dd
f0100844:	68 20 6c 10 f0       	push   $0xf0106c20
f0100849:	e8 63 30 00 00       	call   f01038b1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084e:	83 c4 0c             	add    $0xc,%esp
f0100851:	68 00 80 23 00       	push   $0x238000
f0100856:	68 00 80 23 f0       	push   $0xf0238000
f010085b:	68 44 6c 10 f0       	push   $0xf0106c44
f0100860:	e8 4c 30 00 00       	call   f01038b1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100865:	83 c4 0c             	add    $0xc,%esp
f0100868:	68 08 a0 27 00       	push   $0x27a008
f010086d:	68 08 a0 27 f0       	push   $0xf027a008
f0100872:	68 68 6c 10 f0       	push   $0xf0106c68
f0100877:	e8 35 30 00 00       	call   f01038b1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
f010087c:	83 c4 08             	add    $0x8,%esp
		ROUNDUP(end - entry, 1024) / 1024);
f010087f:	b8 08 a0 27 f0       	mov    $0xf027a008,%eax
f0100884:	2d 0d fc 0f f0       	sub    $0xf00ffc0d,%eax
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100889:	c1 f8 0a             	sar    $0xa,%eax
f010088c:	50                   	push   %eax
f010088d:	68 8c 6c 10 f0       	push   $0xf0106c8c
f0100892:	e8 1a 30 00 00       	call   f01038b1 <cprintf>
	return 0;
}
f0100897:	b8 00 00 00 00       	mov    $0x0,%eax
f010089c:	c9                   	leave  
f010089d:	c3                   	ret    

f010089e <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f010089e:	f3 0f 1e fb          	endbr32 
f01008a2:	55                   	push   %ebp
f01008a3:	89 e5                	mov    %esp,%ebp
f01008a5:	57                   	push   %edi
f01008a6:	56                   	push   %esi
f01008a7:	53                   	push   %ebx
f01008a8:	83 ec 2c             	sub    $0x2c,%esp
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01008ab:	89 eb                	mov    %ebp,%ebx
	uint32_t *ebp = (uint32_t *)read_ebp();
	struct Eipdebuginfo eipdebuginfo;
	while (ebp != 0) {
		uint32_t eip = *(ebp + 1);
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
		debuginfo_eip((uintptr_t)eip, &eipdebuginfo);
f01008ad:	8d 7d d0             	lea    -0x30(%ebp),%edi
	while (ebp != 0) {
f01008b0:	85 db                	test   %ebx,%ebx
f01008b2:	74 55                	je     f0100909 <mon_backtrace+0x6b>
		uint32_t eip = *(ebp + 1);
f01008b4:	8b 73 04             	mov    0x4(%ebx),%esi
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, *(ebp + 2), *(ebp + 3), *(ebp + 4), *(ebp + 5), *(ebp + 6));
f01008b7:	ff 73 18             	pushl  0x18(%ebx)
f01008ba:	ff 73 14             	pushl  0x14(%ebx)
f01008bd:	ff 73 10             	pushl  0x10(%ebx)
f01008c0:	ff 73 0c             	pushl  0xc(%ebx)
f01008c3:	ff 73 08             	pushl  0x8(%ebx)
f01008c6:	56                   	push   %esi
f01008c7:	53                   	push   %ebx
f01008c8:	68 b8 6c 10 f0       	push   $0xf0106cb8
f01008cd:	e8 df 2f 00 00       	call   f01038b1 <cprintf>
		debuginfo_eip((uintptr_t)eip, &eipdebuginfo);
f01008d2:	83 c4 18             	add    $0x18,%esp
f01008d5:	57                   	push   %edi
f01008d6:	56                   	push   %esi
f01008d7:	e8 dd 47 00 00       	call   f01050b9 <debuginfo_eip>
		cprintf("%s:%d", eipdebuginfo.eip_file, eipdebuginfo.eip_line);
f01008dc:	83 c4 0c             	add    $0xc,%esp
f01008df:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008e2:	ff 75 d0             	pushl  -0x30(%ebp)
f01008e5:	68 5e 6b 10 f0       	push   $0xf0106b5e
f01008ea:	e8 c2 2f 00 00       	call   f01038b1 <cprintf>
		cprintf(": %.*s+%d\n", eipdebuginfo.eip_fn_namelen, eipdebuginfo.eip_fn_name, eipdebuginfo.eip_fn_addr);
f01008ef:	ff 75 e0             	pushl  -0x20(%ebp)
f01008f2:	ff 75 d8             	pushl  -0x28(%ebp)
f01008f5:	ff 75 dc             	pushl  -0x24(%ebp)
f01008f8:	68 64 6b 10 f0       	push   $0xf0106b64
f01008fd:	e8 af 2f 00 00       	call   f01038b1 <cprintf>
		ebp = (uint32_t *)(*ebp);
f0100902:	8b 1b                	mov    (%ebx),%ebx
f0100904:	83 c4 20             	add    $0x20,%esp
f0100907:	eb a7                	jmp    f01008b0 <mon_backtrace+0x12>
	}
	return 0;
}
f0100909:	b8 00 00 00 00       	mov    $0x0,%eax
f010090e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100911:	5b                   	pop    %ebx
f0100912:	5e                   	pop    %esi
f0100913:	5f                   	pop    %edi
f0100914:	5d                   	pop    %ebp
f0100915:	c3                   	ret    

f0100916 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100916:	f3 0f 1e fb          	endbr32 
f010091a:	55                   	push   %ebp
f010091b:	89 e5                	mov    %esp,%ebp
f010091d:	57                   	push   %edi
f010091e:	56                   	push   %esi
f010091f:	53                   	push   %ebx
f0100920:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100923:	68 ec 6c 10 f0       	push   $0xf0106cec
f0100928:	e8 84 2f 00 00       	call   f01038b1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010092d:	c7 04 24 10 6d 10 f0 	movl   $0xf0106d10,(%esp)
f0100934:	e8 78 2f 00 00       	call   f01038b1 <cprintf>

	if (tf != NULL)
f0100939:	83 c4 10             	add    $0x10,%esp
f010093c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100940:	0f 84 d9 00 00 00    	je     f0100a1f <monitor+0x109>
		print_trapframe(tf);
f0100946:	83 ec 0c             	sub    $0xc,%esp
f0100949:	ff 75 08             	pushl  0x8(%ebp)
f010094c:	e8 69 36 00 00       	call   f0103fba <print_trapframe>
f0100951:	83 c4 10             	add    $0x10,%esp
f0100954:	e9 c6 00 00 00       	jmp    f0100a1f <monitor+0x109>
		while (*buf && strchr(WHITESPACE, *buf))
f0100959:	83 ec 08             	sub    $0x8,%esp
f010095c:	0f be c0             	movsbl %al,%eax
f010095f:	50                   	push   %eax
f0100960:	68 73 6b 10 f0       	push   $0xf0106b73
f0100965:	e8 a0 51 00 00       	call   f0105b0a <strchr>
f010096a:	83 c4 10             	add    $0x10,%esp
f010096d:	85 c0                	test   %eax,%eax
f010096f:	74 63                	je     f01009d4 <monitor+0xbe>
			*buf++ = 0;
f0100971:	c6 03 00             	movb   $0x0,(%ebx)
f0100974:	89 f7                	mov    %esi,%edi
f0100976:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100979:	89 fe                	mov    %edi,%esi
		while (*buf && strchr(WHITESPACE, *buf))
f010097b:	0f b6 03             	movzbl (%ebx),%eax
f010097e:	84 c0                	test   %al,%al
f0100980:	75 d7                	jne    f0100959 <monitor+0x43>
	argv[argc] = 0;
f0100982:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100989:	00 
	if (argc == 0)
f010098a:	85 f6                	test   %esi,%esi
f010098c:	0f 84 8d 00 00 00    	je     f0100a1f <monitor+0x109>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100992:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (strcmp(argv[0], commands[i].name) == 0)
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010099d:	ff 34 85 40 6d 10 f0 	pushl  -0xfef92c0(,%eax,4)
f01009a4:	ff 75 a8             	pushl  -0x58(%ebp)
f01009a7:	e8 f8 50 00 00       	call   f0105aa4 <strcmp>
f01009ac:	83 c4 10             	add    $0x10,%esp
f01009af:	85 c0                	test   %eax,%eax
f01009b1:	0f 84 8f 00 00 00    	je     f0100a46 <monitor+0x130>
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009b7:	83 c3 01             	add    $0x1,%ebx
f01009ba:	83 fb 03             	cmp    $0x3,%ebx
f01009bd:	75 d8                	jne    f0100997 <monitor+0x81>
	cprintf("Unknown command '%s'\n", argv[0]);
f01009bf:	83 ec 08             	sub    $0x8,%esp
f01009c2:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c5:	68 95 6b 10 f0       	push   $0xf0106b95
f01009ca:	e8 e2 2e 00 00       	call   f01038b1 <cprintf>
	return 0;
f01009cf:	83 c4 10             	add    $0x10,%esp
f01009d2:	eb 4b                	jmp    f0100a1f <monitor+0x109>
		if (*buf == 0)
f01009d4:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009d7:	74 a9                	je     f0100982 <monitor+0x6c>
		if (argc == MAXARGS-1) {
f01009d9:	83 fe 0f             	cmp    $0xf,%esi
f01009dc:	74 2f                	je     f0100a0d <monitor+0xf7>
		argv[argc++] = buf;
f01009de:	8d 7e 01             	lea    0x1(%esi),%edi
f01009e1:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
		while (*buf && !strchr(WHITESPACE, *buf))
f01009e5:	0f b6 03             	movzbl (%ebx),%eax
f01009e8:	84 c0                	test   %al,%al
f01009ea:	74 8d                	je     f0100979 <monitor+0x63>
f01009ec:	83 ec 08             	sub    $0x8,%esp
f01009ef:	0f be c0             	movsbl %al,%eax
f01009f2:	50                   	push   %eax
f01009f3:	68 73 6b 10 f0       	push   $0xf0106b73
f01009f8:	e8 0d 51 00 00       	call   f0105b0a <strchr>
f01009fd:	83 c4 10             	add    $0x10,%esp
f0100a00:	85 c0                	test   %eax,%eax
f0100a02:	0f 85 71 ff ff ff    	jne    f0100979 <monitor+0x63>
			buf++;
f0100a08:	83 c3 01             	add    $0x1,%ebx
f0100a0b:	eb d8                	jmp    f01009e5 <monitor+0xcf>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100a0d:	83 ec 08             	sub    $0x8,%esp
f0100a10:	6a 10                	push   $0x10
f0100a12:	68 78 6b 10 f0       	push   $0xf0106b78
f0100a17:	e8 95 2e 00 00       	call   f01038b1 <cprintf>
			return 0;
f0100a1c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100a1f:	83 ec 0c             	sub    $0xc,%esp
f0100a22:	68 6f 6b 10 f0       	push   $0xf0106b6f
f0100a27:	e8 90 4e 00 00       	call   f01058bc <readline>
f0100a2c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100a2e:	83 c4 10             	add    $0x10,%esp
f0100a31:	85 c0                	test   %eax,%eax
f0100a33:	74 ea                	je     f0100a1f <monitor+0x109>
	argv[argc] = 0;
f0100a35:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	argc = 0;
f0100a3c:	be 00 00 00 00       	mov    $0x0,%esi
f0100a41:	e9 35 ff ff ff       	jmp    f010097b <monitor+0x65>
			return commands[i].func(argc, argv, tf);
f0100a46:	83 ec 04             	sub    $0x4,%esp
f0100a49:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a4c:	ff 75 08             	pushl  0x8(%ebp)
f0100a4f:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a52:	52                   	push   %edx
f0100a53:	56                   	push   %esi
f0100a54:	ff 14 85 48 6d 10 f0 	call   *-0xfef92b8(,%eax,4)
			if (runcmd(buf, tf) < 0)
f0100a5b:	83 c4 10             	add    $0x10,%esp
f0100a5e:	85 c0                	test   %eax,%eax
f0100a60:	79 bd                	jns    f0100a1f <monitor+0x109>
				break;
	}
}
f0100a62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a65:	5b                   	pop    %ebx
f0100a66:	5e                   	pop    %esi
f0100a67:	5f                   	pop    %edi
f0100a68:	5d                   	pop    %ebp
f0100a69:	c3                   	ret    

f0100a6a <boot_alloc>:
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree)
f0100a6a:	83 3d 38 82 23 f0 00 	cmpl   $0x0,0xf0238238
f0100a71:	74 1a                	je     f0100a8d <boot_alloc+0x23>
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	result = nextfree;
f0100a73:	8b 15 38 82 23 f0    	mov    0xf0238238,%edx
	nextfree = ROUNDUP((char *)result + n, PGSIZE);
f0100a79:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100a80:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a85:	a3 38 82 23 f0       	mov    %eax,0xf0238238
	return result;
}
f0100a8a:	89 d0                	mov    %edx,%eax
f0100a8c:	c3                   	ret    
		nextfree = ROUNDUP((char *)end, PGSIZE);
f0100a8d:	ba 07 b0 27 f0       	mov    $0xf027b007,%edx
f0100a92:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a98:	89 15 38 82 23 f0    	mov    %edx,0xf0238238
f0100a9e:	eb d3                	jmp    f0100a73 <boot_alloc+0x9>

f0100aa0 <nvram_read>:
{
f0100aa0:	55                   	push   %ebp
f0100aa1:	89 e5                	mov    %esp,%ebp
f0100aa3:	56                   	push   %esi
f0100aa4:	53                   	push   %ebx
f0100aa5:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100aa7:	83 ec 0c             	sub    $0xc,%esp
f0100aaa:	50                   	push   %eax
f0100aab:	e8 5e 2c 00 00       	call   f010370e <mc146818_read>
f0100ab0:	89 c6                	mov    %eax,%esi
f0100ab2:	83 c3 01             	add    $0x1,%ebx
f0100ab5:	89 1c 24             	mov    %ebx,(%esp)
f0100ab8:	e8 51 2c 00 00       	call   f010370e <mc146818_read>
f0100abd:	c1 e0 08             	shl    $0x8,%eax
f0100ac0:	09 f0                	or     %esi,%eax
}
f0100ac2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ac5:	5b                   	pop    %ebx
f0100ac6:	5e                   	pop    %esi
f0100ac7:	5d                   	pop    %ebp
f0100ac8:	c3                   	ret    

f0100ac9 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ac9:	89 d1                	mov    %edx,%ecx
f0100acb:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ace:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100ad1:	a8 01                	test   $0x1,%al
f0100ad3:	74 51                	je     f0100b26 <check_va2pa+0x5d>
		return ~0;
	p = (pte_t *)KADDR(PTE_ADDR(*pgdir));
f0100ad5:	89 c1                	mov    %eax,%ecx
f0100ad7:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	if (PGNUM(pa) >= npages)
f0100add:	c1 e8 0c             	shr    $0xc,%eax
f0100ae0:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0100ae6:	73 23                	jae    f0100b0b <check_va2pa+0x42>
	if (!(p[PTX(va)] & PTE_P))
f0100ae8:	c1 ea 0c             	shr    $0xc,%edx
f0100aeb:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100af1:	8b 94 91 00 00 00 f0 	mov    -0x10000000(%ecx,%edx,4),%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100af8:	89 d0                	mov    %edx,%eax
f0100afa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aff:	f6 c2 01             	test   $0x1,%dl
f0100b02:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100b07:	0f 44 c2             	cmove  %edx,%eax
f0100b0a:	c3                   	ret    
{
f0100b0b:	55                   	push   %ebp
f0100b0c:	89 e5                	mov    %esp,%ebp
f0100b0e:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b11:	51                   	push   %ecx
f0100b12:	68 04 68 10 f0       	push   $0xf0106804
f0100b17:	68 a1 03 00 00       	push   $0x3a1
f0100b1c:	68 45 77 10 f0       	push   $0xf0107745
f0100b21:	e8 1a f5 ff ff       	call   f0100040 <_panic>
		return ~0;
f0100b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100b2b:	c3                   	ret    

f0100b2c <check_page_free_list>:
{
f0100b2c:	55                   	push   %ebp
f0100b2d:	89 e5                	mov    %esp,%ebp
f0100b2f:	57                   	push   %edi
f0100b30:	56                   	push   %esi
f0100b31:	53                   	push   %ebx
f0100b32:	83 ec 2c             	sub    $0x2c,%esp
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b35:	84 c0                	test   %al,%al
f0100b37:	0f 85 77 02 00 00    	jne    f0100db4 <check_page_free_list+0x288>
	if (!page_free_list)
f0100b3d:	83 3d 40 82 23 f0 00 	cmpl   $0x0,0xf0238240
f0100b44:	74 0a                	je     f0100b50 <check_page_free_list+0x24>
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b46:	be 00 04 00 00       	mov    $0x400,%esi
f0100b4b:	e9 bf 02 00 00       	jmp    f0100e0f <check_page_free_list+0x2e3>
		panic("'page_free_list' is a null pointer!");
f0100b50:	83 ec 04             	sub    $0x4,%esp
f0100b53:	68 64 6d 10 f0       	push   $0xf0106d64
f0100b58:	68 cd 02 00 00       	push   $0x2cd
f0100b5d:	68 45 77 10 f0       	push   $0xf0107745
f0100b62:	e8 d9 f4 ff ff       	call   f0100040 <_panic>
f0100b67:	50                   	push   %eax
f0100b68:	68 04 68 10 f0       	push   $0xf0106804
f0100b6d:	6a 58                	push   $0x58
f0100b6f:	68 51 77 10 f0       	push   $0xf0107751
f0100b74:	e8 c7 f4 ff ff       	call   f0100040 <_panic>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b79:	8b 1b                	mov    (%ebx),%ebx
f0100b7b:	85 db                	test   %ebx,%ebx
f0100b7d:	74 41                	je     f0100bc0 <check_page_free_list+0x94>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b7f:	89 d8                	mov    %ebx,%eax
f0100b81:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0100b87:	c1 f8 03             	sar    $0x3,%eax
f0100b8a:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b8d:	89 c2                	mov    %eax,%edx
f0100b8f:	c1 ea 16             	shr    $0x16,%edx
f0100b92:	39 f2                	cmp    %esi,%edx
f0100b94:	73 e3                	jae    f0100b79 <check_page_free_list+0x4d>
	if (PGNUM(pa) >= npages)
f0100b96:	89 c2                	mov    %eax,%edx
f0100b98:	c1 ea 0c             	shr    $0xc,%edx
f0100b9b:	3b 15 88 8e 23 f0    	cmp    0xf0238e88,%edx
f0100ba1:	73 c4                	jae    f0100b67 <check_page_free_list+0x3b>
			memset(page2kva(pp), 0x97, 128);
f0100ba3:	83 ec 04             	sub    $0x4,%esp
f0100ba6:	68 80 00 00 00       	push   $0x80
f0100bab:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bb0:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100bb5:	50                   	push   %eax
f0100bb6:	e8 94 4f 00 00       	call   f0105b4f <memset>
f0100bbb:	83 c4 10             	add    $0x10,%esp
f0100bbe:	eb b9                	jmp    f0100b79 <check_page_free_list+0x4d>
	first_free_page = (char *)boot_alloc(0);
f0100bc0:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bc5:	e8 a0 fe ff ff       	call   f0100a6a <boot_alloc>
f0100bca:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bcd:	8b 15 40 82 23 f0    	mov    0xf0238240,%edx
		assert(pp >= pages);
f0100bd3:	8b 0d 90 8e 23 f0    	mov    0xf0238e90,%ecx
		assert(pp < pages + npages);
f0100bd9:	a1 88 8e 23 f0       	mov    0xf0238e88,%eax
f0100bde:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100be1:	8d 34 c1             	lea    (%ecx,%eax,8),%esi
	int nfree_basemem = 0, nfree_extmem = 0;
f0100be4:	bf 00 00 00 00       	mov    $0x0,%edi
f0100be9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bec:	e9 f9 00 00 00       	jmp    f0100cea <check_page_free_list+0x1be>
		assert(pp >= pages);
f0100bf1:	68 5f 77 10 f0       	push   $0xf010775f
f0100bf6:	68 6b 77 10 f0       	push   $0xf010776b
f0100bfb:	68 ea 02 00 00       	push   $0x2ea
f0100c00:	68 45 77 10 f0       	push   $0xf0107745
f0100c05:	e8 36 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c0a:	68 80 77 10 f0       	push   $0xf0107780
f0100c0f:	68 6b 77 10 f0       	push   $0xf010776b
f0100c14:	68 eb 02 00 00       	push   $0x2eb
f0100c19:	68 45 77 10 f0       	push   $0xf0107745
f0100c1e:	e8 1d f4 ff ff       	call   f0100040 <_panic>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100c23:	68 88 6d 10 f0       	push   $0xf0106d88
f0100c28:	68 6b 77 10 f0       	push   $0xf010776b
f0100c2d:	68 ec 02 00 00       	push   $0x2ec
f0100c32:	68 45 77 10 f0       	push   $0xf0107745
f0100c37:	e8 04 f4 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != 0);
f0100c3c:	68 94 77 10 f0       	push   $0xf0107794
f0100c41:	68 6b 77 10 f0       	push   $0xf010776b
f0100c46:	68 ef 02 00 00       	push   $0x2ef
f0100c4b:	68 45 77 10 f0       	push   $0xf0107745
f0100c50:	e8 eb f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c55:	68 a5 77 10 f0       	push   $0xf01077a5
f0100c5a:	68 6b 77 10 f0       	push   $0xf010776b
f0100c5f:	68 f0 02 00 00       	push   $0x2f0
f0100c64:	68 45 77 10 f0       	push   $0xf0107745
f0100c69:	e8 d2 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c6e:	68 b8 6d 10 f0       	push   $0xf0106db8
f0100c73:	68 6b 77 10 f0       	push   $0xf010776b
f0100c78:	68 f1 02 00 00       	push   $0x2f1
f0100c7d:	68 45 77 10 f0       	push   $0xf0107745
f0100c82:	e8 b9 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c87:	68 be 77 10 f0       	push   $0xf01077be
f0100c8c:	68 6b 77 10 f0       	push   $0xf010776b
f0100c91:	68 f2 02 00 00       	push   $0x2f2
f0100c96:	68 45 77 10 f0       	push   $0xf0107745
f0100c9b:	e8 a0 f3 ff ff       	call   f0100040 <_panic>
	if (PGNUM(pa) >= npages)
f0100ca0:	89 c3                	mov    %eax,%ebx
f0100ca2:	c1 eb 0c             	shr    $0xc,%ebx
f0100ca5:	39 5d d0             	cmp    %ebx,-0x30(%ebp)
f0100ca8:	76 0f                	jbe    f0100cb9 <check_page_free_list+0x18d>
	return (void *)(pa + KERNBASE);
f0100caa:	2d 00 00 00 10       	sub    $0x10000000,%eax
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100caf:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100cb2:	77 17                	ja     f0100ccb <check_page_free_list+0x19f>
			++nfree_extmem;
f0100cb4:	83 c7 01             	add    $0x1,%edi
f0100cb7:	eb 2f                	jmp    f0100ce8 <check_page_free_list+0x1bc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cb9:	50                   	push   %eax
f0100cba:	68 04 68 10 f0       	push   $0xf0106804
f0100cbf:	6a 58                	push   $0x58
f0100cc1:	68 51 77 10 f0       	push   $0xf0107751
f0100cc6:	e8 75 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100ccb:	68 dc 6d 10 f0       	push   $0xf0106ddc
f0100cd0:	68 6b 77 10 f0       	push   $0xf010776b
f0100cd5:	68 f3 02 00 00       	push   $0x2f3
f0100cda:	68 45 77 10 f0       	push   $0xf0107745
f0100cdf:	e8 5c f3 ff ff       	call   f0100040 <_panic>
			++nfree_basemem;
f0100ce4:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ce8:	8b 12                	mov    (%edx),%edx
f0100cea:	85 d2                	test   %edx,%edx
f0100cec:	74 74                	je     f0100d62 <check_page_free_list+0x236>
		assert(pp >= pages);
f0100cee:	39 d1                	cmp    %edx,%ecx
f0100cf0:	0f 87 fb fe ff ff    	ja     f0100bf1 <check_page_free_list+0xc5>
		assert(pp < pages + npages);
f0100cf6:	39 d6                	cmp    %edx,%esi
f0100cf8:	0f 86 0c ff ff ff    	jbe    f0100c0a <check_page_free_list+0xde>
		assert(((char *)pp - (char *)pages) % sizeof(*pp) == 0);
f0100cfe:	89 d0                	mov    %edx,%eax
f0100d00:	29 c8                	sub    %ecx,%eax
f0100d02:	a8 07                	test   $0x7,%al
f0100d04:	0f 85 19 ff ff ff    	jne    f0100c23 <check_page_free_list+0xf7>
	return (pp - pages) << PGSHIFT;
f0100d0a:	c1 f8 03             	sar    $0x3,%eax
		assert(page2pa(pp) != 0);
f0100d0d:	c1 e0 0c             	shl    $0xc,%eax
f0100d10:	0f 84 26 ff ff ff    	je     f0100c3c <check_page_free_list+0x110>
		assert(page2pa(pp) != IOPHYSMEM);
f0100d16:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100d1b:	0f 84 34 ff ff ff    	je     f0100c55 <check_page_free_list+0x129>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100d21:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100d26:	0f 84 42 ff ff ff    	je     f0100c6e <check_page_free_list+0x142>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d2c:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d31:	0f 84 50 ff ff ff    	je     f0100c87 <check_page_free_list+0x15b>
		assert(page2pa(pp) < EXTPHYSMEM || (char *)page2kva(pp) >= first_free_page);
f0100d37:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d3c:	0f 87 5e ff ff ff    	ja     f0100ca0 <check_page_free_list+0x174>
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d42:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d47:	75 9b                	jne    f0100ce4 <check_page_free_list+0x1b8>
f0100d49:	68 d8 77 10 f0       	push   $0xf01077d8
f0100d4e:	68 6b 77 10 f0       	push   $0xf010776b
f0100d53:	68 f5 02 00 00       	push   $0x2f5
f0100d58:	68 45 77 10 f0       	push   $0xf0107745
f0100d5d:	e8 de f2 ff ff       	call   f0100040 <_panic>
f0100d62:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
	assert(nfree_basemem > 0);
f0100d65:	85 db                	test   %ebx,%ebx
f0100d67:	7e 19                	jle    f0100d82 <check_page_free_list+0x256>
	assert(nfree_extmem > 0);
f0100d69:	85 ff                	test   %edi,%edi
f0100d6b:	7e 2e                	jle    f0100d9b <check_page_free_list+0x26f>
	cprintf("check_page_free_list() succeeded!\n");
f0100d6d:	83 ec 0c             	sub    $0xc,%esp
f0100d70:	68 20 6e 10 f0       	push   $0xf0106e20
f0100d75:	e8 37 2b 00 00       	call   f01038b1 <cprintf>
}
f0100d7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d7d:	5b                   	pop    %ebx
f0100d7e:	5e                   	pop    %esi
f0100d7f:	5f                   	pop    %edi
f0100d80:	5d                   	pop    %ebp
f0100d81:	c3                   	ret    
	assert(nfree_basemem > 0);
f0100d82:	68 f5 77 10 f0       	push   $0xf01077f5
f0100d87:	68 6b 77 10 f0       	push   $0xf010776b
f0100d8c:	68 fd 02 00 00       	push   $0x2fd
f0100d91:	68 45 77 10 f0       	push   $0xf0107745
f0100d96:	e8 a5 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d9b:	68 07 78 10 f0       	push   $0xf0107807
f0100da0:	68 6b 77 10 f0       	push   $0xf010776b
f0100da5:	68 fe 02 00 00       	push   $0x2fe
f0100daa:	68 45 77 10 f0       	push   $0xf0107745
f0100daf:	e8 8c f2 ff ff       	call   f0100040 <_panic>
	if (!page_free_list)
f0100db4:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f0100db9:	85 c0                	test   %eax,%eax
f0100dbb:	0f 84 8f fd ff ff    	je     f0100b50 <check_page_free_list+0x24>
		struct PageInfo **tp[2] = {&pp1, &pp2};
f0100dc1:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100dc4:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100dc7:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100dca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100dcd:	89 c2                	mov    %eax,%edx
f0100dcf:	2b 15 90 8e 23 f0    	sub    0xf0238e90,%edx
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100dd5:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ddb:	0f 95 c2             	setne  %dl
f0100dde:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100de1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100de5:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100de7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
		for (pp = page_free_list; pp; pp = pp->pp_link)
f0100deb:	8b 00                	mov    (%eax),%eax
f0100ded:	85 c0                	test   %eax,%eax
f0100def:	75 dc                	jne    f0100dcd <check_page_free_list+0x2a1>
		*tp[1] = 0;
f0100df1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100df4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100dfa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100dfd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100e00:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e02:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e05:	a3 40 82 23 f0       	mov    %eax,0xf0238240
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100e0a:	be 01 00 00 00       	mov    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e0f:	8b 1d 40 82 23 f0    	mov    0xf0238240,%ebx
f0100e15:	e9 61 fd ff ff       	jmp    f0100b7b <check_page_free_list+0x4f>

f0100e1a <page_init>:
{
f0100e1a:	f3 0f 1e fb          	endbr32 
f0100e1e:	55                   	push   %ebp
f0100e1f:	89 e5                	mov    %esp,%ebp
f0100e21:	57                   	push   %edi
f0100e22:	56                   	push   %esi
f0100e23:	53                   	push   %ebx
f0100e24:	83 ec 0c             	sub    $0xc,%esp
	size_t kernel_end_page = PADDR(boot_alloc(0)) / PGSIZE;
f0100e27:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e2c:	e8 39 fc ff ff       	call   f0100a6a <boot_alloc>
	if ((uint32_t)kva < KERNBASE)
f0100e31:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e36:	76 20                	jbe    f0100e58 <page_init+0x3e>
	return (physaddr_t)kva - KERNBASE;
f0100e38:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
f0100e3e:	c1 e9 0c             	shr    $0xc,%ecx
f0100e41:	8b 1d 40 82 23 f0    	mov    0xf0238240,%ebx
	for (i = 0; i < npages; i++)
f0100e47:	be 00 00 00 00       	mov    $0x0,%esi
f0100e4c:	b8 00 00 00 00       	mov    $0x0,%eax
			page_free_list = &pages[i];
f0100e51:	bf 01 00 00 00       	mov    $0x1,%edi
	for (i = 0; i < npages; i++)
f0100e56:	eb 38                	jmp    f0100e90 <page_init+0x76>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100e58:	50                   	push   %eax
f0100e59:	68 28 68 10 f0       	push   $0xf0106828
f0100e5e:	68 3e 01 00 00       	push   $0x13e
f0100e63:	68 45 77 10 f0       	push   $0xf0107745
f0100e68:	e8 d3 f1 ff ff       	call   f0100040 <_panic>
		else if (i >= io_hole_start_page && i < kernel_end_page)
f0100e6d:	3d 9f 00 00 00       	cmp    $0x9f,%eax
f0100e72:	76 3c                	jbe    f0100eb0 <page_init+0x96>
f0100e74:	39 c8                	cmp    %ecx,%eax
f0100e76:	73 38                	jae    f0100eb0 <page_init+0x96>
			pages[i].pp_ref = 1;
f0100e78:	8b 15 90 8e 23 f0    	mov    0xf0238e90,%edx
f0100e7e:	8d 14 c2             	lea    (%edx,%eax,8),%edx
f0100e81:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100e87:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
	for (i = 0; i < npages; i++)
f0100e8d:	83 c0 01             	add    $0x1,%eax
f0100e90:	39 05 88 8e 23 f0    	cmp    %eax,0xf0238e88
f0100e96:	76 55                	jbe    f0100eed <page_init+0xd3>
		if (i == 0)
f0100e98:	85 c0                	test   %eax,%eax
f0100e9a:	75 d1                	jne    f0100e6d <page_init+0x53>
			pages[i].pp_ref = 1;
f0100e9c:	8b 15 90 8e 23 f0    	mov    0xf0238e90,%edx
f0100ea2:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
			pages[i].pp_link = NULL;
f0100ea8:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
f0100eae:	eb dd                	jmp    f0100e8d <page_init+0x73>
		else if (i == MPENTRY_PADDR / PGSIZE)
f0100eb0:	83 f8 07             	cmp    $0x7,%eax
f0100eb3:	74 23                	je     f0100ed8 <page_init+0xbe>
f0100eb5:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100ebc:	89 d6                	mov    %edx,%esi
f0100ebe:	03 35 90 8e 23 f0    	add    0xf0238e90,%esi
f0100ec4:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
			pages[i].pp_link = page_free_list;
f0100eca:	89 1e                	mov    %ebx,(%esi)
			page_free_list = &pages[i];
f0100ecc:	89 d3                	mov    %edx,%ebx
f0100ece:	03 1d 90 8e 23 f0    	add    0xf0238e90,%ebx
f0100ed4:	89 fe                	mov    %edi,%esi
f0100ed6:	eb b5                	jmp    f0100e8d <page_init+0x73>
			pages[i].pp_ref = 1;
f0100ed8:	8b 15 90 8e 23 f0    	mov    0xf0238e90,%edx
f0100ede:	66 c7 42 3c 01 00    	movw   $0x1,0x3c(%edx)
			pages[i].pp_link = NULL;
f0100ee4:	c7 42 38 00 00 00 00 	movl   $0x0,0x38(%edx)
f0100eeb:	eb a0                	jmp    f0100e8d <page_init+0x73>
f0100eed:	89 f0                	mov    %esi,%eax
f0100eef:	84 c0                	test   %al,%al
f0100ef1:	74 06                	je     f0100ef9 <page_init+0xdf>
f0100ef3:	89 1d 40 82 23 f0    	mov    %ebx,0xf0238240
}
f0100ef9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100efc:	5b                   	pop    %ebx
f0100efd:	5e                   	pop    %esi
f0100efe:	5f                   	pop    %edi
f0100eff:	5d                   	pop    %ebp
f0100f00:	c3                   	ret    

f0100f01 <page_alloc>:
{
f0100f01:	f3 0f 1e fb          	endbr32 
f0100f05:	55                   	push   %ebp
f0100f06:	89 e5                	mov    %esp,%ebp
f0100f08:	53                   	push   %ebx
f0100f09:	83 ec 04             	sub    $0x4,%esp
	struct PageInfo *ret = page_free_list;
f0100f0c:	8b 1d 40 82 23 f0    	mov    0xf0238240,%ebx
	if (ret == NULL)
f0100f12:	85 db                	test   %ebx,%ebx
f0100f14:	74 13                	je     f0100f29 <page_alloc+0x28>
	page_free_list = ret->pp_link;
f0100f16:	8b 03                	mov    (%ebx),%eax
f0100f18:	a3 40 82 23 f0       	mov    %eax,0xf0238240
	ret->pp_link = NULL;
f0100f1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO)
f0100f23:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100f27:	75 07                	jne    f0100f30 <page_alloc+0x2f>
}
f0100f29:	89 d8                	mov    %ebx,%eax
f0100f2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f2e:	c9                   	leave  
f0100f2f:	c3                   	ret    
	return (pp - pages) << PGSHIFT;
f0100f30:	89 d8                	mov    %ebx,%eax
f0100f32:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0100f38:	c1 f8 03             	sar    $0x3,%eax
f0100f3b:	89 c2                	mov    %eax,%edx
f0100f3d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0100f40:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0100f45:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0100f4b:	73 1b                	jae    f0100f68 <page_alloc+0x67>
		memset(page2kva(ret), 0, PGSIZE);
f0100f4d:	83 ec 04             	sub    $0x4,%esp
f0100f50:	68 00 10 00 00       	push   $0x1000
f0100f55:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100f57:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0100f5d:	52                   	push   %edx
f0100f5e:	e8 ec 4b 00 00       	call   f0105b4f <memset>
f0100f63:	83 c4 10             	add    $0x10,%esp
f0100f66:	eb c1                	jmp    f0100f29 <page_alloc+0x28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f68:	52                   	push   %edx
f0100f69:	68 04 68 10 f0       	push   $0xf0106804
f0100f6e:	6a 58                	push   $0x58
f0100f70:	68 51 77 10 f0       	push   $0xf0107751
f0100f75:	e8 c6 f0 ff ff       	call   f0100040 <_panic>

f0100f7a <page_free>:
{
f0100f7a:	f3 0f 1e fb          	endbr32 
f0100f7e:	55                   	push   %ebp
f0100f7f:	89 e5                	mov    %esp,%ebp
f0100f81:	83 ec 08             	sub    $0x8,%esp
f0100f84:	8b 45 08             	mov    0x8(%ebp),%eax
	if (pp->pp_ref != 0 || pp->pp_link != NULL)
f0100f87:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f8c:	75 14                	jne    f0100fa2 <page_free+0x28>
f0100f8e:	83 38 00             	cmpl   $0x0,(%eax)
f0100f91:	75 0f                	jne    f0100fa2 <page_free+0x28>
	pp->pp_link = page_free_list;
f0100f93:	8b 15 40 82 23 f0    	mov    0xf0238240,%edx
f0100f99:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f9b:	a3 40 82 23 f0       	mov    %eax,0xf0238240
}
f0100fa0:	c9                   	leave  
f0100fa1:	c3                   	ret    
		panic("page_free: pp->pp_ref is nonzero or pp->pp_link is not NULL\n");
f0100fa2:	83 ec 04             	sub    $0x4,%esp
f0100fa5:	68 44 6e 10 f0       	push   $0xf0106e44
f0100faa:	68 81 01 00 00       	push   $0x181
f0100faf:	68 45 77 10 f0       	push   $0xf0107745
f0100fb4:	e8 87 f0 ff ff       	call   f0100040 <_panic>

f0100fb9 <page_decref>:
{
f0100fb9:	f3 0f 1e fb          	endbr32 
f0100fbd:	55                   	push   %ebp
f0100fbe:	89 e5                	mov    %esp,%ebp
f0100fc0:	83 ec 08             	sub    $0x8,%esp
f0100fc3:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100fc6:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100fca:	83 e8 01             	sub    $0x1,%eax
f0100fcd:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100fd1:	66 85 c0             	test   %ax,%ax
f0100fd4:	74 02                	je     f0100fd8 <page_decref+0x1f>
}
f0100fd6:	c9                   	leave  
f0100fd7:	c3                   	ret    
		page_free(pp);
f0100fd8:	83 ec 0c             	sub    $0xc,%esp
f0100fdb:	52                   	push   %edx
f0100fdc:	e8 99 ff ff ff       	call   f0100f7a <page_free>
f0100fe1:	83 c4 10             	add    $0x10,%esp
}
f0100fe4:	eb f0                	jmp    f0100fd6 <page_decref+0x1d>

f0100fe6 <pgdir_walk>:
{
f0100fe6:	f3 0f 1e fb          	endbr32 
f0100fea:	55                   	push   %ebp
f0100feb:	89 e5                	mov    %esp,%ebp
f0100fed:	56                   	push   %esi
f0100fee:	53                   	push   %ebx
f0100fef:	8b 75 0c             	mov    0xc(%ebp),%esi
	pde_t *pde = &pgdir[PDX(va)];
f0100ff2:	89 f3                	mov    %esi,%ebx
f0100ff4:	c1 eb 16             	shr    $0x16,%ebx
f0100ff7:	c1 e3 02             	shl    $0x2,%ebx
f0100ffa:	03 5d 08             	add    0x8(%ebp),%ebx
	if (!(*pde & PTE_P))
f0100ffd:	f6 03 01             	testb  $0x1,(%ebx)
f0101000:	75 2d                	jne    f010102f <pgdir_walk+0x49>
		if (!create)
f0101002:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0101006:	74 68                	je     f0101070 <pgdir_walk+0x8a>
		if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f0101008:	83 ec 0c             	sub    $0xc,%esp
f010100b:	6a 01                	push   $0x1
f010100d:	e8 ef fe ff ff       	call   f0100f01 <page_alloc>
f0101012:	83 c4 10             	add    $0x10,%esp
f0101015:	85 c0                	test   %eax,%eax
f0101017:	74 3b                	je     f0101054 <pgdir_walk+0x6e>
		pp->pp_ref++;
f0101019:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010101e:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101024:	c1 f8 03             	sar    $0x3,%eax
f0101027:	c1 e0 0c             	shl    $0xc,%eax
		*pde = page2pa(pp) | PTE_P | PTE_W | PTE_U;
f010102a:	83 c8 07             	or     $0x7,%eax
f010102d:	89 03                	mov    %eax,(%ebx)
	pt_addr = KADDR(PTE_ADDR(*pde));
f010102f:	8b 03                	mov    (%ebx),%eax
f0101031:	89 c2                	mov    %eax,%edx
f0101033:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101039:	c1 e8 0c             	shr    $0xc,%eax
f010103c:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0101042:	73 17                	jae    f010105b <pgdir_walk+0x75>
	return (pte_t *)(pt_addr + PTX(va));
f0101044:	c1 ee 0a             	shr    $0xa,%esi
f0101047:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
f010104d:	8d 84 32 00 00 00 f0 	lea    -0x10000000(%edx,%esi,1),%eax
}
f0101054:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101057:	5b                   	pop    %ebx
f0101058:	5e                   	pop    %esi
f0101059:	5d                   	pop    %ebp
f010105a:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010105b:	52                   	push   %edx
f010105c:	68 04 68 10 f0       	push   $0xf0106804
f0101061:	68 be 01 00 00       	push   $0x1be
f0101066:	68 45 77 10 f0       	push   $0xf0107745
f010106b:	e8 d0 ef ff ff       	call   f0100040 <_panic>
			return NULL;
f0101070:	b8 00 00 00 00       	mov    $0x0,%eax
f0101075:	eb dd                	jmp    f0101054 <pgdir_walk+0x6e>

f0101077 <boot_map_region>:
{
f0101077:	55                   	push   %ebp
f0101078:	89 e5                	mov    %esp,%ebp
f010107a:	57                   	push   %edi
f010107b:	56                   	push   %esi
f010107c:	53                   	push   %ebx
f010107d:	83 ec 1c             	sub    $0x1c,%esp
f0101080:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101083:	8b 45 08             	mov    0x8(%ebp),%eax
	size_t pgs = size / PGSIZE;
f0101086:	89 cb                	mov    %ecx,%ebx
f0101088:	c1 eb 0c             	shr    $0xc,%ebx
	if (size % PGSIZE != 0)
f010108b:	81 e1 ff 0f 00 00    	and    $0xfff,%ecx
		pgs++;
f0101091:	83 f9 01             	cmp    $0x1,%ecx
f0101094:	83 db ff             	sbb    $0xffffffff,%ebx
f0101097:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
	for (int i = 0; i < pgs; i++)
f010109a:	89 c3                	mov    %eax,%ebx
f010109c:	be 00 00 00 00       	mov    $0x0,%esi
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010a1:	89 d7                	mov    %edx,%edi
f01010a3:	29 c7                	sub    %eax,%edi
	for (int i = 0; i < pgs; i++)
f01010a5:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
f01010a8:	74 44                	je     f01010ee <boot_map_region+0x77>
		pte_t *pte = pgdir_walk(pgdir, (void *)va, 1);
f01010aa:	83 ec 04             	sub    $0x4,%esp
f01010ad:	6a 01                	push   $0x1
f01010af:	8d 04 1f             	lea    (%edi,%ebx,1),%eax
f01010b2:	50                   	push   %eax
f01010b3:	ff 75 e0             	pushl  -0x20(%ebp)
f01010b6:	e8 2b ff ff ff       	call   f0100fe6 <pgdir_walk>
		if (pte == NULL)
f01010bb:	83 c4 10             	add    $0x10,%esp
f01010be:	85 c0                	test   %eax,%eax
f01010c0:	74 15                	je     f01010d7 <boot_map_region+0x60>
		*pte = pa | PTE_P | perm;
f01010c2:	89 da                	mov    %ebx,%edx
f01010c4:	0b 55 0c             	or     0xc(%ebp),%edx
f01010c7:	83 ca 01             	or     $0x1,%edx
f01010ca:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f01010cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (int i = 0; i < pgs; i++)
f01010d2:	83 c6 01             	add    $0x1,%esi
f01010d5:	eb ce                	jmp    f01010a5 <boot_map_region+0x2e>
			panic("boot_map_region(): out of memory\n");
f01010d7:	83 ec 04             	sub    $0x4,%esp
f01010da:	68 84 6e 10 f0       	push   $0xf0106e84
f01010df:	68 db 01 00 00       	push   $0x1db
f01010e4:	68 45 77 10 f0       	push   $0xf0107745
f01010e9:	e8 52 ef ff ff       	call   f0100040 <_panic>
}
f01010ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01010f1:	5b                   	pop    %ebx
f01010f2:	5e                   	pop    %esi
f01010f3:	5f                   	pop    %edi
f01010f4:	5d                   	pop    %ebp
f01010f5:	c3                   	ret    

f01010f6 <page_lookup>:
{
f01010f6:	f3 0f 1e fb          	endbr32 
f01010fa:	55                   	push   %ebp
f01010fb:	89 e5                	mov    %esp,%ebp
f01010fd:	53                   	push   %ebx
f01010fe:	83 ec 08             	sub    $0x8,%esp
f0101101:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f0101104:	6a 00                	push   $0x0
f0101106:	ff 75 0c             	pushl  0xc(%ebp)
f0101109:	ff 75 08             	pushl  0x8(%ebp)
f010110c:	e8 d5 fe ff ff       	call   f0100fe6 <pgdir_walk>
	if (pte == NULL)
f0101111:	83 c4 10             	add    $0x10,%esp
f0101114:	85 c0                	test   %eax,%eax
f0101116:	74 3b                	je     f0101153 <page_lookup+0x5d>
	if (!(*pte) & PTE_P)
f0101118:	8b 10                	mov    (%eax),%edx
f010111a:	85 d2                	test   %edx,%edx
f010111c:	74 39                	je     f0101157 <page_lookup+0x61>
f010111e:	c1 ea 0c             	shr    $0xc,%edx
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101121:	39 15 88 8e 23 f0    	cmp    %edx,0xf0238e88
f0101127:	76 16                	jbe    f010113f <page_lookup+0x49>
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f0101129:	8b 0d 90 8e 23 f0    	mov    0xf0238e90,%ecx
f010112f:	8d 14 d1             	lea    (%ecx,%edx,8),%edx
	if (pte_store != NULL)
f0101132:	85 db                	test   %ebx,%ebx
f0101134:	74 02                	je     f0101138 <page_lookup+0x42>
		*pte_store = pte;
f0101136:	89 03                	mov    %eax,(%ebx)
}
f0101138:	89 d0                	mov    %edx,%eax
f010113a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010113d:	c9                   	leave  
f010113e:	c3                   	ret    
		panic("pa2page called with invalid pa");
f010113f:	83 ec 04             	sub    $0x4,%esp
f0101142:	68 a8 6e 10 f0       	push   $0xf0106ea8
f0101147:	6a 51                	push   $0x51
f0101149:	68 51 77 10 f0       	push   $0xf0107751
f010114e:	e8 ed ee ff ff       	call   f0100040 <_panic>
		return NULL;
f0101153:	89 c2                	mov    %eax,%edx
f0101155:	eb e1                	jmp    f0101138 <page_lookup+0x42>
		return NULL;
f0101157:	ba 00 00 00 00       	mov    $0x0,%edx
f010115c:	eb da                	jmp    f0101138 <page_lookup+0x42>

f010115e <tlb_invalidate>:
{
f010115e:	f3 0f 1e fb          	endbr32 
f0101162:	55                   	push   %ebp
f0101163:	89 e5                	mov    %esp,%ebp
f0101165:	83 ec 08             	sub    $0x8,%esp
	if (!curenv || curenv->env_pgdir == pgdir)
f0101168:	e8 01 50 00 00       	call   f010616e <cpunum>
f010116d:	6b c0 74             	imul   $0x74,%eax,%eax
f0101170:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0101177:	74 16                	je     f010118f <tlb_invalidate+0x31>
f0101179:	e8 f0 4f 00 00       	call   f010616e <cpunum>
f010117e:	6b c0 74             	imul   $0x74,%eax,%eax
f0101181:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0101187:	8b 55 08             	mov    0x8(%ebp),%edx
f010118a:	39 50 60             	cmp    %edx,0x60(%eax)
f010118d:	75 06                	jne    f0101195 <tlb_invalidate+0x37>
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010118f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101192:	0f 01 38             	invlpg (%eax)
}
f0101195:	c9                   	leave  
f0101196:	c3                   	ret    

f0101197 <page_remove>:
{
f0101197:	f3 0f 1e fb          	endbr32 
f010119b:	55                   	push   %ebp
f010119c:	89 e5                	mov    %esp,%ebp
f010119e:	56                   	push   %esi
f010119f:	53                   	push   %ebx
f01011a0:	83 ec 14             	sub    $0x14,%esp
f01011a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01011a6:	8b 75 0c             	mov    0xc(%ebp),%esi
	struct PageInfo *pp = page_lookup(pgdir, va, &pte_store);
f01011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01011ac:	50                   	push   %eax
f01011ad:	56                   	push   %esi
f01011ae:	53                   	push   %ebx
f01011af:	e8 42 ff ff ff       	call   f01010f6 <page_lookup>
	if (pp == NULL)
f01011b4:	83 c4 10             	add    $0x10,%esp
f01011b7:	85 c0                	test   %eax,%eax
f01011b9:	74 1f                	je     f01011da <page_remove+0x43>
	page_decref(pp);
f01011bb:	83 ec 0c             	sub    $0xc,%esp
f01011be:	50                   	push   %eax
f01011bf:	e8 f5 fd ff ff       	call   f0100fb9 <page_decref>
	*pte_store = 0;
f01011c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va);
f01011cd:	83 c4 08             	add    $0x8,%esp
f01011d0:	56                   	push   %esi
f01011d1:	53                   	push   %ebx
f01011d2:	e8 87 ff ff ff       	call   f010115e <tlb_invalidate>
f01011d7:	83 c4 10             	add    $0x10,%esp
}
f01011da:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01011dd:	5b                   	pop    %ebx
f01011de:	5e                   	pop    %esi
f01011df:	5d                   	pop    %ebp
f01011e0:	c3                   	ret    

f01011e1 <page_insert>:
{
f01011e1:	f3 0f 1e fb          	endbr32 
f01011e5:	55                   	push   %ebp
f01011e6:	89 e5                	mov    %esp,%ebp
f01011e8:	57                   	push   %edi
f01011e9:	56                   	push   %esi
f01011ea:	53                   	push   %ebx
f01011eb:	83 ec 10             	sub    $0x10,%esp
f01011ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01011f1:	8b 7d 10             	mov    0x10(%ebp),%edi
	if ((pte = pgdir_walk(pgdir, va, 1)) == NULL)
f01011f4:	6a 01                	push   $0x1
f01011f6:	57                   	push   %edi
f01011f7:	ff 75 08             	pushl  0x8(%ebp)
f01011fa:	e8 e7 fd ff ff       	call   f0100fe6 <pgdir_walk>
f01011ff:	83 c4 10             	add    $0x10,%esp
f0101202:	85 c0                	test   %eax,%eax
f0101204:	74 3e                	je     f0101244 <page_insert+0x63>
f0101206:	89 c6                	mov    %eax,%esi
	pp->pp_ref++;
f0101208:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
	if (*pte & PTE_P)
f010120d:	f6 00 01             	testb  $0x1,(%eax)
f0101210:	75 21                	jne    f0101233 <page_insert+0x52>
	return (pp - pages) << PGSHIFT;
f0101212:	2b 1d 90 8e 23 f0    	sub    0xf0238e90,%ebx
f0101218:	c1 fb 03             	sar    $0x3,%ebx
f010121b:	c1 e3 0c             	shl    $0xc,%ebx
	*pte = page2pa(pp) | perm | PTE_P;
f010121e:	0b 5d 14             	or     0x14(%ebp),%ebx
f0101221:	83 cb 01             	or     $0x1,%ebx
f0101224:	89 1e                	mov    %ebx,(%esi)
	return 0;
f0101226:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010122b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010122e:	5b                   	pop    %ebx
f010122f:	5e                   	pop    %esi
f0101230:	5f                   	pop    %edi
f0101231:	5d                   	pop    %ebp
f0101232:	c3                   	ret    
		page_remove(pgdir, va);
f0101233:	83 ec 08             	sub    $0x8,%esp
f0101236:	57                   	push   %edi
f0101237:	ff 75 08             	pushl  0x8(%ebp)
f010123a:	e8 58 ff ff ff       	call   f0101197 <page_remove>
f010123f:	83 c4 10             	add    $0x10,%esp
f0101242:	eb ce                	jmp    f0101212 <page_insert+0x31>
		return -E_NO_MEM;
f0101244:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f0101249:	eb e0                	jmp    f010122b <page_insert+0x4a>

f010124b <mmio_map_region>:
{
f010124b:	f3 0f 1e fb          	endbr32 
f010124f:	55                   	push   %ebp
f0101250:	89 e5                	mov    %esp,%ebp
f0101252:	57                   	push   %edi
f0101253:	56                   	push   %esi
f0101254:	53                   	push   %ebx
f0101255:	83 ec 0c             	sub    $0xc,%esp
f0101258:	8b 5d 08             	mov    0x8(%ebp),%ebx
	size = ROUNDUP(pa + size, PGSIZE);
f010125b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010125e:	8d bc 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%edi
f0101265:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	pa = ROUNDDOWN(pa, PGSIZE);
f010126b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	size -= pa;
f0101271:	89 fe                	mov    %edi,%esi
f0101273:	29 de                	sub    %ebx,%esi
	if (base + size >= MMIOLIM)
f0101275:	8b 15 00 33 12 f0    	mov    0xf0123300,%edx
f010127b:	8d 04 32             	lea    (%edx,%esi,1),%eax
f010127e:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101283:	77 2b                	ja     f01012b0 <mmio_map_region+0x65>
	boot_map_region(kern_pgdir, base, size, pa, PTE_PCD | PTE_PWT | PTE_W);
f0101285:	83 ec 08             	sub    $0x8,%esp
f0101288:	6a 1a                	push   $0x1a
f010128a:	53                   	push   %ebx
f010128b:	89 f1                	mov    %esi,%ecx
f010128d:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0101292:	e8 e0 fd ff ff       	call   f0101077 <boot_map_region>
	base += size;
f0101297:	89 f0                	mov    %esi,%eax
f0101299:	03 05 00 33 12 f0    	add    0xf0123300,%eax
f010129f:	a3 00 33 12 f0       	mov    %eax,0xf0123300
	return (void *)(base - size);
f01012a4:	29 fb                	sub    %edi,%ebx
f01012a6:	01 d8                	add    %ebx,%eax
}
f01012a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012ab:	5b                   	pop    %ebx
f01012ac:	5e                   	pop    %esi
f01012ad:	5f                   	pop    %edi
f01012ae:	5d                   	pop    %ebp
f01012af:	c3                   	ret    
		panic("not enough memory");
f01012b0:	83 ec 04             	sub    $0x4,%esp
f01012b3:	68 18 78 10 f0       	push   $0xf0107818
f01012b8:	68 7d 02 00 00       	push   $0x27d
f01012bd:	68 45 77 10 f0       	push   $0xf0107745
f01012c2:	e8 79 ed ff ff       	call   f0100040 <_panic>

f01012c7 <mem_init>:
{
f01012c7:	f3 0f 1e fb          	endbr32 
f01012cb:	55                   	push   %ebp
f01012cc:	89 e5                	mov    %esp,%ebp
f01012ce:	57                   	push   %edi
f01012cf:	56                   	push   %esi
f01012d0:	53                   	push   %ebx
f01012d1:	83 ec 3c             	sub    $0x3c,%esp
	basemem = nvram_read(NVRAM_BASELO);
f01012d4:	b8 15 00 00 00       	mov    $0x15,%eax
f01012d9:	e8 c2 f7 ff ff       	call   f0100aa0 <nvram_read>
f01012de:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01012e0:	b8 17 00 00 00       	mov    $0x17,%eax
f01012e5:	e8 b6 f7 ff ff       	call   f0100aa0 <nvram_read>
f01012ea:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01012ec:	b8 34 00 00 00       	mov    $0x34,%eax
f01012f1:	e8 aa f7 ff ff       	call   f0100aa0 <nvram_read>
	if (ext16mem)
f01012f6:	c1 e0 06             	shl    $0x6,%eax
f01012f9:	0f 84 df 00 00 00    	je     f01013de <mem_init+0x117>
		totalmem = 16 * 1024 + ext16mem;
f01012ff:	05 00 40 00 00       	add    $0x4000,%eax
	npages = totalmem / (PGSIZE / 1024);
f0101304:	89 c2                	mov    %eax,%edx
f0101306:	c1 ea 02             	shr    $0x2,%edx
f0101309:	89 15 88 8e 23 f0    	mov    %edx,0xf0238e88
	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010130f:	89 c2                	mov    %eax,%edx
f0101311:	29 da                	sub    %ebx,%edx
f0101313:	52                   	push   %edx
f0101314:	53                   	push   %ebx
f0101315:	50                   	push   %eax
f0101316:	68 c8 6e 10 f0       	push   $0xf0106ec8
f010131b:	e8 91 25 00 00       	call   f01038b1 <cprintf>
	kern_pgdir = (pde_t *)boot_alloc(PGSIZE);
f0101320:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101325:	e8 40 f7 ff ff       	call   f0100a6a <boot_alloc>
f010132a:	a3 8c 8e 23 f0       	mov    %eax,0xf0238e8c
	memset(kern_pgdir, 0, PGSIZE);
f010132f:	83 c4 0c             	add    $0xc,%esp
f0101332:	68 00 10 00 00       	push   $0x1000
f0101337:	6a 00                	push   $0x0
f0101339:	50                   	push   %eax
f010133a:	e8 10 48 00 00       	call   f0105b4f <memset>
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010133f:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0101344:	83 c4 10             	add    $0x10,%esp
f0101347:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010134c:	0f 86 9c 00 00 00    	jbe    f01013ee <mem_init+0x127>
	return (physaddr_t)kva - KERNBASE;
f0101352:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101358:	83 ca 05             	or     $0x5,%edx
f010135b:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	pages = (struct PageInfo *)boot_alloc(sizeof(struct PageInfo) * npages);
f0101361:	a1 88 8e 23 f0       	mov    0xf0238e88,%eax
f0101366:	c1 e0 03             	shl    $0x3,%eax
f0101369:	e8 fc f6 ff ff       	call   f0100a6a <boot_alloc>
f010136e:	a3 90 8e 23 f0       	mov    %eax,0xf0238e90
	memset(pages, 0, sizeof(struct PageInfo) * npages);
f0101373:	83 ec 04             	sub    $0x4,%esp
f0101376:	8b 0d 88 8e 23 f0    	mov    0xf0238e88,%ecx
f010137c:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101383:	52                   	push   %edx
f0101384:	6a 00                	push   $0x0
f0101386:	50                   	push   %eax
f0101387:	e8 c3 47 00 00       	call   f0105b4f <memset>
	envs = (struct Env *)boot_alloc(sizeof(struct Env) * NENV);
f010138c:	b8 00 10 02 00       	mov    $0x21000,%eax
f0101391:	e8 d4 f6 ff ff       	call   f0100a6a <boot_alloc>
f0101396:	a3 44 82 23 f0       	mov    %eax,0xf0238244
	memset(envs, 0, sizeof(struct Env) * NENV);
f010139b:	83 c4 0c             	add    $0xc,%esp
f010139e:	68 00 10 02 00       	push   $0x21000
f01013a3:	6a 00                	push   $0x0
f01013a5:	50                   	push   %eax
f01013a6:	e8 a4 47 00 00       	call   f0105b4f <memset>
	page_init();
f01013ab:	e8 6a fa ff ff       	call   f0100e1a <page_init>
	check_page_free_list(1);
f01013b0:	b8 01 00 00 00       	mov    $0x1,%eax
f01013b5:	e8 72 f7 ff ff       	call   f0100b2c <check_page_free_list>
	if (!pages)
f01013ba:	83 c4 10             	add    $0x10,%esp
f01013bd:	83 3d 90 8e 23 f0 00 	cmpl   $0x0,0xf0238e90
f01013c4:	74 3d                	je     f0101403 <mem_init+0x13c>
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013c6:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f01013cb:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
f01013d2:	85 c0                	test   %eax,%eax
f01013d4:	74 44                	je     f010141a <mem_init+0x153>
		++nfree;
f01013d6:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01013da:	8b 00                	mov    (%eax),%eax
f01013dc:	eb f4                	jmp    f01013d2 <mem_init+0x10b>
		totalmem = 1 * 1024 + extmem;
f01013de:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01013e4:	85 f6                	test   %esi,%esi
f01013e6:	0f 44 c3             	cmove  %ebx,%eax
f01013e9:	e9 16 ff ff ff       	jmp    f0101304 <mem_init+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01013ee:	50                   	push   %eax
f01013ef:	68 28 68 10 f0       	push   $0xf0106828
f01013f4:	68 90 00 00 00       	push   $0x90
f01013f9:	68 45 77 10 f0       	push   $0xf0107745
f01013fe:	e8 3d ec ff ff       	call   f0100040 <_panic>
		panic("'pages' is a null pointer!");
f0101403:	83 ec 04             	sub    $0x4,%esp
f0101406:	68 2a 78 10 f0       	push   $0xf010782a
f010140b:	68 11 03 00 00       	push   $0x311
f0101410:	68 45 77 10 f0       	push   $0xf0107745
f0101415:	e8 26 ec ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010141a:	83 ec 0c             	sub    $0xc,%esp
f010141d:	6a 00                	push   $0x0
f010141f:	e8 dd fa ff ff       	call   f0100f01 <page_alloc>
f0101424:	89 c3                	mov    %eax,%ebx
f0101426:	83 c4 10             	add    $0x10,%esp
f0101429:	85 c0                	test   %eax,%eax
f010142b:	0f 84 11 02 00 00    	je     f0101642 <mem_init+0x37b>
	assert((pp1 = page_alloc(0)));
f0101431:	83 ec 0c             	sub    $0xc,%esp
f0101434:	6a 00                	push   $0x0
f0101436:	e8 c6 fa ff ff       	call   f0100f01 <page_alloc>
f010143b:	89 c6                	mov    %eax,%esi
f010143d:	83 c4 10             	add    $0x10,%esp
f0101440:	85 c0                	test   %eax,%eax
f0101442:	0f 84 13 02 00 00    	je     f010165b <mem_init+0x394>
	assert((pp2 = page_alloc(0)));
f0101448:	83 ec 0c             	sub    $0xc,%esp
f010144b:	6a 00                	push   $0x0
f010144d:	e8 af fa ff ff       	call   f0100f01 <page_alloc>
f0101452:	89 c7                	mov    %eax,%edi
f0101454:	83 c4 10             	add    $0x10,%esp
f0101457:	85 c0                	test   %eax,%eax
f0101459:	0f 84 15 02 00 00    	je     f0101674 <mem_init+0x3ad>
	assert(pp1 && pp1 != pp0);
f010145f:	39 f3                	cmp    %esi,%ebx
f0101461:	0f 84 26 02 00 00    	je     f010168d <mem_init+0x3c6>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101467:	39 c3                	cmp    %eax,%ebx
f0101469:	0f 84 37 02 00 00    	je     f01016a6 <mem_init+0x3df>
f010146f:	39 c6                	cmp    %eax,%esi
f0101471:	0f 84 2f 02 00 00    	je     f01016a6 <mem_init+0x3df>
	return (pp - pages) << PGSHIFT;
f0101477:	8b 0d 90 8e 23 f0    	mov    0xf0238e90,%ecx
	assert(page2pa(pp0) < npages * PGSIZE);
f010147d:	8b 15 88 8e 23 f0    	mov    0xf0238e88,%edx
f0101483:	c1 e2 0c             	shl    $0xc,%edx
f0101486:	89 d8                	mov    %ebx,%eax
f0101488:	29 c8                	sub    %ecx,%eax
f010148a:	c1 f8 03             	sar    $0x3,%eax
f010148d:	c1 e0 0c             	shl    $0xc,%eax
f0101490:	39 d0                	cmp    %edx,%eax
f0101492:	0f 83 27 02 00 00    	jae    f01016bf <mem_init+0x3f8>
f0101498:	89 f0                	mov    %esi,%eax
f010149a:	29 c8                	sub    %ecx,%eax
f010149c:	c1 f8 03             	sar    $0x3,%eax
f010149f:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages * PGSIZE);
f01014a2:	39 c2                	cmp    %eax,%edx
f01014a4:	0f 86 2e 02 00 00    	jbe    f01016d8 <mem_init+0x411>
f01014aa:	89 f8                	mov    %edi,%eax
f01014ac:	29 c8                	sub    %ecx,%eax
f01014ae:	c1 f8 03             	sar    $0x3,%eax
f01014b1:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages * PGSIZE);
f01014b4:	39 c2                	cmp    %eax,%edx
f01014b6:	0f 86 35 02 00 00    	jbe    f01016f1 <mem_init+0x42a>
	fl = page_free_list;
f01014bc:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f01014c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014c4:	c7 05 40 82 23 f0 00 	movl   $0x0,0xf0238240
f01014cb:	00 00 00 
	assert(!page_alloc(0));
f01014ce:	83 ec 0c             	sub    $0xc,%esp
f01014d1:	6a 00                	push   $0x0
f01014d3:	e8 29 fa ff ff       	call   f0100f01 <page_alloc>
f01014d8:	83 c4 10             	add    $0x10,%esp
f01014db:	85 c0                	test   %eax,%eax
f01014dd:	0f 85 27 02 00 00    	jne    f010170a <mem_init+0x443>
	page_free(pp0);
f01014e3:	83 ec 0c             	sub    $0xc,%esp
f01014e6:	53                   	push   %ebx
f01014e7:	e8 8e fa ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f01014ec:	89 34 24             	mov    %esi,(%esp)
f01014ef:	e8 86 fa ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f01014f4:	89 3c 24             	mov    %edi,(%esp)
f01014f7:	e8 7e fa ff ff       	call   f0100f7a <page_free>
	assert((pp0 = page_alloc(0)));
f01014fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101503:	e8 f9 f9 ff ff       	call   f0100f01 <page_alloc>
f0101508:	89 c3                	mov    %eax,%ebx
f010150a:	83 c4 10             	add    $0x10,%esp
f010150d:	85 c0                	test   %eax,%eax
f010150f:	0f 84 0e 02 00 00    	je     f0101723 <mem_init+0x45c>
	assert((pp1 = page_alloc(0)));
f0101515:	83 ec 0c             	sub    $0xc,%esp
f0101518:	6a 00                	push   $0x0
f010151a:	e8 e2 f9 ff ff       	call   f0100f01 <page_alloc>
f010151f:	89 c6                	mov    %eax,%esi
f0101521:	83 c4 10             	add    $0x10,%esp
f0101524:	85 c0                	test   %eax,%eax
f0101526:	0f 84 10 02 00 00    	je     f010173c <mem_init+0x475>
	assert((pp2 = page_alloc(0)));
f010152c:	83 ec 0c             	sub    $0xc,%esp
f010152f:	6a 00                	push   $0x0
f0101531:	e8 cb f9 ff ff       	call   f0100f01 <page_alloc>
f0101536:	89 c7                	mov    %eax,%edi
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	0f 84 12 02 00 00    	je     f0101755 <mem_init+0x48e>
	assert(pp1 && pp1 != pp0);
f0101543:	39 f3                	cmp    %esi,%ebx
f0101545:	0f 84 23 02 00 00    	je     f010176e <mem_init+0x4a7>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010154b:	39 c6                	cmp    %eax,%esi
f010154d:	0f 84 34 02 00 00    	je     f0101787 <mem_init+0x4c0>
f0101553:	39 c3                	cmp    %eax,%ebx
f0101555:	0f 84 2c 02 00 00    	je     f0101787 <mem_init+0x4c0>
	assert(!page_alloc(0));
f010155b:	83 ec 0c             	sub    $0xc,%esp
f010155e:	6a 00                	push   $0x0
f0101560:	e8 9c f9 ff ff       	call   f0100f01 <page_alloc>
f0101565:	83 c4 10             	add    $0x10,%esp
f0101568:	85 c0                	test   %eax,%eax
f010156a:	0f 85 30 02 00 00    	jne    f01017a0 <mem_init+0x4d9>
f0101570:	89 d8                	mov    %ebx,%eax
f0101572:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101578:	c1 f8 03             	sar    $0x3,%eax
f010157b:	89 c2                	mov    %eax,%edx
f010157d:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101580:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101585:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f010158b:	0f 83 28 02 00 00    	jae    f01017b9 <mem_init+0x4f2>
	memset(page2kva(pp0), 1, PGSIZE);
f0101591:	83 ec 04             	sub    $0x4,%esp
f0101594:	68 00 10 00 00       	push   $0x1000
f0101599:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f010159b:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f01015a1:	52                   	push   %edx
f01015a2:	e8 a8 45 00 00       	call   f0105b4f <memset>
	page_free(pp0);
f01015a7:	89 1c 24             	mov    %ebx,(%esp)
f01015aa:	e8 cb f9 ff ff       	call   f0100f7a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015af:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015b6:	e8 46 f9 ff ff       	call   f0100f01 <page_alloc>
f01015bb:	83 c4 10             	add    $0x10,%esp
f01015be:	85 c0                	test   %eax,%eax
f01015c0:	0f 84 05 02 00 00    	je     f01017cb <mem_init+0x504>
	assert(pp && pp0 == pp);
f01015c6:	39 c3                	cmp    %eax,%ebx
f01015c8:	0f 85 16 02 00 00    	jne    f01017e4 <mem_init+0x51d>
	return (pp - pages) << PGSHIFT;
f01015ce:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f01015d4:	c1 f8 03             	sar    $0x3,%eax
f01015d7:	89 c2                	mov    %eax,%edx
f01015d9:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f01015dc:	25 ff ff 0f 00       	and    $0xfffff,%eax
f01015e1:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f01015e7:	0f 83 10 02 00 00    	jae    f01017fd <mem_init+0x536>
	return (void *)(pa + KERNBASE);
f01015ed:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f01015f3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
		assert(c[i] == 0);
f01015f9:	80 38 00             	cmpb   $0x0,(%eax)
f01015fc:	0f 85 0d 02 00 00    	jne    f010180f <mem_init+0x548>
f0101602:	83 c0 01             	add    $0x1,%eax
	for (i = 0; i < PGSIZE; i++)
f0101605:	39 d0                	cmp    %edx,%eax
f0101607:	75 f0                	jne    f01015f9 <mem_init+0x332>
	page_free_list = fl;
f0101609:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010160c:	a3 40 82 23 f0       	mov    %eax,0xf0238240
	page_free(pp0);
f0101611:	83 ec 0c             	sub    $0xc,%esp
f0101614:	53                   	push   %ebx
f0101615:	e8 60 f9 ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f010161a:	89 34 24             	mov    %esi,(%esp)
f010161d:	e8 58 f9 ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f0101622:	89 3c 24             	mov    %edi,(%esp)
f0101625:	e8 50 f9 ff ff       	call   f0100f7a <page_free>
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010162a:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f010162f:	83 c4 10             	add    $0x10,%esp
f0101632:	85 c0                	test   %eax,%eax
f0101634:	0f 84 ee 01 00 00    	je     f0101828 <mem_init+0x561>
		--nfree;
f010163a:	83 6d d4 01          	subl   $0x1,-0x2c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010163e:	8b 00                	mov    (%eax),%eax
f0101640:	eb f0                	jmp    f0101632 <mem_init+0x36b>
	assert((pp0 = page_alloc(0)));
f0101642:	68 45 78 10 f0       	push   $0xf0107845
f0101647:	68 6b 77 10 f0       	push   $0xf010776b
f010164c:	68 19 03 00 00       	push   $0x319
f0101651:	68 45 77 10 f0       	push   $0xf0107745
f0101656:	e8 e5 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010165b:	68 5b 78 10 f0       	push   $0xf010785b
f0101660:	68 6b 77 10 f0       	push   $0xf010776b
f0101665:	68 1a 03 00 00       	push   $0x31a
f010166a:	68 45 77 10 f0       	push   $0xf0107745
f010166f:	e8 cc e9 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101674:	68 71 78 10 f0       	push   $0xf0107871
f0101679:	68 6b 77 10 f0       	push   $0xf010776b
f010167e:	68 1b 03 00 00       	push   $0x31b
f0101683:	68 45 77 10 f0       	push   $0xf0107745
f0101688:	e8 b3 e9 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010168d:	68 87 78 10 f0       	push   $0xf0107887
f0101692:	68 6b 77 10 f0       	push   $0xf010776b
f0101697:	68 1e 03 00 00       	push   $0x31e
f010169c:	68 45 77 10 f0       	push   $0xf0107745
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01016a6:	68 04 6f 10 f0       	push   $0xf0106f04
f01016ab:	68 6b 77 10 f0       	push   $0xf010776b
f01016b0:	68 1f 03 00 00       	push   $0x31f
f01016b5:	68 45 77 10 f0       	push   $0xf0107745
f01016ba:	e8 81 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp0) < npages * PGSIZE);
f01016bf:	68 24 6f 10 f0       	push   $0xf0106f24
f01016c4:	68 6b 77 10 f0       	push   $0xf010776b
f01016c9:	68 20 03 00 00       	push   $0x320
f01016ce:	68 45 77 10 f0       	push   $0xf0107745
f01016d3:	e8 68 e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages * PGSIZE);
f01016d8:	68 44 6f 10 f0       	push   $0xf0106f44
f01016dd:	68 6b 77 10 f0       	push   $0xf010776b
f01016e2:	68 21 03 00 00       	push   $0x321
f01016e7:	68 45 77 10 f0       	push   $0xf0107745
f01016ec:	e8 4f e9 ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages * PGSIZE);
f01016f1:	68 64 6f 10 f0       	push   $0xf0106f64
f01016f6:	68 6b 77 10 f0       	push   $0xf010776b
f01016fb:	68 22 03 00 00       	push   $0x322
f0101700:	68 45 77 10 f0       	push   $0xf0107745
f0101705:	e8 36 e9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010170a:	68 99 78 10 f0       	push   $0xf0107899
f010170f:	68 6b 77 10 f0       	push   $0xf010776b
f0101714:	68 29 03 00 00       	push   $0x329
f0101719:	68 45 77 10 f0       	push   $0xf0107745
f010171e:	e8 1d e9 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0101723:	68 45 78 10 f0       	push   $0xf0107845
f0101728:	68 6b 77 10 f0       	push   $0xf010776b
f010172d:	68 30 03 00 00       	push   $0x330
f0101732:	68 45 77 10 f0       	push   $0xf0107745
f0101737:	e8 04 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010173c:	68 5b 78 10 f0       	push   $0xf010785b
f0101741:	68 6b 77 10 f0       	push   $0xf010776b
f0101746:	68 31 03 00 00       	push   $0x331
f010174b:	68 45 77 10 f0       	push   $0xf0107745
f0101750:	e8 eb e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101755:	68 71 78 10 f0       	push   $0xf0107871
f010175a:	68 6b 77 10 f0       	push   $0xf010776b
f010175f:	68 32 03 00 00       	push   $0x332
f0101764:	68 45 77 10 f0       	push   $0xf0107745
f0101769:	e8 d2 e8 ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f010176e:	68 87 78 10 f0       	push   $0xf0107887
f0101773:	68 6b 77 10 f0       	push   $0xf010776b
f0101778:	68 34 03 00 00       	push   $0x334
f010177d:	68 45 77 10 f0       	push   $0xf0107745
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101787:	68 04 6f 10 f0       	push   $0xf0106f04
f010178c:	68 6b 77 10 f0       	push   $0xf010776b
f0101791:	68 35 03 00 00       	push   $0x335
f0101796:	68 45 77 10 f0       	push   $0xf0107745
f010179b:	e8 a0 e8 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01017a0:	68 99 78 10 f0       	push   $0xf0107899
f01017a5:	68 6b 77 10 f0       	push   $0xf010776b
f01017aa:	68 36 03 00 00       	push   $0x336
f01017af:	68 45 77 10 f0       	push   $0xf0107745
f01017b4:	e8 87 e8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01017b9:	52                   	push   %edx
f01017ba:	68 04 68 10 f0       	push   $0xf0106804
f01017bf:	6a 58                	push   $0x58
f01017c1:	68 51 77 10 f0       	push   $0xf0107751
f01017c6:	e8 75 e8 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01017cb:	68 a8 78 10 f0       	push   $0xf01078a8
f01017d0:	68 6b 77 10 f0       	push   $0xf010776b
f01017d5:	68 3b 03 00 00       	push   $0x33b
f01017da:	68 45 77 10 f0       	push   $0xf0107745
f01017df:	e8 5c e8 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f01017e4:	68 c6 78 10 f0       	push   $0xf01078c6
f01017e9:	68 6b 77 10 f0       	push   $0xf010776b
f01017ee:	68 3c 03 00 00       	push   $0x33c
f01017f3:	68 45 77 10 f0       	push   $0xf0107745
f01017f8:	e8 43 e8 ff ff       	call   f0100040 <_panic>
f01017fd:	52                   	push   %edx
f01017fe:	68 04 68 10 f0       	push   $0xf0106804
f0101803:	6a 58                	push   $0x58
f0101805:	68 51 77 10 f0       	push   $0xf0107751
f010180a:	e8 31 e8 ff ff       	call   f0100040 <_panic>
		assert(c[i] == 0);
f010180f:	68 d6 78 10 f0       	push   $0xf01078d6
f0101814:	68 6b 77 10 f0       	push   $0xf010776b
f0101819:	68 3f 03 00 00       	push   $0x33f
f010181e:	68 45 77 10 f0       	push   $0xf0107745
f0101823:	e8 18 e8 ff ff       	call   f0100040 <_panic>
	assert(nfree == 0);
f0101828:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f010182c:	0f 85 43 09 00 00    	jne    f0102175 <mem_init+0xeae>
	cprintf("check_page_alloc() succeeded!\n");
f0101832:	83 ec 0c             	sub    $0xc,%esp
f0101835:	68 84 6f 10 f0       	push   $0xf0106f84
f010183a:	e8 72 20 00 00       	call   f01038b1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010183f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101846:	e8 b6 f6 ff ff       	call   f0100f01 <page_alloc>
f010184b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010184e:	83 c4 10             	add    $0x10,%esp
f0101851:	85 c0                	test   %eax,%eax
f0101853:	0f 84 35 09 00 00    	je     f010218e <mem_init+0xec7>
	assert((pp1 = page_alloc(0)));
f0101859:	83 ec 0c             	sub    $0xc,%esp
f010185c:	6a 00                	push   $0x0
f010185e:	e8 9e f6 ff ff       	call   f0100f01 <page_alloc>
f0101863:	89 c7                	mov    %eax,%edi
f0101865:	83 c4 10             	add    $0x10,%esp
f0101868:	85 c0                	test   %eax,%eax
f010186a:	0f 84 37 09 00 00    	je     f01021a7 <mem_init+0xee0>
	assert((pp2 = page_alloc(0)));
f0101870:	83 ec 0c             	sub    $0xc,%esp
f0101873:	6a 00                	push   $0x0
f0101875:	e8 87 f6 ff ff       	call   f0100f01 <page_alloc>
f010187a:	89 c3                	mov    %eax,%ebx
f010187c:	83 c4 10             	add    $0x10,%esp
f010187f:	85 c0                	test   %eax,%eax
f0101881:	0f 84 39 09 00 00    	je     f01021c0 <mem_init+0xef9>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101887:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f010188a:	0f 84 49 09 00 00    	je     f01021d9 <mem_init+0xf12>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101890:	39 c7                	cmp    %eax,%edi
f0101892:	0f 84 5a 09 00 00    	je     f01021f2 <mem_init+0xf2b>
f0101898:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010189b:	0f 84 51 09 00 00    	je     f01021f2 <mem_init+0xf2b>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01018a1:	a1 40 82 23 f0       	mov    0xf0238240,%eax
f01018a6:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f01018a9:	c7 05 40 82 23 f0 00 	movl   $0x0,0xf0238240
f01018b0:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01018b3:	83 ec 0c             	sub    $0xc,%esp
f01018b6:	6a 00                	push   $0x0
f01018b8:	e8 44 f6 ff ff       	call   f0100f01 <page_alloc>
f01018bd:	83 c4 10             	add    $0x10,%esp
f01018c0:	85 c0                	test   %eax,%eax
f01018c2:	0f 85 43 09 00 00    	jne    f010220b <mem_init+0xf44>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f01018c8:	83 ec 04             	sub    $0x4,%esp
f01018cb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01018ce:	50                   	push   %eax
f01018cf:	6a 00                	push   $0x0
f01018d1:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f01018d7:	e8 1a f8 ff ff       	call   f01010f6 <page_lookup>
f01018dc:	83 c4 10             	add    $0x10,%esp
f01018df:	85 c0                	test   %eax,%eax
f01018e1:	0f 85 3d 09 00 00    	jne    f0102224 <mem_init+0xf5d>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01018e7:	6a 02                	push   $0x2
f01018e9:	6a 00                	push   $0x0
f01018eb:	57                   	push   %edi
f01018ec:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f01018f2:	e8 ea f8 ff ff       	call   f01011e1 <page_insert>
f01018f7:	83 c4 10             	add    $0x10,%esp
f01018fa:	85 c0                	test   %eax,%eax
f01018fc:	0f 89 3b 09 00 00    	jns    f010223d <mem_init+0xf76>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101902:	83 ec 0c             	sub    $0xc,%esp
f0101905:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101908:	e8 6d f6 ff ff       	call   f0100f7a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f010190d:	6a 02                	push   $0x2
f010190f:	6a 00                	push   $0x0
f0101911:	57                   	push   %edi
f0101912:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101918:	e8 c4 f8 ff ff       	call   f01011e1 <page_insert>
f010191d:	83 c4 20             	add    $0x20,%esp
f0101920:	85 c0                	test   %eax,%eax
f0101922:	0f 85 2e 09 00 00    	jne    f0102256 <mem_init+0xf8f>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101928:	8b 35 8c 8e 23 f0    	mov    0xf0238e8c,%esi
	return (pp - pages) << PGSHIFT;
f010192e:	8b 0d 90 8e 23 f0    	mov    0xf0238e90,%ecx
f0101934:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0101937:	8b 16                	mov    (%esi),%edx
f0101939:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010193f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101942:	29 c8                	sub    %ecx,%eax
f0101944:	c1 f8 03             	sar    $0x3,%eax
f0101947:	c1 e0 0c             	shl    $0xc,%eax
f010194a:	39 c2                	cmp    %eax,%edx
f010194c:	0f 85 1d 09 00 00    	jne    f010226f <mem_init+0xfa8>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0101952:	ba 00 00 00 00       	mov    $0x0,%edx
f0101957:	89 f0                	mov    %esi,%eax
f0101959:	e8 6b f1 ff ff       	call   f0100ac9 <check_va2pa>
f010195e:	89 c2                	mov    %eax,%edx
f0101960:	89 f8                	mov    %edi,%eax
f0101962:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0101965:	c1 f8 03             	sar    $0x3,%eax
f0101968:	c1 e0 0c             	shl    $0xc,%eax
f010196b:	39 c2                	cmp    %eax,%edx
f010196d:	0f 85 15 09 00 00    	jne    f0102288 <mem_init+0xfc1>
	assert(pp1->pp_ref == 1);
f0101973:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101978:	0f 85 23 09 00 00    	jne    f01022a1 <mem_init+0xfda>
	assert(pp0->pp_ref == 1);
f010197e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101981:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101986:	0f 85 2e 09 00 00    	jne    f01022ba <mem_init+0xff3>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f010198c:	6a 02                	push   $0x2
f010198e:	68 00 10 00 00       	push   $0x1000
f0101993:	53                   	push   %ebx
f0101994:	56                   	push   %esi
f0101995:	e8 47 f8 ff ff       	call   f01011e1 <page_insert>
f010199a:	83 c4 10             	add    $0x10,%esp
f010199d:	85 c0                	test   %eax,%eax
f010199f:	0f 85 2e 09 00 00    	jne    f01022d3 <mem_init+0x100c>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019a5:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019aa:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f01019af:	e8 15 f1 ff ff       	call   f0100ac9 <check_va2pa>
f01019b4:	89 c2                	mov    %eax,%edx
f01019b6:	89 d8                	mov    %ebx,%eax
f01019b8:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f01019be:	c1 f8 03             	sar    $0x3,%eax
f01019c1:	c1 e0 0c             	shl    $0xc,%eax
f01019c4:	39 c2                	cmp    %eax,%edx
f01019c6:	0f 85 20 09 00 00    	jne    f01022ec <mem_init+0x1025>
	assert(pp2->pp_ref == 1);
f01019cc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01019d1:	0f 85 2e 09 00 00    	jne    f0102305 <mem_init+0x103e>

	// should be no free memory
	assert(!page_alloc(0));
f01019d7:	83 ec 0c             	sub    $0xc,%esp
f01019da:	6a 00                	push   $0x0
f01019dc:	e8 20 f5 ff ff       	call   f0100f01 <page_alloc>
f01019e1:	83 c4 10             	add    $0x10,%esp
f01019e4:	85 c0                	test   %eax,%eax
f01019e6:	0f 85 32 09 00 00    	jne    f010231e <mem_init+0x1057>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01019ec:	6a 02                	push   $0x2
f01019ee:	68 00 10 00 00       	push   $0x1000
f01019f3:	53                   	push   %ebx
f01019f4:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f01019fa:	e8 e2 f7 ff ff       	call   f01011e1 <page_insert>
f01019ff:	83 c4 10             	add    $0x10,%esp
f0101a02:	85 c0                	test   %eax,%eax
f0101a04:	0f 85 2d 09 00 00    	jne    f0102337 <mem_init+0x1070>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a0a:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a0f:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0101a14:	e8 b0 f0 ff ff       	call   f0100ac9 <check_va2pa>
f0101a19:	89 c2                	mov    %eax,%edx
f0101a1b:	89 d8                	mov    %ebx,%eax
f0101a1d:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101a23:	c1 f8 03             	sar    $0x3,%eax
f0101a26:	c1 e0 0c             	shl    $0xc,%eax
f0101a29:	39 c2                	cmp    %eax,%edx
f0101a2b:	0f 85 1f 09 00 00    	jne    f0102350 <mem_init+0x1089>
	assert(pp2->pp_ref == 1);
f0101a31:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a36:	0f 85 2d 09 00 00    	jne    f0102369 <mem_init+0x10a2>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a3c:	83 ec 0c             	sub    $0xc,%esp
f0101a3f:	6a 00                	push   $0x0
f0101a41:	e8 bb f4 ff ff       	call   f0100f01 <page_alloc>
f0101a46:	83 c4 10             	add    $0x10,%esp
f0101a49:	85 c0                	test   %eax,%eax
f0101a4b:	0f 85 31 09 00 00    	jne    f0102382 <mem_init+0x10bb>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a51:	8b 0d 8c 8e 23 f0    	mov    0xf0238e8c,%ecx
f0101a57:	8b 01                	mov    (%ecx),%eax
f0101a59:	89 c2                	mov    %eax,%edx
f0101a5b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	if (PGNUM(pa) >= npages)
f0101a61:	c1 e8 0c             	shr    $0xc,%eax
f0101a64:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0101a6a:	0f 83 2b 09 00 00    	jae    f010239b <mem_init+0x10d4>
	return (void *)(pa + KERNBASE);
f0101a70:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0101a76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f0101a79:	83 ec 04             	sub    $0x4,%esp
f0101a7c:	6a 00                	push   $0x0
f0101a7e:	68 00 10 00 00       	push   $0x1000
f0101a83:	51                   	push   %ecx
f0101a84:	e8 5d f5 ff ff       	call   f0100fe6 <pgdir_walk>
f0101a89:	89 c2                	mov    %eax,%edx
f0101a8b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101a8e:	83 c0 04             	add    $0x4,%eax
f0101a91:	83 c4 10             	add    $0x10,%esp
f0101a94:	39 d0                	cmp    %edx,%eax
f0101a96:	0f 85 14 09 00 00    	jne    f01023b0 <mem_init+0x10e9>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f0101a9c:	6a 06                	push   $0x6
f0101a9e:	68 00 10 00 00       	push   $0x1000
f0101aa3:	53                   	push   %ebx
f0101aa4:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101aaa:	e8 32 f7 ff ff       	call   f01011e1 <page_insert>
f0101aaf:	83 c4 10             	add    $0x10,%esp
f0101ab2:	85 c0                	test   %eax,%eax
f0101ab4:	0f 85 0f 09 00 00    	jne    f01023c9 <mem_init+0x1102>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101aba:	8b 35 8c 8e 23 f0    	mov    0xf0238e8c,%esi
f0101ac0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ac5:	89 f0                	mov    %esi,%eax
f0101ac7:	e8 fd ef ff ff       	call   f0100ac9 <check_va2pa>
f0101acc:	89 c2                	mov    %eax,%edx
	return (pp - pages) << PGSHIFT;
f0101ace:	89 d8                	mov    %ebx,%eax
f0101ad0:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101ad6:	c1 f8 03             	sar    $0x3,%eax
f0101ad9:	c1 e0 0c             	shl    $0xc,%eax
f0101adc:	39 c2                	cmp    %eax,%edx
f0101ade:	0f 85 fe 08 00 00    	jne    f01023e2 <mem_init+0x111b>
	assert(pp2->pp_ref == 1);
f0101ae4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ae9:	0f 85 0c 09 00 00    	jne    f01023fb <mem_init+0x1134>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	56                   	push   %esi
f0101afa:	e8 e7 f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101aff:	83 c4 10             	add    $0x10,%esp
f0101b02:	f6 00 04             	testb  $0x4,(%eax)
f0101b05:	0f 84 09 09 00 00    	je     f0102414 <mem_init+0x114d>
	assert(kern_pgdir[0] & PTE_U);
f0101b0b:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0101b10:	f6 00 04             	testb  $0x4,(%eax)
f0101b13:	0f 84 14 09 00 00    	je     f010242d <mem_init+0x1166>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0101b19:	6a 02                	push   $0x2
f0101b1b:	68 00 10 00 00       	push   $0x1000
f0101b20:	53                   	push   %ebx
f0101b21:	50                   	push   %eax
f0101b22:	e8 ba f6 ff ff       	call   f01011e1 <page_insert>
f0101b27:	83 c4 10             	add    $0x10,%esp
f0101b2a:	85 c0                	test   %eax,%eax
f0101b2c:	0f 85 14 09 00 00    	jne    f0102446 <mem_init+0x117f>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f0101b32:	83 ec 04             	sub    $0x4,%esp
f0101b35:	6a 00                	push   $0x0
f0101b37:	68 00 10 00 00       	push   $0x1000
f0101b3c:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101b42:	e8 9f f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101b47:	83 c4 10             	add    $0x10,%esp
f0101b4a:	f6 00 02             	testb  $0x2,(%eax)
f0101b4d:	0f 84 0c 09 00 00    	je     f010245f <mem_init+0x1198>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101b53:	83 ec 04             	sub    $0x4,%esp
f0101b56:	6a 00                	push   $0x0
f0101b58:	68 00 10 00 00       	push   $0x1000
f0101b5d:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101b63:	e8 7e f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101b68:	83 c4 10             	add    $0x10,%esp
f0101b6b:	f6 00 04             	testb  $0x4,(%eax)
f0101b6e:	0f 85 04 09 00 00    	jne    f0102478 <mem_init+0x11b1>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0101b74:	6a 02                	push   $0x2
f0101b76:	68 00 00 40 00       	push   $0x400000
f0101b7b:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101b7e:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101b84:	e8 58 f6 ff ff       	call   f01011e1 <page_insert>
f0101b89:	83 c4 10             	add    $0x10,%esp
f0101b8c:	85 c0                	test   %eax,%eax
f0101b8e:	0f 89 fd 08 00 00    	jns    f0102491 <mem_init+0x11ca>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f0101b94:	6a 02                	push   $0x2
f0101b96:	68 00 10 00 00       	push   $0x1000
f0101b9b:	57                   	push   %edi
f0101b9c:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101ba2:	e8 3a f6 ff ff       	call   f01011e1 <page_insert>
f0101ba7:	83 c4 10             	add    $0x10,%esp
f0101baa:	85 c0                	test   %eax,%eax
f0101bac:	0f 85 f8 08 00 00    	jne    f01024aa <mem_init+0x11e3>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0101bb2:	83 ec 04             	sub    $0x4,%esp
f0101bb5:	6a 00                	push   $0x0
f0101bb7:	68 00 10 00 00       	push   $0x1000
f0101bbc:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101bc2:	e8 1f f4 ff ff       	call   f0100fe6 <pgdir_walk>
f0101bc7:	83 c4 10             	add    $0x10,%esp
f0101bca:	f6 00 04             	testb  $0x4,(%eax)
f0101bcd:	0f 85 f0 08 00 00    	jne    f01024c3 <mem_init+0x11fc>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bd3:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0101bd8:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101bdb:	ba 00 00 00 00       	mov    $0x0,%edx
f0101be0:	e8 e4 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101be5:	89 fe                	mov    %edi,%esi
f0101be7:	2b 35 90 8e 23 f0    	sub    0xf0238e90,%esi
f0101bed:	c1 fe 03             	sar    $0x3,%esi
f0101bf0:	c1 e6 0c             	shl    $0xc,%esi
f0101bf3:	39 f0                	cmp    %esi,%eax
f0101bf5:	0f 85 e1 08 00 00    	jne    f01024dc <mem_init+0x1215>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101bfb:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c00:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101c03:	e8 c1 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c08:	39 c6                	cmp    %eax,%esi
f0101c0a:	0f 85 e5 08 00 00    	jne    f01024f5 <mem_init+0x122e>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c10:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c15:	0f 85 f3 08 00 00    	jne    f010250e <mem_init+0x1247>
	assert(pp2->pp_ref == 0);
f0101c1b:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c20:	0f 85 01 09 00 00    	jne    f0102527 <mem_init+0x1260>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c26:	83 ec 0c             	sub    $0xc,%esp
f0101c29:	6a 00                	push   $0x0
f0101c2b:	e8 d1 f2 ff ff       	call   f0100f01 <page_alloc>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	39 c3                	cmp    %eax,%ebx
f0101c35:	0f 85 05 09 00 00    	jne    f0102540 <mem_init+0x1279>
f0101c3b:	85 c0                	test   %eax,%eax
f0101c3d:	0f 84 fd 08 00 00    	je     f0102540 <mem_init+0x1279>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c43:	83 ec 08             	sub    $0x8,%esp
f0101c46:	6a 00                	push   $0x0
f0101c48:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101c4e:	e8 44 f5 ff ff       	call   f0101197 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c53:	8b 35 8c 8e 23 f0    	mov    0xf0238e8c,%esi
f0101c59:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c5e:	89 f0                	mov    %esi,%eax
f0101c60:	e8 64 ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c6b:	0f 85 e8 08 00 00    	jne    f0102559 <mem_init+0x1292>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c71:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c76:	89 f0                	mov    %esi,%eax
f0101c78:	e8 4c ee ff ff       	call   f0100ac9 <check_va2pa>
f0101c7d:	89 c2                	mov    %eax,%edx
f0101c7f:	89 f8                	mov    %edi,%eax
f0101c81:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101c87:	c1 f8 03             	sar    $0x3,%eax
f0101c8a:	c1 e0 0c             	shl    $0xc,%eax
f0101c8d:	39 c2                	cmp    %eax,%edx
f0101c8f:	0f 85 dd 08 00 00    	jne    f0102572 <mem_init+0x12ab>
	assert(pp1->pp_ref == 1);
f0101c95:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101c9a:	0f 85 eb 08 00 00    	jne    f010258b <mem_init+0x12c4>
	assert(pp2->pp_ref == 0);
f0101ca0:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ca5:	0f 85 f9 08 00 00    	jne    f01025a4 <mem_init+0x12dd>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f0101cab:	6a 00                	push   $0x0
f0101cad:	68 00 10 00 00       	push   $0x1000
f0101cb2:	57                   	push   %edi
f0101cb3:	56                   	push   %esi
f0101cb4:	e8 28 f5 ff ff       	call   f01011e1 <page_insert>
f0101cb9:	83 c4 10             	add    $0x10,%esp
f0101cbc:	85 c0                	test   %eax,%eax
f0101cbe:	0f 85 f9 08 00 00    	jne    f01025bd <mem_init+0x12f6>
	assert(pp1->pp_ref);
f0101cc4:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101cc9:	0f 84 07 09 00 00    	je     f01025d6 <mem_init+0x130f>
	assert(pp1->pp_link == NULL);
f0101ccf:	83 3f 00             	cmpl   $0x0,(%edi)
f0101cd2:	0f 85 17 09 00 00    	jne    f01025ef <mem_init+0x1328>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void *)PGSIZE);
f0101cd8:	83 ec 08             	sub    $0x8,%esp
f0101cdb:	68 00 10 00 00       	push   $0x1000
f0101ce0:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101ce6:	e8 ac f4 ff ff       	call   f0101197 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101ceb:	8b 35 8c 8e 23 f0    	mov    0xf0238e8c,%esi
f0101cf1:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cf6:	89 f0                	mov    %esi,%eax
f0101cf8:	e8 cc ed ff ff       	call   f0100ac9 <check_va2pa>
f0101cfd:	83 c4 10             	add    $0x10,%esp
f0101d00:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d03:	0f 85 ff 08 00 00    	jne    f0102608 <mem_init+0x1341>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d09:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d0e:	89 f0                	mov    %esi,%eax
f0101d10:	e8 b4 ed ff ff       	call   f0100ac9 <check_va2pa>
f0101d15:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d18:	0f 85 03 09 00 00    	jne    f0102621 <mem_init+0x135a>
	assert(pp1->pp_ref == 0);
f0101d1e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d23:	0f 85 11 09 00 00    	jne    f010263a <mem_init+0x1373>
	assert(pp2->pp_ref == 0);
f0101d29:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d2e:	0f 85 1f 09 00 00    	jne    f0102653 <mem_init+0x138c>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101d34:	83 ec 0c             	sub    $0xc,%esp
f0101d37:	6a 00                	push   $0x0
f0101d39:	e8 c3 f1 ff ff       	call   f0100f01 <page_alloc>
f0101d3e:	83 c4 10             	add    $0x10,%esp
f0101d41:	85 c0                	test   %eax,%eax
f0101d43:	0f 84 23 09 00 00    	je     f010266c <mem_init+0x13a5>
f0101d49:	39 c7                	cmp    %eax,%edi
f0101d4b:	0f 85 1b 09 00 00    	jne    f010266c <mem_init+0x13a5>

	// should be no free memory
	assert(!page_alloc(0));
f0101d51:	83 ec 0c             	sub    $0xc,%esp
f0101d54:	6a 00                	push   $0x0
f0101d56:	e8 a6 f1 ff ff       	call   f0100f01 <page_alloc>
f0101d5b:	83 c4 10             	add    $0x10,%esp
f0101d5e:	85 c0                	test   %eax,%eax
f0101d60:	0f 85 1f 09 00 00    	jne    f0102685 <mem_init+0x13be>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101d66:	8b 0d 8c 8e 23 f0    	mov    0xf0238e8c,%ecx
f0101d6c:	8b 11                	mov    (%ecx),%edx
f0101d6e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101d74:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d77:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101d7d:	c1 f8 03             	sar    $0x3,%eax
f0101d80:	c1 e0 0c             	shl    $0xc,%eax
f0101d83:	39 c2                	cmp    %eax,%edx
f0101d85:	0f 85 13 09 00 00    	jne    f010269e <mem_init+0x13d7>
	kern_pgdir[0] = 0;
f0101d8b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101d91:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101d94:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101d99:	0f 85 18 09 00 00    	jne    f01026b7 <mem_init+0x13f0>
	pp0->pp_ref = 0;
f0101d9f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101da2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101da8:	83 ec 0c             	sub    $0xc,%esp
f0101dab:	50                   	push   %eax
f0101dac:	e8 c9 f1 ff ff       	call   f0100f7a <page_free>
	va = (void *)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101db1:	83 c4 0c             	add    $0xc,%esp
f0101db4:	6a 01                	push   $0x1
f0101db6:	68 00 10 40 00       	push   $0x401000
f0101dbb:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101dc1:	e8 20 f2 ff ff       	call   f0100fe6 <pgdir_walk>
f0101dc6:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0101dc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *)KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101dcc:	8b 0d 8c 8e 23 f0    	mov    0xf0238e8c,%ecx
f0101dd2:	8b 41 04             	mov    0x4(%ecx),%eax
f0101dd5:	89 c6                	mov    %eax,%esi
f0101dd7:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f0101ddd:	8b 15 88 8e 23 f0    	mov    0xf0238e88,%edx
f0101de3:	c1 e8 0c             	shr    $0xc,%eax
f0101de6:	83 c4 10             	add    $0x10,%esp
f0101de9:	39 d0                	cmp    %edx,%eax
f0101deb:	0f 83 df 08 00 00    	jae    f01026d0 <mem_init+0x1409>
	assert(ptep == ptep1 + PTX(va));
f0101df1:	81 ee fc ff ff 0f    	sub    $0xffffffc,%esi
f0101df7:	39 75 d0             	cmp    %esi,-0x30(%ebp)
f0101dfa:	0f 85 e5 08 00 00    	jne    f01026e5 <mem_init+0x141e>
	kern_pgdir[PDX(va)] = 0;
f0101e00:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
	pp0->pp_ref = 0;
f0101e07:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e0a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f0101e10:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101e16:	c1 f8 03             	sar    $0x3,%eax
f0101e19:	89 c1                	mov    %eax,%ecx
f0101e1b:	c1 e1 0c             	shl    $0xc,%ecx
	if (PGNUM(pa) >= npages)
f0101e1e:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e23:	39 c2                	cmp    %eax,%edx
f0101e25:	0f 86 d3 08 00 00    	jbe    f01026fe <mem_init+0x1437>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101e2b:	83 ec 04             	sub    $0x4,%esp
f0101e2e:	68 00 10 00 00       	push   $0x1000
f0101e33:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0101e38:	81 e9 00 00 00 10    	sub    $0x10000000,%ecx
f0101e3e:	51                   	push   %ecx
f0101e3f:	e8 0b 3d 00 00       	call   f0105b4f <memset>
	page_free(pp0);
f0101e44:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f0101e47:	89 34 24             	mov    %esi,(%esp)
f0101e4a:	e8 2b f1 ff ff       	call   f0100f7a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101e4f:	83 c4 0c             	add    $0xc,%esp
f0101e52:	6a 01                	push   $0x1
f0101e54:	6a 00                	push   $0x0
f0101e56:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101e5c:	e8 85 f1 ff ff       	call   f0100fe6 <pgdir_walk>
	return (pp - pages) << PGSHIFT;
f0101e61:	89 f0                	mov    %esi,%eax
f0101e63:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0101e69:	c1 f8 03             	sar    $0x3,%eax
f0101e6c:	89 c2                	mov    %eax,%edx
f0101e6e:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0101e71:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0101e76:	83 c4 10             	add    $0x10,%esp
f0101e79:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0101e7f:	0f 83 8b 08 00 00    	jae    f0102710 <mem_init+0x1449>
	return (void *)(pa + KERNBASE);
f0101e85:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *)page2kva(pp0);
f0101e8b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101e8e:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for (i = 0; i < NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101e94:	f6 00 01             	testb  $0x1,(%eax)
f0101e97:	0f 85 85 08 00 00    	jne    f0102722 <mem_init+0x145b>
f0101e9d:	83 c0 04             	add    $0x4,%eax
	for (i = 0; i < NPTENTRIES; i++)
f0101ea0:	39 d0                	cmp    %edx,%eax
f0101ea2:	75 f0                	jne    f0101e94 <mem_init+0xbcd>
	kern_pgdir[0] = 0;
f0101ea4:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0101ea9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101eaf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101eb2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101eb8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101ebb:	89 0d 40 82 23 f0    	mov    %ecx,0xf0238240

	// free the pages we took
	page_free(pp0);
f0101ec1:	83 ec 0c             	sub    $0xc,%esp
f0101ec4:	50                   	push   %eax
f0101ec5:	e8 b0 f0 ff ff       	call   f0100f7a <page_free>
	page_free(pp1);
f0101eca:	89 3c 24             	mov    %edi,(%esp)
f0101ecd:	e8 a8 f0 ff ff       	call   f0100f7a <page_free>
	page_free(pp2);
f0101ed2:	89 1c 24             	mov    %ebx,(%esp)
f0101ed5:	e8 a0 f0 ff ff       	call   f0100f7a <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t)mmio_map_region(0, 4097);
f0101eda:	83 c4 08             	add    $0x8,%esp
f0101edd:	68 01 10 00 00       	push   $0x1001
f0101ee2:	6a 00                	push   $0x0
f0101ee4:	e8 62 f3 ff ff       	call   f010124b <mmio_map_region>
f0101ee9:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t)mmio_map_region(0, 4096);
f0101eeb:	83 c4 08             	add    $0x8,%esp
f0101eee:	68 00 10 00 00       	push   $0x1000
f0101ef3:	6a 00                	push   $0x0
f0101ef5:	e8 51 f3 ff ff       	call   f010124b <mmio_map_region>
f0101efa:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f0101efc:	8d 83 00 20 00 00    	lea    0x2000(%ebx),%eax
f0101f02:	83 c4 10             	add    $0x10,%esp
f0101f05:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101f0b:	0f 86 2a 08 00 00    	jbe    f010273b <mem_init+0x1474>
f0101f11:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0101f16:	0f 87 1f 08 00 00    	ja     f010273b <mem_init+0x1474>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0101f1c:	8d 96 00 20 00 00    	lea    0x2000(%esi),%edx
f0101f22:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f0101f28:	0f 87 26 08 00 00    	ja     f0102754 <mem_init+0x148d>
f0101f2e:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101f34:	0f 86 1a 08 00 00    	jbe    f0102754 <mem_init+0x148d>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0101f3a:	89 da                	mov    %ebx,%edx
f0101f3c:	09 f2                	or     %esi,%edx
f0101f3e:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0101f44:	0f 85 23 08 00 00    	jne    f010276d <mem_init+0x14a6>
	// check that they don't overlap
	assert(mm1 + 8192 <= mm2);
f0101f4a:	39 c6                	cmp    %eax,%esi
f0101f4c:	0f 82 34 08 00 00    	jb     f0102786 <mem_init+0x14bf>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0101f52:	8b 3d 8c 8e 23 f0    	mov    0xf0238e8c,%edi
f0101f58:	89 da                	mov    %ebx,%edx
f0101f5a:	89 f8                	mov    %edi,%eax
f0101f5c:	e8 68 eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f61:	85 c0                	test   %eax,%eax
f0101f63:	0f 85 36 08 00 00    	jne    f010279f <mem_init+0x14d8>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f0101f69:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0101f6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f72:	89 c2                	mov    %eax,%edx
f0101f74:	89 f8                	mov    %edi,%eax
f0101f76:	e8 4e eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f7b:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0101f80:	0f 85 32 08 00 00    	jne    f01027b8 <mem_init+0x14f1>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0101f86:	89 f2                	mov    %esi,%edx
f0101f88:	89 f8                	mov    %edi,%eax
f0101f8a:	e8 3a eb ff ff       	call   f0100ac9 <check_va2pa>
f0101f8f:	85 c0                	test   %eax,%eax
f0101f91:	0f 85 3a 08 00 00    	jne    f01027d1 <mem_init+0x150a>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f0101f97:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0101f9d:	89 f8                	mov    %edi,%eax
f0101f9f:	e8 25 eb ff ff       	call   f0100ac9 <check_va2pa>
f0101fa4:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa7:	0f 85 3d 08 00 00    	jne    f01027ea <mem_init+0x1523>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0101fad:	83 ec 04             	sub    $0x4,%esp
f0101fb0:	6a 00                	push   $0x0
f0101fb2:	53                   	push   %ebx
f0101fb3:	57                   	push   %edi
f0101fb4:	e8 2d f0 ff ff       	call   f0100fe6 <pgdir_walk>
f0101fb9:	83 c4 10             	add    $0x10,%esp
f0101fbc:	f6 00 1a             	testb  $0x1a,(%eax)
f0101fbf:	0f 84 3e 08 00 00    	je     f0102803 <mem_init+0x153c>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f0101fc5:	83 ec 04             	sub    $0x4,%esp
f0101fc8:	6a 00                	push   $0x0
f0101fca:	53                   	push   %ebx
f0101fcb:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101fd1:	e8 10 f0 ff ff       	call   f0100fe6 <pgdir_walk>
f0101fd6:	8b 00                	mov    (%eax),%eax
f0101fd8:	83 c4 10             	add    $0x10,%esp
f0101fdb:	83 e0 04             	and    $0x4,%eax
f0101fde:	89 c7                	mov    %eax,%edi
f0101fe0:	0f 85 36 08 00 00    	jne    f010281c <mem_init+0x1555>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void *)mm1, 0) = 0;
f0101fe6:	83 ec 04             	sub    $0x4,%esp
f0101fe9:	6a 00                	push   $0x0
f0101feb:	53                   	push   %ebx
f0101fec:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0101ff2:	e8 ef ef ff ff       	call   f0100fe6 <pgdir_walk>
f0101ff7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm1 + PGSIZE, 0) = 0;
f0101ffd:	83 c4 0c             	add    $0xc,%esp
f0102000:	6a 00                	push   $0x0
f0102002:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102005:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f010200b:	e8 d6 ef ff ff       	call   f0100fe6 <pgdir_walk>
f0102010:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void *)mm2, 0) = 0;
f0102016:	83 c4 0c             	add    $0xc,%esp
f0102019:	6a 00                	push   $0x0
f010201b:	56                   	push   %esi
f010201c:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0102022:	e8 bf ef ff ff       	call   f0100fe6 <pgdir_walk>
f0102027:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010202d:	c7 04 24 c9 79 10 f0 	movl   $0xf01079c9,(%esp)
f0102034:	e8 78 18 00 00       	call   f01038b1 <cprintf>
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102039:	a1 90 8e 23 f0       	mov    0xf0238e90,%eax
	if ((uint32_t)kva < KERNBASE)
f010203e:	83 c4 10             	add    $0x10,%esp
f0102041:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102046:	0f 86 e9 07 00 00    	jbe    f0102835 <mem_init+0x156e>
f010204c:	83 ec 08             	sub    $0x8,%esp
f010204f:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102051:	05 00 00 00 10       	add    $0x10000000,%eax
f0102056:	50                   	push   %eax
f0102057:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010205c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0102061:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0102066:	e8 0c f0 ff ff       	call   f0101077 <boot_map_region>
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f010206b:	a1 44 82 23 f0       	mov    0xf0238244,%eax
	if ((uint32_t)kva < KERNBASE)
f0102070:	83 c4 10             	add    $0x10,%esp
f0102073:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102078:	0f 86 cc 07 00 00    	jbe    f010284a <mem_init+0x1583>
f010207e:	83 ec 08             	sub    $0x8,%esp
f0102081:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102083:	05 00 00 00 10       	add    $0x10000000,%eax
f0102088:	50                   	push   %eax
f0102089:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010208e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102093:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0102098:	e8 da ef ff ff       	call   f0101077 <boot_map_region>
	if ((uint32_t)kva < KERNBASE)
f010209d:	83 c4 10             	add    $0x10,%esp
f01020a0:	b8 00 90 11 f0       	mov    $0xf0119000,%eax
f01020a5:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020aa:	0f 86 af 07 00 00    	jbe    f010285f <mem_init+0x1598>
	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020b0:	83 ec 08             	sub    $0x8,%esp
f01020b3:	6a 02                	push   $0x2
f01020b5:	68 00 90 11 00       	push   $0x119000
f01020ba:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020bf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020c4:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f01020c9:	e8 a9 ef ff ff       	call   f0101077 <boot_map_region>
	boot_map_region(kern_pgdir, KERNBASE, 0xffffffff - KERNBASE, 0, PTE_W);
f01020ce:	83 c4 08             	add    $0x8,%esp
f01020d1:	6a 02                	push   $0x2
f01020d3:	6a 00                	push   $0x0
f01020d5:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f01020da:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020df:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f01020e4:	e8 8e ef ff ff       	call   f0101077 <boot_map_region>
f01020e9:	c7 45 d0 00 a0 23 f0 	movl   $0xf023a000,-0x30(%ebp)
f01020f0:	83 c4 10             	add    $0x10,%esp
f01020f3:	bb 00 a0 23 f0       	mov    $0xf023a000,%ebx
f01020f8:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01020fd:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f0102103:	0f 86 6b 07 00 00    	jbe    f0102874 <mem_init+0x15ad>
		boot_map_region(kern_pgdir,
f0102109:	83 ec 08             	sub    $0x8,%esp
f010210c:	6a 02                	push   $0x2
f010210e:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f0102114:	50                   	push   %eax
f0102115:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010211a:	89 f2                	mov    %esi,%edx
f010211c:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0102121:	e8 51 ef ff ff       	call   f0101077 <boot_map_region>
f0102126:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f010212c:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	for (int i = 0; i < NCPU; i++)
f0102132:	83 c4 10             	add    $0x10,%esp
f0102135:	81 fb 00 a0 27 f0    	cmp    $0xf027a000,%ebx
f010213b:	75 c0                	jne    f01020fd <mem_init+0xe36>
	pgdir = kern_pgdir;
f010213d:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
f0102142:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	n = ROUNDUP(npages * sizeof(struct PageInfo), PGSIZE);
f0102145:	a1 88 8e 23 f0       	mov    0xf0238e88,%eax
f010214a:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010214d:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102154:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102159:	89 45 cc             	mov    %eax,-0x34(%ebp)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010215c:	8b 35 90 8e 23 f0    	mov    0xf0238e90,%esi
f0102162:	89 75 c8             	mov    %esi,-0x38(%ebp)
	return (physaddr_t)kva - KERNBASE;
f0102165:	8d 86 00 00 00 10    	lea    0x10000000(%esi),%eax
f010216b:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
f010216e:	89 fb                	mov    %edi,%ebx
f0102170:	e9 2f 07 00 00       	jmp    f01028a4 <mem_init+0x15dd>
	assert(nfree == 0);
f0102175:	68 e0 78 10 f0       	push   $0xf01078e0
f010217a:	68 6b 77 10 f0       	push   $0xf010776b
f010217f:	68 4c 03 00 00       	push   $0x34c
f0102184:	68 45 77 10 f0       	push   $0xf0107745
f0102189:	e8 b2 de ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f010218e:	68 45 78 10 f0       	push   $0xf0107845
f0102193:	68 6b 77 10 f0       	push   $0xf010776b
f0102198:	68 b5 03 00 00       	push   $0x3b5
f010219d:	68 45 77 10 f0       	push   $0xf0107745
f01021a2:	e8 99 de ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01021a7:	68 5b 78 10 f0       	push   $0xf010785b
f01021ac:	68 6b 77 10 f0       	push   $0xf010776b
f01021b1:	68 b6 03 00 00       	push   $0x3b6
f01021b6:	68 45 77 10 f0       	push   $0xf0107745
f01021bb:	e8 80 de ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01021c0:	68 71 78 10 f0       	push   $0xf0107871
f01021c5:	68 6b 77 10 f0       	push   $0xf010776b
f01021ca:	68 b7 03 00 00       	push   $0x3b7
f01021cf:	68 45 77 10 f0       	push   $0xf0107745
f01021d4:	e8 67 de ff ff       	call   f0100040 <_panic>
	assert(pp1 && pp1 != pp0);
f01021d9:	68 87 78 10 f0       	push   $0xf0107887
f01021de:	68 6b 77 10 f0       	push   $0xf010776b
f01021e3:	68 ba 03 00 00       	push   $0x3ba
f01021e8:	68 45 77 10 f0       	push   $0xf0107745
f01021ed:	e8 4e de ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01021f2:	68 04 6f 10 f0       	push   $0xf0106f04
f01021f7:	68 6b 77 10 f0       	push   $0xf010776b
f01021fc:	68 bb 03 00 00       	push   $0x3bb
f0102201:	68 45 77 10 f0       	push   $0xf0107745
f0102206:	e8 35 de ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010220b:	68 99 78 10 f0       	push   $0xf0107899
f0102210:	68 6b 77 10 f0       	push   $0xf010776b
f0102215:	68 c2 03 00 00       	push   $0x3c2
f010221a:	68 45 77 10 f0       	push   $0xf0107745
f010221f:	e8 1c de ff ff       	call   f0100040 <_panic>
	assert(page_lookup(kern_pgdir, (void *)0x0, &ptep) == NULL);
f0102224:	68 a4 6f 10 f0       	push   $0xf0106fa4
f0102229:	68 6b 77 10 f0       	push   $0xf010776b
f010222e:	68 c5 03 00 00       	push   $0x3c5
f0102233:	68 45 77 10 f0       	push   $0xf0107745
f0102238:	e8 03 de ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010223d:	68 d8 6f 10 f0       	push   $0xf0106fd8
f0102242:	68 6b 77 10 f0       	push   $0xf010776b
f0102247:	68 c8 03 00 00       	push   $0x3c8
f010224c:	68 45 77 10 f0       	push   $0xf0107745
f0102251:	e8 ea dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102256:	68 08 70 10 f0       	push   $0xf0107008
f010225b:	68 6b 77 10 f0       	push   $0xf010776b
f0102260:	68 cc 03 00 00       	push   $0x3cc
f0102265:	68 45 77 10 f0       	push   $0xf0107745
f010226a:	e8 d1 dd ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010226f:	68 38 70 10 f0       	push   $0xf0107038
f0102274:	68 6b 77 10 f0       	push   $0xf010776b
f0102279:	68 cd 03 00 00       	push   $0x3cd
f010227e:	68 45 77 10 f0       	push   $0xf0107745
f0102283:	e8 b8 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f0102288:	68 60 70 10 f0       	push   $0xf0107060
f010228d:	68 6b 77 10 f0       	push   $0xf010776b
f0102292:	68 ce 03 00 00       	push   $0x3ce
f0102297:	68 45 77 10 f0       	push   $0xf0107745
f010229c:	e8 9f dd ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f01022a1:	68 eb 78 10 f0       	push   $0xf01078eb
f01022a6:	68 6b 77 10 f0       	push   $0xf010776b
f01022ab:	68 cf 03 00 00       	push   $0x3cf
f01022b0:	68 45 77 10 f0       	push   $0xf0107745
f01022b5:	e8 86 dd ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01022ba:	68 fc 78 10 f0       	push   $0xf01078fc
f01022bf:	68 6b 77 10 f0       	push   $0xf010776b
f01022c4:	68 d0 03 00 00       	push   $0x3d0
f01022c9:	68 45 77 10 f0       	push   $0xf0107745
f01022ce:	e8 6d dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f01022d3:	68 90 70 10 f0       	push   $0xf0107090
f01022d8:	68 6b 77 10 f0       	push   $0xf010776b
f01022dd:	68 d3 03 00 00       	push   $0x3d3
f01022e2:	68 45 77 10 f0       	push   $0xf0107745
f01022e7:	e8 54 dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022ec:	68 cc 70 10 f0       	push   $0xf01070cc
f01022f1:	68 6b 77 10 f0       	push   $0xf010776b
f01022f6:	68 d4 03 00 00       	push   $0x3d4
f01022fb:	68 45 77 10 f0       	push   $0xf0107745
f0102300:	e8 3b dd ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102305:	68 0d 79 10 f0       	push   $0xf010790d
f010230a:	68 6b 77 10 f0       	push   $0xf010776b
f010230f:	68 d5 03 00 00       	push   $0x3d5
f0102314:	68 45 77 10 f0       	push   $0xf0107745
f0102319:	e8 22 dd ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f010231e:	68 99 78 10 f0       	push   $0xf0107899
f0102323:	68 6b 77 10 f0       	push   $0xf010776b
f0102328:	68 d8 03 00 00       	push   $0x3d8
f010232d:	68 45 77 10 f0       	push   $0xf0107745
f0102332:	e8 09 dd ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102337:	68 90 70 10 f0       	push   $0xf0107090
f010233c:	68 6b 77 10 f0       	push   $0xf010776b
f0102341:	68 db 03 00 00       	push   $0x3db
f0102346:	68 45 77 10 f0       	push   $0xf0107745
f010234b:	e8 f0 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0102350:	68 cc 70 10 f0       	push   $0xf01070cc
f0102355:	68 6b 77 10 f0       	push   $0xf010776b
f010235a:	68 dc 03 00 00       	push   $0x3dc
f010235f:	68 45 77 10 f0       	push   $0xf0107745
f0102364:	e8 d7 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102369:	68 0d 79 10 f0       	push   $0xf010790d
f010236e:	68 6b 77 10 f0       	push   $0xf010776b
f0102373:	68 dd 03 00 00       	push   $0x3dd
f0102378:	68 45 77 10 f0       	push   $0xf0107745
f010237d:	e8 be dc ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102382:	68 99 78 10 f0       	push   $0xf0107899
f0102387:	68 6b 77 10 f0       	push   $0xf010776b
f010238c:	68 e1 03 00 00       	push   $0x3e1
f0102391:	68 45 77 10 f0       	push   $0xf0107745
f0102396:	e8 a5 dc ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010239b:	52                   	push   %edx
f010239c:	68 04 68 10 f0       	push   $0xf0106804
f01023a1:	68 e4 03 00 00       	push   $0x3e4
f01023a6:	68 45 77 10 f0       	push   $0xf0107745
f01023ab:	e8 90 dc ff ff       	call   f0100040 <_panic>
	assert(pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) == ptep + PTX(PGSIZE));
f01023b0:	68 fc 70 10 f0       	push   $0xf01070fc
f01023b5:	68 6b 77 10 f0       	push   $0xf010776b
f01023ba:	68 e5 03 00 00       	push   $0x3e5
f01023bf:	68 45 77 10 f0       	push   $0xf0107745
f01023c4:	e8 77 dc ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W | PTE_U) == 0);
f01023c9:	68 3c 71 10 f0       	push   $0xf010713c
f01023ce:	68 6b 77 10 f0       	push   $0xf010776b
f01023d3:	68 e8 03 00 00       	push   $0x3e8
f01023d8:	68 45 77 10 f0       	push   $0xf0107745
f01023dd:	e8 5e dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023e2:	68 cc 70 10 f0       	push   $0xf01070cc
f01023e7:	68 6b 77 10 f0       	push   $0xf010776b
f01023ec:	68 e9 03 00 00       	push   $0x3e9
f01023f1:	68 45 77 10 f0       	push   $0xf0107745
f01023f6:	e8 45 dc ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01023fb:	68 0d 79 10 f0       	push   $0xf010790d
f0102400:	68 6b 77 10 f0       	push   $0xf010776b
f0102405:	68 ea 03 00 00       	push   $0x3ea
f010240a:	68 45 77 10 f0       	push   $0xf0107745
f010240f:	e8 2c dc ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U);
f0102414:	68 80 71 10 f0       	push   $0xf0107180
f0102419:	68 6b 77 10 f0       	push   $0xf010776b
f010241e:	68 eb 03 00 00       	push   $0x3eb
f0102423:	68 45 77 10 f0       	push   $0xf0107745
f0102428:	e8 13 dc ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f010242d:	68 1e 79 10 f0       	push   $0xf010791e
f0102432:	68 6b 77 10 f0       	push   $0xf010776b
f0102437:	68 ec 03 00 00       	push   $0x3ec
f010243c:	68 45 77 10 f0       	push   $0xf0107745
f0102441:	e8 fa db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W) == 0);
f0102446:	68 90 70 10 f0       	push   $0xf0107090
f010244b:	68 6b 77 10 f0       	push   $0xf010776b
f0102450:	68 ef 03 00 00       	push   $0x3ef
f0102455:	68 45 77 10 f0       	push   $0xf0107745
f010245a:	e8 e1 db ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_W);
f010245f:	68 b4 71 10 f0       	push   $0xf01071b4
f0102464:	68 6b 77 10 f0       	push   $0xf010776b
f0102469:	68 f0 03 00 00       	push   $0x3f0
f010246e:	68 45 77 10 f0       	push   $0xf0107745
f0102473:	e8 c8 db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f0102478:	68 e8 71 10 f0       	push   $0xf01071e8
f010247d:	68 6b 77 10 f0       	push   $0xf010776b
f0102482:	68 f1 03 00 00       	push   $0x3f1
f0102487:	68 45 77 10 f0       	push   $0xf0107745
f010248c:	e8 af db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp0, (void *)PTSIZE, PTE_W) < 0);
f0102491:	68 20 72 10 f0       	push   $0xf0107220
f0102496:	68 6b 77 10 f0       	push   $0xf010776b
f010249b:	68 f4 03 00 00       	push   $0x3f4
f01024a0:	68 45 77 10 f0       	push   $0xf0107745
f01024a5:	e8 96 db ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W) == 0);
f01024aa:	68 58 72 10 f0       	push   $0xf0107258
f01024af:	68 6b 77 10 f0       	push   $0xf010776b
f01024b4:	68 f7 03 00 00       	push   $0x3f7
f01024b9:	68 45 77 10 f0       	push   $0xf0107745
f01024be:	e8 7d db ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)PGSIZE, 0) & PTE_U));
f01024c3:	68 e8 71 10 f0       	push   $0xf01071e8
f01024c8:	68 6b 77 10 f0       	push   $0xf010776b
f01024cd:	68 f8 03 00 00       	push   $0x3f8
f01024d2:	68 45 77 10 f0       	push   $0xf0107745
f01024d7:	e8 64 db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01024dc:	68 94 72 10 f0       	push   $0xf0107294
f01024e1:	68 6b 77 10 f0       	push   $0xf010776b
f01024e6:	68 fb 03 00 00       	push   $0x3fb
f01024eb:	68 45 77 10 f0       	push   $0xf0107745
f01024f0:	e8 4b db ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024f5:	68 c0 72 10 f0       	push   $0xf01072c0
f01024fa:	68 6b 77 10 f0       	push   $0xf010776b
f01024ff:	68 fc 03 00 00       	push   $0x3fc
f0102504:	68 45 77 10 f0       	push   $0xf0107745
f0102509:	e8 32 db ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 2);
f010250e:	68 34 79 10 f0       	push   $0xf0107934
f0102513:	68 6b 77 10 f0       	push   $0xf010776b
f0102518:	68 fe 03 00 00       	push   $0x3fe
f010251d:	68 45 77 10 f0       	push   $0xf0107745
f0102522:	e8 19 db ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102527:	68 45 79 10 f0       	push   $0xf0107945
f010252c:	68 6b 77 10 f0       	push   $0xf010776b
f0102531:	68 ff 03 00 00       	push   $0x3ff
f0102536:	68 45 77 10 f0       	push   $0xf0107745
f010253b:	e8 00 db ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp2);
f0102540:	68 f0 72 10 f0       	push   $0xf01072f0
f0102545:	68 6b 77 10 f0       	push   $0xf010776b
f010254a:	68 02 04 00 00       	push   $0x402
f010254f:	68 45 77 10 f0       	push   $0xf0107745
f0102554:	e8 e7 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102559:	68 14 73 10 f0       	push   $0xf0107314
f010255e:	68 6b 77 10 f0       	push   $0xf010776b
f0102563:	68 06 04 00 00       	push   $0x406
f0102568:	68 45 77 10 f0       	push   $0xf0107745
f010256d:	e8 ce da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102572:	68 c0 72 10 f0       	push   $0xf01072c0
f0102577:	68 6b 77 10 f0       	push   $0xf010776b
f010257c:	68 07 04 00 00       	push   $0x407
f0102581:	68 45 77 10 f0       	push   $0xf0107745
f0102586:	e8 b5 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010258b:	68 eb 78 10 f0       	push   $0xf01078eb
f0102590:	68 6b 77 10 f0       	push   $0xf010776b
f0102595:	68 08 04 00 00       	push   $0x408
f010259a:	68 45 77 10 f0       	push   $0xf0107745
f010259f:	e8 9c da ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f01025a4:	68 45 79 10 f0       	push   $0xf0107945
f01025a9:	68 6b 77 10 f0       	push   $0xf010776b
f01025ae:	68 09 04 00 00       	push   $0x409
f01025b3:	68 45 77 10 f0       	push   $0xf0107745
f01025b8:	e8 83 da ff ff       	call   f0100040 <_panic>
	assert(page_insert(kern_pgdir, pp1, (void *)PGSIZE, 0) == 0);
f01025bd:	68 38 73 10 f0       	push   $0xf0107338
f01025c2:	68 6b 77 10 f0       	push   $0xf010776b
f01025c7:	68 0c 04 00 00       	push   $0x40c
f01025cc:	68 45 77 10 f0       	push   $0xf0107745
f01025d1:	e8 6a da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f01025d6:	68 56 79 10 f0       	push   $0xf0107956
f01025db:	68 6b 77 10 f0       	push   $0xf010776b
f01025e0:	68 0d 04 00 00       	push   $0x40d
f01025e5:	68 45 77 10 f0       	push   $0xf0107745
f01025ea:	e8 51 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f01025ef:	68 62 79 10 f0       	push   $0xf0107962
f01025f4:	68 6b 77 10 f0       	push   $0xf010776b
f01025f9:	68 0e 04 00 00       	push   $0x40e
f01025fe:	68 45 77 10 f0       	push   $0xf0107745
f0102603:	e8 38 da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0102608:	68 14 73 10 f0       	push   $0xf0107314
f010260d:	68 6b 77 10 f0       	push   $0xf010776b
f0102612:	68 12 04 00 00       	push   $0x412
f0102617:	68 45 77 10 f0       	push   $0xf0107745
f010261c:	e8 1f da ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102621:	68 70 73 10 f0       	push   $0xf0107370
f0102626:	68 6b 77 10 f0       	push   $0xf010776b
f010262b:	68 13 04 00 00       	push   $0x413
f0102630:	68 45 77 10 f0       	push   $0xf0107745
f0102635:	e8 06 da ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f010263a:	68 77 79 10 f0       	push   $0xf0107977
f010263f:	68 6b 77 10 f0       	push   $0xf010776b
f0102644:	68 14 04 00 00       	push   $0x414
f0102649:	68 45 77 10 f0       	push   $0xf0107745
f010264e:	e8 ed d9 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102653:	68 45 79 10 f0       	push   $0xf0107945
f0102658:	68 6b 77 10 f0       	push   $0xf010776b
f010265d:	68 15 04 00 00       	push   $0x415
f0102662:	68 45 77 10 f0       	push   $0xf0107745
f0102667:	e8 d4 d9 ff ff       	call   f0100040 <_panic>
	assert((pp = page_alloc(0)) && pp == pp1);
f010266c:	68 98 73 10 f0       	push   $0xf0107398
f0102671:	68 6b 77 10 f0       	push   $0xf010776b
f0102676:	68 18 04 00 00       	push   $0x418
f010267b:	68 45 77 10 f0       	push   $0xf0107745
f0102680:	e8 bb d9 ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0102685:	68 99 78 10 f0       	push   $0xf0107899
f010268a:	68 6b 77 10 f0       	push   $0xf010776b
f010268f:	68 1b 04 00 00       	push   $0x41b
f0102694:	68 45 77 10 f0       	push   $0xf0107745
f0102699:	e8 a2 d9 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010269e:	68 38 70 10 f0       	push   $0xf0107038
f01026a3:	68 6b 77 10 f0       	push   $0xf010776b
f01026a8:	68 1e 04 00 00       	push   $0x41e
f01026ad:	68 45 77 10 f0       	push   $0xf0107745
f01026b2:	e8 89 d9 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f01026b7:	68 fc 78 10 f0       	push   $0xf01078fc
f01026bc:	68 6b 77 10 f0       	push   $0xf010776b
f01026c1:	68 20 04 00 00       	push   $0x420
f01026c6:	68 45 77 10 f0       	push   $0xf0107745
f01026cb:	e8 70 d9 ff ff       	call   f0100040 <_panic>
f01026d0:	56                   	push   %esi
f01026d1:	68 04 68 10 f0       	push   $0xf0106804
f01026d6:	68 27 04 00 00       	push   $0x427
f01026db:	68 45 77 10 f0       	push   $0xf0107745
f01026e0:	e8 5b d9 ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f01026e5:	68 88 79 10 f0       	push   $0xf0107988
f01026ea:	68 6b 77 10 f0       	push   $0xf010776b
f01026ef:	68 28 04 00 00       	push   $0x428
f01026f4:	68 45 77 10 f0       	push   $0xf0107745
f01026f9:	e8 42 d9 ff ff       	call   f0100040 <_panic>
f01026fe:	51                   	push   %ecx
f01026ff:	68 04 68 10 f0       	push   $0xf0106804
f0102704:	6a 58                	push   $0x58
f0102706:	68 51 77 10 f0       	push   $0xf0107751
f010270b:	e8 30 d9 ff ff       	call   f0100040 <_panic>
f0102710:	52                   	push   %edx
f0102711:	68 04 68 10 f0       	push   $0xf0106804
f0102716:	6a 58                	push   $0x58
f0102718:	68 51 77 10 f0       	push   $0xf0107751
f010271d:	e8 1e d9 ff ff       	call   f0100040 <_panic>
		assert((ptep[i] & PTE_P) == 0);
f0102722:	68 a0 79 10 f0       	push   $0xf01079a0
f0102727:	68 6b 77 10 f0       	push   $0xf010776b
f010272c:	68 32 04 00 00       	push   $0x432
f0102731:	68 45 77 10 f0       	push   $0xf0107745
f0102736:	e8 05 d9 ff ff       	call   f0100040 <_panic>
	assert(mm1 >= MMIOBASE && mm1 + 8192 < MMIOLIM);
f010273b:	68 bc 73 10 f0       	push   $0xf01073bc
f0102740:	68 6b 77 10 f0       	push   $0xf010776b
f0102745:	68 42 04 00 00       	push   $0x442
f010274a:	68 45 77 10 f0       	push   $0xf0107745
f010274f:	e8 ec d8 ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8192 < MMIOLIM);
f0102754:	68 e4 73 10 f0       	push   $0xf01073e4
f0102759:	68 6b 77 10 f0       	push   $0xf010776b
f010275e:	68 43 04 00 00       	push   $0x443
f0102763:	68 45 77 10 f0       	push   $0xf0107745
f0102768:	e8 d3 d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f010276d:	68 0c 74 10 f0       	push   $0xf010740c
f0102772:	68 6b 77 10 f0       	push   $0xf010776b
f0102777:	68 45 04 00 00       	push   $0x445
f010277c:	68 45 77 10 f0       	push   $0xf0107745
f0102781:	e8 ba d8 ff ff       	call   f0100040 <_panic>
	assert(mm1 + 8192 <= mm2);
f0102786:	68 b7 79 10 f0       	push   $0xf01079b7
f010278b:	68 6b 77 10 f0       	push   $0xf010776b
f0102790:	68 47 04 00 00       	push   $0x447
f0102795:	68 45 77 10 f0       	push   $0xf0107745
f010279a:	e8 a1 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f010279f:	68 34 74 10 f0       	push   $0xf0107434
f01027a4:	68 6b 77 10 f0       	push   $0xf010776b
f01027a9:	68 49 04 00 00       	push   $0x449
f01027ae:	68 45 77 10 f0       	push   $0xf0107745
f01027b3:	e8 88 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1 + PGSIZE) == PGSIZE);
f01027b8:	68 58 74 10 f0       	push   $0xf0107458
f01027bd:	68 6b 77 10 f0       	push   $0xf010776b
f01027c2:	68 4a 04 00 00       	push   $0x44a
f01027c7:	68 45 77 10 f0       	push   $0xf0107745
f01027cc:	e8 6f d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f01027d1:	68 88 74 10 f0       	push   $0xf0107488
f01027d6:	68 6b 77 10 f0       	push   $0xf010776b
f01027db:	68 4b 04 00 00       	push   $0x44b
f01027e0:	68 45 77 10 f0       	push   $0xf0107745
f01027e5:	e8 56 d8 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2 + PGSIZE) == ~0);
f01027ea:	68 ac 74 10 f0       	push   $0xf01074ac
f01027ef:	68 6b 77 10 f0       	push   $0xf010776b
f01027f4:	68 4c 04 00 00       	push   $0x44c
f01027f9:	68 45 77 10 f0       	push   $0xf0107745
f01027fe:	e8 3d d8 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & (PTE_W | PTE_PWT | PTE_PCD));
f0102803:	68 d8 74 10 f0       	push   $0xf01074d8
f0102808:	68 6b 77 10 f0       	push   $0xf010776b
f010280d:	68 4e 04 00 00       	push   $0x44e
f0102812:	68 45 77 10 f0       	push   $0xf0107745
f0102817:	e8 24 d8 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void *)mm1, 0) & PTE_U));
f010281c:	68 20 75 10 f0       	push   $0xf0107520
f0102821:	68 6b 77 10 f0       	push   $0xf010776b
f0102826:	68 4f 04 00 00       	push   $0x44f
f010282b:	68 45 77 10 f0       	push   $0xf0107745
f0102830:	e8 0b d8 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102835:	50                   	push   %eax
f0102836:	68 28 68 10 f0       	push   $0xf0106828
f010283b:	68 b9 00 00 00       	push   $0xb9
f0102840:	68 45 77 10 f0       	push   $0xf0107745
f0102845:	e8 f6 d7 ff ff       	call   f0100040 <_panic>
f010284a:	50                   	push   %eax
f010284b:	68 28 68 10 f0       	push   $0xf0106828
f0102850:	68 c2 00 00 00       	push   $0xc2
f0102855:	68 45 77 10 f0       	push   $0xf0107745
f010285a:	e8 e1 d7 ff ff       	call   f0100040 <_panic>
f010285f:	50                   	push   %eax
f0102860:	68 28 68 10 f0       	push   $0xf0106828
f0102865:	68 d0 00 00 00       	push   $0xd0
f010286a:	68 45 77 10 f0       	push   $0xf0107745
f010286f:	e8 cc d7 ff ff       	call   f0100040 <_panic>
f0102874:	53                   	push   %ebx
f0102875:	68 28 68 10 f0       	push   $0xf0106828
f010287a:	68 13 01 00 00       	push   $0x113
f010287f:	68 45 77 10 f0       	push   $0xf0107745
f0102884:	e8 b7 d7 ff ff       	call   f0100040 <_panic>
f0102889:	56                   	push   %esi
f010288a:	68 28 68 10 f0       	push   $0xf0106828
f010288f:	68 64 03 00 00       	push   $0x364
f0102894:	68 45 77 10 f0       	push   $0xf0107745
f0102899:	e8 a2 d7 ff ff       	call   f0100040 <_panic>
	for (i = 0; i < n; i += PGSIZE)
f010289e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01028a4:	39 5d cc             	cmp    %ebx,-0x34(%ebp)
f01028a7:	76 3a                	jbe    f01028e3 <mem_init+0x161c>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01028a9:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01028af:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028b2:	e8 12 e2 ff ff       	call   f0100ac9 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01028b7:	81 7d c8 ff ff ff ef 	cmpl   $0xefffffff,-0x38(%ebp)
f01028be:	76 c9                	jbe    f0102889 <mem_init+0x15c2>
f01028c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01028c3:	8d 14 0b             	lea    (%ebx,%ecx,1),%edx
f01028c6:	39 d0                	cmp    %edx,%eax
f01028c8:	74 d4                	je     f010289e <mem_init+0x15d7>
f01028ca:	68 54 75 10 f0       	push   $0xf0107554
f01028cf:	68 6b 77 10 f0       	push   $0xf010776b
f01028d4:	68 64 03 00 00       	push   $0x364
f01028d9:	68 45 77 10 f0       	push   $0xf0107745
f01028de:	e8 5d d7 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01028e3:	a1 44 82 23 f0       	mov    0xf0238244,%eax
f01028e8:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01028eb:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01028ee:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01028f3:	8d b0 00 00 40 21    	lea    0x21400000(%eax),%esi
f01028f9:	89 da                	mov    %ebx,%edx
f01028fb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01028fe:	e8 c6 e1 ff ff       	call   f0100ac9 <check_va2pa>
f0102903:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f010290a:	76 3b                	jbe    f0102947 <mem_init+0x1680>
f010290c:	8d 14 1e             	lea    (%esi,%ebx,1),%edx
f010290f:	39 d0                	cmp    %edx,%eax
f0102911:	75 4b                	jne    f010295e <mem_init+0x1697>
f0102913:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
f0102919:	81 fb 00 10 c2 ee    	cmp    $0xeec21000,%ebx
f010291f:	75 d8                	jne    f01028f9 <mem_init+0x1632>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102921:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0102924:	c1 e6 0c             	shl    $0xc,%esi
f0102927:	89 fb                	mov    %edi,%ebx
f0102929:	39 f3                	cmp    %esi,%ebx
f010292b:	73 63                	jae    f0102990 <mem_init+0x16c9>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010292d:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102933:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102936:	e8 8e e1 ff ff       	call   f0100ac9 <check_va2pa>
f010293b:	39 c3                	cmp    %eax,%ebx
f010293d:	75 38                	jne    f0102977 <mem_init+0x16b0>
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010293f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102945:	eb e2                	jmp    f0102929 <mem_init+0x1662>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102947:	ff 75 c8             	pushl  -0x38(%ebp)
f010294a:	68 28 68 10 f0       	push   $0xf0106828
f010294f:	68 69 03 00 00       	push   $0x369
f0102954:	68 45 77 10 f0       	push   $0xf0107745
f0102959:	e8 e2 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010295e:	68 88 75 10 f0       	push   $0xf0107588
f0102963:	68 6b 77 10 f0       	push   $0xf010776b
f0102968:	68 69 03 00 00       	push   $0x369
f010296d:	68 45 77 10 f0       	push   $0xf0107745
f0102972:	e8 c9 d6 ff ff       	call   f0100040 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102977:	68 bc 75 10 f0       	push   $0xf01075bc
f010297c:	68 6b 77 10 f0       	push   $0xf010776b
f0102981:	68 6d 03 00 00       	push   $0x36d
f0102986:	68 45 77 10 f0       	push   $0xf0107745
f010298b:	e8 b0 d6 ff ff       	call   f0100040 <_panic>
f0102990:	c7 45 cc 00 a0 24 00 	movl   $0x24a000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102997:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
f010299c:	89 7d c0             	mov    %edi,-0x40(%ebp)
f010299f:	8d bb 00 80 ff ff    	lea    -0x8000(%ebx),%edi
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01029a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01029a8:	89 45 bc             	mov    %eax,-0x44(%ebp)
f01029ab:	89 de                	mov    %ebx,%esi
f01029ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01029b0:	05 00 80 ff 0f       	add    $0xfff8000,%eax
f01029b5:	89 45 c8             	mov    %eax,-0x38(%ebp)
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029b8:	8d 83 00 80 00 00    	lea    0x8000(%ebx),%eax
f01029be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f01029c1:	89 f2                	mov    %esi,%edx
f01029c3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029c6:	e8 fe e0 ff ff       	call   f0100ac9 <check_va2pa>
	if ((uint32_t)kva < KERNBASE)
f01029cb:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01029d2:	76 58                	jbe    f0102a2c <mem_init+0x1765>
f01029d4:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f01029d7:	8d 14 31             	lea    (%ecx,%esi,1),%edx
f01029da:	39 d0                	cmp    %edx,%eax
f01029dc:	75 65                	jne    f0102a43 <mem_init+0x177c>
f01029de:	81 c6 00 10 00 00    	add    $0x1000,%esi
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01029e4:	3b 75 c4             	cmp    -0x3c(%ebp),%esi
f01029e7:	75 d8                	jne    f01029c1 <mem_init+0x16fa>
			assert(check_va2pa(pgdir, base + i) == ~0);
f01029e9:	89 fa                	mov    %edi,%edx
f01029eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01029ee:	e8 d6 e0 ff ff       	call   f0100ac9 <check_va2pa>
f01029f3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029f6:	75 64                	jne    f0102a5c <mem_init+0x1795>
f01029f8:	81 c7 00 10 00 00    	add    $0x1000,%edi
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01029fe:	39 df                	cmp    %ebx,%edi
f0102a00:	75 e7                	jne    f01029e9 <mem_init+0x1722>
f0102a02:	81 eb 00 00 01 00    	sub    $0x10000,%ebx
f0102a08:	81 45 d0 00 80 00 00 	addl   $0x8000,-0x30(%ebp)
f0102a0f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102a12:	81 45 cc 00 80 01 00 	addl   $0x18000,-0x34(%ebp)
	for (n = 0; n < NCPU; n++)
f0102a19:	3d 00 a0 27 f0       	cmp    $0xf027a000,%eax
f0102a1e:	0f 85 7b ff ff ff    	jne    f010299f <mem_init+0x16d8>
f0102a24:	8b 7d c0             	mov    -0x40(%ebp),%edi
f0102a27:	e9 84 00 00 00       	jmp    f0102ab0 <mem_init+0x17e9>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102a2c:	ff 75 bc             	pushl  -0x44(%ebp)
f0102a2f:	68 28 68 10 f0       	push   $0xf0106828
f0102a34:	68 75 03 00 00       	push   $0x375
f0102a39:	68 45 77 10 f0       	push   $0xf0107745
f0102a3e:	e8 fd d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + KSTKGAP + i) == PADDR(percpu_kstacks[n]) + i);
f0102a43:	68 e4 75 10 f0       	push   $0xf01075e4
f0102a48:	68 6b 77 10 f0       	push   $0xf010776b
f0102a4d:	68 75 03 00 00       	push   $0x375
f0102a52:	68 45 77 10 f0       	push   $0xf0107745
f0102a57:	e8 e4 d5 ff ff       	call   f0100040 <_panic>
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102a5c:	68 2c 76 10 f0       	push   $0xf010762c
f0102a61:	68 6b 77 10 f0       	push   $0xf010776b
f0102a66:	68 77 03 00 00       	push   $0x377
f0102a6b:	68 45 77 10 f0       	push   $0xf0107745
f0102a70:	e8 cb d5 ff ff       	call   f0100040 <_panic>
			assert(pgdir[i] & PTE_P);
f0102a75:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a78:	f6 04 b8 01          	testb  $0x1,(%eax,%edi,4)
f0102a7c:	75 4e                	jne    f0102acc <mem_init+0x1805>
f0102a7e:	68 e2 79 10 f0       	push   $0xf01079e2
f0102a83:	68 6b 77 10 f0       	push   $0xf010776b
f0102a88:	68 84 03 00 00       	push   $0x384
f0102a8d:	68 45 77 10 f0       	push   $0xf0107745
f0102a92:	e8 a9 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_P);
f0102a97:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102a9a:	8b 04 b8             	mov    (%eax,%edi,4),%eax
f0102a9d:	a8 01                	test   $0x1,%al
f0102a9f:	74 30                	je     f0102ad1 <mem_init+0x180a>
				assert(pgdir[i] & PTE_W);
f0102aa1:	a8 02                	test   $0x2,%al
f0102aa3:	74 45                	je     f0102aea <mem_init+0x1823>
	for (i = 0; i < NPDENTRIES; i++)
f0102aa5:	83 c7 01             	add    $0x1,%edi
f0102aa8:	81 ff 00 04 00 00    	cmp    $0x400,%edi
f0102aae:	74 6c                	je     f0102b1c <mem_init+0x1855>
		switch (i)
f0102ab0:	8d 87 45 fc ff ff    	lea    -0x3bb(%edi),%eax
f0102ab6:	83 f8 04             	cmp    $0x4,%eax
f0102ab9:	76 ba                	jbe    f0102a75 <mem_init+0x17ae>
			if (i >= PDX(KERNBASE))
f0102abb:	81 ff bf 03 00 00    	cmp    $0x3bf,%edi
f0102ac1:	77 d4                	ja     f0102a97 <mem_init+0x17d0>
				assert(pgdir[i] == 0);
f0102ac3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ac6:	83 3c b8 00          	cmpl   $0x0,(%eax,%edi,4)
f0102aca:	75 37                	jne    f0102b03 <mem_init+0x183c>
	for (i = 0; i < NPDENTRIES; i++)
f0102acc:	83 c7 01             	add    $0x1,%edi
f0102acf:	eb df                	jmp    f0102ab0 <mem_init+0x17e9>
				assert(pgdir[i] & PTE_P);
f0102ad1:	68 e2 79 10 f0       	push   $0xf01079e2
f0102ad6:	68 6b 77 10 f0       	push   $0xf010776b
f0102adb:	68 89 03 00 00       	push   $0x389
f0102ae0:	68 45 77 10 f0       	push   $0xf0107745
f0102ae5:	e8 56 d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102aea:	68 f3 79 10 f0       	push   $0xf01079f3
f0102aef:	68 6b 77 10 f0       	push   $0xf010776b
f0102af4:	68 8a 03 00 00       	push   $0x38a
f0102af9:	68 45 77 10 f0       	push   $0xf0107745
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] == 0);
f0102b03:	68 04 7a 10 f0       	push   $0xf0107a04
f0102b08:	68 6b 77 10 f0       	push   $0xf010776b
f0102b0d:	68 8d 03 00 00       	push   $0x38d
f0102b12:	68 45 77 10 f0       	push   $0xf0107745
f0102b17:	e8 24 d5 ff ff       	call   f0100040 <_panic>
	cprintf("check_kern_pgdir() succeeded!\n");
f0102b1c:	83 ec 0c             	sub    $0xc,%esp
f0102b1f:	68 50 76 10 f0       	push   $0xf0107650
f0102b24:	e8 88 0d 00 00       	call   f01038b1 <cprintf>
	lcr3(PADDR(kern_pgdir));
f0102b29:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0102b2e:	83 c4 10             	add    $0x10,%esp
f0102b31:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b36:	0f 86 03 02 00 00    	jbe    f0102d3f <mem_init+0x1a78>
	return (physaddr_t)kva - KERNBASE;
f0102b3c:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102b41:	0f 22 d8             	mov    %eax,%cr3
	check_page_free_list(0);
f0102b44:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b49:	e8 de df ff ff       	call   f0100b2c <check_page_free_list>
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102b4e:	0f 20 c0             	mov    %cr0,%eax
	cr0 &= ~(CR0_TS | CR0_EM);
f0102b51:	83 e0 f3             	and    $0xfffffff3,%eax
f0102b54:	0d 23 00 05 80       	or     $0x80050023,%eax
	asm volatile("movl %0,%%cr0" : : "r" (val));
f0102b59:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102b5c:	83 ec 0c             	sub    $0xc,%esp
f0102b5f:	6a 00                	push   $0x0
f0102b61:	e8 9b e3 ff ff       	call   f0100f01 <page_alloc>
f0102b66:	89 c6                	mov    %eax,%esi
f0102b68:	83 c4 10             	add    $0x10,%esp
f0102b6b:	85 c0                	test   %eax,%eax
f0102b6d:	0f 84 e1 01 00 00    	je     f0102d54 <mem_init+0x1a8d>
	assert((pp1 = page_alloc(0)));
f0102b73:	83 ec 0c             	sub    $0xc,%esp
f0102b76:	6a 00                	push   $0x0
f0102b78:	e8 84 e3 ff ff       	call   f0100f01 <page_alloc>
f0102b7d:	89 c7                	mov    %eax,%edi
f0102b7f:	83 c4 10             	add    $0x10,%esp
f0102b82:	85 c0                	test   %eax,%eax
f0102b84:	0f 84 e3 01 00 00    	je     f0102d6d <mem_init+0x1aa6>
	assert((pp2 = page_alloc(0)));
f0102b8a:	83 ec 0c             	sub    $0xc,%esp
f0102b8d:	6a 00                	push   $0x0
f0102b8f:	e8 6d e3 ff ff       	call   f0100f01 <page_alloc>
f0102b94:	89 c3                	mov    %eax,%ebx
f0102b96:	83 c4 10             	add    $0x10,%esp
f0102b99:	85 c0                	test   %eax,%eax
f0102b9b:	0f 84 e5 01 00 00    	je     f0102d86 <mem_init+0x1abf>
	page_free(pp0);
f0102ba1:	83 ec 0c             	sub    $0xc,%esp
f0102ba4:	56                   	push   %esi
f0102ba5:	e8 d0 e3 ff ff       	call   f0100f7a <page_free>
	return (pp - pages) << PGSHIFT;
f0102baa:	89 f8                	mov    %edi,%eax
f0102bac:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0102bb2:	c1 f8 03             	sar    $0x3,%eax
f0102bb5:	89 c2                	mov    %eax,%edx
f0102bb7:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bba:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102bbf:	83 c4 10             	add    $0x10,%esp
f0102bc2:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0102bc8:	0f 83 d1 01 00 00    	jae    f0102d9f <mem_init+0x1ad8>
	memset(page2kva(pp1), 1, PGSIZE);
f0102bce:	83 ec 04             	sub    $0x4,%esp
f0102bd1:	68 00 10 00 00       	push   $0x1000
f0102bd6:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102bd8:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102bde:	52                   	push   %edx
f0102bdf:	e8 6b 2f 00 00       	call   f0105b4f <memset>
	return (pp - pages) << PGSHIFT;
f0102be4:	89 d8                	mov    %ebx,%eax
f0102be6:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0102bec:	c1 f8 03             	sar    $0x3,%eax
f0102bef:	89 c2                	mov    %eax,%edx
f0102bf1:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102bf4:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102bf9:	83 c4 10             	add    $0x10,%esp
f0102bfc:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0102c02:	0f 83 a9 01 00 00    	jae    f0102db1 <mem_init+0x1aea>
	memset(page2kva(pp2), 2, PGSIZE);
f0102c08:	83 ec 04             	sub    $0x4,%esp
f0102c0b:	68 00 10 00 00       	push   $0x1000
f0102c10:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f0102c12:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102c18:	52                   	push   %edx
f0102c19:	e8 31 2f 00 00       	call   f0105b4f <memset>
	page_insert(kern_pgdir, pp1, (void *)PGSIZE, PTE_W);
f0102c1e:	6a 02                	push   $0x2
f0102c20:	68 00 10 00 00       	push   $0x1000
f0102c25:	57                   	push   %edi
f0102c26:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0102c2c:	e8 b0 e5 ff ff       	call   f01011e1 <page_insert>
	assert(pp1->pp_ref == 1);
f0102c31:	83 c4 20             	add    $0x20,%esp
f0102c34:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102c39:	0f 85 84 01 00 00    	jne    f0102dc3 <mem_init+0x1afc>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102c3f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102c46:	01 01 01 
f0102c49:	0f 85 8d 01 00 00    	jne    f0102ddc <mem_init+0x1b15>
	page_insert(kern_pgdir, pp2, (void *)PGSIZE, PTE_W);
f0102c4f:	6a 02                	push   $0x2
f0102c51:	68 00 10 00 00       	push   $0x1000
f0102c56:	53                   	push   %ebx
f0102c57:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0102c5d:	e8 7f e5 ff ff       	call   f01011e1 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102c62:	83 c4 10             	add    $0x10,%esp
f0102c65:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102c6c:	02 02 02 
f0102c6f:	0f 85 80 01 00 00    	jne    f0102df5 <mem_init+0x1b2e>
	assert(pp2->pp_ref == 1);
f0102c75:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102c7a:	0f 85 8e 01 00 00    	jne    f0102e0e <mem_init+0x1b47>
	assert(pp1->pp_ref == 0);
f0102c80:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102c85:	0f 85 9c 01 00 00    	jne    f0102e27 <mem_init+0x1b60>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102c8b:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102c92:	03 03 03 
	return (pp - pages) << PGSHIFT;
f0102c95:	89 d8                	mov    %ebx,%eax
f0102c97:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0102c9d:	c1 f8 03             	sar    $0x3,%eax
f0102ca0:	89 c2                	mov    %eax,%edx
f0102ca2:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0102ca5:	25 ff ff 0f 00       	and    $0xfffff,%eax
f0102caa:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0102cb0:	0f 83 8a 01 00 00    	jae    f0102e40 <mem_init+0x1b79>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102cb6:	81 ba 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%edx)
f0102cbd:	03 03 03 
f0102cc0:	0f 85 8c 01 00 00    	jne    f0102e52 <mem_init+0x1b8b>
	page_remove(kern_pgdir, (void *)PGSIZE);
f0102cc6:	83 ec 08             	sub    $0x8,%esp
f0102cc9:	68 00 10 00 00       	push   $0x1000
f0102cce:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0102cd4:	e8 be e4 ff ff       	call   f0101197 <page_remove>
	assert(pp2->pp_ref == 0);
f0102cd9:	83 c4 10             	add    $0x10,%esp
f0102cdc:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102ce1:	0f 85 84 01 00 00    	jne    f0102e6b <mem_init+0x1ba4>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102ce7:	8b 0d 8c 8e 23 f0    	mov    0xf0238e8c,%ecx
f0102ced:	8b 11                	mov    (%ecx),%edx
f0102cef:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
	return (pp - pages) << PGSHIFT;
f0102cf5:	89 f0                	mov    %esi,%eax
f0102cf7:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0102cfd:	c1 f8 03             	sar    $0x3,%eax
f0102d00:	c1 e0 0c             	shl    $0xc,%eax
f0102d03:	39 c2                	cmp    %eax,%edx
f0102d05:	0f 85 79 01 00 00    	jne    f0102e84 <mem_init+0x1bbd>
	kern_pgdir[0] = 0;
f0102d0b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102d11:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102d16:	0f 85 81 01 00 00    	jne    f0102e9d <mem_init+0x1bd6>
	pp0->pp_ref = 0;
f0102d1c:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// free the pages we took
	page_free(pp0);
f0102d22:	83 ec 0c             	sub    $0xc,%esp
f0102d25:	56                   	push   %esi
f0102d26:	e8 4f e2 ff ff       	call   f0100f7a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102d2b:	c7 04 24 e4 76 10 f0 	movl   $0xf01076e4,(%esp)
f0102d32:	e8 7a 0b 00 00       	call   f01038b1 <cprintf>
}
f0102d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d3a:	5b                   	pop    %ebx
f0102d3b:	5e                   	pop    %esi
f0102d3c:	5f                   	pop    %edi
f0102d3d:	5d                   	pop    %ebp
f0102d3e:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102d3f:	50                   	push   %eax
f0102d40:	68 28 68 10 f0       	push   $0xf0106828
f0102d45:	68 e9 00 00 00       	push   $0xe9
f0102d4a:	68 45 77 10 f0       	push   $0xf0107745
f0102d4f:	e8 ec d2 ff ff       	call   f0100040 <_panic>
	assert((pp0 = page_alloc(0)));
f0102d54:	68 45 78 10 f0       	push   $0xf0107845
f0102d59:	68 6b 77 10 f0       	push   $0xf010776b
f0102d5e:	68 64 04 00 00       	push   $0x464
f0102d63:	68 45 77 10 f0       	push   $0xf0107745
f0102d68:	e8 d3 d2 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0102d6d:	68 5b 78 10 f0       	push   $0xf010785b
f0102d72:	68 6b 77 10 f0       	push   $0xf010776b
f0102d77:	68 65 04 00 00       	push   $0x465
f0102d7c:	68 45 77 10 f0       	push   $0xf0107745
f0102d81:	e8 ba d2 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102d86:	68 71 78 10 f0       	push   $0xf0107871
f0102d8b:	68 6b 77 10 f0       	push   $0xf010776b
f0102d90:	68 66 04 00 00       	push   $0x466
f0102d95:	68 45 77 10 f0       	push   $0xf0107745
f0102d9a:	e8 a1 d2 ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102d9f:	52                   	push   %edx
f0102da0:	68 04 68 10 f0       	push   $0xf0106804
f0102da5:	6a 58                	push   $0x58
f0102da7:	68 51 77 10 f0       	push   $0xf0107751
f0102dac:	e8 8f d2 ff ff       	call   f0100040 <_panic>
f0102db1:	52                   	push   %edx
f0102db2:	68 04 68 10 f0       	push   $0xf0106804
f0102db7:	6a 58                	push   $0x58
f0102db9:	68 51 77 10 f0       	push   $0xf0107751
f0102dbe:	e8 7d d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0102dc3:	68 eb 78 10 f0       	push   $0xf01078eb
f0102dc8:	68 6b 77 10 f0       	push   $0xf010776b
f0102dcd:	68 6b 04 00 00       	push   $0x46b
f0102dd2:	68 45 77 10 f0       	push   $0xf0107745
f0102dd7:	e8 64 d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102ddc:	68 70 76 10 f0       	push   $0xf0107670
f0102de1:	68 6b 77 10 f0       	push   $0xf010776b
f0102de6:	68 6c 04 00 00       	push   $0x46c
f0102deb:	68 45 77 10 f0       	push   $0xf0107745
f0102df0:	e8 4b d2 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102df5:	68 94 76 10 f0       	push   $0xf0107694
f0102dfa:	68 6b 77 10 f0       	push   $0xf010776b
f0102dff:	68 6e 04 00 00       	push   $0x46e
f0102e04:	68 45 77 10 f0       	push   $0xf0107745
f0102e09:	e8 32 d2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102e0e:	68 0d 79 10 f0       	push   $0xf010790d
f0102e13:	68 6b 77 10 f0       	push   $0xf010776b
f0102e18:	68 6f 04 00 00       	push   $0x46f
f0102e1d:	68 45 77 10 f0       	push   $0xf0107745
f0102e22:	e8 19 d2 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102e27:	68 77 79 10 f0       	push   $0xf0107977
f0102e2c:	68 6b 77 10 f0       	push   $0xf010776b
f0102e31:	68 70 04 00 00       	push   $0x470
f0102e36:	68 45 77 10 f0       	push   $0xf0107745
f0102e3b:	e8 00 d2 ff ff       	call   f0100040 <_panic>
f0102e40:	52                   	push   %edx
f0102e41:	68 04 68 10 f0       	push   $0xf0106804
f0102e46:	6a 58                	push   $0x58
f0102e48:	68 51 77 10 f0       	push   $0xf0107751
f0102e4d:	e8 ee d1 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102e52:	68 b8 76 10 f0       	push   $0xf01076b8
f0102e57:	68 6b 77 10 f0       	push   $0xf010776b
f0102e5c:	68 72 04 00 00       	push   $0x472
f0102e61:	68 45 77 10 f0       	push   $0xf0107745
f0102e66:	e8 d5 d1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102e6b:	68 45 79 10 f0       	push   $0xf0107945
f0102e70:	68 6b 77 10 f0       	push   $0xf010776b
f0102e75:	68 74 04 00 00       	push   $0x474
f0102e7a:	68 45 77 10 f0       	push   $0xf0107745
f0102e7f:	e8 bc d1 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e84:	68 38 70 10 f0       	push   $0xf0107038
f0102e89:	68 6b 77 10 f0       	push   $0xf010776b
f0102e8e:	68 77 04 00 00       	push   $0x477
f0102e93:	68 45 77 10 f0       	push   $0xf0107745
f0102e98:	e8 a3 d1 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0102e9d:	68 fc 78 10 f0       	push   $0xf01078fc
f0102ea2:	68 6b 77 10 f0       	push   $0xf010776b
f0102ea7:	68 79 04 00 00       	push   $0x479
f0102eac:	68 45 77 10 f0       	push   $0xf0107745
f0102eb1:	e8 8a d1 ff ff       	call   f0100040 <_panic>

f0102eb6 <user_mem_check>:
{
f0102eb6:	f3 0f 1e fb          	endbr32 
f0102eba:	55                   	push   %ebp
f0102ebb:	89 e5                	mov    %esp,%ebp
f0102ebd:	57                   	push   %edi
f0102ebe:	56                   	push   %esi
f0102ebf:	53                   	push   %ebx
f0102ec0:	83 ec 0c             	sub    $0xc,%esp
f0102ec3:	8b 75 14             	mov    0x14(%ebp),%esi
	uint32_t begin = (uint32_t)ROUNDDOWN(va, PGSIZE);
f0102ec6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102ec9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end = (uint32_t)ROUNDUP(va + len, PGSIZE);
f0102ecf:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0102ed2:	03 7d 10             	add    0x10(%ebp),%edi
f0102ed5:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
f0102edb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	for (i = (uint32_t)begin; i < end; i += PGSIZE)
f0102ee1:	eb 06                	jmp    f0102ee9 <user_mem_check+0x33>
f0102ee3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ee9:	39 fb                	cmp    %edi,%ebx
f0102eeb:	73 46                	jae    f0102f33 <user_mem_check+0x7d>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void *)i, 0);
f0102eed:	83 ec 04             	sub    $0x4,%esp
f0102ef0:	6a 00                	push   $0x0
f0102ef2:	53                   	push   %ebx
f0102ef3:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ef6:	ff 70 60             	pushl  0x60(%eax)
f0102ef9:	e8 e8 e0 ff ff       	call   f0100fe6 <pgdir_walk>
		if ((i >= ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm))
f0102efe:	83 c4 10             	add    $0x10,%esp
f0102f01:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102f07:	77 10                	ja     f0102f19 <user_mem_check+0x63>
f0102f09:	85 c0                	test   %eax,%eax
f0102f0b:	74 0c                	je     f0102f19 <user_mem_check+0x63>
f0102f0d:	8b 00                	mov    (%eax),%eax
f0102f0f:	a8 01                	test   $0x1,%al
f0102f11:	74 06                	je     f0102f19 <user_mem_check+0x63>
f0102f13:	21 f0                	and    %esi,%eax
f0102f15:	39 c6                	cmp    %eax,%esi
f0102f17:	74 ca                	je     f0102ee3 <user_mem_check+0x2d>
			user_mem_check_addr = (i < (uint32_t)va ? (uint32_t)va : i);
f0102f19:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
f0102f1c:	0f 42 5d 0c          	cmovb  0xc(%ebp),%ebx
f0102f20:	89 1d 3c 82 23 f0    	mov    %ebx,0xf023823c
			return -E_FAULT;
f0102f26:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
}
f0102f2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102f2e:	5b                   	pop    %ebx
f0102f2f:	5e                   	pop    %esi
f0102f30:	5f                   	pop    %edi
f0102f31:	5d                   	pop    %ebp
f0102f32:	c3                   	ret    
	return 0;
f0102f33:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f38:	eb f1                	jmp    f0102f2b <user_mem_check+0x75>

f0102f3a <user_mem_assert>:
{
f0102f3a:	f3 0f 1e fb          	endbr32 
f0102f3e:	55                   	push   %ebp
f0102f3f:	89 e5                	mov    %esp,%ebp
f0102f41:	53                   	push   %ebx
f0102f42:	83 ec 04             	sub    $0x4,%esp
f0102f45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0)
f0102f48:	8b 45 14             	mov    0x14(%ebp),%eax
f0102f4b:	83 c8 04             	or     $0x4,%eax
f0102f4e:	50                   	push   %eax
f0102f4f:	ff 75 10             	pushl  0x10(%ebp)
f0102f52:	ff 75 0c             	pushl  0xc(%ebp)
f0102f55:	53                   	push   %ebx
f0102f56:	e8 5b ff ff ff       	call   f0102eb6 <user_mem_check>
f0102f5b:	83 c4 10             	add    $0x10,%esp
f0102f5e:	85 c0                	test   %eax,%eax
f0102f60:	78 05                	js     f0102f67 <user_mem_assert+0x2d>
}
f0102f62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102f65:	c9                   	leave  
f0102f66:	c3                   	ret    
		cprintf("[%08x] user_mem_check assertion failure for "
f0102f67:	83 ec 04             	sub    $0x4,%esp
f0102f6a:	ff 35 3c 82 23 f0    	pushl  0xf023823c
f0102f70:	ff 73 48             	pushl  0x48(%ebx)
f0102f73:	68 10 77 10 f0       	push   $0xf0107710
f0102f78:	e8 34 09 00 00       	call   f01038b1 <cprintf>
		env_destroy(env); // may not return
f0102f7d:	89 1c 24             	mov    %ebx,(%esp)
f0102f80:	e8 41 06 00 00       	call   f01035c6 <env_destroy>
f0102f85:	83 c4 10             	add    $0x10,%esp
}
f0102f88:	eb d8                	jmp    f0102f62 <user_mem_assert+0x28>

f0102f8a <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102f8a:	55                   	push   %ebp
f0102f8b:	89 e5                	mov    %esp,%ebp
f0102f8d:	57                   	push   %edi
f0102f8e:	56                   	push   %esi
f0102f8f:	53                   	push   %ebx
f0102f90:	83 ec 0c             	sub    $0xc,%esp
f0102f93:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE), *end = ROUNDUP(va+len, PGSIZE);
f0102f95:	89 d3                	mov    %edx,%ebx
f0102f97:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0102f9d:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102fa4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	while (begin < end) {
f0102faa:	39 f3                	cmp    %esi,%ebx
f0102fac:	73 3f                	jae    f0102fed <region_alloc+0x63>
		struct PageInfo *pg = page_alloc(0);
f0102fae:	83 ec 0c             	sub    $0xc,%esp
f0102fb1:	6a 00                	push   $0x0
f0102fb3:	e8 49 df ff ff       	call   f0100f01 <page_alloc>
		if (!pg) {
f0102fb8:	83 c4 10             	add    $0x10,%esp
f0102fbb:	85 c0                	test   %eax,%eax
f0102fbd:	74 17                	je     f0102fd6 <region_alloc+0x4c>
			panic("region_alloc failed\n");
		}
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102fbf:	6a 06                	push   $0x6
f0102fc1:	53                   	push   %ebx
f0102fc2:	50                   	push   %eax
f0102fc3:	ff 77 60             	pushl  0x60(%edi)
f0102fc6:	e8 16 e2 ff ff       	call   f01011e1 <page_insert>
		begin += PGSIZE;
f0102fcb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102fd1:	83 c4 10             	add    $0x10,%esp
f0102fd4:	eb d4                	jmp    f0102faa <region_alloc+0x20>
			panic("region_alloc failed\n");
f0102fd6:	83 ec 04             	sub    $0x4,%esp
f0102fd9:	68 12 7a 10 f0       	push   $0xf0107a12
f0102fde:	68 29 01 00 00       	push   $0x129
f0102fe3:	68 27 7a 10 f0       	push   $0xf0107a27
f0102fe8:	e8 53 d0 ff ff       	call   f0100040 <_panic>
	}
}
f0102fed:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ff0:	5b                   	pop    %ebx
f0102ff1:	5e                   	pop    %esi
f0102ff2:	5f                   	pop    %edi
f0102ff3:	5d                   	pop    %ebp
f0102ff4:	c3                   	ret    

f0102ff5 <envid2env>:
{
f0102ff5:	f3 0f 1e fb          	endbr32 
f0102ff9:	55                   	push   %ebp
f0102ffa:	89 e5                	mov    %esp,%ebp
f0102ffc:	56                   	push   %esi
f0102ffd:	53                   	push   %ebx
f0102ffe:	8b 75 08             	mov    0x8(%ebp),%esi
f0103001:	8b 45 10             	mov    0x10(%ebp),%eax
	if (envid == 0) {
f0103004:	85 f6                	test   %esi,%esi
f0103006:	74 31                	je     f0103039 <envid2env+0x44>
	e = &envs[ENVX(envid)];
f0103008:	89 f3                	mov    %esi,%ebx
f010300a:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103010:	69 db 84 00 00 00    	imul   $0x84,%ebx,%ebx
f0103016:	03 1d 44 82 23 f0    	add    0xf0238244,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010301c:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103020:	74 2e                	je     f0103050 <envid2env+0x5b>
f0103022:	39 73 48             	cmp    %esi,0x48(%ebx)
f0103025:	75 29                	jne    f0103050 <envid2env+0x5b>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103027:	84 c0                	test   %al,%al
f0103029:	75 35                	jne    f0103060 <envid2env+0x6b>
	*env_store = e;
f010302b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010302e:	89 18                	mov    %ebx,(%eax)
	return 0;
f0103030:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103035:	5b                   	pop    %ebx
f0103036:	5e                   	pop    %esi
f0103037:	5d                   	pop    %ebp
f0103038:	c3                   	ret    
		*env_store = curenv;
f0103039:	e8 30 31 00 00       	call   f010616e <cpunum>
f010303e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103041:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103047:	8b 55 0c             	mov    0xc(%ebp),%edx
f010304a:	89 02                	mov    %eax,(%edx)
		return 0;
f010304c:	89 f0                	mov    %esi,%eax
f010304e:	eb e5                	jmp    f0103035 <envid2env+0x40>
		*env_store = 0;
f0103050:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103053:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0103059:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010305e:	eb d5                	jmp    f0103035 <envid2env+0x40>
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103060:	e8 09 31 00 00       	call   f010616e <cpunum>
f0103065:	6b c0 74             	imul   $0x74,%eax,%eax
f0103068:	39 98 28 90 23 f0    	cmp    %ebx,-0xfdc6fd8(%eax)
f010306e:	74 bb                	je     f010302b <envid2env+0x36>
f0103070:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0103073:	e8 f6 30 00 00       	call   f010616e <cpunum>
f0103078:	6b c0 74             	imul   $0x74,%eax,%eax
f010307b:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103081:	3b 70 48             	cmp    0x48(%eax),%esi
f0103084:	74 a5                	je     f010302b <envid2env+0x36>
		*env_store = 0;
f0103086:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103089:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010308f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0103094:	eb 9f                	jmp    f0103035 <envid2env+0x40>

f0103096 <env_init_percpu>:
{
f0103096:	f3 0f 1e fb          	endbr32 
	asm volatile("lgdt (%0)" : : "r" (p));
f010309a:	b8 20 33 12 f0       	mov    $0xf0123320,%eax
f010309f:	0f 01 10             	lgdtl  (%eax)
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f01030a2:	b8 23 00 00 00       	mov    $0x23,%eax
f01030a7:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f01030a9:	8e e0                	mov    %eax,%fs
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f01030ab:	b8 10 00 00 00       	mov    $0x10,%eax
f01030b0:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f01030b2:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f01030b4:	8e d0                	mov    %eax,%ss
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f01030b6:	ea bd 30 10 f0 08 00 	ljmp   $0x8,$0xf01030bd
	asm volatile("lldt %0" : : "r" (sel));
f01030bd:	b8 00 00 00 00       	mov    $0x0,%eax
f01030c2:	0f 00 d0             	lldt   %ax
}
f01030c5:	c3                   	ret    

f01030c6 <env_init>:
{
f01030c6:	f3 0f 1e fb          	endbr32 
f01030ca:	55                   	push   %ebp
f01030cb:	89 e5                	mov    %esp,%ebp
f01030cd:	56                   	push   %esi
f01030ce:	53                   	push   %ebx
		envs[i].env_id = 0;
f01030cf:	8b 35 44 82 23 f0    	mov    0xf0238244,%esi
f01030d5:	8d 86 7c 0f 02 00    	lea    0x20f7c(%esi),%eax
f01030db:	89 f3                	mov    %esi,%ebx
f01030dd:	ba 00 00 00 00       	mov    $0x0,%edx
f01030e2:	89 d1                	mov    %edx,%ecx
f01030e4:	89 c2                	mov    %eax,%edx
f01030e6:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01030ed:	89 48 44             	mov    %ecx,0x44(%eax)
f01030f0:	2d 84 00 00 00       	sub    $0x84,%eax
	for (int i = NENV - 1; i >= 0; i--) {		
f01030f5:	39 da                	cmp    %ebx,%edx
f01030f7:	75 e9                	jne    f01030e2 <env_init+0x1c>
f01030f9:	89 35 48 82 23 f0    	mov    %esi,0xf0238248
	env_init_percpu();
f01030ff:	e8 92 ff ff ff       	call   f0103096 <env_init_percpu>
}
f0103104:	5b                   	pop    %ebx
f0103105:	5e                   	pop    %esi
f0103106:	5d                   	pop    %ebp
f0103107:	c3                   	ret    

f0103108 <env_alloc>:
{
f0103108:	f3 0f 1e fb          	endbr32 
f010310c:	55                   	push   %ebp
f010310d:	89 e5                	mov    %esp,%ebp
f010310f:	53                   	push   %ebx
f0103110:	83 ec 04             	sub    $0x4,%esp
	if (!(e = env_free_list))
f0103113:	8b 1d 48 82 23 f0    	mov    0xf0238248,%ebx
f0103119:	85 db                	test   %ebx,%ebx
f010311b:	0f 84 88 01 00 00    	je     f01032a9 <env_alloc+0x1a1>
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103121:	83 ec 0c             	sub    $0xc,%esp
f0103124:	6a 01                	push   $0x1
f0103126:	e8 d6 dd ff ff       	call   f0100f01 <page_alloc>
f010312b:	83 c4 10             	add    $0x10,%esp
f010312e:	85 c0                	test   %eax,%eax
f0103130:	0f 84 7a 01 00 00    	je     f01032b0 <env_alloc+0x1a8>
	p->pp_ref++;
f0103136:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	return (pp - pages) << PGSHIFT;
f010313b:	2b 05 90 8e 23 f0    	sub    0xf0238e90,%eax
f0103141:	c1 f8 03             	sar    $0x3,%eax
f0103144:	89 c2                	mov    %eax,%edx
f0103146:	c1 e2 0c             	shl    $0xc,%edx
	if (PGNUM(pa) >= npages)
f0103149:	25 ff ff 0f 00       	and    $0xfffff,%eax
f010314e:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0103154:	0f 83 28 01 00 00    	jae    f0103282 <env_alloc+0x17a>
	return (void *)(pa + KERNBASE);
f010315a:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0103160:	89 43 60             	mov    %eax,0x60(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0103163:	83 ec 04             	sub    $0x4,%esp
f0103166:	68 00 10 00 00       	push   $0x1000
f010316b:	ff 35 8c 8e 23 f0    	pushl  0xf0238e8c
f0103171:	50                   	push   %eax
f0103172:	e8 8a 2a 00 00       	call   f0105c01 <memcpy>
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0103177:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f010317a:	83 c4 10             	add    $0x10,%esp
f010317d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103182:	0f 86 0c 01 00 00    	jbe    f0103294 <env_alloc+0x18c>
	return (physaddr_t)kva - KERNBASE;
f0103188:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010318e:	83 ca 05             	or     $0x5,%edx
f0103191:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103197:	8b 43 48             	mov    0x48(%ebx),%eax
f010319a:	05 00 10 00 00       	add    $0x1000,%eax
		generation = 1 << ENVGENSHIFT;
f010319f:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01031a4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01031a9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01031ac:	89 da                	mov    %ebx,%edx
f01031ae:	2b 15 44 82 23 f0    	sub    0xf0238244,%edx
f01031b4:	c1 fa 02             	sar    $0x2,%edx
f01031b7:	69 d2 e1 83 0f 3e    	imul   $0x3e0f83e1,%edx,%edx
f01031bd:	09 d0                	or     %edx,%eax
f01031bf:	89 43 48             	mov    %eax,0x48(%ebx)
	e->env_parent_id = parent_id;
f01031c2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01031c5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01031c8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01031cf:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01031d6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
	e->runtime=0;
f01031dd:	c7 43 7c 00 00 00 00 	movl   $0x0,0x7c(%ebx)
	e->Q=0;
f01031e4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
f01031eb:	00 00 00 
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01031ee:	83 ec 04             	sub    $0x4,%esp
f01031f1:	6a 44                	push   $0x44
f01031f3:	6a 00                	push   $0x0
f01031f5:	53                   	push   %ebx
f01031f6:	e8 54 29 00 00       	call   f0105b4f <memset>
	e->env_tf.tf_ds = GD_UD | 3;
f01031fb:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103201:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103207:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f010320d:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103214:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	e->env_tf.tf_eflags |= FL_IF;
f010321a:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)
	e->env_pgfault_upcall = 0;
f0103221:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)
	e->env_ipc_recving = 0;
f0103228:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env_free_list = e->env_link;
f010322c:	8b 43 44             	mov    0x44(%ebx),%eax
f010322f:	a3 48 82 23 f0       	mov    %eax,0xf0238248
	*newenv_store = e;
f0103234:	8b 45 08             	mov    0x8(%ebp),%eax
f0103237:	89 18                	mov    %ebx,(%eax)
	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103239:	8b 5b 48             	mov    0x48(%ebx),%ebx
f010323c:	e8 2d 2f 00 00       	call   f010616e <cpunum>
f0103241:	6b c0 74             	imul   $0x74,%eax,%eax
f0103244:	83 c4 10             	add    $0x10,%esp
f0103247:	ba 00 00 00 00       	mov    $0x0,%edx
f010324c:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0103253:	74 11                	je     f0103266 <env_alloc+0x15e>
f0103255:	e8 14 2f 00 00       	call   f010616e <cpunum>
f010325a:	6b c0 74             	imul   $0x74,%eax,%eax
f010325d:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0103263:	8b 50 48             	mov    0x48(%eax),%edx
f0103266:	83 ec 04             	sub    $0x4,%esp
f0103269:	53                   	push   %ebx
f010326a:	52                   	push   %edx
f010326b:	68 32 7a 10 f0       	push   $0xf0107a32
f0103270:	e8 3c 06 00 00       	call   f01038b1 <cprintf>
	return 0;
f0103275:	83 c4 10             	add    $0x10,%esp
f0103278:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010327d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103280:	c9                   	leave  
f0103281:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103282:	52                   	push   %edx
f0103283:	68 04 68 10 f0       	push   $0xf0106804
f0103288:	6a 58                	push   $0x58
f010328a:	68 51 77 10 f0       	push   $0xf0107751
f010328f:	e8 ac cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103294:	50                   	push   %eax
f0103295:	68 28 68 10 f0       	push   $0xf0106828
f010329a:	68 c5 00 00 00       	push   $0xc5
f010329f:	68 27 7a 10 f0       	push   $0xf0107a27
f01032a4:	e8 97 cd ff ff       	call   f0100040 <_panic>
		return -E_NO_FREE_ENV;
f01032a9:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f01032ae:	eb cd                	jmp    f010327d <env_alloc+0x175>
		return -E_NO_MEM;
f01032b0:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01032b5:	eb c6                	jmp    f010327d <env_alloc+0x175>

f01032b7 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f01032b7:	f3 0f 1e fb          	endbr32 
f01032bb:	55                   	push   %ebp
f01032bc:	89 e5                	mov    %esp,%ebp
f01032be:	57                   	push   %edi
f01032bf:	56                   	push   %esi
f01032c0:	53                   	push   %ebx
f01032c1:	83 ec 34             	sub    $0x34,%esp
f01032c4:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	struct Env *e;
	int r;
	if ((r = env_alloc(&e, 0) != 0)) {
f01032c7:	6a 00                	push   $0x0
f01032c9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01032cc:	50                   	push   %eax
f01032cd:	e8 36 fe ff ff       	call   f0103108 <env_alloc>
f01032d2:	83 c4 10             	add    $0x10,%esp
f01032d5:	85 c0                	test   %eax,%eax
f01032d7:	75 35                	jne    f010330e <env_create+0x57>
		panic("create env failed\n");
	}

	load_icode(e, binary);
f01032d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
	if (ELFHDR->e_magic != ELF_MAGIC) {
f01032dc:	81 3e 7f 45 4c 46    	cmpl   $0x464c457f,(%esi)
f01032e2:	75 41                	jne    f0103325 <env_create+0x6e>
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f01032e4:	8b 5e 1c             	mov    0x1c(%esi),%ebx
	ph_num = ELFHDR->e_phnum;
f01032e7:	0f b7 46 2c          	movzwl 0x2c(%esi),%eax
	lcr3(PADDR(e->env_pgdir));			
f01032eb:	8b 57 60             	mov    0x60(%edi),%edx
	if ((uint32_t)kva < KERNBASE)
f01032ee:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01032f4:	76 46                	jbe    f010333c <env_create+0x85>
	return (physaddr_t)kva - KERNBASE;
f01032f6:	81 c2 00 00 00 10    	add    $0x10000000,%edx
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01032fc:	0f 22 da             	mov    %edx,%cr3
f01032ff:	01 f3                	add    %esi,%ebx
f0103301:	0f b7 c0             	movzwl %ax,%eax
f0103304:	c1 e0 05             	shl    $0x5,%eax
f0103307:	01 d8                	add    %ebx,%eax
f0103309:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (int i = 0; i < ph_num; i++) {
f010330c:	eb 7a                	jmp    f0103388 <env_create+0xd1>
		panic("create env failed\n");
f010330e:	83 ec 04             	sub    $0x4,%esp
f0103311:	68 47 7a 10 f0       	push   $0xf0107a47
f0103316:	68 90 01 00 00       	push   $0x190
f010331b:	68 27 7a 10 f0       	push   $0xf0107a27
f0103320:	e8 1b cd ff ff       	call   f0100040 <_panic>
		panic("binary is not ELF format\n");
f0103325:	83 ec 04             	sub    $0x4,%esp
f0103328:	68 5a 7a 10 f0       	push   $0xf0107a5a
f010332d:	68 6a 01 00 00       	push   $0x16a
f0103332:	68 27 7a 10 f0       	push   $0xf0107a27
f0103337:	e8 04 cd ff ff       	call   f0100040 <_panic>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010333c:	52                   	push   %edx
f010333d:	68 28 68 10 f0       	push   $0xf0106828
f0103342:	68 6f 01 00 00       	push   $0x16f
f0103347:	68 27 7a 10 f0       	push   $0xf0107a27
f010334c:	e8 ef cc ff ff       	call   f0100040 <_panic>
			region_alloc(e, (void *)ph[i].p_va, ph[i].p_memsz);
f0103351:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103354:	8b 53 08             	mov    0x8(%ebx),%edx
f0103357:	89 f8                	mov    %edi,%eax
f0103359:	e8 2c fc ff ff       	call   f0102f8a <region_alloc>
			memset((void *)ph[i].p_va, 0, ph[i].p_memsz);		
f010335e:	83 ec 04             	sub    $0x4,%esp
f0103361:	ff 73 14             	pushl  0x14(%ebx)
f0103364:	6a 00                	push   $0x0
f0103366:	ff 73 08             	pushl  0x8(%ebx)
f0103369:	e8 e1 27 00 00       	call   f0105b4f <memset>
			memcpy((void *)ph[i].p_va, binary + ph[i].p_offset, ph[i].p_filesz); 
f010336e:	83 c4 0c             	add    $0xc,%esp
f0103371:	ff 73 10             	pushl  0x10(%ebx)
f0103374:	89 f0                	mov    %esi,%eax
f0103376:	03 43 04             	add    0x4(%ebx),%eax
f0103379:	50                   	push   %eax
f010337a:	ff 73 08             	pushl  0x8(%ebx)
f010337d:	e8 7f 28 00 00       	call   f0105c01 <memcpy>
f0103382:	83 c4 10             	add    $0x10,%esp
f0103385:	83 c3 20             	add    $0x20,%ebx
	for (int i = 0; i < ph_num; i++) {
f0103388:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
f010338b:	74 07                	je     f0103394 <env_create+0xdd>
		if (ph[i].p_type == ELF_PROG_LOAD) {	
f010338d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103390:	75 f3                	jne    f0103385 <env_create+0xce>
f0103392:	eb bd                	jmp    f0103351 <env_create+0x9a>
	lcr3(PADDR(kern_pgdir));
f0103394:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103399:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010339e:	76 30                	jbe    f01033d0 <env_create+0x119>
	return (physaddr_t)kva - KERNBASE;
f01033a0:	05 00 00 00 10       	add    $0x10000000,%eax
f01033a5:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01033a8:	8b 46 18             	mov    0x18(%esi),%eax
f01033ab:	89 47 30             	mov    %eax,0x30(%edi)
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01033ae:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01033b3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01033b8:	89 f8                	mov    %edi,%eax
f01033ba:	e8 cb fb ff ff       	call   f0102f8a <region_alloc>
	e->env_type = type;
f01033bf:	8b 55 0c             	mov    0xc(%ebp),%edx
f01033c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01033c5:	89 50 50             	mov    %edx,0x50(%eax)
}
f01033c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01033cb:	5b                   	pop    %ebx
f01033cc:	5e                   	pop    %esi
f01033cd:	5f                   	pop    %edi
f01033ce:	5d                   	pop    %ebp
f01033cf:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033d0:	50                   	push   %eax
f01033d1:	68 28 68 10 f0       	push   $0xf0106828
f01033d6:	68 78 01 00 00       	push   $0x178
f01033db:	68 27 7a 10 f0       	push   $0xf0107a27
f01033e0:	e8 5b cc ff ff       	call   f0100040 <_panic>

f01033e5 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01033e5:	f3 0f 1e fb          	endbr32 
f01033e9:	55                   	push   %ebp
f01033ea:	89 e5                	mov    %esp,%ebp
f01033ec:	57                   	push   %edi
f01033ed:	56                   	push   %esi
f01033ee:	53                   	push   %ebx
f01033ef:	83 ec 1c             	sub    $0x1c,%esp
f01033f2:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01033f5:	e8 74 2d 00 00       	call   f010616e <cpunum>
f01033fa:	6b c0 74             	imul   $0x74,%eax,%eax
f01033fd:	39 b8 28 90 23 f0    	cmp    %edi,-0xfdc6fd8(%eax)
f0103403:	74 48                	je     f010344d <env_free+0x68>
		lcr3(PADDR(kern_pgdir));

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103405:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103408:	e8 61 2d 00 00       	call   f010616e <cpunum>
f010340d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103410:	ba 00 00 00 00       	mov    $0x0,%edx
f0103415:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f010341c:	74 11                	je     f010342f <env_free+0x4a>
f010341e:	e8 4b 2d 00 00       	call   f010616e <cpunum>
f0103423:	6b c0 74             	imul   $0x74,%eax,%eax
f0103426:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010342c:	8b 50 48             	mov    0x48(%eax),%edx
f010342f:	83 ec 04             	sub    $0x4,%esp
f0103432:	53                   	push   %ebx
f0103433:	52                   	push   %edx
f0103434:	68 74 7a 10 f0       	push   $0xf0107a74
f0103439:	e8 73 04 00 00       	call   f01038b1 <cprintf>
f010343e:	83 c4 10             	add    $0x10,%esp
f0103441:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103448:	e9 a9 00 00 00       	jmp    f01034f6 <env_free+0x111>
		lcr3(PADDR(kern_pgdir));
f010344d:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0103452:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103457:	76 0a                	jbe    f0103463 <env_free+0x7e>
	return (physaddr_t)kva - KERNBASE;
f0103459:	05 00 00 00 10       	add    $0x10000000,%eax
f010345e:	0f 22 d8             	mov    %eax,%cr3
}
f0103461:	eb a2                	jmp    f0103405 <env_free+0x20>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103463:	50                   	push   %eax
f0103464:	68 28 68 10 f0       	push   $0xf0106828
f0103469:	68 a5 01 00 00       	push   $0x1a5
f010346e:	68 27 7a 10 f0       	push   $0xf0107a27
f0103473:	e8 c8 cb ff ff       	call   f0100040 <_panic>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103478:	56                   	push   %esi
f0103479:	68 04 68 10 f0       	push   $0xf0106804
f010347e:	68 b4 01 00 00       	push   $0x1b4
f0103483:	68 27 7a 10 f0       	push   $0xf0107a27
f0103488:	e8 b3 cb ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f010348d:	83 ec 08             	sub    $0x8,%esp
f0103490:	89 d8                	mov    %ebx,%eax
f0103492:	c1 e0 0c             	shl    $0xc,%eax
f0103495:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0103498:	50                   	push   %eax
f0103499:	ff 77 60             	pushl  0x60(%edi)
f010349c:	e8 f6 dc ff ff       	call   f0101197 <page_remove>
f01034a1:	83 c4 10             	add    $0x10,%esp
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01034a4:	83 c3 01             	add    $0x1,%ebx
f01034a7:	83 c6 04             	add    $0x4,%esi
f01034aa:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01034b0:	74 07                	je     f01034b9 <env_free+0xd4>
			if (pt[pteno] & PTE_P)
f01034b2:	f6 06 01             	testb  $0x1,(%esi)
f01034b5:	74 ed                	je     f01034a4 <env_free+0xbf>
f01034b7:	eb d4                	jmp    f010348d <env_free+0xa8>
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01034b9:	8b 47 60             	mov    0x60(%edi),%eax
f01034bc:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034bf:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	if (PGNUM(pa) >= npages)
f01034c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01034c9:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f01034cf:	73 65                	jae    f0103536 <env_free+0x151>
		page_decref(pa2page(pa));
f01034d1:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f01034d4:	a1 90 8e 23 f0       	mov    0xf0238e90,%eax
f01034d9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01034dc:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01034df:	50                   	push   %eax
f01034e0:	e8 d4 da ff ff       	call   f0100fb9 <page_decref>
f01034e5:	83 c4 10             	add    $0x10,%esp
f01034e8:	83 45 e0 04          	addl   $0x4,-0x20(%ebp)
f01034ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01034ef:	3d ec 0e 00 00       	cmp    $0xeec,%eax
f01034f4:	74 54                	je     f010354a <env_free+0x165>
		if (!(e->env_pgdir[pdeno] & PTE_P))
f01034f6:	8b 47 60             	mov    0x60(%edi),%eax
f01034f9:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01034fc:	8b 04 10             	mov    (%eax,%edx,1),%eax
f01034ff:	a8 01                	test   $0x1,%al
f0103501:	74 e5                	je     f01034e8 <env_free+0x103>
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103503:	89 c6                	mov    %eax,%esi
f0103505:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	if (PGNUM(pa) >= npages)
f010350b:	c1 e8 0c             	shr    $0xc,%eax
f010350e:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0103511:	39 05 88 8e 23 f0    	cmp    %eax,0xf0238e88
f0103517:	0f 86 5b ff ff ff    	jbe    f0103478 <env_free+0x93>
	return (void *)(pa + KERNBASE);
f010351d:	81 ee 00 00 00 10    	sub    $0x10000000,%esi
f0103523:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103526:	c1 e0 14             	shl    $0x14,%eax
f0103529:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f010352c:	bb 00 00 00 00       	mov    $0x0,%ebx
f0103531:	e9 7c ff ff ff       	jmp    f01034b2 <env_free+0xcd>
		panic("pa2page called with invalid pa");
f0103536:	83 ec 04             	sub    $0x4,%esp
f0103539:	68 a8 6e 10 f0       	push   $0xf0106ea8
f010353e:	6a 51                	push   $0x51
f0103540:	68 51 77 10 f0       	push   $0xf0107751
f0103545:	e8 f6 ca ff ff       	call   f0100040 <_panic>
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010354a:	8b 47 60             	mov    0x60(%edi),%eax
	if ((uint32_t)kva < KERNBASE)
f010354d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103552:	76 49                	jbe    f010359d <env_free+0x1b8>
	e->env_pgdir = 0;
f0103554:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
	return (physaddr_t)kva - KERNBASE;
f010355b:	05 00 00 00 10       	add    $0x10000000,%eax
	if (PGNUM(pa) >= npages)
f0103560:	c1 e8 0c             	shr    $0xc,%eax
f0103563:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0103569:	73 47                	jae    f01035b2 <env_free+0x1cd>
	page_decref(pa2page(pa));
f010356b:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010356e:	8b 15 90 8e 23 f0    	mov    0xf0238e90,%edx
f0103574:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103577:	50                   	push   %eax
f0103578:	e8 3c da ff ff       	call   f0100fb9 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f010357d:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103584:	a1 48 82 23 f0       	mov    0xf0238248,%eax
f0103589:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f010358c:	89 3d 48 82 23 f0    	mov    %edi,0xf0238248
}
f0103592:	83 c4 10             	add    $0x10,%esp
f0103595:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103598:	5b                   	pop    %ebx
f0103599:	5e                   	pop    %esi
f010359a:	5f                   	pop    %edi
f010359b:	5d                   	pop    %ebp
f010359c:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010359d:	50                   	push   %eax
f010359e:	68 28 68 10 f0       	push   $0xf0106828
f01035a3:	68 c2 01 00 00       	push   $0x1c2
f01035a8:	68 27 7a 10 f0       	push   $0xf0107a27
f01035ad:	e8 8e ca ff ff       	call   f0100040 <_panic>
		panic("pa2page called with invalid pa");
f01035b2:	83 ec 04             	sub    $0x4,%esp
f01035b5:	68 a8 6e 10 f0       	push   $0xf0106ea8
f01035ba:	6a 51                	push   $0x51
f01035bc:	68 51 77 10 f0       	push   $0xf0107751
f01035c1:	e8 7a ca ff ff       	call   f0100040 <_panic>

f01035c6 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01035c6:	f3 0f 1e fb          	endbr32 
f01035ca:	55                   	push   %ebp
f01035cb:	89 e5                	mov    %esp,%ebp
f01035cd:	53                   	push   %ebx
f01035ce:	83 ec 04             	sub    $0x4,%esp
f01035d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035d4:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01035d8:	74 21                	je     f01035fb <env_destroy+0x35>
		e->env_status = ENV_DYING;
		return;
	}

	env_free(e);
f01035da:	83 ec 0c             	sub    $0xc,%esp
f01035dd:	53                   	push   %ebx
f01035de:	e8 02 fe ff ff       	call   f01033e5 <env_free>

	if (curenv == e) {
f01035e3:	e8 86 2b 00 00       	call   f010616e <cpunum>
f01035e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01035eb:	83 c4 10             	add    $0x10,%esp
f01035ee:	39 98 28 90 23 f0    	cmp    %ebx,-0xfdc6fd8(%eax)
f01035f4:	74 1e                	je     f0103614 <env_destroy+0x4e>
		curenv = NULL;
		sched_yield();
	}
}
f01035f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01035f9:	c9                   	leave  
f01035fa:	c3                   	ret    
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01035fb:	e8 6e 2b 00 00       	call   f010616e <cpunum>
f0103600:	6b c0 74             	imul   $0x74,%eax,%eax
f0103603:	39 98 28 90 23 f0    	cmp    %ebx,-0xfdc6fd8(%eax)
f0103609:	74 cf                	je     f01035da <env_destroy+0x14>
		e->env_status = ENV_DYING;
f010360b:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103612:	eb e2                	jmp    f01035f6 <env_destroy+0x30>
		curenv = NULL;
f0103614:	e8 55 2b 00 00       	call   f010616e <cpunum>
f0103619:	6b c0 74             	imul   $0x74,%eax,%eax
f010361c:	c7 80 28 90 23 f0 00 	movl   $0x0,-0xfdc6fd8(%eax)
f0103623:	00 00 00 
		sched_yield();
f0103626:	e8 8a 10 00 00       	call   f01046b5 <sched_yield>

f010362b <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f010362b:	f3 0f 1e fb          	endbr32 
f010362f:	55                   	push   %ebp
f0103630:	89 e5                	mov    %esp,%ebp
f0103632:	53                   	push   %ebx
f0103633:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103636:	e8 33 2b 00 00       	call   f010616e <cpunum>
f010363b:	6b c0 74             	imul   $0x74,%eax,%eax
f010363e:	8b 98 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%ebx
f0103644:	e8 25 2b 00 00       	call   f010616e <cpunum>
f0103649:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010364c:	8b 65 08             	mov    0x8(%ebp),%esp
f010364f:	61                   	popa   
f0103650:	07                   	pop    %es
f0103651:	1f                   	pop    %ds
f0103652:	83 c4 08             	add    $0x8,%esp
f0103655:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103656:	83 ec 04             	sub    $0x4,%esp
f0103659:	68 8a 7a 10 f0       	push   $0xf0107a8a
f010365e:	68 f9 01 00 00       	push   $0x1f9
f0103663:	68 27 7a 10 f0       	push   $0xf0107a27
f0103668:	e8 d3 c9 ff ff       	call   f0100040 <_panic>

f010366d <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f010366d:	f3 0f 1e fb          	endbr32 
f0103671:	55                   	push   %ebp
f0103672:	89 e5                	mov    %esp,%ebp
f0103674:	53                   	push   %ebx
f0103675:	83 ec 04             	sub    $0x4,%esp
f0103678:	8b 5d 08             	mov    0x8(%ebp),%ebx
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	if (curenv != NULL && curenv->env_status == ENV_RUNNING) {	
f010367b:	e8 ee 2a 00 00       	call   f010616e <cpunum>
f0103680:	6b c0 74             	imul   $0x74,%eax,%eax
f0103683:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f010368a:	74 14                	je     f01036a0 <env_run+0x33>
f010368c:	e8 dd 2a 00 00       	call   f010616e <cpunum>
f0103691:	6b c0 74             	imul   $0x74,%eax,%eax
f0103694:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010369a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010369e:	74 42                	je     f01036e2 <env_run+0x75>
		curenv->env_status = ENV_RUNNABLE;
	}
	curenv = e;
f01036a0:	e8 c9 2a 00 00       	call   f010616e <cpunum>
f01036a5:	6b c0 74             	imul   $0x74,%eax,%eax
f01036a8:	89 98 28 90 23 f0    	mov    %ebx,-0xfdc6fd8(%eax)
	e->env_status = ENV_RUNNING;
f01036ae:	c7 43 54 03 00 00 00 	movl   $0x3,0x54(%ebx)
	e->env_runs++;
f01036b5:	83 43 58 01          	addl   $0x1,0x58(%ebx)
	lcr3(PADDR(e->env_pgdir));
f01036b9:	8b 43 60             	mov    0x60(%ebx),%eax
	if ((uint32_t)kva < KERNBASE)
f01036bc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01036c1:	76 36                	jbe    f01036f9 <env_run+0x8c>
	return (physaddr_t)kva - KERNBASE;
f01036c3:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01036c8:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01036cb:	83 ec 0c             	sub    $0xc,%esp
f01036ce:	68 c0 33 12 f0       	push   $0xf01233c0
f01036d3:	e8 bc 2d 00 00       	call   f0106494 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01036d8:	f3 90                	pause  
	unlock_kernel();						
	env_pop_tf(&e->env_tf);
f01036da:	89 1c 24             	mov    %ebx,(%esp)
f01036dd:	e8 49 ff ff ff       	call   f010362b <env_pop_tf>
		curenv->env_status = ENV_RUNNABLE;
f01036e2:	e8 87 2a 00 00       	call   f010616e <cpunum>
f01036e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01036ea:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01036f0:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01036f7:	eb a7                	jmp    f01036a0 <env_run+0x33>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01036f9:	50                   	push   %eax
f01036fa:	68 28 68 10 f0       	push   $0xf0106828
f01036ff:	68 1d 02 00 00       	push   $0x21d
f0103704:	68 27 7a 10 f0       	push   $0xf0107a27
f0103709:	e8 32 c9 ff ff       	call   f0100040 <_panic>

f010370e <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f010370e:	f3 0f 1e fb          	endbr32 
f0103712:	55                   	push   %ebp
f0103713:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103715:	8b 45 08             	mov    0x8(%ebp),%eax
f0103718:	ba 70 00 00 00       	mov    $0x70,%edx
f010371d:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010371e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103723:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103724:	0f b6 c0             	movzbl %al,%eax
}
f0103727:	5d                   	pop    %ebp
f0103728:	c3                   	ret    

f0103729 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103729:	f3 0f 1e fb          	endbr32 
f010372d:	55                   	push   %ebp
f010372e:	89 e5                	mov    %esp,%ebp
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103730:	8b 45 08             	mov    0x8(%ebp),%eax
f0103733:	ba 70 00 00 00       	mov    $0x70,%edx
f0103738:	ee                   	out    %al,(%dx)
f0103739:	8b 45 0c             	mov    0xc(%ebp),%eax
f010373c:	ba 71 00 00 00       	mov    $0x71,%edx
f0103741:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103742:	5d                   	pop    %ebp
f0103743:	c3                   	ret    

f0103744 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103744:	f3 0f 1e fb          	endbr32 
f0103748:	55                   	push   %ebp
f0103749:	89 e5                	mov    %esp,%ebp
f010374b:	56                   	push   %esi
f010374c:	53                   	push   %ebx
f010374d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103750:	66 a3 a8 33 12 f0    	mov    %ax,0xf01233a8
	if (!didinit)
f0103756:	80 3d 4c 82 23 f0 00 	cmpb   $0x0,0xf023824c
f010375d:	75 07                	jne    f0103766 <irq_setmask_8259A+0x22>
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
}
f010375f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103762:	5b                   	pop    %ebx
f0103763:	5e                   	pop    %esi
f0103764:	5d                   	pop    %ebp
f0103765:	c3                   	ret    
f0103766:	89 c6                	mov    %eax,%esi
f0103768:	ba 21 00 00 00       	mov    $0x21,%edx
f010376d:	ee                   	out    %al,(%dx)
	outb(IO_PIC2+1, (char)(mask >> 8));
f010376e:	66 c1 e8 08          	shr    $0x8,%ax
f0103772:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103777:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103778:	83 ec 0c             	sub    $0xc,%esp
f010377b:	68 96 7a 10 f0       	push   $0xf0107a96
f0103780:	e8 2c 01 00 00       	call   f01038b1 <cprintf>
f0103785:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103788:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010378d:	0f b7 f6             	movzwl %si,%esi
f0103790:	f7 d6                	not    %esi
f0103792:	eb 19                	jmp    f01037ad <irq_setmask_8259A+0x69>
			cprintf(" %d", i);
f0103794:	83 ec 08             	sub    $0x8,%esp
f0103797:	53                   	push   %ebx
f0103798:	68 8b 7f 10 f0       	push   $0xf0107f8b
f010379d:	e8 0f 01 00 00       	call   f01038b1 <cprintf>
f01037a2:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f01037a5:	83 c3 01             	add    $0x1,%ebx
f01037a8:	83 fb 10             	cmp    $0x10,%ebx
f01037ab:	74 07                	je     f01037b4 <irq_setmask_8259A+0x70>
		if (~mask & (1<<i))
f01037ad:	0f a3 de             	bt     %ebx,%esi
f01037b0:	73 f3                	jae    f01037a5 <irq_setmask_8259A+0x61>
f01037b2:	eb e0                	jmp    f0103794 <irq_setmask_8259A+0x50>
	cprintf("\n");
f01037b4:	83 ec 0c             	sub    $0xc,%esp
f01037b7:	68 e0 79 10 f0       	push   $0xf01079e0
f01037bc:	e8 f0 00 00 00       	call   f01038b1 <cprintf>
f01037c1:	83 c4 10             	add    $0x10,%esp
f01037c4:	eb 99                	jmp    f010375f <irq_setmask_8259A+0x1b>

f01037c6 <pic_init>:
{
f01037c6:	f3 0f 1e fb          	endbr32 
f01037ca:	55                   	push   %ebp
f01037cb:	89 e5                	mov    %esp,%ebp
f01037cd:	57                   	push   %edi
f01037ce:	56                   	push   %esi
f01037cf:	53                   	push   %ebx
f01037d0:	83 ec 0c             	sub    $0xc,%esp
	didinit = 1;
f01037d3:	c6 05 4c 82 23 f0 01 	movb   $0x1,0xf023824c
f01037da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01037df:	bb 21 00 00 00       	mov    $0x21,%ebx
f01037e4:	89 da                	mov    %ebx,%edx
f01037e6:	ee                   	out    %al,(%dx)
f01037e7:	b9 a1 00 00 00       	mov    $0xa1,%ecx
f01037ec:	89 ca                	mov    %ecx,%edx
f01037ee:	ee                   	out    %al,(%dx)
f01037ef:	bf 11 00 00 00       	mov    $0x11,%edi
f01037f4:	be 20 00 00 00       	mov    $0x20,%esi
f01037f9:	89 f8                	mov    %edi,%eax
f01037fb:	89 f2                	mov    %esi,%edx
f01037fd:	ee                   	out    %al,(%dx)
f01037fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0103803:	89 da                	mov    %ebx,%edx
f0103805:	ee                   	out    %al,(%dx)
f0103806:	b8 04 00 00 00       	mov    $0x4,%eax
f010380b:	ee                   	out    %al,(%dx)
f010380c:	b8 03 00 00 00       	mov    $0x3,%eax
f0103811:	ee                   	out    %al,(%dx)
f0103812:	bb a0 00 00 00       	mov    $0xa0,%ebx
f0103817:	89 f8                	mov    %edi,%eax
f0103819:	89 da                	mov    %ebx,%edx
f010381b:	ee                   	out    %al,(%dx)
f010381c:	b8 28 00 00 00       	mov    $0x28,%eax
f0103821:	89 ca                	mov    %ecx,%edx
f0103823:	ee                   	out    %al,(%dx)
f0103824:	b8 02 00 00 00       	mov    $0x2,%eax
f0103829:	ee                   	out    %al,(%dx)
f010382a:	b8 01 00 00 00       	mov    $0x1,%eax
f010382f:	ee                   	out    %al,(%dx)
f0103830:	bf 68 00 00 00       	mov    $0x68,%edi
f0103835:	89 f8                	mov    %edi,%eax
f0103837:	89 f2                	mov    %esi,%edx
f0103839:	ee                   	out    %al,(%dx)
f010383a:	b9 0a 00 00 00       	mov    $0xa,%ecx
f010383f:	89 c8                	mov    %ecx,%eax
f0103841:	ee                   	out    %al,(%dx)
f0103842:	89 f8                	mov    %edi,%eax
f0103844:	89 da                	mov    %ebx,%edx
f0103846:	ee                   	out    %al,(%dx)
f0103847:	89 c8                	mov    %ecx,%eax
f0103849:	ee                   	out    %al,(%dx)
	if (irq_mask_8259A != 0xFFFF)
f010384a:	0f b7 05 a8 33 12 f0 	movzwl 0xf01233a8,%eax
f0103851:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103855:	75 08                	jne    f010385f <pic_init+0x99>
}
f0103857:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010385a:	5b                   	pop    %ebx
f010385b:	5e                   	pop    %esi
f010385c:	5f                   	pop    %edi
f010385d:	5d                   	pop    %ebp
f010385e:	c3                   	ret    
		irq_setmask_8259A(irq_mask_8259A);
f010385f:	83 ec 0c             	sub    $0xc,%esp
f0103862:	0f b7 c0             	movzwl %ax,%eax
f0103865:	50                   	push   %eax
f0103866:	e8 d9 fe ff ff       	call   f0103744 <irq_setmask_8259A>
f010386b:	83 c4 10             	add    $0x10,%esp
}
f010386e:	eb e7                	jmp    f0103857 <pic_init+0x91>

f0103870 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103870:	f3 0f 1e fb          	endbr32 
f0103874:	55                   	push   %ebp
f0103875:	89 e5                	mov    %esp,%ebp
f0103877:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010387a:	ff 75 08             	pushl  0x8(%ebp)
f010387d:	e8 f2 ce ff ff       	call   f0100774 <cputchar>
	*cnt++;
}
f0103882:	83 c4 10             	add    $0x10,%esp
f0103885:	c9                   	leave  
f0103886:	c3                   	ret    

f0103887 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103887:	f3 0f 1e fb          	endbr32 
f010388b:	55                   	push   %ebp
f010388c:	89 e5                	mov    %esp,%ebp
f010388e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103891:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103898:	ff 75 0c             	pushl  0xc(%ebp)
f010389b:	ff 75 08             	pushl  0x8(%ebp)
f010389e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01038a1:	50                   	push   %eax
f01038a2:	68 70 38 10 f0       	push   $0xf0103870
f01038a7:	e8 4c 1b 00 00       	call   f01053f8 <vprintfmt>
	return cnt;
}
f01038ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01038af:	c9                   	leave  
f01038b0:	c3                   	ret    

f01038b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01038b1:	f3 0f 1e fb          	endbr32 
f01038b5:	55                   	push   %ebp
f01038b6:	89 e5                	mov    %esp,%ebp
f01038b8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01038bb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01038be:	50                   	push   %eax
f01038bf:	ff 75 08             	pushl  0x8(%ebp)
f01038c2:	e8 c0 ff ff ff       	call   f0103887 <vcprintf>
	va_end(ap);

	return cnt;
}
f01038c7:	c9                   	leave  
f01038c8:	c3                   	ret    

f01038c9 <trap_init_percpu>:
	trap_init_percpu();
}

// Initialize and load the per-CPU TSS and IDT
void trap_init_percpu(void)
{
f01038c9:	f3 0f 1e fb          	endbr32 
f01038cd:	55                   	push   %ebp
f01038ce:	89 e5                	mov    %esp,%ebp
f01038d0:	57                   	push   %edi
f01038d1:	56                   	push   %esi
f01038d2:	53                   	push   %ebx
f01038d3:	83 ec 0c             	sub    $0xc,%esp
	// get a triple fault.  If you set up an individual CPU's TSS
	// wrong, you may not get a fault until you try to return from
	// user space on that CPU.
	//
	// LAB 4: Your code here:
	int cid = thiscpu->cpu_id;
f01038d6:	e8 93 28 00 00       	call   f010616e <cpunum>
f01038db:	6b c0 74             	imul   $0x74,%eax,%eax
f01038de:	0f b6 98 20 90 23 f0 	movzbl -0xfdc6fe0(%eax),%ebx
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - cid * (KSTKSIZE + KSTKGAP);
f01038e5:	e8 84 28 00 00       	call   f010616e <cpunum>
f01038ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01038ed:	89 d9                	mov    %ebx,%ecx
f01038ef:	c1 e1 10             	shl    $0x10,%ecx
f01038f2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01038f7:	29 ca                	sub    %ecx,%edx
f01038f9:	89 90 30 90 23 f0    	mov    %edx,-0xfdc6fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;
f01038ff:	e8 6a 28 00 00       	call   f010616e <cpunum>
f0103904:	6b c0 74             	imul   $0x74,%eax,%eax
f0103907:	66 c7 80 34 90 23 f0 	movw   $0x10,-0xfdc6fcc(%eax)
f010390e:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + cid] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)),
f0103910:	83 c3 05             	add    $0x5,%ebx
f0103913:	e8 56 28 00 00       	call   f010616e <cpunum>
f0103918:	89 c7                	mov    %eax,%edi
f010391a:	e8 4f 28 00 00       	call   f010616e <cpunum>
f010391f:	89 c6                	mov    %eax,%esi
f0103921:	e8 48 28 00 00       	call   f010616e <cpunum>
f0103926:	66 c7 04 dd 40 33 12 	movw   $0x68,-0xfedccc0(,%ebx,8)
f010392d:	f0 68 00 
f0103930:	6b ff 74             	imul   $0x74,%edi,%edi
f0103933:	81 c7 2c 90 23 f0    	add    $0xf023902c,%edi
f0103939:	66 89 3c dd 42 33 12 	mov    %di,-0xfedccbe(,%ebx,8)
f0103940:	f0 
f0103941:	6b d6 74             	imul   $0x74,%esi,%edx
f0103944:	81 c2 2c 90 23 f0    	add    $0xf023902c,%edx
f010394a:	c1 ea 10             	shr    $0x10,%edx
f010394d:	88 14 dd 44 33 12 f0 	mov    %dl,-0xfedccbc(,%ebx,8)
f0103954:	c6 04 dd 46 33 12 f0 	movb   $0x40,-0xfedccba(,%ebx,8)
f010395b:	40 
f010395c:	6b c0 74             	imul   $0x74,%eax,%eax
f010395f:	05 2c 90 23 f0       	add    $0xf023902c,%eax
f0103964:	c1 e8 18             	shr    $0x18,%eax
f0103967:	88 04 dd 47 33 12 f0 	mov    %al,-0xfedccb9(,%ebx,8)
									  sizeof(struct Taskstate), 0);
	gdt[(GD_TSS0 >> 3) + cid].sd_s = 0;
f010396e:	c6 04 dd 45 33 12 f0 	movb   $0x89,-0xfedccbb(,%ebx,8)
f0103975:	89 

	// Load the TSS selector (like other segment selectors, the
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * cid);
f0103976:	c1 e3 03             	shl    $0x3,%ebx
	asm volatile("ltr %0" : : "r" (sel));
f0103979:	0f 00 db             	ltr    %bx
	asm volatile("lidt (%0)" : : "r" (p));
f010397c:	b8 ac 33 12 f0       	mov    $0xf01233ac,%eax
f0103981:	0f 01 18             	lidtl  (%eax)

	// Load the IDT
	lidt(&idt_pd);
}
f0103984:	83 c4 0c             	add    $0xc,%esp
f0103987:	5b                   	pop    %ebx
f0103988:	5e                   	pop    %esi
f0103989:	5f                   	pop    %edi
f010398a:	5d                   	pop    %ebp
f010398b:	c3                   	ret    

f010398c <trap_init>:
{
f010398c:	f3 0f 1e fb          	endbr32 
f0103990:	55                   	push   %ebp
f0103991:	89 e5                	mov    %esp,%ebp
f0103993:	83 ec 08             	sub    $0x8,%esp
	SETGATE(idt[T_DIVIDE], 0, GD_KT, &th_divide, 0);
f0103996:	b8 ee 44 10 f0       	mov    $0xf01044ee,%eax
f010399b:	66 a3 60 82 23 f0    	mov    %ax,0xf0238260
f01039a1:	66 c7 05 62 82 23 f0 	movw   $0x8,0xf0238262
f01039a8:	08 00 
f01039aa:	c6 05 64 82 23 f0 00 	movb   $0x0,0xf0238264
f01039b1:	c6 05 65 82 23 f0 8e 	movb   $0x8e,0xf0238265
f01039b8:	c1 e8 10             	shr    $0x10,%eax
f01039bb:	66 a3 66 82 23 f0    	mov    %ax,0xf0238266
	SETGATE(idt[T_DEBUG], 0, GD_KT, &th_debug, 0);
f01039c1:	b8 f8 44 10 f0       	mov    $0xf01044f8,%eax
f01039c6:	66 a3 68 82 23 f0    	mov    %ax,0xf0238268
f01039cc:	66 c7 05 6a 82 23 f0 	movw   $0x8,0xf023826a
f01039d3:	08 00 
f01039d5:	c6 05 6c 82 23 f0 00 	movb   $0x0,0xf023826c
f01039dc:	c6 05 6d 82 23 f0 8e 	movb   $0x8e,0xf023826d
f01039e3:	c1 e8 10             	shr    $0x10,%eax
f01039e6:	66 a3 6e 82 23 f0    	mov    %ax,0xf023826e
	SETGATE(idt[T_NMI], 0, GD_KT, &th_nmi, 0);
f01039ec:	b8 02 45 10 f0       	mov    $0xf0104502,%eax
f01039f1:	66 a3 70 82 23 f0    	mov    %ax,0xf0238270
f01039f7:	66 c7 05 72 82 23 f0 	movw   $0x8,0xf0238272
f01039fe:	08 00 
f0103a00:	c6 05 74 82 23 f0 00 	movb   $0x0,0xf0238274
f0103a07:	c6 05 75 82 23 f0 8e 	movb   $0x8e,0xf0238275
f0103a0e:	c1 e8 10             	shr    $0x10,%eax
f0103a11:	66 a3 76 82 23 f0    	mov    %ax,0xf0238276
	SETGATE(idt[T_BRKPT], 0, GD_KT, &th_brkpt, 0);
f0103a17:	b8 0c 45 10 f0       	mov    $0xf010450c,%eax
f0103a1c:	66 a3 78 82 23 f0    	mov    %ax,0xf0238278
f0103a22:	66 c7 05 7a 82 23 f0 	movw   $0x8,0xf023827a
f0103a29:	08 00 
f0103a2b:	c6 05 7c 82 23 f0 00 	movb   $0x0,0xf023827c
f0103a32:	c6 05 7d 82 23 f0 8e 	movb   $0x8e,0xf023827d
f0103a39:	c1 e8 10             	shr    $0x10,%eax
f0103a3c:	66 a3 7e 82 23 f0    	mov    %ax,0xf023827e
	SETGATE(idt[T_OFLOW], 0, GD_KT, &th_oflow, 0);
f0103a42:	b8 16 45 10 f0       	mov    $0xf0104516,%eax
f0103a47:	66 a3 80 82 23 f0    	mov    %ax,0xf0238280
f0103a4d:	66 c7 05 82 82 23 f0 	movw   $0x8,0xf0238282
f0103a54:	08 00 
f0103a56:	c6 05 84 82 23 f0 00 	movb   $0x0,0xf0238284
f0103a5d:	c6 05 85 82 23 f0 8e 	movb   $0x8e,0xf0238285
f0103a64:	c1 e8 10             	shr    $0x10,%eax
f0103a67:	66 a3 86 82 23 f0    	mov    %ax,0xf0238286
	SETGATE(idt[T_BOUND], 0, GD_KT, &th_bound, 0);
f0103a6d:	b8 20 45 10 f0       	mov    $0xf0104520,%eax
f0103a72:	66 a3 88 82 23 f0    	mov    %ax,0xf0238288
f0103a78:	66 c7 05 8a 82 23 f0 	movw   $0x8,0xf023828a
f0103a7f:	08 00 
f0103a81:	c6 05 8c 82 23 f0 00 	movb   $0x0,0xf023828c
f0103a88:	c6 05 8d 82 23 f0 8e 	movb   $0x8e,0xf023828d
f0103a8f:	c1 e8 10             	shr    $0x10,%eax
f0103a92:	66 a3 8e 82 23 f0    	mov    %ax,0xf023828e
	SETGATE(idt[T_ILLOP], 0, GD_KT, &th_illop, 0);
f0103a98:	b8 2a 45 10 f0       	mov    $0xf010452a,%eax
f0103a9d:	66 a3 90 82 23 f0    	mov    %ax,0xf0238290
f0103aa3:	66 c7 05 92 82 23 f0 	movw   $0x8,0xf0238292
f0103aaa:	08 00 
f0103aac:	c6 05 94 82 23 f0 00 	movb   $0x0,0xf0238294
f0103ab3:	c6 05 95 82 23 f0 8e 	movb   $0x8e,0xf0238295
f0103aba:	c1 e8 10             	shr    $0x10,%eax
f0103abd:	66 a3 96 82 23 f0    	mov    %ax,0xf0238296
	SETGATE(idt[T_DEVICE], 0, GD_KT, &th_device, 0);
f0103ac3:	b8 34 45 10 f0       	mov    $0xf0104534,%eax
f0103ac8:	66 a3 98 82 23 f0    	mov    %ax,0xf0238298
f0103ace:	66 c7 05 9a 82 23 f0 	movw   $0x8,0xf023829a
f0103ad5:	08 00 
f0103ad7:	c6 05 9c 82 23 f0 00 	movb   $0x0,0xf023829c
f0103ade:	c6 05 9d 82 23 f0 8e 	movb   $0x8e,0xf023829d
f0103ae5:	c1 e8 10             	shr    $0x10,%eax
f0103ae8:	66 a3 9e 82 23 f0    	mov    %ax,0xf023829e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, &th_dblflt, 0);
f0103aee:	b8 3e 45 10 f0       	mov    $0xf010453e,%eax
f0103af3:	66 a3 a0 82 23 f0    	mov    %ax,0xf02382a0
f0103af9:	66 c7 05 a2 82 23 f0 	movw   $0x8,0xf02382a2
f0103b00:	08 00 
f0103b02:	c6 05 a4 82 23 f0 00 	movb   $0x0,0xf02382a4
f0103b09:	c6 05 a5 82 23 f0 8e 	movb   $0x8e,0xf02382a5
f0103b10:	c1 e8 10             	shr    $0x10,%eax
f0103b13:	66 a3 a6 82 23 f0    	mov    %ax,0xf02382a6
	SETGATE(idt[T_TSS], 0, GD_KT, &th_tss, 0);
f0103b19:	b8 50 45 10 f0       	mov    $0xf0104550,%eax
f0103b1e:	66 a3 b0 82 23 f0    	mov    %ax,0xf02382b0
f0103b24:	66 c7 05 b2 82 23 f0 	movw   $0x8,0xf02382b2
f0103b2b:	08 00 
f0103b2d:	c6 05 b4 82 23 f0 00 	movb   $0x0,0xf02382b4
f0103b34:	c6 05 b5 82 23 f0 8e 	movb   $0x8e,0xf02382b5
f0103b3b:	c1 e8 10             	shr    $0x10,%eax
f0103b3e:	66 a3 b6 82 23 f0    	mov    %ax,0xf02382b6
	SETGATE(idt[9], 0, GD_KT, &th9, 0);
f0103b44:	b8 46 45 10 f0       	mov    $0xf0104546,%eax
f0103b49:	66 a3 a8 82 23 f0    	mov    %ax,0xf02382a8
f0103b4f:	66 c7 05 aa 82 23 f0 	movw   $0x8,0xf02382aa
f0103b56:	08 00 
f0103b58:	c6 05 ac 82 23 f0 00 	movb   $0x0,0xf02382ac
f0103b5f:	c6 05 ad 82 23 f0 8e 	movb   $0x8e,0xf02382ad
f0103b66:	c1 e8 10             	shr    $0x10,%eax
f0103b69:	66 a3 ae 82 23 f0    	mov    %ax,0xf02382ae
	SETGATE(idt[T_SEGNP], 0, GD_KT, &th_segnp, 0);
f0103b6f:	b8 54 45 10 f0       	mov    $0xf0104554,%eax
f0103b74:	66 a3 b8 82 23 f0    	mov    %ax,0xf02382b8
f0103b7a:	66 c7 05 ba 82 23 f0 	movw   $0x8,0xf02382ba
f0103b81:	08 00 
f0103b83:	c6 05 bc 82 23 f0 00 	movb   $0x0,0xf02382bc
f0103b8a:	c6 05 bd 82 23 f0 8e 	movb   $0x8e,0xf02382bd
f0103b91:	c1 e8 10             	shr    $0x10,%eax
f0103b94:	66 a3 be 82 23 f0    	mov    %ax,0xf02382be
	SETGATE(idt[T_STACK], 0, GD_KT, &th_stack, 0);
f0103b9a:	b8 58 45 10 f0       	mov    $0xf0104558,%eax
f0103b9f:	66 a3 c0 82 23 f0    	mov    %ax,0xf02382c0
f0103ba5:	66 c7 05 c2 82 23 f0 	movw   $0x8,0xf02382c2
f0103bac:	08 00 
f0103bae:	c6 05 c4 82 23 f0 00 	movb   $0x0,0xf02382c4
f0103bb5:	c6 05 c5 82 23 f0 8e 	movb   $0x8e,0xf02382c5
f0103bbc:	c1 e8 10             	shr    $0x10,%eax
f0103bbf:	66 a3 c6 82 23 f0    	mov    %ax,0xf02382c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, &th_gpflt, 0);
f0103bc5:	b8 5c 45 10 f0       	mov    $0xf010455c,%eax
f0103bca:	66 a3 c8 82 23 f0    	mov    %ax,0xf02382c8
f0103bd0:	66 c7 05 ca 82 23 f0 	movw   $0x8,0xf02382ca
f0103bd7:	08 00 
f0103bd9:	c6 05 cc 82 23 f0 00 	movb   $0x0,0xf02382cc
f0103be0:	c6 05 cd 82 23 f0 8e 	movb   $0x8e,0xf02382cd
f0103be7:	c1 e8 10             	shr    $0x10,%eax
f0103bea:	66 a3 ce 82 23 f0    	mov    %ax,0xf02382ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, &th_pgflt, 0);
f0103bf0:	b8 60 45 10 f0       	mov    $0xf0104560,%eax
f0103bf5:	66 a3 d0 82 23 f0    	mov    %ax,0xf02382d0
f0103bfb:	66 c7 05 d2 82 23 f0 	movw   $0x8,0xf02382d2
f0103c02:	08 00 
f0103c04:	c6 05 d4 82 23 f0 00 	movb   $0x0,0xf02382d4
f0103c0b:	c6 05 d5 82 23 f0 8e 	movb   $0x8e,0xf02382d5
f0103c12:	c1 e8 10             	shr    $0x10,%eax
f0103c15:	66 a3 d6 82 23 f0    	mov    %ax,0xf02382d6
	SETGATE(idt[T_FPERR], 0, GD_KT, &th_fperr, 0);
f0103c1b:	b8 64 45 10 f0       	mov    $0xf0104564,%eax
f0103c20:	66 a3 e0 82 23 f0    	mov    %ax,0xf02382e0
f0103c26:	66 c7 05 e2 82 23 f0 	movw   $0x8,0xf02382e2
f0103c2d:	08 00 
f0103c2f:	c6 05 e4 82 23 f0 00 	movb   $0x0,0xf02382e4
f0103c36:	c6 05 e5 82 23 f0 8e 	movb   $0x8e,0xf02382e5
f0103c3d:	c1 e8 10             	shr    $0x10,%eax
f0103c40:	66 a3 e6 82 23 f0    	mov    %ax,0xf02382e6
	SETGATE(idt[IRQ_OFFSET], 0, GD_KT, th32, 0);
f0103c46:	b8 6a 45 10 f0       	mov    $0xf010456a,%eax
f0103c4b:	66 a3 60 83 23 f0    	mov    %ax,0xf0238360
f0103c51:	66 c7 05 62 83 23 f0 	movw   $0x8,0xf0238362
f0103c58:	08 00 
f0103c5a:	c6 05 64 83 23 f0 00 	movb   $0x0,0xf0238364
f0103c61:	c6 05 65 83 23 f0 8e 	movb   $0x8e,0xf0238365
f0103c68:	c1 e8 10             	shr    $0x10,%eax
f0103c6b:	66 a3 66 83 23 f0    	mov    %ax,0xf0238366
	SETGATE(idt[IRQ_OFFSET + 1], 0, GD_KT, th33, 0);
f0103c71:	b8 70 45 10 f0       	mov    $0xf0104570,%eax
f0103c76:	66 a3 68 83 23 f0    	mov    %ax,0xf0238368
f0103c7c:	66 c7 05 6a 83 23 f0 	movw   $0x8,0xf023836a
f0103c83:	08 00 
f0103c85:	c6 05 6c 83 23 f0 00 	movb   $0x0,0xf023836c
f0103c8c:	c6 05 6d 83 23 f0 8e 	movb   $0x8e,0xf023836d
f0103c93:	c1 e8 10             	shr    $0x10,%eax
f0103c96:	66 a3 6e 83 23 f0    	mov    %ax,0xf023836e
	SETGATE(idt[IRQ_OFFSET + 2], 0, GD_KT, th34, 0);
f0103c9c:	b8 76 45 10 f0       	mov    $0xf0104576,%eax
f0103ca1:	66 a3 70 83 23 f0    	mov    %ax,0xf0238370
f0103ca7:	66 c7 05 72 83 23 f0 	movw   $0x8,0xf0238372
f0103cae:	08 00 
f0103cb0:	c6 05 74 83 23 f0 00 	movb   $0x0,0xf0238374
f0103cb7:	c6 05 75 83 23 f0 8e 	movb   $0x8e,0xf0238375
f0103cbe:	c1 e8 10             	shr    $0x10,%eax
f0103cc1:	66 a3 76 83 23 f0    	mov    %ax,0xf0238376
	SETGATE(idt[IRQ_OFFSET + 3], 0, GD_KT, th35, 0);
f0103cc7:	b8 7c 45 10 f0       	mov    $0xf010457c,%eax
f0103ccc:	66 a3 78 83 23 f0    	mov    %ax,0xf0238378
f0103cd2:	66 c7 05 7a 83 23 f0 	movw   $0x8,0xf023837a
f0103cd9:	08 00 
f0103cdb:	c6 05 7c 83 23 f0 00 	movb   $0x0,0xf023837c
f0103ce2:	c6 05 7d 83 23 f0 8e 	movb   $0x8e,0xf023837d
f0103ce9:	c1 e8 10             	shr    $0x10,%eax
f0103cec:	66 a3 7e 83 23 f0    	mov    %ax,0xf023837e
	SETGATE(idt[IRQ_OFFSET + 4], 0, GD_KT, th36, 0);
f0103cf2:	b8 82 45 10 f0       	mov    $0xf0104582,%eax
f0103cf7:	66 a3 80 83 23 f0    	mov    %ax,0xf0238380
f0103cfd:	66 c7 05 82 83 23 f0 	movw   $0x8,0xf0238382
f0103d04:	08 00 
f0103d06:	c6 05 84 83 23 f0 00 	movb   $0x0,0xf0238384
f0103d0d:	c6 05 85 83 23 f0 8e 	movb   $0x8e,0xf0238385
f0103d14:	c1 e8 10             	shr    $0x10,%eax
f0103d17:	66 a3 86 83 23 f0    	mov    %ax,0xf0238386
	SETGATE(idt[IRQ_OFFSET + 5], 0, GD_KT, th37, 0);
f0103d1d:	b8 88 45 10 f0       	mov    $0xf0104588,%eax
f0103d22:	66 a3 88 83 23 f0    	mov    %ax,0xf0238388
f0103d28:	66 c7 05 8a 83 23 f0 	movw   $0x8,0xf023838a
f0103d2f:	08 00 
f0103d31:	c6 05 8c 83 23 f0 00 	movb   $0x0,0xf023838c
f0103d38:	c6 05 8d 83 23 f0 8e 	movb   $0x8e,0xf023838d
f0103d3f:	c1 e8 10             	shr    $0x10,%eax
f0103d42:	66 a3 8e 83 23 f0    	mov    %ax,0xf023838e
	SETGATE(idt[IRQ_OFFSET + 6], 0, GD_KT, th38, 0);
f0103d48:	b8 8e 45 10 f0       	mov    $0xf010458e,%eax
f0103d4d:	66 a3 90 83 23 f0    	mov    %ax,0xf0238390
f0103d53:	66 c7 05 92 83 23 f0 	movw   $0x8,0xf0238392
f0103d5a:	08 00 
f0103d5c:	c6 05 94 83 23 f0 00 	movb   $0x0,0xf0238394
f0103d63:	c6 05 95 83 23 f0 8e 	movb   $0x8e,0xf0238395
f0103d6a:	c1 e8 10             	shr    $0x10,%eax
f0103d6d:	66 a3 96 83 23 f0    	mov    %ax,0xf0238396
	SETGATE(idt[IRQ_OFFSET + 7], 0, GD_KT, th39, 0);
f0103d73:	b8 94 45 10 f0       	mov    $0xf0104594,%eax
f0103d78:	66 a3 98 83 23 f0    	mov    %ax,0xf0238398
f0103d7e:	66 c7 05 9a 83 23 f0 	movw   $0x8,0xf023839a
f0103d85:	08 00 
f0103d87:	c6 05 9c 83 23 f0 00 	movb   $0x0,0xf023839c
f0103d8e:	c6 05 9d 83 23 f0 8e 	movb   $0x8e,0xf023839d
f0103d95:	c1 e8 10             	shr    $0x10,%eax
f0103d98:	66 a3 9e 83 23 f0    	mov    %ax,0xf023839e
	SETGATE(idt[IRQ_OFFSET + 8], 0, GD_KT, th40, 0);
f0103d9e:	b8 9a 45 10 f0       	mov    $0xf010459a,%eax
f0103da3:	66 a3 a0 83 23 f0    	mov    %ax,0xf02383a0
f0103da9:	66 c7 05 a2 83 23 f0 	movw   $0x8,0xf02383a2
f0103db0:	08 00 
f0103db2:	c6 05 a4 83 23 f0 00 	movb   $0x0,0xf02383a4
f0103db9:	c6 05 a5 83 23 f0 8e 	movb   $0x8e,0xf02383a5
f0103dc0:	c1 e8 10             	shr    $0x10,%eax
f0103dc3:	66 a3 a6 83 23 f0    	mov    %ax,0xf02383a6
	SETGATE(idt[IRQ_OFFSET + 9], 0, GD_KT, th41, 0);
f0103dc9:	b8 a0 45 10 f0       	mov    $0xf01045a0,%eax
f0103dce:	66 a3 a8 83 23 f0    	mov    %ax,0xf02383a8
f0103dd4:	66 c7 05 aa 83 23 f0 	movw   $0x8,0xf02383aa
f0103ddb:	08 00 
f0103ddd:	c6 05 ac 83 23 f0 00 	movb   $0x0,0xf02383ac
f0103de4:	c6 05 ad 83 23 f0 8e 	movb   $0x8e,0xf02383ad
f0103deb:	c1 e8 10             	shr    $0x10,%eax
f0103dee:	66 a3 ae 83 23 f0    	mov    %ax,0xf02383ae
	SETGATE(idt[IRQ_OFFSET + 10], 0, GD_KT, th42, 0);
f0103df4:	b8 a6 45 10 f0       	mov    $0xf01045a6,%eax
f0103df9:	66 a3 b0 83 23 f0    	mov    %ax,0xf02383b0
f0103dff:	66 c7 05 b2 83 23 f0 	movw   $0x8,0xf02383b2
f0103e06:	08 00 
f0103e08:	c6 05 b4 83 23 f0 00 	movb   $0x0,0xf02383b4
f0103e0f:	c6 05 b5 83 23 f0 8e 	movb   $0x8e,0xf02383b5
f0103e16:	c1 e8 10             	shr    $0x10,%eax
f0103e19:	66 a3 b6 83 23 f0    	mov    %ax,0xf02383b6
	SETGATE(idt[IRQ_OFFSET + 11], 0, GD_KT, th43, 0);
f0103e1f:	b8 ac 45 10 f0       	mov    $0xf01045ac,%eax
f0103e24:	66 a3 b8 83 23 f0    	mov    %ax,0xf02383b8
f0103e2a:	66 c7 05 ba 83 23 f0 	movw   $0x8,0xf02383ba
f0103e31:	08 00 
f0103e33:	c6 05 bc 83 23 f0 00 	movb   $0x0,0xf02383bc
f0103e3a:	c6 05 bd 83 23 f0 8e 	movb   $0x8e,0xf02383bd
f0103e41:	c1 e8 10             	shr    $0x10,%eax
f0103e44:	66 a3 be 83 23 f0    	mov    %ax,0xf02383be
	SETGATE(idt[IRQ_OFFSET + 12], 0, GD_KT, th44, 0);
f0103e4a:	b8 b2 45 10 f0       	mov    $0xf01045b2,%eax
f0103e4f:	66 a3 c0 83 23 f0    	mov    %ax,0xf02383c0
f0103e55:	66 c7 05 c2 83 23 f0 	movw   $0x8,0xf02383c2
f0103e5c:	08 00 
f0103e5e:	c6 05 c4 83 23 f0 00 	movb   $0x0,0xf02383c4
f0103e65:	c6 05 c5 83 23 f0 8e 	movb   $0x8e,0xf02383c5
f0103e6c:	c1 e8 10             	shr    $0x10,%eax
f0103e6f:	66 a3 c6 83 23 f0    	mov    %ax,0xf02383c6
	SETGATE(idt[IRQ_OFFSET + 13], 0, GD_KT, th45, 0);
f0103e75:	b8 b8 45 10 f0       	mov    $0xf01045b8,%eax
f0103e7a:	66 a3 c8 83 23 f0    	mov    %ax,0xf02383c8
f0103e80:	66 c7 05 ca 83 23 f0 	movw   $0x8,0xf02383ca
f0103e87:	08 00 
f0103e89:	c6 05 cc 83 23 f0 00 	movb   $0x0,0xf02383cc
f0103e90:	c6 05 cd 83 23 f0 8e 	movb   $0x8e,0xf02383cd
f0103e97:	c1 e8 10             	shr    $0x10,%eax
f0103e9a:	66 a3 ce 83 23 f0    	mov    %ax,0xf02383ce
	SETGATE(idt[IRQ_OFFSET + 14], 0, GD_KT, th46, 0);
f0103ea0:	b8 be 45 10 f0       	mov    $0xf01045be,%eax
f0103ea5:	66 a3 d0 83 23 f0    	mov    %ax,0xf02383d0
f0103eab:	66 c7 05 d2 83 23 f0 	movw   $0x8,0xf02383d2
f0103eb2:	08 00 
f0103eb4:	c6 05 d4 83 23 f0 00 	movb   $0x0,0xf02383d4
f0103ebb:	c6 05 d5 83 23 f0 8e 	movb   $0x8e,0xf02383d5
f0103ec2:	c1 e8 10             	shr    $0x10,%eax
f0103ec5:	66 a3 d6 83 23 f0    	mov    %ax,0xf02383d6
	SETGATE(idt[IRQ_OFFSET + 15], 0, GD_KT, th47, 0);
f0103ecb:	b8 c4 45 10 f0       	mov    $0xf01045c4,%eax
f0103ed0:	66 a3 d8 83 23 f0    	mov    %ax,0xf02383d8
f0103ed6:	66 c7 05 da 83 23 f0 	movw   $0x8,0xf02383da
f0103edd:	08 00 
f0103edf:	c6 05 dc 83 23 f0 00 	movb   $0x0,0xf02383dc
f0103ee6:	c6 05 dd 83 23 f0 8e 	movb   $0x8e,0xf02383dd
f0103eed:	c1 e8 10             	shr    $0x10,%eax
f0103ef0:	66 a3 de 83 23 f0    	mov    %ax,0xf02383de
	SETGATE(idt[T_SYSCALL], 0, GD_KT, th_syscall, 3);
f0103ef6:	b8 ca 45 10 f0       	mov    $0xf01045ca,%eax
f0103efb:	66 a3 e0 83 23 f0    	mov    %ax,0xf02383e0
f0103f01:	66 c7 05 e2 83 23 f0 	movw   $0x8,0xf02383e2
f0103f08:	08 00 
f0103f0a:	c6 05 e4 83 23 f0 00 	movb   $0x0,0xf02383e4
f0103f11:	c6 05 e5 83 23 f0 ee 	movb   $0xee,0xf02383e5
f0103f18:	c1 e8 10             	shr    $0x10,%eax
f0103f1b:	66 a3 e6 83 23 f0    	mov    %ax,0xf02383e6
	trap_init_percpu();
f0103f21:	e8 a3 f9 ff ff       	call   f01038c9 <trap_init_percpu>
}
f0103f26:	c9                   	leave  
f0103f27:	c3                   	ret    

f0103f28 <print_regs>:
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
	}
}

void print_regs(struct PushRegs *regs)
{
f0103f28:	f3 0f 1e fb          	endbr32 
f0103f2c:	55                   	push   %ebp
f0103f2d:	89 e5                	mov    %esp,%ebp
f0103f2f:	53                   	push   %ebx
f0103f30:	83 ec 0c             	sub    $0xc,%esp
f0103f33:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103f36:	ff 33                	pushl  (%ebx)
f0103f38:	68 aa 7a 10 f0       	push   $0xf0107aaa
f0103f3d:	e8 6f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103f42:	83 c4 08             	add    $0x8,%esp
f0103f45:	ff 73 04             	pushl  0x4(%ebx)
f0103f48:	68 b9 7a 10 f0       	push   $0xf0107ab9
f0103f4d:	e8 5f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103f52:	83 c4 08             	add    $0x8,%esp
f0103f55:	ff 73 08             	pushl  0x8(%ebx)
f0103f58:	68 c8 7a 10 f0       	push   $0xf0107ac8
f0103f5d:	e8 4f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103f62:	83 c4 08             	add    $0x8,%esp
f0103f65:	ff 73 0c             	pushl  0xc(%ebx)
f0103f68:	68 d7 7a 10 f0       	push   $0xf0107ad7
f0103f6d:	e8 3f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103f72:	83 c4 08             	add    $0x8,%esp
f0103f75:	ff 73 10             	pushl  0x10(%ebx)
f0103f78:	68 e6 7a 10 f0       	push   $0xf0107ae6
f0103f7d:	e8 2f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103f82:	83 c4 08             	add    $0x8,%esp
f0103f85:	ff 73 14             	pushl  0x14(%ebx)
f0103f88:	68 f5 7a 10 f0       	push   $0xf0107af5
f0103f8d:	e8 1f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103f92:	83 c4 08             	add    $0x8,%esp
f0103f95:	ff 73 18             	pushl  0x18(%ebx)
f0103f98:	68 04 7b 10 f0       	push   $0xf0107b04
f0103f9d:	e8 0f f9 ff ff       	call   f01038b1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103fa2:	83 c4 08             	add    $0x8,%esp
f0103fa5:	ff 73 1c             	pushl  0x1c(%ebx)
f0103fa8:	68 13 7b 10 f0       	push   $0xf0107b13
f0103fad:	e8 ff f8 ff ff       	call   f01038b1 <cprintf>
}
f0103fb2:	83 c4 10             	add    $0x10,%esp
f0103fb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103fb8:	c9                   	leave  
f0103fb9:	c3                   	ret    

f0103fba <print_trapframe>:
{
f0103fba:	f3 0f 1e fb          	endbr32 
f0103fbe:	55                   	push   %ebp
f0103fbf:	89 e5                	mov    %esp,%ebp
f0103fc1:	56                   	push   %esi
f0103fc2:	53                   	push   %ebx
f0103fc3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103fc6:	e8 a3 21 00 00       	call   f010616e <cpunum>
f0103fcb:	83 ec 04             	sub    $0x4,%esp
f0103fce:	50                   	push   %eax
f0103fcf:	53                   	push   %ebx
f0103fd0:	68 77 7b 10 f0       	push   $0xf0107b77
f0103fd5:	e8 d7 f8 ff ff       	call   f01038b1 <cprintf>
	print_regs(&tf->tf_regs);
f0103fda:	89 1c 24             	mov    %ebx,(%esp)
f0103fdd:	e8 46 ff ff ff       	call   f0103f28 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103fe2:	83 c4 08             	add    $0x8,%esp
f0103fe5:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103fe9:	50                   	push   %eax
f0103fea:	68 95 7b 10 f0       	push   $0xf0107b95
f0103fef:	e8 bd f8 ff ff       	call   f01038b1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103ff4:	83 c4 08             	add    $0x8,%esp
f0103ff7:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103ffb:	50                   	push   %eax
f0103ffc:	68 a8 7b 10 f0       	push   $0xf0107ba8
f0104001:	e8 ab f8 ff ff       	call   f01038b1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104006:	8b 43 28             	mov    0x28(%ebx),%eax
	if (trapno < ARRAY_SIZE(excnames))
f0104009:	83 c4 10             	add    $0x10,%esp
f010400c:	83 f8 13             	cmp    $0x13,%eax
f010400f:	0f 86 da 00 00 00    	jbe    f01040ef <print_trapframe+0x135>
		return "System call";
f0104015:	ba 22 7b 10 f0       	mov    $0xf0107b22,%edx
	if (trapno == T_SYSCALL)
f010401a:	83 f8 30             	cmp    $0x30,%eax
f010401d:	74 13                	je     f0104032 <print_trapframe+0x78>
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010401f:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
f0104022:	83 fa 0f             	cmp    $0xf,%edx
f0104025:	ba 2e 7b 10 f0       	mov    $0xf0107b2e,%edx
f010402a:	b9 3d 7b 10 f0       	mov    $0xf0107b3d,%ecx
f010402f:	0f 46 d1             	cmovbe %ecx,%edx
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104032:	83 ec 04             	sub    $0x4,%esp
f0104035:	52                   	push   %edx
f0104036:	50                   	push   %eax
f0104037:	68 bb 7b 10 f0       	push   $0xf0107bbb
f010403c:	e8 70 f8 ff ff       	call   f01038b1 <cprintf>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104041:	83 c4 10             	add    $0x10,%esp
f0104044:	39 1d 60 8a 23 f0    	cmp    %ebx,0xf0238a60
f010404a:	0f 84 ab 00 00 00    	je     f01040fb <print_trapframe+0x141>
	cprintf("  err  0x%08x", tf->tf_err);
f0104050:	83 ec 08             	sub    $0x8,%esp
f0104053:	ff 73 2c             	pushl  0x2c(%ebx)
f0104056:	68 dc 7b 10 f0       	push   $0xf0107bdc
f010405b:	e8 51 f8 ff ff       	call   f01038b1 <cprintf>
	if (tf->tf_trapno == T_PGFLT)
f0104060:	83 c4 10             	add    $0x10,%esp
f0104063:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104067:	0f 85 b1 00 00 00    	jne    f010411e <print_trapframe+0x164>
				tf->tf_err & 1 ? "protection" : "not-present");
f010406d:	8b 43 2c             	mov    0x2c(%ebx),%eax
		cprintf(" [%s, %s, %s]\n",
f0104070:	a8 01                	test   $0x1,%al
f0104072:	b9 50 7b 10 f0       	mov    $0xf0107b50,%ecx
f0104077:	ba 5b 7b 10 f0       	mov    $0xf0107b5b,%edx
f010407c:	0f 44 ca             	cmove  %edx,%ecx
f010407f:	a8 02                	test   $0x2,%al
f0104081:	be 67 7b 10 f0       	mov    $0xf0107b67,%esi
f0104086:	ba 6d 7b 10 f0       	mov    $0xf0107b6d,%edx
f010408b:	0f 45 d6             	cmovne %esi,%edx
f010408e:	a8 04                	test   $0x4,%al
f0104090:	b8 72 7b 10 f0       	mov    $0xf0107b72,%eax
f0104095:	be a7 7c 10 f0       	mov    $0xf0107ca7,%esi
f010409a:	0f 44 c6             	cmove  %esi,%eax
f010409d:	51                   	push   %ecx
f010409e:	52                   	push   %edx
f010409f:	50                   	push   %eax
f01040a0:	68 ea 7b 10 f0       	push   $0xf0107bea
f01040a5:	e8 07 f8 ff ff       	call   f01038b1 <cprintf>
f01040aa:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01040ad:	83 ec 08             	sub    $0x8,%esp
f01040b0:	ff 73 30             	pushl  0x30(%ebx)
f01040b3:	68 f9 7b 10 f0       	push   $0xf0107bf9
f01040b8:	e8 f4 f7 ff ff       	call   f01038b1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01040bd:	83 c4 08             	add    $0x8,%esp
f01040c0:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01040c4:	50                   	push   %eax
f01040c5:	68 08 7c 10 f0       	push   $0xf0107c08
f01040ca:	e8 e2 f7 ff ff       	call   f01038b1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01040cf:	83 c4 08             	add    $0x8,%esp
f01040d2:	ff 73 38             	pushl  0x38(%ebx)
f01040d5:	68 1b 7c 10 f0       	push   $0xf0107c1b
f01040da:	e8 d2 f7 ff ff       	call   f01038b1 <cprintf>
	if ((tf->tf_cs & 3) != 0)
f01040df:	83 c4 10             	add    $0x10,%esp
f01040e2:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01040e6:	75 4b                	jne    f0104133 <print_trapframe+0x179>
}
f01040e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01040eb:	5b                   	pop    %ebx
f01040ec:	5e                   	pop    %esi
f01040ed:	5d                   	pop    %ebp
f01040ee:	c3                   	ret    
		return excnames[trapno];
f01040ef:	8b 14 85 60 7e 10 f0 	mov    -0xfef81a0(,%eax,4),%edx
f01040f6:	e9 37 ff ff ff       	jmp    f0104032 <print_trapframe+0x78>
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01040fb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f01040ff:	0f 85 4b ff ff ff    	jne    f0104050 <print_trapframe+0x96>
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0104105:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104108:	83 ec 08             	sub    $0x8,%esp
f010410b:	50                   	push   %eax
f010410c:	68 cd 7b 10 f0       	push   $0xf0107bcd
f0104111:	e8 9b f7 ff ff       	call   f01038b1 <cprintf>
f0104116:	83 c4 10             	add    $0x10,%esp
f0104119:	e9 32 ff ff ff       	jmp    f0104050 <print_trapframe+0x96>
		cprintf("\n");
f010411e:	83 ec 0c             	sub    $0xc,%esp
f0104121:	68 e0 79 10 f0       	push   $0xf01079e0
f0104126:	e8 86 f7 ff ff       	call   f01038b1 <cprintf>
f010412b:	83 c4 10             	add    $0x10,%esp
f010412e:	e9 7a ff ff ff       	jmp    f01040ad <print_trapframe+0xf3>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104133:	83 ec 08             	sub    $0x8,%esp
f0104136:	ff 73 3c             	pushl  0x3c(%ebx)
f0104139:	68 2a 7c 10 f0       	push   $0xf0107c2a
f010413e:	e8 6e f7 ff ff       	call   f01038b1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104143:	83 c4 08             	add    $0x8,%esp
f0104146:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010414a:	50                   	push   %eax
f010414b:	68 39 7c 10 f0       	push   $0xf0107c39
f0104150:	e8 5c f7 ff ff       	call   f01038b1 <cprintf>
f0104155:	83 c4 10             	add    $0x10,%esp
}
f0104158:	eb 8e                	jmp    f01040e8 <print_trapframe+0x12e>

f010415a <page_fault_handler>:
	else
		sched_yield();
}

void page_fault_handler(struct Trapframe *tf)
{
f010415a:	f3 0f 1e fb          	endbr32 
f010415e:	55                   	push   %ebp
f010415f:	89 e5                	mov    %esp,%ebp
f0104161:	57                   	push   %edi
f0104162:	56                   	push   %esi
f0104163:	53                   	push   %ebx
f0104164:	83 ec 1c             	sub    $0x1c,%esp
f0104167:	8b 5d 08             	mov    0x8(%ebp),%ebx
f010416a:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 3) == 0)
f010416d:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104171:	74 5d                	je     f01041d0 <page_fault_handler+0x76>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.
	if (curenv->env_pgfault_upcall)
f0104173:	e8 f6 1f 00 00       	call   f010616e <cpunum>
f0104178:	6b c0 74             	imul   $0x74,%eax,%eax
f010417b:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104181:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0104185:	75 60                	jne    f01041e7 <page_fault_handler+0x8d>
		curenv->env_tf.tf_esp = (uintptr_t)utr;
		env_run(curenv); //重新进入用户态
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104187:	8b 7b 30             	mov    0x30(%ebx),%edi
			curenv->env_id, fault_va, tf->tf_eip);
f010418a:	e8 df 1f 00 00       	call   f010616e <cpunum>
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010418f:	57                   	push   %edi
f0104190:	56                   	push   %esi
			curenv->env_id, fault_va, tf->tf_eip);
f0104191:	6b c0 74             	imul   $0x74,%eax,%eax
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104194:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010419a:	ff 70 48             	pushl  0x48(%eax)
f010419d:	68 28 7e 10 f0       	push   $0xf0107e28
f01041a2:	e8 0a f7 ff ff       	call   f01038b1 <cprintf>
	print_trapframe(tf);
f01041a7:	89 1c 24             	mov    %ebx,(%esp)
f01041aa:	e8 0b fe ff ff       	call   f0103fba <print_trapframe>
	env_destroy(curenv);
f01041af:	e8 ba 1f 00 00       	call   f010616e <cpunum>
f01041b4:	83 c4 04             	add    $0x4,%esp
f01041b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ba:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f01041c0:	e8 01 f4 ff ff       	call   f01035c6 <env_destroy>
}
f01041c5:	83 c4 10             	add    $0x10,%esp
f01041c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01041cb:	5b                   	pop    %ebx
f01041cc:	5e                   	pop    %esi
f01041cd:	5f                   	pop    %edi
f01041ce:	5d                   	pop    %ebp
f01041cf:	c3                   	ret    
		panic("page_fault_handler():page fault in kernel mode!\n");
f01041d0:	83 ec 04             	sub    $0x4,%esp
f01041d3:	68 f4 7d 10 f0       	push   $0xf0107df4
f01041d8:	68 72 01 00 00       	push   $0x172
f01041dd:	68 4c 7c 10 f0       	push   $0xf0107c4c
f01041e2:	e8 59 be ff ff       	call   f0100040 <_panic>
		if (UXSTACKTOP - PGSIZE < tf->tf_esp && tf->tf_esp < UXSTACKTOP)
f01041e7:	8b 7b 3c             	mov    0x3c(%ebx),%edi
f01041ea:	8d 87 ff 0f 40 11    	lea    0x11400fff(%edi),%eax
		uintptr_t stacktop = UXSTACKTOP;
f01041f0:	3d ff 0f 00 00       	cmp    $0xfff,%eax
f01041f5:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
f01041fa:	0f 43 f8             	cmovae %eax,%edi
		user_mem_assert(curenv, (void *)stacktop - size, size, PTE_U | PTE_W);
f01041fd:	8d 57 c8             	lea    -0x38(%edi),%edx
f0104200:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104203:	e8 66 1f 00 00       	call   f010616e <cpunum>
f0104208:	6a 06                	push   $0x6
f010420a:	6a 38                	push   $0x38
f010420c:	ff 75 e4             	pushl  -0x1c(%ebp)
f010420f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104212:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104218:	e8 1d ed ff ff       	call   f0102f3a <user_mem_assert>
		utr->utf_fault_va = fault_va;
f010421d:	89 77 c8             	mov    %esi,-0x38(%edi)
		utr->utf_err = tf->tf_err;
f0104220:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104223:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104226:	89 42 04             	mov    %eax,0x4(%edx)
		utr->utf_regs = tf->tf_regs;
f0104229:	83 ef 30             	sub    $0x30,%edi
f010422c:	b9 08 00 00 00       	mov    $0x8,%ecx
f0104231:	89 de                	mov    %ebx,%esi
f0104233:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utr->utf_eip = tf->tf_eip;
f0104235:	8b 43 30             	mov    0x30(%ebx),%eax
f0104238:	89 42 28             	mov    %eax,0x28(%edx)
		utr->utf_eflags = tf->tf_eflags;
f010423b:	8b 43 38             	mov    0x38(%ebx),%eax
f010423e:	89 d6                	mov    %edx,%esi
f0104240:	89 42 2c             	mov    %eax,0x2c(%edx)
		utr->utf_esp = tf->tf_esp; //UXSTACKTOP栈上需要保存发生缺页异常时的%esp和%eip
f0104243:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104246:	89 42 30             	mov    %eax,0x30(%edx)
		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0104249:	e8 20 1f 00 00       	call   f010616e <cpunum>
f010424e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104251:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104257:	8b 58 64             	mov    0x64(%eax),%ebx
f010425a:	e8 0f 1f 00 00       	call   f010616e <cpunum>
f010425f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104262:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104268:	89 58 30             	mov    %ebx,0x30(%eax)
		curenv->env_tf.tf_esp = (uintptr_t)utr;
f010426b:	e8 fe 1e 00 00       	call   f010616e <cpunum>
f0104270:	6b c0 74             	imul   $0x74,%eax,%eax
f0104273:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104279:	89 70 3c             	mov    %esi,0x3c(%eax)
		env_run(curenv); //重新进入用户态
f010427c:	e8 ed 1e 00 00       	call   f010616e <cpunum>
f0104281:	83 c4 04             	add    $0x4,%esp
f0104284:	6b c0 74             	imul   $0x74,%eax,%eax
f0104287:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f010428d:	e8 db f3 ff ff       	call   f010366d <env_run>

f0104292 <trap>:
{
f0104292:	f3 0f 1e fb          	endbr32 
f0104296:	55                   	push   %ebp
f0104297:	89 e5                	mov    %esp,%ebp
f0104299:	57                   	push   %edi
f010429a:	56                   	push   %esi
f010429b:	8b 75 08             	mov    0x8(%ebp),%esi
	asm volatile("cld" ::
f010429e:	fc                   	cld    
	if (panicstr)
f010429f:	83 3d 80 8e 23 f0 00 	cmpl   $0x0,0xf0238e80
f01042a6:	74 01                	je     f01042a9 <trap+0x17>
		asm volatile("hlt");
f01042a8:	f4                   	hlt    
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01042a9:	e8 c0 1e 00 00       	call   f010616e <cpunum>
f01042ae:	6b d0 74             	imul   $0x74,%eax,%edx
f01042b1:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f01042b4:	b8 01 00 00 00       	mov    $0x1,%eax
f01042b9:	f0 87 82 20 90 23 f0 	lock xchg %eax,-0xfdc6fe0(%edx)
f01042c0:	83 f8 02             	cmp    $0x2,%eax
f01042c3:	0f 84 b0 00 00 00    	je     f0104379 <trap+0xe7>
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f01042c9:	9c                   	pushf  
f01042ca:	58                   	pop    %eax
	assert(!(read_eflags() & FL_IF));
f01042cb:	f6 c4 02             	test   $0x2,%ah
f01042ce:	0f 85 ba 00 00 00    	jne    f010438e <trap+0xfc>
	if ((tf->tf_cs & 3) == 3)
f01042d4:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f01042d8:	83 e0 03             	and    $0x3,%eax
f01042db:	66 83 f8 03          	cmp    $0x3,%ax
f01042df:	0f 84 c2 00 00 00    	je     f01043a7 <trap+0x115>
	last_tf = tf;
f01042e5:	89 35 60 8a 23 f0    	mov    %esi,0xf0238a60
	if (tf->tf_trapno == T_PGFLT)
f01042eb:	8b 46 28             	mov    0x28(%esi),%eax
f01042ee:	83 f8 0e             	cmp    $0xe,%eax
f01042f1:	0f 84 55 01 00 00    	je     f010444c <trap+0x1ba>
	if (tf->tf_trapno == T_BRKPT)
f01042f7:	83 f8 03             	cmp    $0x3,%eax
f01042fa:	0f 84 5d 01 00 00    	je     f010445d <trap+0x1cb>
	if (tf->tf_trapno == T_SYSCALL)
f0104300:	83 f8 30             	cmp    $0x30,%eax
f0104303:	0f 84 65 01 00 00    	je     f010446e <trap+0x1dc>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS)
f0104309:	83 f8 27             	cmp    $0x27,%eax
f010430c:	0f 84 80 01 00 00    	je     f0104492 <trap+0x200>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
f0104312:	83 f8 20             	cmp    $0x20,%eax
f0104315:	0f 84 94 01 00 00    	je     f01044af <trap+0x21d>
	print_trapframe(tf);
f010431b:	83 ec 0c             	sub    $0xc,%esp
f010431e:	56                   	push   %esi
f010431f:	e8 96 fc ff ff       	call   f0103fba <print_trapframe>
	if (tf->tf_cs == GD_KT)
f0104324:	83 c4 10             	add    $0x10,%esp
f0104327:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f010432c:	0f 84 8e 01 00 00    	je     f01044c0 <trap+0x22e>
		env_destroy(curenv);
f0104332:	e8 37 1e 00 00       	call   f010616e <cpunum>
f0104337:	83 ec 0c             	sub    $0xc,%esp
f010433a:	6b c0 74             	imul   $0x74,%eax,%eax
f010433d:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104343:	e8 7e f2 ff ff       	call   f01035c6 <env_destroy>
		return;
f0104348:	83 c4 10             	add    $0x10,%esp
	if (curenv && curenv->env_status == ENV_RUNNING)
f010434b:	e8 1e 1e 00 00       	call   f010616e <cpunum>
f0104350:	6b c0 74             	imul   $0x74,%eax,%eax
f0104353:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f010435a:	74 18                	je     f0104374 <trap+0xe2>
f010435c:	e8 0d 1e 00 00       	call   f010616e <cpunum>
f0104361:	6b c0 74             	imul   $0x74,%eax,%eax
f0104364:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010436a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010436e:	0f 84 63 01 00 00    	je     f01044d7 <trap+0x245>
		sched_yield();
f0104374:	e8 3c 03 00 00       	call   f01046b5 <sched_yield>
	spin_lock(&kernel_lock);
f0104379:	83 ec 0c             	sub    $0xc,%esp
f010437c:	68 c0 33 12 f0       	push   $0xf01233c0
f0104381:	e8 70 20 00 00       	call   f01063f6 <spin_lock>
}
f0104386:	83 c4 10             	add    $0x10,%esp
f0104389:	e9 3b ff ff ff       	jmp    f01042c9 <trap+0x37>
	assert(!(read_eflags() & FL_IF));
f010438e:	68 58 7c 10 f0       	push   $0xf0107c58
f0104393:	68 6b 77 10 f0       	push   $0xf010776b
f0104398:	68 3c 01 00 00       	push   $0x13c
f010439d:	68 4c 7c 10 f0       	push   $0xf0107c4c
f01043a2:	e8 99 bc ff ff       	call   f0100040 <_panic>
		assert(curenv);
f01043a7:	e8 c2 1d 00 00       	call   f010616e <cpunum>
f01043ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01043af:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01043b6:	74 4e                	je     f0104406 <trap+0x174>
	spin_lock(&kernel_lock);
f01043b8:	83 ec 0c             	sub    $0xc,%esp
f01043bb:	68 c0 33 12 f0       	push   $0xf01233c0
f01043c0:	e8 31 20 00 00       	call   f01063f6 <spin_lock>
		if (curenv->env_status == ENV_DYING)
f01043c5:	e8 a4 1d 00 00       	call   f010616e <cpunum>
f01043ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01043cd:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01043d3:	83 c4 10             	add    $0x10,%esp
f01043d6:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f01043da:	74 43                	je     f010441f <trap+0x18d>
		curenv->env_tf = *tf; 
f01043dc:	e8 8d 1d 00 00       	call   f010616e <cpunum>
f01043e1:	6b c0 74             	imul   $0x74,%eax,%eax
f01043e4:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01043ea:	b9 11 00 00 00       	mov    $0x11,%ecx
f01043ef:	89 c7                	mov    %eax,%edi
f01043f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		tf = &curenv->env_tf;
f01043f3:	e8 76 1d 00 00       	call   f010616e <cpunum>
f01043f8:	6b c0 74             	imul   $0x74,%eax,%eax
f01043fb:	8b b0 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%esi
f0104401:	e9 df fe ff ff       	jmp    f01042e5 <trap+0x53>
		assert(curenv);
f0104406:	68 71 7c 10 f0       	push   $0xf0107c71
f010440b:	68 6b 77 10 f0       	push   $0xf010776b
f0104410:	68 44 01 00 00       	push   $0x144
f0104415:	68 4c 7c 10 f0       	push   $0xf0107c4c
f010441a:	e8 21 bc ff ff       	call   f0100040 <_panic>
			env_free(curenv);
f010441f:	e8 4a 1d 00 00       	call   f010616e <cpunum>
f0104424:	83 ec 0c             	sub    $0xc,%esp
f0104427:	6b c0 74             	imul   $0x74,%eax,%eax
f010442a:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104430:	e8 b0 ef ff ff       	call   f01033e5 <env_free>
			curenv = NULL;
f0104435:	e8 34 1d 00 00       	call   f010616e <cpunum>
f010443a:	6b c0 74             	imul   $0x74,%eax,%eax
f010443d:	c7 80 28 90 23 f0 00 	movl   $0x0,-0xfdc6fd8(%eax)
f0104444:	00 00 00 
			sched_yield();
f0104447:	e8 69 02 00 00       	call   f01046b5 <sched_yield>
		page_fault_handler(tf);
f010444c:	83 ec 0c             	sub    $0xc,%esp
f010444f:	56                   	push   %esi
f0104450:	e8 05 fd ff ff       	call   f010415a <page_fault_handler>
		return;
f0104455:	83 c4 10             	add    $0x10,%esp
f0104458:	e9 ee fe ff ff       	jmp    f010434b <trap+0xb9>
		monitor(tf);
f010445d:	83 ec 0c             	sub    $0xc,%esp
f0104460:	56                   	push   %esi
f0104461:	e8 b0 c4 ff ff       	call   f0100916 <monitor>
		return;
f0104466:	83 c4 10             	add    $0x10,%esp
f0104469:	e9 dd fe ff ff       	jmp    f010434b <trap+0xb9>
		tf->tf_regs.reg_eax = syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f010446e:	83 ec 08             	sub    $0x8,%esp
f0104471:	ff 76 04             	pushl  0x4(%esi)
f0104474:	ff 36                	pushl  (%esi)
f0104476:	ff 76 10             	pushl  0x10(%esi)
f0104479:	ff 76 18             	pushl  0x18(%esi)
f010447c:	ff 76 14             	pushl  0x14(%esi)
f010447f:	ff 76 1c             	pushl  0x1c(%esi)
f0104482:	e8 ec 05 00 00       	call   f0104a73 <syscall>
f0104487:	89 46 1c             	mov    %eax,0x1c(%esi)
		return;
f010448a:	83 c4 20             	add    $0x20,%esp
f010448d:	e9 b9 fe ff ff       	jmp    f010434b <trap+0xb9>
		cprintf("Spurious interrupt on irq 7\n");
f0104492:	83 ec 0c             	sub    $0xc,%esp
f0104495:	68 78 7c 10 f0       	push   $0xf0107c78
f010449a:	e8 12 f4 ff ff       	call   f01038b1 <cprintf>
		print_trapframe(tf);
f010449f:	89 34 24             	mov    %esi,(%esp)
f01044a2:	e8 13 fb ff ff       	call   f0103fba <print_trapframe>
		return;
f01044a7:	83 c4 10             	add    $0x10,%esp
f01044aa:	e9 9c fe ff ff       	jmp    f010434b <trap+0xb9>
		nexTime+=1;
f01044af:	83 05 68 8a 23 f0 01 	addl   $0x1,0xf0238a68
		lapic_eoi();
f01044b6:	e8 02 1e 00 00       	call   f01062bd <lapic_eoi>
		sched_yield();
f01044bb:	e8 f5 01 00 00       	call   f01046b5 <sched_yield>
		panic("unhandled trap in kernel");
f01044c0:	83 ec 04             	sub    $0x4,%esp
f01044c3:	68 95 7c 10 f0       	push   $0xf0107c95
f01044c8:	68 21 01 00 00       	push   $0x121
f01044cd:	68 4c 7c 10 f0       	push   $0xf0107c4c
f01044d2:	e8 69 bb ff ff       	call   f0100040 <_panic>
		env_run(curenv);
f01044d7:	e8 92 1c 00 00       	call   f010616e <cpunum>
f01044dc:	83 ec 0c             	sub    $0xc,%esp
f01044df:	6b c0 74             	imul   $0x74,%eax,%eax
f01044e2:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f01044e8:	e8 80 f1 ff ff       	call   f010366d <env_run>
f01044ed:	90                   	nop

f01044ee <th_divide>:
/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */


	TRAPHANDLER_NOEC(th_divide, T_DIVIDE)
f01044ee:	6a 00                	push   $0x0
f01044f0:	6a 00                	push   $0x0
f01044f2:	e9 d9 00 00 00       	jmp    f01045d0 <_alltraps>
f01044f7:	90                   	nop

f01044f8 <th_debug>:
	TRAPHANDLER_NOEC(th_debug, T_DEBUG)
f01044f8:	6a 00                	push   $0x0
f01044fa:	6a 01                	push   $0x1
f01044fc:	e9 cf 00 00 00       	jmp    f01045d0 <_alltraps>
f0104501:	90                   	nop

f0104502 <th_nmi>:
	TRAPHANDLER_NOEC(th_nmi, T_NMI)
f0104502:	6a 00                	push   $0x0
f0104504:	6a 02                	push   $0x2
f0104506:	e9 c5 00 00 00       	jmp    f01045d0 <_alltraps>
f010450b:	90                   	nop

f010450c <th_brkpt>:
	TRAPHANDLER_NOEC(th_brkpt, T_BRKPT)
f010450c:	6a 00                	push   $0x0
f010450e:	6a 03                	push   $0x3
f0104510:	e9 bb 00 00 00       	jmp    f01045d0 <_alltraps>
f0104515:	90                   	nop

f0104516 <th_oflow>:
	TRAPHANDLER_NOEC(th_oflow, T_OFLOW)
f0104516:	6a 00                	push   $0x0
f0104518:	6a 04                	push   $0x4
f010451a:	e9 b1 00 00 00       	jmp    f01045d0 <_alltraps>
f010451f:	90                   	nop

f0104520 <th_bound>:
	TRAPHANDLER_NOEC(th_bound, T_BOUND)
f0104520:	6a 00                	push   $0x0
f0104522:	6a 05                	push   $0x5
f0104524:	e9 a7 00 00 00       	jmp    f01045d0 <_alltraps>
f0104529:	90                   	nop

f010452a <th_illop>:
	TRAPHANDLER_NOEC(th_illop, T_ILLOP)
f010452a:	6a 00                	push   $0x0
f010452c:	6a 06                	push   $0x6
f010452e:	e9 9d 00 00 00       	jmp    f01045d0 <_alltraps>
f0104533:	90                   	nop

f0104534 <th_device>:
	TRAPHANDLER_NOEC(th_device, T_DEVICE)
f0104534:	6a 00                	push   $0x0
f0104536:	6a 07                	push   $0x7
f0104538:	e9 93 00 00 00       	jmp    f01045d0 <_alltraps>
f010453d:	90                   	nop

f010453e <th_dblflt>:
	TRAPHANDLER(th_dblflt, T_DBLFLT)
f010453e:	6a 08                	push   $0x8
f0104540:	e9 8b 00 00 00       	jmp    f01045d0 <_alltraps>
f0104545:	90                   	nop

f0104546 <th9>:
	TRAPHANDLER_NOEC(th9, 9)
f0104546:	6a 00                	push   $0x0
f0104548:	6a 09                	push   $0x9
f010454a:	e9 81 00 00 00       	jmp    f01045d0 <_alltraps>
f010454f:	90                   	nop

f0104550 <th_tss>:
	TRAPHANDLER(th_tss, T_TSS)
f0104550:	6a 0a                	push   $0xa
f0104552:	eb 7c                	jmp    f01045d0 <_alltraps>

f0104554 <th_segnp>:
	TRAPHANDLER(th_segnp, T_SEGNP)
f0104554:	6a 0b                	push   $0xb
f0104556:	eb 78                	jmp    f01045d0 <_alltraps>

f0104558 <th_stack>:
	TRAPHANDLER(th_stack, T_STACK)
f0104558:	6a 0c                	push   $0xc
f010455a:	eb 74                	jmp    f01045d0 <_alltraps>

f010455c <th_gpflt>:
	TRAPHANDLER(th_gpflt, T_GPFLT)
f010455c:	6a 0d                	push   $0xd
f010455e:	eb 70                	jmp    f01045d0 <_alltraps>

f0104560 <th_pgflt>:
	TRAPHANDLER(th_pgflt, T_PGFLT)
f0104560:	6a 0e                	push   $0xe
f0104562:	eb 6c                	jmp    f01045d0 <_alltraps>

f0104564 <th_fperr>:
	TRAPHANDLER_NOEC(th_fperr, T_FPERR)
f0104564:	6a 00                	push   $0x0
f0104566:	6a 10                	push   $0x10
f0104568:	eb 66                	jmp    f01045d0 <_alltraps>

f010456a <th32>:

	TRAPHANDLER_NOEC(th32, IRQ_OFFSET)
f010456a:	6a 00                	push   $0x0
f010456c:	6a 20                	push   $0x20
f010456e:	eb 60                	jmp    f01045d0 <_alltraps>

f0104570 <th33>:
	TRAPHANDLER_NOEC(th33, IRQ_OFFSET + 1)
f0104570:	6a 00                	push   $0x0
f0104572:	6a 21                	push   $0x21
f0104574:	eb 5a                	jmp    f01045d0 <_alltraps>

f0104576 <th34>:
	TRAPHANDLER_NOEC(th34, IRQ_OFFSET + 2)
f0104576:	6a 00                	push   $0x0
f0104578:	6a 22                	push   $0x22
f010457a:	eb 54                	jmp    f01045d0 <_alltraps>

f010457c <th35>:
	TRAPHANDLER_NOEC(th35, IRQ_OFFSET + 3)
f010457c:	6a 00                	push   $0x0
f010457e:	6a 23                	push   $0x23
f0104580:	eb 4e                	jmp    f01045d0 <_alltraps>

f0104582 <th36>:
	TRAPHANDLER_NOEC(th36, IRQ_OFFSET + 4)
f0104582:	6a 00                	push   $0x0
f0104584:	6a 24                	push   $0x24
f0104586:	eb 48                	jmp    f01045d0 <_alltraps>

f0104588 <th37>:
	TRAPHANDLER_NOEC(th37, IRQ_OFFSET + 5)
f0104588:	6a 00                	push   $0x0
f010458a:	6a 25                	push   $0x25
f010458c:	eb 42                	jmp    f01045d0 <_alltraps>

f010458e <th38>:
	TRAPHANDLER_NOEC(th38, IRQ_OFFSET + 6)
f010458e:	6a 00                	push   $0x0
f0104590:	6a 26                	push   $0x26
f0104592:	eb 3c                	jmp    f01045d0 <_alltraps>

f0104594 <th39>:
	TRAPHANDLER_NOEC(th39, IRQ_OFFSET + 7)
f0104594:	6a 00                	push   $0x0
f0104596:	6a 27                	push   $0x27
f0104598:	eb 36                	jmp    f01045d0 <_alltraps>

f010459a <th40>:
	TRAPHANDLER_NOEC(th40, IRQ_OFFSET + 8)
f010459a:	6a 00                	push   $0x0
f010459c:	6a 28                	push   $0x28
f010459e:	eb 30                	jmp    f01045d0 <_alltraps>

f01045a0 <th41>:
	TRAPHANDLER_NOEC(th41, IRQ_OFFSET + 9)
f01045a0:	6a 00                	push   $0x0
f01045a2:	6a 29                	push   $0x29
f01045a4:	eb 2a                	jmp    f01045d0 <_alltraps>

f01045a6 <th42>:
	TRAPHANDLER_NOEC(th42, IRQ_OFFSET + 10)
f01045a6:	6a 00                	push   $0x0
f01045a8:	6a 2a                	push   $0x2a
f01045aa:	eb 24                	jmp    f01045d0 <_alltraps>

f01045ac <th43>:
	TRAPHANDLER_NOEC(th43, IRQ_OFFSET + 11)
f01045ac:	6a 00                	push   $0x0
f01045ae:	6a 2b                	push   $0x2b
f01045b0:	eb 1e                	jmp    f01045d0 <_alltraps>

f01045b2 <th44>:
	TRAPHANDLER_NOEC(th44, IRQ_OFFSET + 12)
f01045b2:	6a 00                	push   $0x0
f01045b4:	6a 2c                	push   $0x2c
f01045b6:	eb 18                	jmp    f01045d0 <_alltraps>

f01045b8 <th45>:
	TRAPHANDLER_NOEC(th45, IRQ_OFFSET + 13)
f01045b8:	6a 00                	push   $0x0
f01045ba:	6a 2d                	push   $0x2d
f01045bc:	eb 12                	jmp    f01045d0 <_alltraps>

f01045be <th46>:
	TRAPHANDLER_NOEC(th46, IRQ_OFFSET + 14)
f01045be:	6a 00                	push   $0x0
f01045c0:	6a 2e                	push   $0x2e
f01045c2:	eb 0c                	jmp    f01045d0 <_alltraps>

f01045c4 <th47>:
	TRAPHANDLER_NOEC(th47, IRQ_OFFSET + 15)
f01045c4:	6a 00                	push   $0x0
f01045c6:	6a 2f                	push   $0x2f
f01045c8:	eb 06                	jmp    f01045d0 <_alltraps>

f01045ca <th_syscall>:

	TRAPHANDLER_NOEC(th_syscall, T_SYSCALL)
f01045ca:	6a 00                	push   $0x0
f01045cc:	6a 30                	push   $0x30
f01045ce:	eb 00                	jmp    f01045d0 <_alltraps>

f01045d0 <_alltraps>:

/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushl %ds
f01045d0:	1e                   	push   %ds
    pushl %es
f01045d1:	06                   	push   %es
    pushal
f01045d2:	60                   	pusha  
    movw $GD_KD, %ax
f01045d3:	66 b8 10 00          	mov    $0x10,%ax
    movw %ax, %ds
f01045d7:	8e d8                	mov    %eax,%ds
    movw %ax, %es
f01045d9:	8e c0                	mov    %eax,%es
    pushl %esp
f01045db:	54                   	push   %esp
    call trap
f01045dc:	e8 b1 fc ff ff       	call   f0104292 <trap>

f01045e1 <sched_halt>:

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
f01045e1:	f3 0f 1e fb          	endbr32 
f01045e5:	55                   	push   %ebp
f01045e6:	89 e5                	mov    %esp,%ebp
f01045e8:	83 ec 08             	sub    $0x8,%esp
f01045eb:	a1 44 82 23 f0       	mov    0xf0238244,%eax
f01045f0:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
f01045f3:	b9 00 00 00 00       	mov    $0x0,%ecx
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
f01045f8:	8b 02                	mov    (%edx),%eax
f01045fa:	83 e8 01             	sub    $0x1,%eax
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01045fd:	83 f8 02             	cmp    $0x2,%eax
f0104600:	76 30                	jbe    f0104632 <sched_halt+0x51>
	for (i = 0; i < NENV; i++)
f0104602:	83 c1 01             	add    $0x1,%ecx
f0104605:	81 c2 84 00 00 00    	add    $0x84,%edx
f010460b:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0104611:	75 e5                	jne    f01045f8 <sched_halt+0x17>
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
	{
		cprintf("No runnable environments in the system!\n");
f0104613:	83 ec 0c             	sub    $0xc,%esp
f0104616:	68 b0 7e 10 f0       	push   $0xf0107eb0
f010461b:	e8 91 f2 ff ff       	call   f01038b1 <cprintf>
f0104620:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0104623:	83 ec 0c             	sub    $0xc,%esp
f0104626:	6a 00                	push   $0x0
f0104628:	e8 e9 c2 ff ff       	call   f0100916 <monitor>
f010462d:	83 c4 10             	add    $0x10,%esp
f0104630:	eb f1                	jmp    f0104623 <sched_halt+0x42>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0104632:	e8 37 1b 00 00       	call   f010616e <cpunum>
f0104637:	6b c0 74             	imul   $0x74,%eax,%eax
f010463a:	c7 80 28 90 23 f0 00 	movl   $0x0,-0xfdc6fd8(%eax)
f0104641:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0104644:	a1 8c 8e 23 f0       	mov    0xf0238e8c,%eax
	if ((uint32_t)kva < KERNBASE)
f0104649:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010464e:	76 50                	jbe    f01046a0 <sched_halt+0xbf>
	return (physaddr_t)kva - KERNBASE;
f0104650:	05 00 00 00 10       	add    $0x10000000,%eax
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104655:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104658:	e8 11 1b 00 00       	call   f010616e <cpunum>
f010465d:	6b d0 74             	imul   $0x74,%eax,%edx
f0104660:	83 c2 04             	add    $0x4,%edx
	asm volatile("lock; xchgl %0, %1"
f0104663:	b8 02 00 00 00       	mov    $0x2,%eax
f0104668:	f0 87 82 20 90 23 f0 	lock xchg %eax,-0xfdc6fe0(%edx)
	spin_unlock(&kernel_lock);
f010466f:	83 ec 0c             	sub    $0xc,%esp
f0104672:	68 c0 33 12 f0       	push   $0xf01233c0
f0104677:	e8 18 1e 00 00       	call   f0106494 <spin_unlock>
	asm volatile("pause");
f010467c:	f3 90                	pause  
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
f010467e:	e8 eb 1a 00 00       	call   f010616e <cpunum>
f0104683:	6b c0 74             	imul   $0x74,%eax,%eax
	asm volatile(
f0104686:	8b 80 30 90 23 f0    	mov    -0xfdc6fd0(%eax),%eax
f010468c:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104691:	89 c4                	mov    %eax,%esp
f0104693:	6a 00                	push   $0x0
f0104695:	6a 00                	push   $0x0
f0104697:	fb                   	sti    
f0104698:	f4                   	hlt    
f0104699:	eb fd                	jmp    f0104698 <sched_halt+0xb7>
}
f010469b:	83 c4 10             	add    $0x10,%esp
f010469e:	c9                   	leave  
f010469f:	c3                   	ret    
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01046a0:	50                   	push   %eax
f01046a1:	68 28 68 10 f0       	push   $0xf0106828
f01046a6:	68 b1 00 00 00       	push   $0xb1
f01046ab:	68 d9 7e 10 f0       	push   $0xf0107ed9
f01046b0:	e8 8b b9 ff ff       	call   f0100040 <_panic>

f01046b5 <sched_yield>:
{
f01046b5:	f3 0f 1e fb          	endbr32 
f01046b9:	55                   	push   %ebp
f01046ba:	89 e5                	mov    %esp,%ebp
f01046bc:	57                   	push   %edi
f01046bd:	56                   	push   %esi
f01046be:	53                   	push   %ebx
f01046bf:	83 ec 1c             	sub    $0x1c,%esp
	if(nexTime>curTime){
f01046c2:	a1 6c 8a 23 f0       	mov    0xf0238a6c,%eax
f01046c7:	39 05 68 8a 23 f0    	cmp    %eax,0xf0238a68
f01046cd:	0f 8e d8 00 00 00    	jle    f01047ab <sched_yield+0xf6>
		curTime+=1;
f01046d3:	8d 50 01             	lea    0x1(%eax),%edx
		if(curTime == MAXTIME){
f01046d6:	83 f8 13             	cmp    $0x13,%eax
f01046d9:	0f 84 29 01 00 00    	je     f0104808 <sched_yield+0x153>
		curTime+=1;
f01046df:	89 15 6c 8a 23 f0    	mov    %edx,0xf0238a6c
		if(curenv){
f01046e5:	e8 84 1a 00 00       	call   f010616e <cpunum>
f01046ea:	6b c0 74             	imul   $0x74,%eax,%eax
f01046ed:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01046f4:	0f 84 6c 01 00 00    	je     f0104866 <sched_yield+0x1b1>
			curenv->runtime+=1;
f01046fa:	e8 6f 1a 00 00       	call   f010616e <cpunum>
f01046ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104702:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104708:	83 40 7c 01          	addl   $0x1,0x7c(%eax)
			start= ENVX(curenv->env_id) + 1;
f010470c:	e8 5d 1a 00 00       	call   f010616e <cpunum>
f0104711:	6b c0 74             	imul   $0x74,%eax,%eax
f0104714:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010471a:	8b 40 48             	mov    0x48(%eax),%eax
f010471d:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104722:	83 c0 01             	add    $0x1,%eax
f0104725:	89 45 e4             	mov    %eax,-0x1c(%ebp)
			if(curenv->runtime >= limite[curenv->Q]){
f0104728:	e8 41 1a 00 00       	call   f010616e <cpunum>
f010472d:	6b c0 74             	imul   $0x74,%eax,%eax
f0104730:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104736:	8b 58 7c             	mov    0x7c(%eax),%ebx
f0104739:	e8 30 1a 00 00       	call   f010616e <cpunum>
f010473e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104741:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104747:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
f010474d:	3b 1c 85 e8 7e 10 f0 	cmp    -0xfef8118(,%eax,4),%ebx
f0104754:	0f 8c f6 00 00 00    	jl     f0104850 <sched_yield+0x19b>
				curenv->Q+=1;
f010475a:	e8 0f 1a 00 00       	call   f010616e <cpunum>
f010475f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104762:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104768:	83 80 80 00 00 00 01 	addl   $0x1,0x80(%eax)
				curenv->runtime = 0;
f010476f:	e8 fa 19 00 00       	call   f010616e <cpunum>
f0104774:	6b c0 74             	imul   $0x74,%eax,%eax
f0104777:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010477d:	c7 40 7c 00 00 00 00 	movl   $0x0,0x7c(%eax)
		for(curQ=0;curQ<4;curQ++){
f0104784:	c7 05 64 8a 23 f0 00 	movl   $0x0,0xf0238a64
f010478b:	00 00 00 
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)
f010478e:	8b 1d 44 82 23 f0    	mov    0xf0238244,%ebx
f0104794:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
		for(curQ=0;curQ<4;curQ++){
f0104798:	bf 00 00 00 00       	mov    $0x0,%edi
f010479d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047a0:	8d b0 00 04 00 00    	lea    0x400(%eax),%esi
f01047a6:	e9 17 01 00 00       	jmp    f01048c2 <sched_yield+0x20d>
		if (curenv)
f01047ab:	e8 be 19 00 00       	call   f010616e <cpunum>
f01047b0:	6b c0 74             	imul   $0x74,%eax,%eax
f01047b3:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01047ba:	74 43                	je     f01047ff <sched_yield+0x14a>
			start = ENVX(curenv->env_id) + 1; 
f01047bc:	e8 ad 19 00 00       	call   f010616e <cpunum>
f01047c1:	6b c0 74             	imul   $0x74,%eax,%eax
f01047c4:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01047ca:	8b 40 48             	mov    0x48(%eax),%eax
f01047cd:	25 ff 03 00 00       	and    $0x3ff,%eax
f01047d2:	83 c0 01             	add    $0x1,%eax
f01047d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		for(curQ=0;curQ<4;curQ++){
f01047d8:	c7 05 64 8a 23 f0 00 	movl   $0x0,0xf0238a64
f01047df:	00 00 00 
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)
f01047e2:	8b 35 44 82 23 f0    	mov    0xf0238244,%esi
f01047e8:	c6 45 e3 00          	movb   $0x0,-0x1d(%ebp)
		for(curQ=0;curQ<4;curQ++){
f01047ec:	bf 00 00 00 00       	mov    $0x0,%edi
f01047f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01047f4:	8d 98 00 04 00 00    	lea    0x400(%eax),%ebx
f01047fa:	e9 66 01 00 00       	jmp    f0104965 <sched_yield+0x2b0>
	int start = 0;
f01047ff:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104806:	eb d0                	jmp    f01047d8 <sched_yield+0x123>
			curTime=0;
f0104808:	c7 05 6c 8a 23 f0 00 	movl   $0x0,0xf0238a6c
f010480f:	00 00 00 
			nexTime=0;
f0104812:	c7 05 68 8a 23 f0 00 	movl   $0x0,0xf0238a68
f0104819:	00 00 00 
			curQ=0;
f010481c:	c7 05 64 8a 23 f0 00 	movl   $0x0,0xf0238a64
f0104823:	00 00 00 
				envs[i].Q=0;
f0104826:	8b 15 44 82 23 f0    	mov    0xf0238244,%edx
f010482c:	8d 42 7c             	lea    0x7c(%edx),%eax
f010482f:	81 c2 7c 10 02 00    	add    $0x2107c,%edx
f0104835:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
				envs[i].runtime=0;
f010483c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0104842:	05 84 00 00 00       	add    $0x84,%eax
			for(int i=0;i<NENV;i++){
f0104847:	39 d0                	cmp    %edx,%eax
f0104849:	75 ea                	jne    f0104835 <sched_yield+0x180>
f010484b:	e9 95 fe ff ff       	jmp    f01046e5 <sched_yield+0x30>
				env_run(curenv);
f0104850:	e8 19 19 00 00       	call   f010616e <cpunum>
f0104855:	83 ec 0c             	sub    $0xc,%esp
f0104858:	6b c0 74             	imul   $0x74,%eax,%eax
f010485b:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104861:	e8 07 ee ff ff       	call   f010366d <env_run>
	int start = 0;
f0104866:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010486d:	e9 12 ff ff ff       	jmp    f0104784 <sched_yield+0xcf>
f0104872:	83 c2 01             	add    $0x1,%edx
			for (int i = 0; i < NENV ; i++){
f0104875:	39 f2                	cmp    %esi,%edx
f0104877:	74 3d                	je     f01048b6 <sched_yield+0x201>
				j = (start + i) % NENV;
f0104879:	89 d1                	mov    %edx,%ecx
f010487b:	c1 f9 1f             	sar    $0x1f,%ecx
f010487e:	c1 e9 16             	shr    $0x16,%ecx
f0104881:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0104884:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104889:	29 c8                	sub    %ecx,%eax
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)
f010488b:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0104891:	01 d8                	add    %ebx,%eax
f0104893:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104897:	75 d9                	jne    f0104872 <sched_yield+0x1bd>
f0104899:	39 b8 80 00 00 00    	cmp    %edi,0x80(%eax)
f010489f:	75 d1                	jne    f0104872 <sched_yield+0x1bd>
f01048a1:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f01048a5:	74 06                	je     f01048ad <sched_yield+0x1f8>
f01048a7:	89 3d 64 8a 23 f0    	mov    %edi,0xf0238a64
					env_run(&envs[j]);
f01048ad:	83 ec 0c             	sub    $0xc,%esp
f01048b0:	50                   	push   %eax
f01048b1:	e8 b7 ed ff ff       	call   f010366d <env_run>
		for(curQ=0;curQ<4;curQ++){
f01048b6:	83 c7 01             	add    $0x1,%edi
f01048b9:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f01048bd:	83 ff 03             	cmp    $0x3,%edi
f01048c0:	7f 05                	jg     f01048c7 <sched_yield+0x212>
f01048c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01048c5:	eb b2                	jmp    f0104879 <sched_yield+0x1c4>
f01048c7:	89 3d 64 8a 23 f0    	mov    %edi,0xf0238a64
		if (curenv && curenv->env_status == ENV_RUNNING)
f01048cd:	e8 9c 18 00 00       	call   f010616e <cpunum>
f01048d2:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d5:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01048dc:	74 14                	je     f01048f2 <sched_yield+0x23d>
f01048de:	e8 8b 18 00 00       	call   f010616e <cpunum>
f01048e3:	6b c0 74             	imul   $0x74,%eax,%eax
f01048e6:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01048ec:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01048f0:	74 0d                	je     f01048ff <sched_yield+0x24a>
		sched_halt();
f01048f2:	e8 ea fc ff ff       	call   f01045e1 <sched_halt>
}
f01048f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01048fa:	5b                   	pop    %ebx
f01048fb:	5e                   	pop    %esi
f01048fc:	5f                   	pop    %edi
f01048fd:	5d                   	pop    %ebp
f01048fe:	c3                   	ret    
			env_run(curenv);
f01048ff:	e8 6a 18 00 00       	call   f010616e <cpunum>
f0104904:	83 ec 0c             	sub    $0xc,%esp
f0104907:	6b c0 74             	imul   $0x74,%eax,%eax
f010490a:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104910:	e8 58 ed ff ff       	call   f010366d <env_run>
f0104915:	83 c2 01             	add    $0x1,%edx
			for (int i = 0; i < NENV ; i++){
f0104918:	39 d3                	cmp    %edx,%ebx
f010491a:	74 3d                	je     f0104959 <sched_yield+0x2a4>
				j = (start + i) % NENV;
f010491c:	89 d1                	mov    %edx,%ecx
f010491e:	c1 f9 1f             	sar    $0x1f,%ecx
f0104921:	c1 e9 16             	shr    $0x16,%ecx
f0104924:	8d 04 0a             	lea    (%edx,%ecx,1),%eax
f0104927:	25 ff 03 00 00       	and    $0x3ff,%eax
f010492c:	29 c8                	sub    %ecx,%eax
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)
f010492e:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0104934:	01 f0                	add    %esi,%eax
f0104936:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f010493a:	75 d9                	jne    f0104915 <sched_yield+0x260>
f010493c:	39 b8 80 00 00 00    	cmp    %edi,0x80(%eax)
f0104942:	75 d1                	jne    f0104915 <sched_yield+0x260>
f0104944:	80 7d e3 00          	cmpb   $0x0,-0x1d(%ebp)
f0104948:	74 06                	je     f0104950 <sched_yield+0x29b>
f010494a:	89 3d 64 8a 23 f0    	mov    %edi,0xf0238a64
					env_run(&envs[j]);
f0104950:	83 ec 0c             	sub    $0xc,%esp
f0104953:	50                   	push   %eax
f0104954:	e8 14 ed ff ff       	call   f010366d <env_run>
		for(curQ=0;curQ<4;curQ++){
f0104959:	83 c7 01             	add    $0x1,%edi
f010495c:	c6 45 e3 01          	movb   $0x1,-0x1d(%ebp)
f0104960:	83 ff 03             	cmp    $0x3,%edi
f0104963:	7f 05                	jg     f010496a <sched_yield+0x2b5>
f0104965:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104968:	eb b2                	jmp    f010491c <sched_yield+0x267>
f010496a:	89 3d 64 8a 23 f0    	mov    %edi,0xf0238a64
		if (curenv && curenv->env_status == ENV_RUNNING)
f0104970:	e8 f9 17 00 00       	call   f010616e <cpunum>
f0104975:	6b c0 74             	imul   $0x74,%eax,%eax
f0104978:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f010497f:	74 14                	je     f0104995 <sched_yield+0x2e0>
f0104981:	e8 e8 17 00 00       	call   f010616e <cpunum>
f0104986:	6b c0 74             	imul   $0x74,%eax,%eax
f0104989:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f010498f:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104993:	74 0a                	je     f010499f <sched_yield+0x2ea>
		sched_halt();
f0104995:	e8 47 fc ff ff       	call   f01045e1 <sched_halt>
}
f010499a:	e9 58 ff ff ff       	jmp    f01048f7 <sched_yield+0x242>
			env_run(curenv);
f010499f:	e8 ca 17 00 00       	call   f010616e <cpunum>
f01049a4:	83 ec 0c             	sub    $0xc,%esp
f01049a7:	6b c0 74             	imul   $0x74,%eax,%eax
f01049aa:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f01049b0:	e8 b8 ec ff ff       	call   f010366d <env_run>

f01049b5 <sched_yield2>:
{
f01049b5:	f3 0f 1e fb          	endbr32 
f01049b9:	55                   	push   %ebp
f01049ba:	89 e5                	mov    %esp,%ebp
f01049bc:	56                   	push   %esi
f01049bd:	53                   	push   %ebx
	if (curenv)
f01049be:	e8 ab 17 00 00       	call   f010616e <cpunum>
f01049c3:	6b c0 74             	imul   $0x74,%eax,%eax
	int start = 0;
f01049c6:	b9 00 00 00 00       	mov    $0x0,%ecx
	if (curenv)
f01049cb:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f01049d2:	74 1a                	je     f01049ee <sched_yield2+0x39>
		start = ENVX(curenv->env_id) + 1; 
f01049d4:	e8 95 17 00 00       	call   f010616e <cpunum>
f01049d9:	6b c0 74             	imul   $0x74,%eax,%eax
f01049dc:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f01049e2:	8b 48 48             	mov    0x48(%eax),%ecx
f01049e5:	81 e1 ff 03 00 00    	and    $0x3ff,%ecx
f01049eb:	83 c1 01             	add    $0x1,%ecx
		if (envs[j].env_status == ENV_RUNNABLE )
f01049ee:	8b 1d 44 82 23 f0    	mov    0xf0238244,%ebx
f01049f4:	89 ca                	mov    %ecx,%edx
f01049f6:	81 c1 00 04 00 00    	add    $0x400,%ecx
		j = (start + i) % NENV;
f01049fc:	89 d6                	mov    %edx,%esi
f01049fe:	c1 fe 1f             	sar    $0x1f,%esi
f0104a01:	c1 ee 16             	shr    $0x16,%esi
f0104a04:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0104a07:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104a0c:	29 f0                	sub    %esi,%eax
		if (envs[j].env_status == ENV_RUNNABLE )
f0104a0e:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
f0104a14:	01 d8                	add    %ebx,%eax
f0104a16:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104a1a:	74 38                	je     f0104a54 <sched_yield2+0x9f>
f0104a1c:	83 c2 01             	add    $0x1,%edx
	for (int i = 0; i < NENV ; i++)
f0104a1f:	39 ca                	cmp    %ecx,%edx
f0104a21:	75 d9                	jne    f01049fc <sched_yield2+0x47>
	if (curenv && curenv->env_status == ENV_RUNNING)
f0104a23:	e8 46 17 00 00       	call   f010616e <cpunum>
f0104a28:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a2b:	83 b8 28 90 23 f0 00 	cmpl   $0x0,-0xfdc6fd8(%eax)
f0104a32:	74 14                	je     f0104a48 <sched_yield2+0x93>
f0104a34:	e8 35 17 00 00       	call   f010616e <cpunum>
f0104a39:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a3c:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104a42:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0104a46:	74 15                	je     f0104a5d <sched_yield2+0xa8>
	sched_halt();
f0104a48:	e8 94 fb ff ff       	call   f01045e1 <sched_halt>
}
f0104a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0104a50:	5b                   	pop    %ebx
f0104a51:	5e                   	pop    %esi
f0104a52:	5d                   	pop    %ebp
f0104a53:	c3                   	ret    
			env_run(&envs[j]);
f0104a54:	83 ec 0c             	sub    $0xc,%esp
f0104a57:	50                   	push   %eax
f0104a58:	e8 10 ec ff ff       	call   f010366d <env_run>
		env_run(curenv);
f0104a5d:	e8 0c 17 00 00       	call   f010616e <cpunum>
f0104a62:	83 ec 0c             	sub    $0xc,%esp
f0104a65:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a68:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104a6e:	e8 fa eb ff ff       	call   f010366d <env_run>

f0104a73 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104a73:	f3 0f 1e fb          	endbr32 
f0104a77:	55                   	push   %ebp
f0104a78:	89 e5                	mov    %esp,%ebp
f0104a7a:	57                   	push   %edi
f0104a7b:	56                   	push   %esi
f0104a7c:	53                   	push   %ebx
f0104a7d:	83 ec 1c             	sub    $0x1c,%esp
f0104a80:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a83:	83 f8 0c             	cmp    $0xc,%eax
f0104a86:	0f 87 2e 05 00 00    	ja     f0104fba <syscall+0x547>
f0104a8c:	3e ff 24 85 30 7f 10 	notrack jmp *-0xfef80d0(,%eax,4)
f0104a93:	f0 
	user_mem_assert(curenv, s, len, 0);
f0104a94:	e8 d5 16 00 00       	call   f010616e <cpunum>
f0104a99:	6a 00                	push   $0x0
f0104a9b:	ff 75 10             	pushl  0x10(%ebp)
f0104a9e:	ff 75 0c             	pushl  0xc(%ebp)
f0104aa1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104aa4:	ff b0 28 90 23 f0    	pushl  -0xfdc6fd8(%eax)
f0104aaa:	e8 8b e4 ff ff       	call   f0102f3a <user_mem_assert>
	cprintf("%.*s", len, s);
f0104aaf:	83 c4 0c             	add    $0xc,%esp
f0104ab2:	ff 75 0c             	pushl  0xc(%ebp)
f0104ab5:	ff 75 10             	pushl  0x10(%ebp)
f0104ab8:	68 f8 7e 10 f0       	push   $0xf0107ef8
f0104abd:	e8 ef ed ff ff       	call   f01038b1 <cprintf>
}
f0104ac2:	83 c4 10             	add    $0x10,%esp
	// LAB 3: Your code here.
	int32_t ret;
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *)a1, (size_t)a2);
			ret = 0;
f0104ac5:	bb 00 00 00 00       	mov    $0x0,%ebx
		default:
			return -E_INVAL;
	}

	return ret;
}
f0104aca:	89 d8                	mov    %ebx,%eax
f0104acc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104acf:	5b                   	pop    %ebx
f0104ad0:	5e                   	pop    %esi
f0104ad1:	5f                   	pop    %edi
f0104ad2:	5d                   	pop    %ebp
f0104ad3:	c3                   	ret    
	return cons_getc();
f0104ad4:	e8 26 bb ff ff       	call   f01005ff <cons_getc>
f0104ad9:	89 c3                	mov    %eax,%ebx
			break;
f0104adb:	eb ed                	jmp    f0104aca <syscall+0x57>
	return curenv->env_id;
f0104add:	e8 8c 16 00 00       	call   f010616e <cpunum>
f0104ae2:	6b c0 74             	imul   $0x74,%eax,%eax
f0104ae5:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104aeb:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f0104aee:	eb da                	jmp    f0104aca <syscall+0x57>
	if ((r = envid2env(envid, &e, 1)) < 0)
f0104af0:	83 ec 04             	sub    $0x4,%esp
f0104af3:	6a 01                	push   $0x1
f0104af5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104af8:	50                   	push   %eax
f0104af9:	ff 75 0c             	pushl  0xc(%ebp)
f0104afc:	e8 f4 e4 ff ff       	call   f0102ff5 <envid2env>
f0104b01:	89 c3                	mov    %eax,%ebx
f0104b03:	83 c4 10             	add    $0x10,%esp
f0104b06:	85 c0                	test   %eax,%eax
f0104b08:	78 c0                	js     f0104aca <syscall+0x57>
	if (e == curenv)
f0104b0a:	e8 5f 16 00 00       	call   f010616e <cpunum>
f0104b0f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104b12:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b15:	39 90 28 90 23 f0    	cmp    %edx,-0xfdc6fd8(%eax)
f0104b1b:	74 3d                	je     f0104b5a <syscall+0xe7>
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104b1d:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104b20:	e8 49 16 00 00       	call   f010616e <cpunum>
f0104b25:	83 ec 04             	sub    $0x4,%esp
f0104b28:	53                   	push   %ebx
f0104b29:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b2c:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104b32:	ff 70 48             	pushl  0x48(%eax)
f0104b35:	68 18 7f 10 f0       	push   $0xf0107f18
f0104b3a:	e8 72 ed ff ff       	call   f01038b1 <cprintf>
f0104b3f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104b42:	83 ec 0c             	sub    $0xc,%esp
f0104b45:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104b48:	e8 79 ea ff ff       	call   f01035c6 <env_destroy>
	return 0;
f0104b4d:	83 c4 10             	add    $0x10,%esp
f0104b50:	bb 00 00 00 00       	mov    $0x0,%ebx
			break;
f0104b55:	e9 70 ff ff ff       	jmp    f0104aca <syscall+0x57>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104b5a:	e8 0f 16 00 00       	call   f010616e <cpunum>
f0104b5f:	83 ec 08             	sub    $0x8,%esp
f0104b62:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b65:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104b6b:	ff 70 48             	pushl  0x48(%eax)
f0104b6e:	68 fd 7e 10 f0       	push   $0xf0107efd
f0104b73:	e8 39 ed ff ff       	call   f01038b1 <cprintf>
f0104b78:	83 c4 10             	add    $0x10,%esp
f0104b7b:	eb c5                	jmp    f0104b42 <syscall+0xcf>
	sched_yield();
f0104b7d:	e8 33 fb ff ff       	call   f01046b5 <sched_yield>
	int ret = env_alloc(&e, curenv->env_id);
f0104b82:	e8 e7 15 00 00       	call   f010616e <cpunum>
f0104b87:	83 ec 08             	sub    $0x8,%esp
f0104b8a:	6b c0 74             	imul   $0x74,%eax,%eax
f0104b8d:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104b93:	ff 70 48             	pushl  0x48(%eax)
f0104b96:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104b99:	50                   	push   %eax
f0104b9a:	e8 69 e5 ff ff       	call   f0103108 <env_alloc>
f0104b9f:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104ba1:	83 c4 10             	add    $0x10,%esp
f0104ba4:	85 c0                	test   %eax,%eax
f0104ba6:	0f 88 1e ff ff ff    	js     f0104aca <syscall+0x57>
	e->env_tf = curenv->env_tf;			
f0104bac:	e8 bd 15 00 00       	call   f010616e <cpunum>
f0104bb1:	6b c0 74             	imul   $0x74,%eax,%eax
f0104bb4:	8b b0 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%esi
f0104bba:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104bbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bc2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	e->env_status = ENV_NOT_RUNNABLE;
f0104bc4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104bc7:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	e->env_tf.tf_regs.reg_eax = 0;		
f0104bce:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return e->env_id;
f0104bd5:	8b 58 48             	mov    0x48(%eax),%ebx
			break;
f0104bd8:	e9 ed fe ff ff       	jmp    f0104aca <syscall+0x57>
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104bdd:	8b 45 10             	mov    0x10(%ebp),%eax
f0104be0:	83 e8 02             	sub    $0x2,%eax
f0104be3:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104be8:	75 31                	jne    f0104c1b <syscall+0x1a8>
	int ret = envid2env(envid, &e, 1);
f0104bea:	83 ec 04             	sub    $0x4,%esp
f0104bed:	6a 01                	push   $0x1
f0104bef:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104bf2:	50                   	push   %eax
f0104bf3:	ff 75 0c             	pushl  0xc(%ebp)
f0104bf6:	e8 fa e3 ff ff       	call   f0102ff5 <envid2env>
f0104bfb:	89 c3                	mov    %eax,%ebx
	if (ret < 0) {
f0104bfd:	83 c4 10             	add    $0x10,%esp
f0104c00:	85 c0                	test   %eax,%eax
f0104c02:	0f 88 c2 fe ff ff    	js     f0104aca <syscall+0x57>
	e->env_status = status;
f0104c08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104c0e:	89 48 54             	mov    %ecx,0x54(%eax)
	return 0;
f0104c11:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104c16:	e9 af fe ff ff       	jmp    f0104aca <syscall+0x57>
	if (status != ENV_NOT_RUNNABLE && status != ENV_RUNNABLE) return -E_INVAL;
f0104c1b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104c20:	e9 a5 fe ff ff       	jmp    f0104aca <syscall+0x57>
	int ret = envid2env(envid, &e, 1);
f0104c25:	83 ec 04             	sub    $0x4,%esp
f0104c28:	6a 01                	push   $0x1
f0104c2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104c2d:	50                   	push   %eax
f0104c2e:	ff 75 0c             	pushl  0xc(%ebp)
f0104c31:	e8 bf e3 ff ff       	call   f0102ff5 <envid2env>
f0104c36:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	
f0104c38:	83 c4 10             	add    $0x10,%esp
f0104c3b:	85 c0                	test   %eax,%eax
f0104c3d:	0f 85 87 fe ff ff    	jne    f0104aca <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;	
f0104c43:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104c4a:	77 5c                	ja     f0104ca8 <syscall+0x235>
f0104c4c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104c53:	75 5d                	jne    f0104cb2 <syscall+0x23f>
	if ((perm & flag) != flag) return -E_INVAL;
f0104c55:	8b 45 14             	mov    0x14(%ebp),%eax
f0104c58:	83 e0 05             	and    $0x5,%eax
f0104c5b:	83 f8 05             	cmp    $0x5,%eax
f0104c5e:	75 5c                	jne    f0104cbc <syscall+0x249>
	struct PageInfo *pg = page_alloc(1);			
f0104c60:	83 ec 0c             	sub    $0xc,%esp
f0104c63:	6a 01                	push   $0x1
f0104c65:	e8 97 c2 ff ff       	call   f0100f01 <page_alloc>
f0104c6a:	89 c6                	mov    %eax,%esi
	if (!pg) return -E_NO_MEM;
f0104c6c:	83 c4 10             	add    $0x10,%esp
f0104c6f:	85 c0                	test   %eax,%eax
f0104c71:	74 53                	je     f0104cc6 <syscall+0x253>
	pg->pp_ref++;
f0104c73:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
	ret = page_insert(e->env_pgdir, pg, va, perm);	
f0104c78:	ff 75 14             	pushl  0x14(%ebp)
f0104c7b:	ff 75 10             	pushl  0x10(%ebp)
f0104c7e:	50                   	push   %eax
f0104c7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104c82:	ff 70 60             	pushl  0x60(%eax)
f0104c85:	e8 57 c5 ff ff       	call   f01011e1 <page_insert>
f0104c8a:	89 c3                	mov    %eax,%ebx
	if (ret) {
f0104c8c:	83 c4 10             	add    $0x10,%esp
f0104c8f:	85 c0                	test   %eax,%eax
f0104c91:	0f 84 33 fe ff ff    	je     f0104aca <syscall+0x57>
		page_free(pg);
f0104c97:	83 ec 0c             	sub    $0xc,%esp
f0104c9a:	56                   	push   %esi
f0104c9b:	e8 da c2 ff ff       	call   f0100f7a <page_free>
		return ret;
f0104ca0:	83 c4 10             	add    $0x10,%esp
f0104ca3:	e9 22 fe ff ff       	jmp    f0104aca <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;	
f0104ca8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cad:	e9 18 fe ff ff       	jmp    f0104aca <syscall+0x57>
f0104cb2:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cb7:	e9 0e fe ff ff       	jmp    f0104aca <syscall+0x57>
	if ((perm & flag) != flag) return -E_INVAL;
f0104cbc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104cc1:	e9 04 fe ff ff       	jmp    f0104aca <syscall+0x57>
	if (!pg) return -E_NO_MEM;
f0104cc6:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
			break;
f0104ccb:	e9 fa fd ff ff       	jmp    f0104aca <syscall+0x57>
	int ret = envid2env(srcenvid, &se, 1);
f0104cd0:	83 ec 04             	sub    $0x4,%esp
f0104cd3:	6a 01                	push   $0x1
f0104cd5:	8d 45 dc             	lea    -0x24(%ebp),%eax
f0104cd8:	50                   	push   %eax
f0104cd9:	ff 75 0c             	pushl  0xc(%ebp)
f0104cdc:	e8 14 e3 ff ff       	call   f0102ff5 <envid2env>
f0104ce1:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104ce3:	83 c4 10             	add    $0x10,%esp
f0104ce6:	85 c0                	test   %eax,%eax
f0104ce8:	0f 85 dc fd ff ff    	jne    f0104aca <syscall+0x57>
	ret = envid2env(dstenvid, &de, 1);
f0104cee:	83 ec 04             	sub    $0x4,%esp
f0104cf1:	6a 01                	push   $0x1
f0104cf3:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104cf6:	50                   	push   %eax
f0104cf7:	ff 75 14             	pushl  0x14(%ebp)
f0104cfa:	e8 f6 e2 ff ff       	call   f0102ff5 <envid2env>
f0104cff:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;	//bad_env
f0104d01:	83 c4 10             	add    $0x10,%esp
f0104d04:	85 c0                	test   %eax,%eax
f0104d06:	0f 85 be fd ff ff    	jne    f0104aca <syscall+0x57>
	if (srcva >= (void*)UTOP || dstva >= (void*)UTOP || 
f0104d0c:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104d13:	77 6c                	ja     f0104d81 <syscall+0x30e>
f0104d15:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104d1c:	77 63                	ja     f0104d81 <syscall+0x30e>
f0104d1e:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104d25:	75 64                	jne    f0104d8b <syscall+0x318>
		ROUNDDOWN(srcva,PGSIZE) != srcva || ROUNDDOWN(dstva,PGSIZE) != dstva) 
f0104d27:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f0104d2e:	75 65                	jne    f0104d95 <syscall+0x322>
	struct PageInfo *pg = page_lookup(se->env_pgdir, srcva, &pte);
f0104d30:	83 ec 04             	sub    $0x4,%esp
f0104d33:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104d36:	50                   	push   %eax
f0104d37:	ff 75 10             	pushl  0x10(%ebp)
f0104d3a:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d3d:	ff 70 60             	pushl  0x60(%eax)
f0104d40:	e8 b1 c3 ff ff       	call   f01010f6 <page_lookup>
	if (!pg) return -E_INVAL;
f0104d45:	83 c4 10             	add    $0x10,%esp
f0104d48:	85 c0                	test   %eax,%eax
f0104d4a:	74 53                	je     f0104d9f <syscall+0x32c>
	if ((perm & flag) != flag) return -E_INVAL;
f0104d4c:	8b 55 1c             	mov    0x1c(%ebp),%edx
f0104d4f:	83 e2 05             	and    $0x5,%edx
f0104d52:	83 fa 05             	cmp    $0x5,%edx
f0104d55:	75 52                	jne    f0104da9 <syscall+0x336>
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104d57:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104d5a:	f6 02 02             	testb  $0x2,(%edx)
f0104d5d:	75 06                	jne    f0104d65 <syscall+0x2f2>
f0104d5f:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f0104d63:	75 4e                	jne    f0104db3 <syscall+0x340>
	ret = page_insert(de->env_pgdir, pg, dstva, perm);
f0104d65:	ff 75 1c             	pushl  0x1c(%ebp)
f0104d68:	ff 75 18             	pushl  0x18(%ebp)
f0104d6b:	50                   	push   %eax
f0104d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d6f:	ff 70 60             	pushl  0x60(%eax)
f0104d72:	e8 6a c4 ff ff       	call   f01011e1 <page_insert>
f0104d77:	89 c3                	mov    %eax,%ebx
	return ret;
f0104d79:	83 c4 10             	add    $0x10,%esp
f0104d7c:	e9 49 fd ff ff       	jmp    f0104aca <syscall+0x57>
		return -E_INVAL;
f0104d81:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d86:	e9 3f fd ff ff       	jmp    f0104aca <syscall+0x57>
f0104d8b:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d90:	e9 35 fd ff ff       	jmp    f0104aca <syscall+0x57>
f0104d95:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104d9a:	e9 2b fd ff ff       	jmp    f0104aca <syscall+0x57>
	if (!pg) return -E_INVAL;
f0104d9f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104da4:	e9 21 fd ff ff       	jmp    f0104aca <syscall+0x57>
	if ((perm & flag) != flag) return -E_INVAL;
f0104da9:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104dae:	e9 17 fd ff ff       	jmp    f0104aca <syscall+0x57>
	if (((*pte&PTE_W) == 0) && (perm&PTE_W)) return -E_INVAL;
f0104db3:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104db8:	e9 0d fd ff ff       	jmp    f0104aca <syscall+0x57>
	int ret = envid2env(envid, &env, 1);
f0104dbd:	83 ec 04             	sub    $0x4,%esp
f0104dc0:	6a 01                	push   $0x1
f0104dc2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104dc5:	50                   	push   %eax
f0104dc6:	ff 75 0c             	pushl  0xc(%ebp)
f0104dc9:	e8 27 e2 ff ff       	call   f0102ff5 <envid2env>
f0104dce:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;
f0104dd0:	83 c4 10             	add    $0x10,%esp
f0104dd3:	85 c0                	test   %eax,%eax
f0104dd5:	0f 85 ef fc ff ff    	jne    f0104aca <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;
f0104ddb:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104de2:	77 22                	ja     f0104e06 <syscall+0x393>
f0104de4:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104deb:	75 23                	jne    f0104e10 <syscall+0x39d>
	page_remove(env->env_pgdir, va);
f0104ded:	83 ec 08             	sub    $0x8,%esp
f0104df0:	ff 75 10             	pushl  0x10(%ebp)
f0104df3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104df6:	ff 70 60             	pushl  0x60(%eax)
f0104df9:	e8 99 c3 ff ff       	call   f0101197 <page_remove>
	return 0;
f0104dfe:	83 c4 10             	add    $0x10,%esp
f0104e01:	e9 c4 fc ff ff       	jmp    f0104aca <syscall+0x57>
	if ((va >= (void*)UTOP) || (ROUNDDOWN(va, PGSIZE) != va)) return -E_INVAL;
f0104e06:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104e0b:	e9 ba fc ff ff       	jmp    f0104aca <syscall+0x57>
f0104e10:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			break;
f0104e15:	e9 b0 fc ff ff       	jmp    f0104aca <syscall+0x57>
	if ((ret = envid2env(envid, &env, 1)) < 0) {
f0104e1a:	83 ec 04             	sub    $0x4,%esp
f0104e1d:	6a 01                	push   $0x1
f0104e1f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104e22:	50                   	push   %eax
f0104e23:	ff 75 0c             	pushl  0xc(%ebp)
f0104e26:	e8 ca e1 ff ff       	call   f0102ff5 <envid2env>
f0104e2b:	89 c3                	mov    %eax,%ebx
f0104e2d:	83 c4 10             	add    $0x10,%esp
f0104e30:	85 c0                	test   %eax,%eax
f0104e32:	0f 88 92 fc ff ff    	js     f0104aca <syscall+0x57>
	env->env_pgfault_upcall = func;
f0104e38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104e3b:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104e3e:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f0104e41:	bb 00 00 00 00       	mov    $0x0,%ebx
			break;
f0104e46:	e9 7f fc ff ff       	jmp    f0104aca <syscall+0x57>
	int ret = envid2env(envid, &rcvenv, 0);
f0104e4b:	83 ec 04             	sub    $0x4,%esp
f0104e4e:	6a 00                	push   $0x0
f0104e50:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104e53:	50                   	push   %eax
f0104e54:	ff 75 0c             	pushl  0xc(%ebp)
f0104e57:	e8 99 e1 ff ff       	call   f0102ff5 <envid2env>
f0104e5c:	89 c3                	mov    %eax,%ebx
	if (ret) return ret;
f0104e5e:	83 c4 10             	add    $0x10,%esp
f0104e61:	85 c0                	test   %eax,%eax
f0104e63:	0f 85 61 fc ff ff    	jne    f0104aca <syscall+0x57>
	if (!rcvenv->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104e69:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e6c:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f0104e70:	0f 84 de 00 00 00    	je     f0104f54 <syscall+0x4e1>
	if (srcva < (void*)UTOP) {
f0104e76:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104e7d:	77 62                	ja     f0104ee1 <syscall+0x46e>
		struct PageInfo *pg = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104e7f:	e8 ea 12 00 00       	call   f010616e <cpunum>
f0104e84:	83 ec 04             	sub    $0x4,%esp
f0104e87:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104e8a:	52                   	push   %edx
f0104e8b:	ff 75 14             	pushl  0x14(%ebp)
f0104e8e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104e91:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104e97:	ff 70 60             	pushl  0x60(%eax)
f0104e9a:	e8 57 c2 ff ff       	call   f01010f6 <page_lookup>
		if (srcva != ROUNDDOWN(srcva, PGSIZE)) return -E_INVAL;		
f0104e9f:	83 c4 10             	add    $0x10,%esp
f0104ea2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f0104ea9:	74 0a                	je     f0104eb5 <syscall+0x442>
f0104eab:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104eb0:	e9 15 fc ff ff       	jmp    f0104aca <syscall+0x57>
		if ((*pte & perm) != perm) return -E_INVAL;					
f0104eb5:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104eb8:	8b 12                	mov    (%edx),%edx
f0104eba:	89 d1                	mov    %edx,%ecx
f0104ebc:	23 4d 18             	and    0x18(%ebp),%ecx
		if (!pg) return -E_INVAL;									
f0104ebf:	3b 4d 18             	cmp    0x18(%ebp),%ecx
f0104ec2:	75 75                	jne    f0104f39 <syscall+0x4c6>
f0104ec4:	85 c0                	test   %eax,%eax
f0104ec6:	74 71                	je     f0104f39 <syscall+0x4c6>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;		
f0104ec8:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104ecc:	74 05                	je     f0104ed3 <syscall+0x460>
f0104ece:	f6 c2 02             	test   $0x2,%dl
f0104ed1:	74 70                	je     f0104f43 <syscall+0x4d0>
		if (rcvenv->env_ipc_dstva < (void*)UTOP) {
f0104ed3:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104ed6:	8b 4a 6c             	mov    0x6c(%edx),%ecx
f0104ed9:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f0104edf:	76 39                	jbe    f0104f1a <syscall+0x4a7>
	rcvenv->env_ipc_recving = 0;					
f0104ee1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ee4:	c6 40 68 00          	movb   $0x0,0x68(%eax)
	rcvenv->env_ipc_from = curenv->env_id;
f0104ee8:	e8 81 12 00 00       	call   f010616e <cpunum>
f0104eed:	89 c2                	mov    %eax,%edx
f0104eef:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ef2:	6b d2 74             	imul   $0x74,%edx,%edx
f0104ef5:	8b 92 28 90 23 f0    	mov    -0xfdc6fd8(%edx),%edx
f0104efb:	8b 52 48             	mov    0x48(%edx),%edx
f0104efe:	89 50 74             	mov    %edx,0x74(%eax)
	rcvenv->env_ipc_value = value; 
f0104f01:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104f04:	89 78 70             	mov    %edi,0x70(%eax)
	rcvenv->env_status = ENV_RUNNABLE;
f0104f07:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	rcvenv->env_tf.tf_regs.reg_eax = 0;
f0104f0e:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104f15:	e9 b0 fb ff ff       	jmp    f0104aca <syscall+0x57>
			ret = page_insert(rcvenv->env_pgdir, pg, rcvenv->env_ipc_dstva, perm); 
f0104f1a:	ff 75 18             	pushl  0x18(%ebp)
f0104f1d:	51                   	push   %ecx
f0104f1e:	50                   	push   %eax
f0104f1f:	ff 72 60             	pushl  0x60(%edx)
f0104f22:	e8 ba c2 ff ff       	call   f01011e1 <page_insert>
			if (ret) return ret;
f0104f27:	83 c4 10             	add    $0x10,%esp
f0104f2a:	85 c0                	test   %eax,%eax
f0104f2c:	75 1f                	jne    f0104f4d <syscall+0x4da>
			rcvenv->env_ipc_perm = perm;
f0104f2e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104f31:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104f34:	89 78 78             	mov    %edi,0x78(%eax)
f0104f37:	eb a8                	jmp    f0104ee1 <syscall+0x46e>
		if (!pg) return -E_INVAL;									
f0104f39:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f3e:	e9 87 fb ff ff       	jmp    f0104aca <syscall+0x57>
		if ((perm & PTE_W) && !(*pte & PTE_W)) return -E_INVAL;		
f0104f43:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f48:	e9 7d fb ff ff       	jmp    f0104aca <syscall+0x57>
			if (ret) return ret;
f0104f4d:	89 c3                	mov    %eax,%ebx
f0104f4f:	e9 76 fb ff ff       	jmp    f0104aca <syscall+0x57>
	if (!rcvenv->env_ipc_recving) return -E_IPC_NOT_RECV;
f0104f54:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			break;
f0104f59:	e9 6c fb ff ff       	jmp    f0104aca <syscall+0x57>
	if (dstva < (void *)UTOP && dstva != ROUNDDOWN(dstva, PGSIZE)) {
f0104f5e:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f0104f65:	77 13                	ja     f0104f7a <syscall+0x507>
f0104f67:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104f6e:	74 0a                	je     f0104f7a <syscall+0x507>
			ret = sys_ipc_recv((void *)a1);
f0104f70:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104f75:	e9 50 fb ff ff       	jmp    f0104aca <syscall+0x57>
	curenv->env_ipc_recving = 1;
f0104f7a:	e8 ef 11 00 00       	call   f010616e <cpunum>
f0104f7f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f82:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104f88:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104f8c:	e8 dd 11 00 00       	call   f010616e <cpunum>
f0104f91:	6b c0 74             	imul   $0x74,%eax,%eax
f0104f94:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104f9a:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_ipc_dstva = dstva;
f0104fa1:	e8 c8 11 00 00       	call   f010616e <cpunum>
f0104fa6:	6b c0 74             	imul   $0x74,%eax,%eax
f0104fa9:	8b 80 28 90 23 f0    	mov    -0xfdc6fd8(%eax),%eax
f0104faf:	8b 7d 0c             	mov    0xc(%ebp),%edi
f0104fb2:	89 78 6c             	mov    %edi,0x6c(%eax)
	sched_yield();
f0104fb5:	e8 fb f6 ff ff       	call   f01046b5 <sched_yield>
			ret = 0;
f0104fba:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104fbf:	e9 06 fb ff ff       	jmp    f0104aca <syscall+0x57>

f0104fc4 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104fc4:	55                   	push   %ebp
f0104fc5:	89 e5                	mov    %esp,%ebp
f0104fc7:	57                   	push   %edi
f0104fc8:	56                   	push   %esi
f0104fc9:	53                   	push   %ebx
f0104fca:	83 ec 14             	sub    $0x14,%esp
f0104fcd:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104fd0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104fd3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104fd6:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104fd9:	8b 1a                	mov    (%edx),%ebx
f0104fdb:	8b 01                	mov    (%ecx),%eax
f0104fdd:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104fe0:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0104fe7:	eb 23                	jmp    f010500c <stab_binsearch+0x48>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104fe9:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104fec:	eb 1e                	jmp    f010500c <stab_binsearch+0x48>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104fee:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104ff1:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104ff4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104ff8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104ffb:	73 46                	jae    f0105043 <stab_binsearch+0x7f>
			*region_left = m;
f0104ffd:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0105000:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0105002:	8d 5f 01             	lea    0x1(%edi),%ebx
		any_matches = 1;
f0105005:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
	while (l <= r) {
f010500c:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010500f:	7f 5f                	jg     f0105070 <stab_binsearch+0xac>
		int true_m = (l + r) / 2, m = true_m;
f0105011:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0105014:	8d 14 03             	lea    (%ebx,%eax,1),%edx
f0105017:	89 d0                	mov    %edx,%eax
f0105019:	c1 e8 1f             	shr    $0x1f,%eax
f010501c:	01 d0                	add    %edx,%eax
f010501e:	89 c7                	mov    %eax,%edi
f0105020:	d1 ff                	sar    %edi
f0105022:	83 e0 fe             	and    $0xfffffffe,%eax
f0105025:	01 f8                	add    %edi,%eax
f0105027:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010502a:	8d 54 81 04          	lea    0x4(%ecx,%eax,4),%edx
f010502e:	89 f8                	mov    %edi,%eax
		while (m >= l && stabs[m].n_type != type)
f0105030:	39 c3                	cmp    %eax,%ebx
f0105032:	7f b5                	jg     f0104fe9 <stab_binsearch+0x25>
f0105034:	0f b6 0a             	movzbl (%edx),%ecx
f0105037:	83 ea 0c             	sub    $0xc,%edx
f010503a:	39 f1                	cmp    %esi,%ecx
f010503c:	74 b0                	je     f0104fee <stab_binsearch+0x2a>
			m--;
f010503e:	83 e8 01             	sub    $0x1,%eax
f0105041:	eb ed                	jmp    f0105030 <stab_binsearch+0x6c>
		} else if (stabs[m].n_value > addr) {
f0105043:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0105046:	76 14                	jbe    f010505c <stab_binsearch+0x98>
			*region_right = m - 1;
f0105048:	83 e8 01             	sub    $0x1,%eax
f010504b:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010504e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105051:	89 07                	mov    %eax,(%edi)
		any_matches = 1;
f0105053:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010505a:	eb b0                	jmp    f010500c <stab_binsearch+0x48>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f010505c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010505f:	89 07                	mov    %eax,(%edi)
			l = m;
			addr++;
f0105061:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0105065:	89 c3                	mov    %eax,%ebx
		any_matches = 1;
f0105067:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010506e:	eb 9c                	jmp    f010500c <stab_binsearch+0x48>
		}
	}

	if (!any_matches)
f0105070:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0105074:	75 15                	jne    f010508b <stab_binsearch+0xc7>
		*region_right = *region_left - 1;
f0105076:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105079:	8b 00                	mov    (%eax),%eax
f010507b:	83 e8 01             	sub    $0x1,%eax
f010507e:	8b 7d e0             	mov    -0x20(%ebp),%edi
f0105081:	89 07                	mov    %eax,(%edi)
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0105083:	83 c4 14             	add    $0x14,%esp
f0105086:	5b                   	pop    %ebx
f0105087:	5e                   	pop    %esi
f0105088:	5f                   	pop    %edi
f0105089:	5d                   	pop    %ebp
f010508a:	c3                   	ret    
		for (l = *region_right;
f010508b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010508e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0105090:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0105093:	8b 0f                	mov    (%edi),%ecx
f0105095:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0105098:	8b 7d ec             	mov    -0x14(%ebp),%edi
f010509b:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
		for (l = *region_right;
f010509f:	eb 03                	jmp    f01050a4 <stab_binsearch+0xe0>
		     l--)
f01050a1:	83 e8 01             	sub    $0x1,%eax
		for (l = *region_right;
f01050a4:	39 c1                	cmp    %eax,%ecx
f01050a6:	7d 0a                	jge    f01050b2 <stab_binsearch+0xee>
		     l > *region_left && stabs[l].n_type != type;
f01050a8:	0f b6 1a             	movzbl (%edx),%ebx
f01050ab:	83 ea 0c             	sub    $0xc,%edx
f01050ae:	39 f3                	cmp    %esi,%ebx
f01050b0:	75 ef                	jne    f01050a1 <stab_binsearch+0xdd>
		*region_left = l;
f01050b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01050b5:	89 07                	mov    %eax,(%edi)
}
f01050b7:	eb ca                	jmp    f0105083 <stab_binsearch+0xbf>

f01050b9 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01050b9:	f3 0f 1e fb          	endbr32 
f01050bd:	55                   	push   %ebp
f01050be:	89 e5                	mov    %esp,%ebp
f01050c0:	57                   	push   %edi
f01050c1:	56                   	push   %esi
f01050c2:	53                   	push   %ebx
f01050c3:	83 ec 4c             	sub    $0x4c,%esp
f01050c6:	8b 75 08             	mov    0x8(%ebp),%esi
f01050c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01050cc:	c7 03 64 7f 10 f0    	movl   $0xf0107f64,(%ebx)
	info->eip_line = 0;
f01050d2:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01050d9:	c7 43 08 64 7f 10 f0 	movl   $0xf0107f64,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01050e0:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01050e7:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01050ea:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01050f1:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01050f7:	0f 87 23 01 00 00    	ja     f0105220 <debuginfo_eip+0x167>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01050fd:	a1 00 00 20 00       	mov    0x200000,%eax
f0105102:	89 45 bc             	mov    %eax,-0x44(%ebp)
		stab_end = usd->stab_end;
f0105105:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f010510a:	8b 3d 08 00 20 00    	mov    0x200008,%edi
f0105110:	89 7d b4             	mov    %edi,-0x4c(%ebp)
		stabstr_end = usd->stabstr_end;
f0105113:	8b 3d 0c 00 20 00    	mov    0x20000c,%edi
f0105119:	89 7d b8             	mov    %edi,-0x48(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010511c:	8b 7d b8             	mov    -0x48(%ebp),%edi
f010511f:	39 7d b4             	cmp    %edi,-0x4c(%ebp)
f0105122:	0f 83 c1 01 00 00    	jae    f01052e9 <debuginfo_eip+0x230>
f0105128:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f010512c:	0f 85 be 01 00 00    	jne    f01052f0 <debuginfo_eip+0x237>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0105132:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0105139:	8b 7d bc             	mov    -0x44(%ebp),%edi
f010513c:	29 f8                	sub    %edi,%eax
f010513e:	c1 f8 02             	sar    $0x2,%eax
f0105141:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0105147:	83 e8 01             	sub    $0x1,%eax
f010514a:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010514d:	56                   	push   %esi
f010514e:	6a 64                	push   $0x64
f0105150:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0105153:	89 c1                	mov    %eax,%ecx
f0105155:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0105158:	89 f8                	mov    %edi,%eax
f010515a:	e8 65 fe ff ff       	call   f0104fc4 <stab_binsearch>
	if (lfile == 0)
f010515f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105162:	83 c4 08             	add    $0x8,%esp
f0105165:	85 c0                	test   %eax,%eax
f0105167:	0f 84 8a 01 00 00    	je     f01052f7 <debuginfo_eip+0x23e>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010516d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0105170:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105173:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0105176:	56                   	push   %esi
f0105177:	6a 24                	push   $0x24
f0105179:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010517c:	89 c1                	mov    %eax,%ecx
f010517e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0105181:	89 f8                	mov    %edi,%eax
f0105183:	e8 3c fe ff ff       	call   f0104fc4 <stab_binsearch>

	if (lfun <= rfun) {
f0105188:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010518b:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f010518e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
f0105191:	83 c4 08             	add    $0x8,%esp
f0105194:	39 c8                	cmp    %ecx,%eax
f0105196:	0f 8f a3 00 00 00    	jg     f010523f <debuginfo_eip+0x186>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f010519c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010519f:	8d 0c 97             	lea    (%edi,%edx,4),%ecx
f01051a2:	8b 11                	mov    (%ecx),%edx
f01051a4:	8b 7d b8             	mov    -0x48(%ebp),%edi
f01051a7:	2b 7d b4             	sub    -0x4c(%ebp),%edi
f01051aa:	39 fa                	cmp    %edi,%edx
f01051ac:	73 06                	jae    f01051b4 <debuginfo_eip+0xfb>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01051ae:	03 55 b4             	add    -0x4c(%ebp),%edx
f01051b1:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01051b4:	8b 51 08             	mov    0x8(%ecx),%edx
f01051b7:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01051ba:	29 d6                	sub    %edx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01051bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01051bf:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01051c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		info->eip_fn_addr = addr;
		lline = lfile;
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01051c5:	83 ec 08             	sub    $0x8,%esp
f01051c8:	6a 3a                	push   $0x3a
f01051ca:	ff 73 08             	pushl  0x8(%ebx)
f01051cd:	e8 5d 09 00 00       	call   f0105b2f <strfind>
f01051d2:	2b 43 08             	sub    0x8(%ebx),%eax
f01051d5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01051d8:	83 c4 08             	add    $0x8,%esp
f01051db:	56                   	push   %esi
f01051dc:	6a 44                	push   $0x44
f01051de:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01051e1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01051e4:	8b 75 bc             	mov    -0x44(%ebp),%esi
f01051e7:	89 f0                	mov    %esi,%eax
f01051e9:	e8 d6 fd ff ff       	call   f0104fc4 <stab_binsearch>
    if(lline <= rline){
f01051ee:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01051f1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01051f4:	83 c4 10             	add    $0x10,%esp
        info->eip_line = stabs[rline].n_desc;
    }
    else {
        info->eip_line = -1;
f01051f7:	b9 ff ff ff ff       	mov    $0xffffffff,%ecx
    if(lline <= rline){
f01051fc:	39 c2                	cmp    %eax,%edx
f01051fe:	7f 08                	jg     f0105208 <debuginfo_eip+0x14f>
        info->eip_line = stabs[rline].n_desc;
f0105200:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105203:	0f b7 4c 86 06       	movzwl 0x6(%esi,%eax,4),%ecx
f0105208:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010520b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010520e:	89 d0                	mov    %edx,%eax
f0105210:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0105213:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105216:	8d 54 96 04          	lea    0x4(%esi,%edx,4),%edx
f010521a:	c6 45 c4 00          	movb   $0x0,-0x3c(%ebp)
f010521e:	eb 3d                	jmp    f010525d <debuginfo_eip+0x1a4>
		stabstr_end = __STABSTR_END__;
f0105220:	c7 45 b8 eb 89 11 f0 	movl   $0xf01189eb,-0x48(%ebp)
		stabstr = __STABSTR_BEGIN__;
f0105227:	c7 45 b4 e1 51 11 f0 	movl   $0xf01151e1,-0x4c(%ebp)
		stab_end = __STAB_END__;
f010522e:	b8 e0 51 11 f0       	mov    $0xf01151e0,%eax
		stabs = __STAB_BEGIN__;
f0105233:	c7 45 bc 54 84 10 f0 	movl   $0xf0108454,-0x44(%ebp)
f010523a:	e9 dd fe ff ff       	jmp    f010511c <debuginfo_eip+0x63>
		info->eip_fn_addr = addr;
f010523f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0105242:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105245:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0105248:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010524b:	89 45 d0             	mov    %eax,-0x30(%ebp)
f010524e:	e9 72 ff ff ff       	jmp    f01051c5 <debuginfo_eip+0x10c>
f0105253:	83 e8 01             	sub    $0x1,%eax
f0105256:	83 ea 0c             	sub    $0xc,%edx
	while (lline >= lfile
f0105259:	c6 45 c4 01          	movb   $0x1,-0x3c(%ebp)
f010525d:	89 45 c0             	mov    %eax,-0x40(%ebp)
f0105260:	39 c7                	cmp    %eax,%edi
f0105262:	7f 45                	jg     f01052a9 <debuginfo_eip+0x1f0>
	       && stabs[lline].n_type != N_SOL
f0105264:	0f b6 0a             	movzbl (%edx),%ecx
f0105267:	80 f9 84             	cmp    $0x84,%cl
f010526a:	74 19                	je     f0105285 <debuginfo_eip+0x1cc>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010526c:	80 f9 64             	cmp    $0x64,%cl
f010526f:	75 e2                	jne    f0105253 <debuginfo_eip+0x19a>
f0105271:	83 7a 04 00          	cmpl   $0x0,0x4(%edx)
f0105275:	74 dc                	je     f0105253 <debuginfo_eip+0x19a>
f0105277:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f010527b:	74 11                	je     f010528e <debuginfo_eip+0x1d5>
f010527d:	8b 75 c0             	mov    -0x40(%ebp),%esi
f0105280:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0105283:	eb 09                	jmp    f010528e <debuginfo_eip+0x1d5>
f0105285:	80 7d c4 00          	cmpb   $0x0,-0x3c(%ebp)
f0105289:	74 03                	je     f010528e <debuginfo_eip+0x1d5>
f010528b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010528e:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0105291:	8b 75 bc             	mov    -0x44(%ebp),%esi
f0105294:	8b 14 86             	mov    (%esi,%eax,4),%edx
f0105297:	8b 45 b8             	mov    -0x48(%ebp),%eax
f010529a:	8b 7d b4             	mov    -0x4c(%ebp),%edi
f010529d:	29 f8                	sub    %edi,%eax
f010529f:	39 c2                	cmp    %eax,%edx
f01052a1:	73 06                	jae    f01052a9 <debuginfo_eip+0x1f0>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01052a3:	89 f8                	mov    %edi,%eax
f01052a5:	01 d0                	add    %edx,%eax
f01052a7:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01052a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01052ac:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01052af:	ba 00 00 00 00       	mov    $0x0,%edx
	if (lfun < rfun)
f01052b4:	39 f0                	cmp    %esi,%eax
f01052b6:	7d 4b                	jge    f0105303 <debuginfo_eip+0x24a>
		for (lline = lfun + 1;
f01052b8:	8d 50 01             	lea    0x1(%eax),%edx
f01052bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f01052be:	89 d0                	mov    %edx,%eax
f01052c0:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01052c3:	8b 7d bc             	mov    -0x44(%ebp),%edi
f01052c6:	8d 54 97 04          	lea    0x4(%edi,%edx,4),%edx
f01052ca:	eb 04                	jmp    f01052d0 <debuginfo_eip+0x217>
			info->eip_fn_narg++;
f01052cc:	83 43 14 01          	addl   $0x1,0x14(%ebx)
		for (lline = lfun + 1;
f01052d0:	39 c6                	cmp    %eax,%esi
f01052d2:	7e 2a                	jle    f01052fe <debuginfo_eip+0x245>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01052d4:	0f b6 0a             	movzbl (%edx),%ecx
f01052d7:	83 c0 01             	add    $0x1,%eax
f01052da:	83 c2 0c             	add    $0xc,%edx
f01052dd:	80 f9 a0             	cmp    $0xa0,%cl
f01052e0:	74 ea                	je     f01052cc <debuginfo_eip+0x213>
	return 0;
f01052e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01052e7:	eb 1a                	jmp    f0105303 <debuginfo_eip+0x24a>
		return -1;
f01052e9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01052ee:	eb 13                	jmp    f0105303 <debuginfo_eip+0x24a>
f01052f0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01052f5:	eb 0c                	jmp    f0105303 <debuginfo_eip+0x24a>
		return -1;
f01052f7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01052fc:	eb 05                	jmp    f0105303 <debuginfo_eip+0x24a>
	return 0;
f01052fe:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0105303:	89 d0                	mov    %edx,%eax
f0105305:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105308:	5b                   	pop    %ebx
f0105309:	5e                   	pop    %esi
f010530a:	5f                   	pop    %edi
f010530b:	5d                   	pop    %ebp
f010530c:	c3                   	ret    

f010530d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010530d:	55                   	push   %ebp
f010530e:	89 e5                	mov    %esp,%ebp
f0105310:	57                   	push   %edi
f0105311:	56                   	push   %esi
f0105312:	53                   	push   %ebx
f0105313:	83 ec 1c             	sub    $0x1c,%esp
f0105316:	89 c7                	mov    %eax,%edi
f0105318:	89 d6                	mov    %edx,%esi
f010531a:	8b 45 08             	mov    0x8(%ebp),%eax
f010531d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105320:	89 d1                	mov    %edx,%ecx
f0105322:	89 c2                	mov    %eax,%edx
f0105324:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105327:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f010532a:	8b 45 10             	mov    0x10(%ebp),%eax
f010532d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0105330:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105333:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f010533a:	39 c2                	cmp    %eax,%edx
f010533c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
f010533f:	72 3e                	jb     f010537f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0105341:	83 ec 0c             	sub    $0xc,%esp
f0105344:	ff 75 18             	pushl  0x18(%ebp)
f0105347:	83 eb 01             	sub    $0x1,%ebx
f010534a:	53                   	push   %ebx
f010534b:	50                   	push   %eax
f010534c:	83 ec 08             	sub    $0x8,%esp
f010534f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105352:	ff 75 e0             	pushl  -0x20(%ebp)
f0105355:	ff 75 dc             	pushl  -0x24(%ebp)
f0105358:	ff 75 d8             	pushl  -0x28(%ebp)
f010535b:	e8 20 12 00 00       	call   f0106580 <__udivdi3>
f0105360:	83 c4 18             	add    $0x18,%esp
f0105363:	52                   	push   %edx
f0105364:	50                   	push   %eax
f0105365:	89 f2                	mov    %esi,%edx
f0105367:	89 f8                	mov    %edi,%eax
f0105369:	e8 9f ff ff ff       	call   f010530d <printnum>
f010536e:	83 c4 20             	add    $0x20,%esp
f0105371:	eb 13                	jmp    f0105386 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0105373:	83 ec 08             	sub    $0x8,%esp
f0105376:	56                   	push   %esi
f0105377:	ff 75 18             	pushl  0x18(%ebp)
f010537a:	ff d7                	call   *%edi
f010537c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
f010537f:	83 eb 01             	sub    $0x1,%ebx
f0105382:	85 db                	test   %ebx,%ebx
f0105384:	7f ed                	jg     f0105373 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0105386:	83 ec 08             	sub    $0x8,%esp
f0105389:	56                   	push   %esi
f010538a:	83 ec 04             	sub    $0x4,%esp
f010538d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0105390:	ff 75 e0             	pushl  -0x20(%ebp)
f0105393:	ff 75 dc             	pushl  -0x24(%ebp)
f0105396:	ff 75 d8             	pushl  -0x28(%ebp)
f0105399:	e8 f2 12 00 00       	call   f0106690 <__umoddi3>
f010539e:	83 c4 14             	add    $0x14,%esp
f01053a1:	0f be 80 6e 7f 10 f0 	movsbl -0xfef8092(%eax),%eax
f01053a8:	50                   	push   %eax
f01053a9:	ff d7                	call   *%edi
}
f01053ab:	83 c4 10             	add    $0x10,%esp
f01053ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01053b1:	5b                   	pop    %ebx
f01053b2:	5e                   	pop    %esi
f01053b3:	5f                   	pop    %edi
f01053b4:	5d                   	pop    %ebp
f01053b5:	c3                   	ret    

f01053b6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01053b6:	f3 0f 1e fb          	endbr32 
f01053ba:	55                   	push   %ebp
f01053bb:	89 e5                	mov    %esp,%ebp
f01053bd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01053c0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01053c4:	8b 10                	mov    (%eax),%edx
f01053c6:	3b 50 04             	cmp    0x4(%eax),%edx
f01053c9:	73 0a                	jae    f01053d5 <sprintputch+0x1f>
		*b->buf++ = ch;
f01053cb:	8d 4a 01             	lea    0x1(%edx),%ecx
f01053ce:	89 08                	mov    %ecx,(%eax)
f01053d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01053d3:	88 02                	mov    %al,(%edx)
}
f01053d5:	5d                   	pop    %ebp
f01053d6:	c3                   	ret    

f01053d7 <printfmt>:
{
f01053d7:	f3 0f 1e fb          	endbr32 
f01053db:	55                   	push   %ebp
f01053dc:	89 e5                	mov    %esp,%ebp
f01053de:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
f01053e1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f01053e4:	50                   	push   %eax
f01053e5:	ff 75 10             	pushl  0x10(%ebp)
f01053e8:	ff 75 0c             	pushl  0xc(%ebp)
f01053eb:	ff 75 08             	pushl  0x8(%ebp)
f01053ee:	e8 05 00 00 00       	call   f01053f8 <vprintfmt>
}
f01053f3:	83 c4 10             	add    $0x10,%esp
f01053f6:	c9                   	leave  
f01053f7:	c3                   	ret    

f01053f8 <vprintfmt>:
{
f01053f8:	f3 0f 1e fb          	endbr32 
f01053fc:	55                   	push   %ebp
f01053fd:	89 e5                	mov    %esp,%ebp
f01053ff:	57                   	push   %edi
f0105400:	56                   	push   %esi
f0105401:	53                   	push   %ebx
f0105402:	83 ec 3c             	sub    $0x3c,%esp
f0105405:	8b 75 08             	mov    0x8(%ebp),%esi
f0105408:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010540b:	8b 7d 10             	mov    0x10(%ebp),%edi
f010540e:	e9 8e 03 00 00       	jmp    f01057a1 <vprintfmt+0x3a9>
		padc = ' ';
f0105413:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
f0105417:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
f010541e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
f0105425:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
f010542c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f0105431:	8d 47 01             	lea    0x1(%edi),%eax
f0105434:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105437:	0f b6 17             	movzbl (%edi),%edx
f010543a:	8d 42 dd             	lea    -0x23(%edx),%eax
f010543d:	3c 55                	cmp    $0x55,%al
f010543f:	0f 87 df 03 00 00    	ja     f0105824 <vprintfmt+0x42c>
f0105445:	0f b6 c0             	movzbl %al,%eax
f0105448:	3e ff 24 85 40 80 10 	notrack jmp *-0xfef7fc0(,%eax,4)
f010544f:	f0 
f0105450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
f0105453:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
f0105457:	eb d8                	jmp    f0105431 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f0105459:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010545c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
f0105460:	eb cf                	jmp    f0105431 <vprintfmt+0x39>
f0105462:	0f b6 d2             	movzbl %dl,%edx
f0105465:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
f0105468:	b8 00 00 00 00       	mov    $0x0,%eax
f010546d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
f0105470:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0105473:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0105477:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f010547a:	8d 4a d0             	lea    -0x30(%edx),%ecx
f010547d:	83 f9 09             	cmp    $0x9,%ecx
f0105480:	77 55                	ja     f01054d7 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
f0105482:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
f0105485:	eb e9                	jmp    f0105470 <vprintfmt+0x78>
			precision = va_arg(ap, int);
f0105487:	8b 45 14             	mov    0x14(%ebp),%eax
f010548a:	8b 00                	mov    (%eax),%eax
f010548c:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010548f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105492:	8d 40 04             	lea    0x4(%eax),%eax
f0105495:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f0105498:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
f010549b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010549f:	79 90                	jns    f0105431 <vprintfmt+0x39>
				width = precision, precision = -1;
f01054a1:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01054a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f01054a7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
f01054ae:	eb 81                	jmp    f0105431 <vprintfmt+0x39>
f01054b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01054b3:	85 c0                	test   %eax,%eax
f01054b5:	ba 00 00 00 00       	mov    $0x0,%edx
f01054ba:	0f 49 d0             	cmovns %eax,%edx
f01054bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
f01054c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054c3:	e9 69 ff ff ff       	jmp    f0105431 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
f01054c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
f01054cb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
f01054d2:	e9 5a ff ff ff       	jmp    f0105431 <vprintfmt+0x39>
f01054d7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01054da:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01054dd:	eb bc                	jmp    f010549b <vprintfmt+0xa3>
			lflag++;
f01054df:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
f01054e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
f01054e5:	e9 47 ff ff ff       	jmp    f0105431 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
f01054ea:	8b 45 14             	mov    0x14(%ebp),%eax
f01054ed:	8d 78 04             	lea    0x4(%eax),%edi
f01054f0:	83 ec 08             	sub    $0x8,%esp
f01054f3:	53                   	push   %ebx
f01054f4:	ff 30                	pushl  (%eax)
f01054f6:	ff d6                	call   *%esi
			break;
f01054f8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
f01054fb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
f01054fe:	e9 9b 02 00 00       	jmp    f010579e <vprintfmt+0x3a6>
			err = va_arg(ap, int);
f0105503:	8b 45 14             	mov    0x14(%ebp),%eax
f0105506:	8d 78 04             	lea    0x4(%eax),%edi
f0105509:	8b 00                	mov    (%eax),%eax
f010550b:	99                   	cltd   
f010550c:	31 d0                	xor    %edx,%eax
f010550e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105510:	83 f8 08             	cmp    $0x8,%eax
f0105513:	7f 23                	jg     f0105538 <vprintfmt+0x140>
f0105515:	8b 14 85 a0 81 10 f0 	mov    -0xfef7e60(,%eax,4),%edx
f010551c:	85 d2                	test   %edx,%edx
f010551e:	74 18                	je     f0105538 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
f0105520:	52                   	push   %edx
f0105521:	68 7d 77 10 f0       	push   $0xf010777d
f0105526:	53                   	push   %ebx
f0105527:	56                   	push   %esi
f0105528:	e8 aa fe ff ff       	call   f01053d7 <printfmt>
f010552d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105530:	89 7d 14             	mov    %edi,0x14(%ebp)
f0105533:	e9 66 02 00 00       	jmp    f010579e <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
f0105538:	50                   	push   %eax
f0105539:	68 86 7f 10 f0       	push   $0xf0107f86
f010553e:	53                   	push   %ebx
f010553f:	56                   	push   %esi
f0105540:	e8 92 fe ff ff       	call   f01053d7 <printfmt>
f0105545:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
f0105548:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
f010554b:	e9 4e 02 00 00       	jmp    f010579e <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
f0105550:	8b 45 14             	mov    0x14(%ebp),%eax
f0105553:	83 c0 04             	add    $0x4,%eax
f0105556:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0105559:	8b 45 14             	mov    0x14(%ebp),%eax
f010555c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
f010555e:	85 d2                	test   %edx,%edx
f0105560:	b8 7f 7f 10 f0       	mov    $0xf0107f7f,%eax
f0105565:	0f 45 c2             	cmovne %edx,%eax
f0105568:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
f010556b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f010556f:	7e 06                	jle    f0105577 <vprintfmt+0x17f>
f0105571:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
f0105575:	75 0d                	jne    f0105584 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
f0105577:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010557a:	89 c7                	mov    %eax,%edi
f010557c:	03 45 e0             	add    -0x20(%ebp),%eax
f010557f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105582:	eb 55                	jmp    f01055d9 <vprintfmt+0x1e1>
f0105584:	83 ec 08             	sub    $0x8,%esp
f0105587:	ff 75 d8             	pushl  -0x28(%ebp)
f010558a:	ff 75 cc             	pushl  -0x34(%ebp)
f010558d:	e8 2c 04 00 00       	call   f01059be <strnlen>
f0105592:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105595:	29 c2                	sub    %eax,%edx
f0105597:	89 55 c4             	mov    %edx,-0x3c(%ebp)
f010559a:	83 c4 10             	add    $0x10,%esp
f010559d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
f010559f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
f01055a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
f01055a6:	85 ff                	test   %edi,%edi
f01055a8:	7e 11                	jle    f01055bb <vprintfmt+0x1c3>
					putch(padc, putdat);
f01055aa:	83 ec 08             	sub    $0x8,%esp
f01055ad:	53                   	push   %ebx
f01055ae:	ff 75 e0             	pushl  -0x20(%ebp)
f01055b1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
f01055b3:	83 ef 01             	sub    $0x1,%edi
f01055b6:	83 c4 10             	add    $0x10,%esp
f01055b9:	eb eb                	jmp    f01055a6 <vprintfmt+0x1ae>
f01055bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01055be:	85 d2                	test   %edx,%edx
f01055c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01055c5:	0f 49 c2             	cmovns %edx,%eax
f01055c8:	29 c2                	sub    %eax,%edx
f01055ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01055cd:	eb a8                	jmp    f0105577 <vprintfmt+0x17f>
					putch(ch, putdat);
f01055cf:	83 ec 08             	sub    $0x8,%esp
f01055d2:	53                   	push   %ebx
f01055d3:	52                   	push   %edx
f01055d4:	ff d6                	call   *%esi
f01055d6:	83 c4 10             	add    $0x10,%esp
f01055d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f01055dc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01055de:	83 c7 01             	add    $0x1,%edi
f01055e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01055e5:	0f be d0             	movsbl %al,%edx
f01055e8:	85 d2                	test   %edx,%edx
f01055ea:	74 4b                	je     f0105637 <vprintfmt+0x23f>
f01055ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f01055f0:	78 06                	js     f01055f8 <vprintfmt+0x200>
f01055f2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
f01055f6:	78 1e                	js     f0105616 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
f01055f8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01055fc:	74 d1                	je     f01055cf <vprintfmt+0x1d7>
f01055fe:	0f be c0             	movsbl %al,%eax
f0105601:	83 e8 20             	sub    $0x20,%eax
f0105604:	83 f8 5e             	cmp    $0x5e,%eax
f0105607:	76 c6                	jbe    f01055cf <vprintfmt+0x1d7>
					putch('?', putdat);
f0105609:	83 ec 08             	sub    $0x8,%esp
f010560c:	53                   	push   %ebx
f010560d:	6a 3f                	push   $0x3f
f010560f:	ff d6                	call   *%esi
f0105611:	83 c4 10             	add    $0x10,%esp
f0105614:	eb c3                	jmp    f01055d9 <vprintfmt+0x1e1>
f0105616:	89 cf                	mov    %ecx,%edi
f0105618:	eb 0e                	jmp    f0105628 <vprintfmt+0x230>
				putch(' ', putdat);
f010561a:	83 ec 08             	sub    $0x8,%esp
f010561d:	53                   	push   %ebx
f010561e:	6a 20                	push   $0x20
f0105620:	ff d6                	call   *%esi
			for (; width > 0; width--)
f0105622:	83 ef 01             	sub    $0x1,%edi
f0105625:	83 c4 10             	add    $0x10,%esp
f0105628:	85 ff                	test   %edi,%edi
f010562a:	7f ee                	jg     f010561a <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
f010562c:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010562f:	89 45 14             	mov    %eax,0x14(%ebp)
f0105632:	e9 67 01 00 00       	jmp    f010579e <vprintfmt+0x3a6>
f0105637:	89 cf                	mov    %ecx,%edi
f0105639:	eb ed                	jmp    f0105628 <vprintfmt+0x230>
	if (lflag >= 2)
f010563b:	83 f9 01             	cmp    $0x1,%ecx
f010563e:	7f 1b                	jg     f010565b <vprintfmt+0x263>
	else if (lflag)
f0105640:	85 c9                	test   %ecx,%ecx
f0105642:	74 63                	je     f01056a7 <vprintfmt+0x2af>
		return va_arg(*ap, long);
f0105644:	8b 45 14             	mov    0x14(%ebp),%eax
f0105647:	8b 00                	mov    (%eax),%eax
f0105649:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010564c:	99                   	cltd   
f010564d:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105650:	8b 45 14             	mov    0x14(%ebp),%eax
f0105653:	8d 40 04             	lea    0x4(%eax),%eax
f0105656:	89 45 14             	mov    %eax,0x14(%ebp)
f0105659:	eb 17                	jmp    f0105672 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
f010565b:	8b 45 14             	mov    0x14(%ebp),%eax
f010565e:	8b 50 04             	mov    0x4(%eax),%edx
f0105661:	8b 00                	mov    (%eax),%eax
f0105663:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0105666:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0105669:	8b 45 14             	mov    0x14(%ebp),%eax
f010566c:	8d 40 08             	lea    0x8(%eax),%eax
f010566f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
f0105672:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105675:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
f0105678:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f010567d:	85 c9                	test   %ecx,%ecx
f010567f:	0f 89 ff 00 00 00    	jns    f0105784 <vprintfmt+0x38c>
				putch('-', putdat);
f0105685:	83 ec 08             	sub    $0x8,%esp
f0105688:	53                   	push   %ebx
f0105689:	6a 2d                	push   $0x2d
f010568b:	ff d6                	call   *%esi
				num = -(long long) num;
f010568d:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0105690:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0105693:	f7 da                	neg    %edx
f0105695:	83 d1 00             	adc    $0x0,%ecx
f0105698:	f7 d9                	neg    %ecx
f010569a:	83 c4 10             	add    $0x10,%esp
			base = 10;
f010569d:	b8 0a 00 00 00       	mov    $0xa,%eax
f01056a2:	e9 dd 00 00 00       	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, int);
f01056a7:	8b 45 14             	mov    0x14(%ebp),%eax
f01056aa:	8b 00                	mov    (%eax),%eax
f01056ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01056af:	99                   	cltd   
f01056b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01056b3:	8b 45 14             	mov    0x14(%ebp),%eax
f01056b6:	8d 40 04             	lea    0x4(%eax),%eax
f01056b9:	89 45 14             	mov    %eax,0x14(%ebp)
f01056bc:	eb b4                	jmp    f0105672 <vprintfmt+0x27a>
	if (lflag >= 2)
f01056be:	83 f9 01             	cmp    $0x1,%ecx
f01056c1:	7f 1e                	jg     f01056e1 <vprintfmt+0x2e9>
	else if (lflag)
f01056c3:	85 c9                	test   %ecx,%ecx
f01056c5:	74 32                	je     f01056f9 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
f01056c7:	8b 45 14             	mov    0x14(%ebp),%eax
f01056ca:	8b 10                	mov    (%eax),%edx
f01056cc:	b9 00 00 00 00       	mov    $0x0,%ecx
f01056d1:	8d 40 04             	lea    0x4(%eax),%eax
f01056d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056d7:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
f01056dc:	e9 a3 00 00 00       	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01056e1:	8b 45 14             	mov    0x14(%ebp),%eax
f01056e4:	8b 10                	mov    (%eax),%edx
f01056e6:	8b 48 04             	mov    0x4(%eax),%ecx
f01056e9:	8d 40 08             	lea    0x8(%eax),%eax
f01056ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f01056ef:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
f01056f4:	e9 8b 00 00 00       	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01056f9:	8b 45 14             	mov    0x14(%ebp),%eax
f01056fc:	8b 10                	mov    (%eax),%edx
f01056fe:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105703:	8d 40 04             	lea    0x4(%eax),%eax
f0105706:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
f0105709:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
f010570e:	eb 74                	jmp    f0105784 <vprintfmt+0x38c>
	if (lflag >= 2)
f0105710:	83 f9 01             	cmp    $0x1,%ecx
f0105713:	7f 1b                	jg     f0105730 <vprintfmt+0x338>
	else if (lflag)
f0105715:	85 c9                	test   %ecx,%ecx
f0105717:	74 2c                	je     f0105745 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
f0105719:	8b 45 14             	mov    0x14(%ebp),%eax
f010571c:	8b 10                	mov    (%eax),%edx
f010571e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105723:	8d 40 04             	lea    0x4(%eax),%eax
f0105726:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105729:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
f010572e:	eb 54                	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f0105730:	8b 45 14             	mov    0x14(%ebp),%eax
f0105733:	8b 10                	mov    (%eax),%edx
f0105735:	8b 48 04             	mov    0x4(%eax),%ecx
f0105738:	8d 40 08             	lea    0x8(%eax),%eax
f010573b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f010573e:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
f0105743:	eb 3f                	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f0105745:	8b 45 14             	mov    0x14(%ebp),%eax
f0105748:	8b 10                	mov    (%eax),%edx
f010574a:	b9 00 00 00 00       	mov    $0x0,%ecx
f010574f:	8d 40 04             	lea    0x4(%eax),%eax
f0105752:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
f0105755:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
f010575a:	eb 28                	jmp    f0105784 <vprintfmt+0x38c>
			putch('0', putdat);
f010575c:	83 ec 08             	sub    $0x8,%esp
f010575f:	53                   	push   %ebx
f0105760:	6a 30                	push   $0x30
f0105762:	ff d6                	call   *%esi
			putch('x', putdat);
f0105764:	83 c4 08             	add    $0x8,%esp
f0105767:	53                   	push   %ebx
f0105768:	6a 78                	push   $0x78
f010576a:	ff d6                	call   *%esi
			num = (unsigned long long)
f010576c:	8b 45 14             	mov    0x14(%ebp),%eax
f010576f:	8b 10                	mov    (%eax),%edx
f0105771:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
f0105776:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
f0105779:	8d 40 04             	lea    0x4(%eax),%eax
f010577c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010577f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
f0105784:	83 ec 0c             	sub    $0xc,%esp
f0105787:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
f010578b:	57                   	push   %edi
f010578c:	ff 75 e0             	pushl  -0x20(%ebp)
f010578f:	50                   	push   %eax
f0105790:	51                   	push   %ecx
f0105791:	52                   	push   %edx
f0105792:	89 da                	mov    %ebx,%edx
f0105794:	89 f0                	mov    %esi,%eax
f0105796:	e8 72 fb ff ff       	call   f010530d <printnum>
			break;
f010579b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
f010579e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
f01057a1:	83 c7 01             	add    $0x1,%edi
f01057a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f01057a8:	83 f8 25             	cmp    $0x25,%eax
f01057ab:	0f 84 62 fc ff ff    	je     f0105413 <vprintfmt+0x1b>
			if (ch == '\0')										
f01057b1:	85 c0                	test   %eax,%eax
f01057b3:	0f 84 8b 00 00 00    	je     f0105844 <vprintfmt+0x44c>
			putch(ch, putdat);
f01057b9:	83 ec 08             	sub    $0x8,%esp
f01057bc:	53                   	push   %ebx
f01057bd:	50                   	push   %eax
f01057be:	ff d6                	call   *%esi
f01057c0:	83 c4 10             	add    $0x10,%esp
f01057c3:	eb dc                	jmp    f01057a1 <vprintfmt+0x3a9>
	if (lflag >= 2)
f01057c5:	83 f9 01             	cmp    $0x1,%ecx
f01057c8:	7f 1b                	jg     f01057e5 <vprintfmt+0x3ed>
	else if (lflag)
f01057ca:	85 c9                	test   %ecx,%ecx
f01057cc:	74 2c                	je     f01057fa <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
f01057ce:	8b 45 14             	mov    0x14(%ebp),%eax
f01057d1:	8b 10                	mov    (%eax),%edx
f01057d3:	b9 00 00 00 00       	mov    $0x0,%ecx
f01057d8:	8d 40 04             	lea    0x4(%eax),%eax
f01057db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057de:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
f01057e3:	eb 9f                	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
f01057e5:	8b 45 14             	mov    0x14(%ebp),%eax
f01057e8:	8b 10                	mov    (%eax),%edx
f01057ea:	8b 48 04             	mov    0x4(%eax),%ecx
f01057ed:	8d 40 08             	lea    0x8(%eax),%eax
f01057f0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f01057f3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
f01057f8:	eb 8a                	jmp    f0105784 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
f01057fa:	8b 45 14             	mov    0x14(%ebp),%eax
f01057fd:	8b 10                	mov    (%eax),%edx
f01057ff:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105804:	8d 40 04             	lea    0x4(%eax),%eax
f0105807:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f010580a:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
f010580f:	e9 70 ff ff ff       	jmp    f0105784 <vprintfmt+0x38c>
			putch(ch, putdat);
f0105814:	83 ec 08             	sub    $0x8,%esp
f0105817:	53                   	push   %ebx
f0105818:	6a 25                	push   $0x25
f010581a:	ff d6                	call   *%esi
			break;
f010581c:	83 c4 10             	add    $0x10,%esp
f010581f:	e9 7a ff ff ff       	jmp    f010579e <vprintfmt+0x3a6>
			putch('%', putdat);
f0105824:	83 ec 08             	sub    $0x8,%esp
f0105827:	53                   	push   %ebx
f0105828:	6a 25                	push   $0x25
f010582a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010582c:	83 c4 10             	add    $0x10,%esp
f010582f:	89 f8                	mov    %edi,%eax
f0105831:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
f0105835:	74 05                	je     f010583c <vprintfmt+0x444>
f0105837:	83 e8 01             	sub    $0x1,%eax
f010583a:	eb f5                	jmp    f0105831 <vprintfmt+0x439>
f010583c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010583f:	e9 5a ff ff ff       	jmp    f010579e <vprintfmt+0x3a6>
}
f0105844:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105847:	5b                   	pop    %ebx
f0105848:	5e                   	pop    %esi
f0105849:	5f                   	pop    %edi
f010584a:	5d                   	pop    %ebp
f010584b:	c3                   	ret    

f010584c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010584c:	f3 0f 1e fb          	endbr32 
f0105850:	55                   	push   %ebp
f0105851:	89 e5                	mov    %esp,%ebp
f0105853:	83 ec 18             	sub    $0x18,%esp
f0105856:	8b 45 08             	mov    0x8(%ebp),%eax
f0105859:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f010585c:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010585f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0105863:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0105866:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f010586d:	85 c0                	test   %eax,%eax
f010586f:	74 26                	je     f0105897 <vsnprintf+0x4b>
f0105871:	85 d2                	test   %edx,%edx
f0105873:	7e 22                	jle    f0105897 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0105875:	ff 75 14             	pushl  0x14(%ebp)
f0105878:	ff 75 10             	pushl  0x10(%ebp)
f010587b:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010587e:	50                   	push   %eax
f010587f:	68 b6 53 10 f0       	push   $0xf01053b6
f0105884:	e8 6f fb ff ff       	call   f01053f8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0105889:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010588c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f010588f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0105892:	83 c4 10             	add    $0x10,%esp
}
f0105895:	c9                   	leave  
f0105896:	c3                   	ret    
		return -E_INVAL;
f0105897:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010589c:	eb f7                	jmp    f0105895 <vsnprintf+0x49>

f010589e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010589e:	f3 0f 1e fb          	endbr32 
f01058a2:	55                   	push   %ebp
f01058a3:	89 e5                	mov    %esp,%ebp
f01058a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01058a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01058ab:	50                   	push   %eax
f01058ac:	ff 75 10             	pushl  0x10(%ebp)
f01058af:	ff 75 0c             	pushl  0xc(%ebp)
f01058b2:	ff 75 08             	pushl  0x8(%ebp)
f01058b5:	e8 92 ff ff ff       	call   f010584c <vsnprintf>
	va_end(ap);

	return rc;
}
f01058ba:	c9                   	leave  
f01058bb:	c3                   	ret    

f01058bc <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01058bc:	f3 0f 1e fb          	endbr32 
f01058c0:	55                   	push   %ebp
f01058c1:	89 e5                	mov    %esp,%ebp
f01058c3:	57                   	push   %edi
f01058c4:	56                   	push   %esi
f01058c5:	53                   	push   %ebx
f01058c6:	83 ec 0c             	sub    $0xc,%esp
f01058c9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01058cc:	85 c0                	test   %eax,%eax
f01058ce:	74 11                	je     f01058e1 <readline+0x25>
		cprintf("%s", prompt);
f01058d0:	83 ec 08             	sub    $0x8,%esp
f01058d3:	50                   	push   %eax
f01058d4:	68 7d 77 10 f0       	push   $0xf010777d
f01058d9:	e8 d3 df ff ff       	call   f01038b1 <cprintf>
f01058de:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f01058e1:	83 ec 0c             	sub    $0xc,%esp
f01058e4:	6a 00                	push   $0x0
f01058e6:	e8 b2 ae ff ff       	call   f010079d <iscons>
f01058eb:	89 c7                	mov    %eax,%edi
f01058ed:	83 c4 10             	add    $0x10,%esp
	i = 0;
f01058f0:	be 00 00 00 00       	mov    $0x0,%esi
f01058f5:	eb 4b                	jmp    f0105942 <readline+0x86>
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
f01058f7:	83 ec 08             	sub    $0x8,%esp
f01058fa:	50                   	push   %eax
f01058fb:	68 c4 81 10 f0       	push   $0xf01081c4
f0105900:	e8 ac df ff ff       	call   f01038b1 <cprintf>
			return NULL;
f0105905:	83 c4 10             	add    $0x10,%esp
f0105908:	b8 00 00 00 00       	mov    $0x0,%eax
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
f010590d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105910:	5b                   	pop    %ebx
f0105911:	5e                   	pop    %esi
f0105912:	5f                   	pop    %edi
f0105913:	5d                   	pop    %ebp
f0105914:	c3                   	ret    
			if (echoing)
f0105915:	85 ff                	test   %edi,%edi
f0105917:	75 05                	jne    f010591e <readline+0x62>
			i--;
f0105919:	83 ee 01             	sub    $0x1,%esi
f010591c:	eb 24                	jmp    f0105942 <readline+0x86>
				cputchar('\b');
f010591e:	83 ec 0c             	sub    $0xc,%esp
f0105921:	6a 08                	push   $0x8
f0105923:	e8 4c ae ff ff       	call   f0100774 <cputchar>
f0105928:	83 c4 10             	add    $0x10,%esp
f010592b:	eb ec                	jmp    f0105919 <readline+0x5d>
				cputchar(c);
f010592d:	83 ec 0c             	sub    $0xc,%esp
f0105930:	53                   	push   %ebx
f0105931:	e8 3e ae ff ff       	call   f0100774 <cputchar>
f0105936:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0105939:	88 9e 80 8a 23 f0    	mov    %bl,-0xfdc7580(%esi)
f010593f:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
f0105942:	e8 41 ae ff ff       	call   f0100788 <getchar>
f0105947:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0105949:	85 c0                	test   %eax,%eax
f010594b:	78 aa                	js     f01058f7 <readline+0x3b>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010594d:	83 f8 08             	cmp    $0x8,%eax
f0105950:	0f 94 c2             	sete   %dl
f0105953:	83 f8 7f             	cmp    $0x7f,%eax
f0105956:	0f 94 c0             	sete   %al
f0105959:	08 c2                	or     %al,%dl
f010595b:	74 04                	je     f0105961 <readline+0xa5>
f010595d:	85 f6                	test   %esi,%esi
f010595f:	7f b4                	jg     f0105915 <readline+0x59>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0105961:	83 fb 1f             	cmp    $0x1f,%ebx
f0105964:	7e 0e                	jle    f0105974 <readline+0xb8>
f0105966:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010596c:	7f 06                	jg     f0105974 <readline+0xb8>
			if (echoing)
f010596e:	85 ff                	test   %edi,%edi
f0105970:	74 c7                	je     f0105939 <readline+0x7d>
f0105972:	eb b9                	jmp    f010592d <readline+0x71>
		} else if (c == '\n' || c == '\r') {
f0105974:	83 fb 0a             	cmp    $0xa,%ebx
f0105977:	74 05                	je     f010597e <readline+0xc2>
f0105979:	83 fb 0d             	cmp    $0xd,%ebx
f010597c:	75 c4                	jne    f0105942 <readline+0x86>
			if (echoing)
f010597e:	85 ff                	test   %edi,%edi
f0105980:	75 11                	jne    f0105993 <readline+0xd7>
			buf[i] = 0;
f0105982:	c6 86 80 8a 23 f0 00 	movb   $0x0,-0xfdc7580(%esi)
			return buf;
f0105989:	b8 80 8a 23 f0       	mov    $0xf0238a80,%eax
f010598e:	e9 7a ff ff ff       	jmp    f010590d <readline+0x51>
				cputchar('\n');
f0105993:	83 ec 0c             	sub    $0xc,%esp
f0105996:	6a 0a                	push   $0xa
f0105998:	e8 d7 ad ff ff       	call   f0100774 <cputchar>
f010599d:	83 c4 10             	add    $0x10,%esp
f01059a0:	eb e0                	jmp    f0105982 <readline+0xc6>

f01059a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01059a2:	f3 0f 1e fb          	endbr32 
f01059a6:	55                   	push   %ebp
f01059a7:	89 e5                	mov    %esp,%ebp
f01059a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01059ac:	b8 00 00 00 00       	mov    $0x0,%eax
f01059b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01059b5:	74 05                	je     f01059bc <strlen+0x1a>
		n++;
f01059b7:	83 c0 01             	add    $0x1,%eax
f01059ba:	eb f5                	jmp    f01059b1 <strlen+0xf>
	return n;
}
f01059bc:	5d                   	pop    %ebp
f01059bd:	c3                   	ret    

f01059be <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01059be:	f3 0f 1e fb          	endbr32 
f01059c2:	55                   	push   %ebp
f01059c3:	89 e5                	mov    %esp,%ebp
f01059c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01059cb:	b8 00 00 00 00       	mov    $0x0,%eax
f01059d0:	39 d0                	cmp    %edx,%eax
f01059d2:	74 0d                	je     f01059e1 <strnlen+0x23>
f01059d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
f01059d8:	74 05                	je     f01059df <strnlen+0x21>
		n++;
f01059da:	83 c0 01             	add    $0x1,%eax
f01059dd:	eb f1                	jmp    f01059d0 <strnlen+0x12>
f01059df:	89 c2                	mov    %eax,%edx
	return n;
}
f01059e1:	89 d0                	mov    %edx,%eax
f01059e3:	5d                   	pop    %ebp
f01059e4:	c3                   	ret    

f01059e5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01059e5:	f3 0f 1e fb          	endbr32 
f01059e9:	55                   	push   %ebp
f01059ea:	89 e5                	mov    %esp,%ebp
f01059ec:	53                   	push   %ebx
f01059ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01059f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f01059f3:	b8 00 00 00 00       	mov    $0x0,%eax
f01059f8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
f01059fc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
f01059ff:	83 c0 01             	add    $0x1,%eax
f0105a02:	84 d2                	test   %dl,%dl
f0105a04:	75 f2                	jne    f01059f8 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
f0105a06:	89 c8                	mov    %ecx,%eax
f0105a08:	5b                   	pop    %ebx
f0105a09:	5d                   	pop    %ebp
f0105a0a:	c3                   	ret    

f0105a0b <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105a0b:	f3 0f 1e fb          	endbr32 
f0105a0f:	55                   	push   %ebp
f0105a10:	89 e5                	mov    %esp,%ebp
f0105a12:	53                   	push   %ebx
f0105a13:	83 ec 10             	sub    $0x10,%esp
f0105a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105a19:	53                   	push   %ebx
f0105a1a:	e8 83 ff ff ff       	call   f01059a2 <strlen>
f0105a1f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
f0105a22:	ff 75 0c             	pushl  0xc(%ebp)
f0105a25:	01 d8                	add    %ebx,%eax
f0105a27:	50                   	push   %eax
f0105a28:	e8 b8 ff ff ff       	call   f01059e5 <strcpy>
	return dst;
}
f0105a2d:	89 d8                	mov    %ebx,%eax
f0105a2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105a32:	c9                   	leave  
f0105a33:	c3                   	ret    

f0105a34 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105a34:	f3 0f 1e fb          	endbr32 
f0105a38:	55                   	push   %ebp
f0105a39:	89 e5                	mov    %esp,%ebp
f0105a3b:	56                   	push   %esi
f0105a3c:	53                   	push   %ebx
f0105a3d:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a40:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105a43:	89 f3                	mov    %esi,%ebx
f0105a45:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105a48:	89 f0                	mov    %esi,%eax
f0105a4a:	39 d8                	cmp    %ebx,%eax
f0105a4c:	74 11                	je     f0105a5f <strncpy+0x2b>
		*dst++ = *src;
f0105a4e:	83 c0 01             	add    $0x1,%eax
f0105a51:	0f b6 0a             	movzbl (%edx),%ecx
f0105a54:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105a57:	80 f9 01             	cmp    $0x1,%cl
f0105a5a:	83 da ff             	sbb    $0xffffffff,%edx
f0105a5d:	eb eb                	jmp    f0105a4a <strncpy+0x16>
	}
	return ret;
}
f0105a5f:	89 f0                	mov    %esi,%eax
f0105a61:	5b                   	pop    %ebx
f0105a62:	5e                   	pop    %esi
f0105a63:	5d                   	pop    %ebp
f0105a64:	c3                   	ret    

f0105a65 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105a65:	f3 0f 1e fb          	endbr32 
f0105a69:	55                   	push   %ebp
f0105a6a:	89 e5                	mov    %esp,%ebp
f0105a6c:	56                   	push   %esi
f0105a6d:	53                   	push   %ebx
f0105a6e:	8b 75 08             	mov    0x8(%ebp),%esi
f0105a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105a74:	8b 55 10             	mov    0x10(%ebp),%edx
f0105a77:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105a79:	85 d2                	test   %edx,%edx
f0105a7b:	74 21                	je     f0105a9e <strlcpy+0x39>
f0105a7d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105a81:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
f0105a83:	39 c2                	cmp    %eax,%edx
f0105a85:	74 14                	je     f0105a9b <strlcpy+0x36>
f0105a87:	0f b6 19             	movzbl (%ecx),%ebx
f0105a8a:	84 db                	test   %bl,%bl
f0105a8c:	74 0b                	je     f0105a99 <strlcpy+0x34>
			*dst++ = *src++;
f0105a8e:	83 c1 01             	add    $0x1,%ecx
f0105a91:	83 c2 01             	add    $0x1,%edx
f0105a94:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105a97:	eb ea                	jmp    f0105a83 <strlcpy+0x1e>
f0105a99:	89 d0                	mov    %edx,%eax
		*dst = '\0';
f0105a9b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0105a9e:	29 f0                	sub    %esi,%eax
}
f0105aa0:	5b                   	pop    %ebx
f0105aa1:	5e                   	pop    %esi
f0105aa2:	5d                   	pop    %ebp
f0105aa3:	c3                   	ret    

f0105aa4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0105aa4:	f3 0f 1e fb          	endbr32 
f0105aa8:	55                   	push   %ebp
f0105aa9:	89 e5                	mov    %esp,%ebp
f0105aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105aae:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0105ab1:	0f b6 01             	movzbl (%ecx),%eax
f0105ab4:	84 c0                	test   %al,%al
f0105ab6:	74 0c                	je     f0105ac4 <strcmp+0x20>
f0105ab8:	3a 02                	cmp    (%edx),%al
f0105aba:	75 08                	jne    f0105ac4 <strcmp+0x20>
		p++, q++;
f0105abc:	83 c1 01             	add    $0x1,%ecx
f0105abf:	83 c2 01             	add    $0x1,%edx
f0105ac2:	eb ed                	jmp    f0105ab1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105ac4:	0f b6 c0             	movzbl %al,%eax
f0105ac7:	0f b6 12             	movzbl (%edx),%edx
f0105aca:	29 d0                	sub    %edx,%eax
}
f0105acc:	5d                   	pop    %ebp
f0105acd:	c3                   	ret    

f0105ace <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0105ace:	f3 0f 1e fb          	endbr32 
f0105ad2:	55                   	push   %ebp
f0105ad3:	89 e5                	mov    %esp,%ebp
f0105ad5:	53                   	push   %ebx
f0105ad6:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ad9:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105adc:	89 c3                	mov    %eax,%ebx
f0105ade:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0105ae1:	eb 06                	jmp    f0105ae9 <strncmp+0x1b>
		n--, p++, q++;
f0105ae3:	83 c0 01             	add    $0x1,%eax
f0105ae6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
f0105ae9:	39 d8                	cmp    %ebx,%eax
f0105aeb:	74 16                	je     f0105b03 <strncmp+0x35>
f0105aed:	0f b6 08             	movzbl (%eax),%ecx
f0105af0:	84 c9                	test   %cl,%cl
f0105af2:	74 04                	je     f0105af8 <strncmp+0x2a>
f0105af4:	3a 0a                	cmp    (%edx),%cl
f0105af6:	74 eb                	je     f0105ae3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105af8:	0f b6 00             	movzbl (%eax),%eax
f0105afb:	0f b6 12             	movzbl (%edx),%edx
f0105afe:	29 d0                	sub    %edx,%eax
}
f0105b00:	5b                   	pop    %ebx
f0105b01:	5d                   	pop    %ebp
f0105b02:	c3                   	ret    
		return 0;
f0105b03:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b08:	eb f6                	jmp    f0105b00 <strncmp+0x32>

f0105b0a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105b0a:	f3 0f 1e fb          	endbr32 
f0105b0e:	55                   	push   %ebp
f0105b0f:	89 e5                	mov    %esp,%ebp
f0105b11:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b18:	0f b6 10             	movzbl (%eax),%edx
f0105b1b:	84 d2                	test   %dl,%dl
f0105b1d:	74 09                	je     f0105b28 <strchr+0x1e>
		if (*s == c)
f0105b1f:	38 ca                	cmp    %cl,%dl
f0105b21:	74 0a                	je     f0105b2d <strchr+0x23>
	for (; *s; s++)
f0105b23:	83 c0 01             	add    $0x1,%eax
f0105b26:	eb f0                	jmp    f0105b18 <strchr+0xe>
			return (char *) s;
	return 0;
f0105b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105b2d:	5d                   	pop    %ebp
f0105b2e:	c3                   	ret    

f0105b2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105b2f:	f3 0f 1e fb          	endbr32 
f0105b33:	55                   	push   %ebp
f0105b34:	89 e5                	mov    %esp,%ebp
f0105b36:	8b 45 08             	mov    0x8(%ebp),%eax
f0105b39:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105b3d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105b40:	38 ca                	cmp    %cl,%dl
f0105b42:	74 09                	je     f0105b4d <strfind+0x1e>
f0105b44:	84 d2                	test   %dl,%dl
f0105b46:	74 05                	je     f0105b4d <strfind+0x1e>
	for (; *s; s++)
f0105b48:	83 c0 01             	add    $0x1,%eax
f0105b4b:	eb f0                	jmp    f0105b3d <strfind+0xe>
			break;
	return (char *) s;
}
f0105b4d:	5d                   	pop    %ebp
f0105b4e:	c3                   	ret    

f0105b4f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105b4f:	f3 0f 1e fb          	endbr32 
f0105b53:	55                   	push   %ebp
f0105b54:	89 e5                	mov    %esp,%ebp
f0105b56:	57                   	push   %edi
f0105b57:	56                   	push   %esi
f0105b58:	53                   	push   %ebx
f0105b59:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105b5c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105b5f:	85 c9                	test   %ecx,%ecx
f0105b61:	74 31                	je     f0105b94 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105b63:	89 f8                	mov    %edi,%eax
f0105b65:	09 c8                	or     %ecx,%eax
f0105b67:	a8 03                	test   $0x3,%al
f0105b69:	75 23                	jne    f0105b8e <memset+0x3f>
		c &= 0xFF;
f0105b6b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105b6f:	89 d3                	mov    %edx,%ebx
f0105b71:	c1 e3 08             	shl    $0x8,%ebx
f0105b74:	89 d0                	mov    %edx,%eax
f0105b76:	c1 e0 18             	shl    $0x18,%eax
f0105b79:	89 d6                	mov    %edx,%esi
f0105b7b:	c1 e6 10             	shl    $0x10,%esi
f0105b7e:	09 f0                	or     %esi,%eax
f0105b80:	09 c2                	or     %eax,%edx
f0105b82:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f0105b84:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
f0105b87:	89 d0                	mov    %edx,%eax
f0105b89:	fc                   	cld    
f0105b8a:	f3 ab                	rep stos %eax,%es:(%edi)
f0105b8c:	eb 06                	jmp    f0105b94 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105b8e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105b91:	fc                   	cld    
f0105b92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f0105b94:	89 f8                	mov    %edi,%eax
f0105b96:	5b                   	pop    %ebx
f0105b97:	5e                   	pop    %esi
f0105b98:	5f                   	pop    %edi
f0105b99:	5d                   	pop    %ebp
f0105b9a:	c3                   	ret    

f0105b9b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0105b9b:	f3 0f 1e fb          	endbr32 
f0105b9f:	55                   	push   %ebp
f0105ba0:	89 e5                	mov    %esp,%ebp
f0105ba2:	57                   	push   %edi
f0105ba3:	56                   	push   %esi
f0105ba4:	8b 45 08             	mov    0x8(%ebp),%eax
f0105ba7:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105baa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105bad:	39 c6                	cmp    %eax,%esi
f0105baf:	73 32                	jae    f0105be3 <memmove+0x48>
f0105bb1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105bb4:	39 c2                	cmp    %eax,%edx
f0105bb6:	76 2b                	jbe    f0105be3 <memmove+0x48>
		s += n;
		d += n;
f0105bb8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105bbb:	89 fe                	mov    %edi,%esi
f0105bbd:	09 ce                	or     %ecx,%esi
f0105bbf:	09 d6                	or     %edx,%esi
f0105bc1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0105bc7:	75 0e                	jne    f0105bd7 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f0105bc9:	83 ef 04             	sub    $0x4,%edi
f0105bcc:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105bcf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
f0105bd2:	fd                   	std    
f0105bd3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105bd5:	eb 09                	jmp    f0105be0 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105bd7:	83 ef 01             	sub    $0x1,%edi
f0105bda:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
f0105bdd:	fd                   	std    
f0105bde:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105be0:	fc                   	cld    
f0105be1:	eb 1a                	jmp    f0105bfd <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105be3:	89 c2                	mov    %eax,%edx
f0105be5:	09 ca                	or     %ecx,%edx
f0105be7:	09 f2                	or     %esi,%edx
f0105be9:	f6 c2 03             	test   $0x3,%dl
f0105bec:	75 0a                	jne    f0105bf8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105bee:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
f0105bf1:	89 c7                	mov    %eax,%edi
f0105bf3:	fc                   	cld    
f0105bf4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105bf6:	eb 05                	jmp    f0105bfd <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
f0105bf8:	89 c7                	mov    %eax,%edi
f0105bfa:	fc                   	cld    
f0105bfb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105bfd:	5e                   	pop    %esi
f0105bfe:	5f                   	pop    %edi
f0105bff:	5d                   	pop    %ebp
f0105c00:	c3                   	ret    

f0105c01 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105c01:	f3 0f 1e fb          	endbr32 
f0105c05:	55                   	push   %ebp
f0105c06:	89 e5                	mov    %esp,%ebp
f0105c08:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105c0b:	ff 75 10             	pushl  0x10(%ebp)
f0105c0e:	ff 75 0c             	pushl  0xc(%ebp)
f0105c11:	ff 75 08             	pushl  0x8(%ebp)
f0105c14:	e8 82 ff ff ff       	call   f0105b9b <memmove>
}
f0105c19:	c9                   	leave  
f0105c1a:	c3                   	ret    

f0105c1b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105c1b:	f3 0f 1e fb          	endbr32 
f0105c1f:	55                   	push   %ebp
f0105c20:	89 e5                	mov    %esp,%ebp
f0105c22:	56                   	push   %esi
f0105c23:	53                   	push   %ebx
f0105c24:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c27:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105c2a:	89 c6                	mov    %eax,%esi
f0105c2c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105c2f:	39 f0                	cmp    %esi,%eax
f0105c31:	74 1c                	je     f0105c4f <memcmp+0x34>
		if (*s1 != *s2)
f0105c33:	0f b6 08             	movzbl (%eax),%ecx
f0105c36:	0f b6 1a             	movzbl (%edx),%ebx
f0105c39:	38 d9                	cmp    %bl,%cl
f0105c3b:	75 08                	jne    f0105c45 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
f0105c3d:	83 c0 01             	add    $0x1,%eax
f0105c40:	83 c2 01             	add    $0x1,%edx
f0105c43:	eb ea                	jmp    f0105c2f <memcmp+0x14>
			return (int) *s1 - (int) *s2;
f0105c45:	0f b6 c1             	movzbl %cl,%eax
f0105c48:	0f b6 db             	movzbl %bl,%ebx
f0105c4b:	29 d8                	sub    %ebx,%eax
f0105c4d:	eb 05                	jmp    f0105c54 <memcmp+0x39>
	}

	return 0;
f0105c4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105c54:	5b                   	pop    %ebx
f0105c55:	5e                   	pop    %esi
f0105c56:	5d                   	pop    %ebp
f0105c57:	c3                   	ret    

f0105c58 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105c58:	f3 0f 1e fb          	endbr32 
f0105c5c:	55                   	push   %ebp
f0105c5d:	89 e5                	mov    %esp,%ebp
f0105c5f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105c62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f0105c65:	89 c2                	mov    %eax,%edx
f0105c67:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f0105c6a:	39 d0                	cmp    %edx,%eax
f0105c6c:	73 09                	jae    f0105c77 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105c6e:	38 08                	cmp    %cl,(%eax)
f0105c70:	74 05                	je     f0105c77 <memfind+0x1f>
	for (; s < ends; s++)
f0105c72:	83 c0 01             	add    $0x1,%eax
f0105c75:	eb f3                	jmp    f0105c6a <memfind+0x12>
			break;
	return (void *) s;
}
f0105c77:	5d                   	pop    %ebp
f0105c78:	c3                   	ret    

f0105c79 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105c79:	f3 0f 1e fb          	endbr32 
f0105c7d:	55                   	push   %ebp
f0105c7e:	89 e5                	mov    %esp,%ebp
f0105c80:	57                   	push   %edi
f0105c81:	56                   	push   %esi
f0105c82:	53                   	push   %ebx
f0105c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105c86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105c89:	eb 03                	jmp    f0105c8e <strtol+0x15>
		s++;
f0105c8b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
f0105c8e:	0f b6 01             	movzbl (%ecx),%eax
f0105c91:	3c 20                	cmp    $0x20,%al
f0105c93:	74 f6                	je     f0105c8b <strtol+0x12>
f0105c95:	3c 09                	cmp    $0x9,%al
f0105c97:	74 f2                	je     f0105c8b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
f0105c99:	3c 2b                	cmp    $0x2b,%al
f0105c9b:	74 2a                	je     f0105cc7 <strtol+0x4e>
	int neg = 0;
f0105c9d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
f0105ca2:	3c 2d                	cmp    $0x2d,%al
f0105ca4:	74 2b                	je     f0105cd1 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105ca6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0105cac:	75 0f                	jne    f0105cbd <strtol+0x44>
f0105cae:	80 39 30             	cmpb   $0x30,(%ecx)
f0105cb1:	74 28                	je     f0105cdb <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105cb3:	85 db                	test   %ebx,%ebx
f0105cb5:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105cba:	0f 44 d8             	cmove  %eax,%ebx
f0105cbd:	b8 00 00 00 00       	mov    $0x0,%eax
f0105cc2:	89 5d 10             	mov    %ebx,0x10(%ebp)
f0105cc5:	eb 46                	jmp    f0105d0d <strtol+0x94>
		s++;
f0105cc7:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
f0105cca:	bf 00 00 00 00       	mov    $0x0,%edi
f0105ccf:	eb d5                	jmp    f0105ca6 <strtol+0x2d>
		s++, neg = 1;
f0105cd1:	83 c1 01             	add    $0x1,%ecx
f0105cd4:	bf 01 00 00 00       	mov    $0x1,%edi
f0105cd9:	eb cb                	jmp    f0105ca6 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105cdb:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0105cdf:	74 0e                	je     f0105cef <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f0105ce1:	85 db                	test   %ebx,%ebx
f0105ce3:	75 d8                	jne    f0105cbd <strtol+0x44>
		s++, base = 8;
f0105ce5:	83 c1 01             	add    $0x1,%ecx
f0105ce8:	bb 08 00 00 00       	mov    $0x8,%ebx
f0105ced:	eb ce                	jmp    f0105cbd <strtol+0x44>
		s += 2, base = 16;
f0105cef:	83 c1 02             	add    $0x2,%ecx
f0105cf2:	bb 10 00 00 00       	mov    $0x10,%ebx
f0105cf7:	eb c4                	jmp    f0105cbd <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
f0105cf9:	0f be d2             	movsbl %dl,%edx
f0105cfc:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
f0105cff:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105d02:	7d 3a                	jge    f0105d3e <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
f0105d04:	83 c1 01             	add    $0x1,%ecx
f0105d07:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105d0b:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
f0105d0d:	0f b6 11             	movzbl (%ecx),%edx
f0105d10:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105d13:	89 f3                	mov    %esi,%ebx
f0105d15:	80 fb 09             	cmp    $0x9,%bl
f0105d18:	76 df                	jbe    f0105cf9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
f0105d1a:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105d1d:	89 f3                	mov    %esi,%ebx
f0105d1f:	80 fb 19             	cmp    $0x19,%bl
f0105d22:	77 08                	ja     f0105d2c <strtol+0xb3>
			dig = *s - 'a' + 10;
f0105d24:	0f be d2             	movsbl %dl,%edx
f0105d27:	83 ea 57             	sub    $0x57,%edx
f0105d2a:	eb d3                	jmp    f0105cff <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
f0105d2c:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105d2f:	89 f3                	mov    %esi,%ebx
f0105d31:	80 fb 19             	cmp    $0x19,%bl
f0105d34:	77 08                	ja     f0105d3e <strtol+0xc5>
			dig = *s - 'A' + 10;
f0105d36:	0f be d2             	movsbl %dl,%edx
f0105d39:	83 ea 37             	sub    $0x37,%edx
f0105d3c:	eb c1                	jmp    f0105cff <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
f0105d3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105d42:	74 05                	je     f0105d49 <strtol+0xd0>
		*endptr = (char *) s;
f0105d44:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105d47:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105d49:	89 c2                	mov    %eax,%edx
f0105d4b:	f7 da                	neg    %edx
f0105d4d:	85 ff                	test   %edi,%edi
f0105d4f:	0f 45 c2             	cmovne %edx,%eax
}
f0105d52:	5b                   	pop    %ebx
f0105d53:	5e                   	pop    %esi
f0105d54:	5f                   	pop    %edi
f0105d55:	5d                   	pop    %ebp
f0105d56:	c3                   	ret    
f0105d57:	90                   	nop

f0105d58 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105d58:	fa                   	cli    

	xorw    %ax, %ax
f0105d59:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105d5b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d5d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d5f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105d61:	0f 01 16             	lgdtl  (%esi)
f0105d64:	74 70                	je     f0105dd6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105d66:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105d69:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105d6d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105d70:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105d76:	08 00                	or     %al,(%eax)

f0105d78 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105d78:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105d7c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105d7e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105d80:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105d82:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105d86:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105d88:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105d8a:	b8 00 10 12 00       	mov    $0x121000,%eax
	movl    %eax, %cr3
f0105d8f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105d92:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105d95:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105d9a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105d9d:	8b 25 84 8e 23 f0    	mov    0xf0238e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105da3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105da8:	b8 a9 01 10 f0       	mov    $0xf01001a9,%eax
	call    *%eax
f0105dad:	ff d0                	call   *%eax

f0105daf <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105daf:	eb fe                	jmp    f0105daf <spin>
f0105db1:	8d 76 00             	lea    0x0(%esi),%esi

f0105db4 <gdt>:
	...
f0105dbc:	ff                   	(bad)  
f0105dbd:	ff 00                	incl   (%eax)
f0105dbf:	00 00                	add    %al,(%eax)
f0105dc1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105dc8:	00                   	.byte 0x0
f0105dc9:	92                   	xchg   %eax,%edx
f0105dca:	cf                   	iret   
	...

f0105dcc <gdtdesc>:
f0105dcc:	17                   	pop    %ss
f0105dcd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105dd2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105dd2:	90                   	nop

f0105dd3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105dd3:	55                   	push   %ebp
f0105dd4:	89 e5                	mov    %esp,%ebp
f0105dd6:	57                   	push   %edi
f0105dd7:	56                   	push   %esi
f0105dd8:	53                   	push   %ebx
f0105dd9:	83 ec 0c             	sub    $0xc,%esp
f0105ddc:	89 c7                	mov    %eax,%edi
	if (PGNUM(pa) >= npages)
f0105dde:	a1 88 8e 23 f0       	mov    0xf0238e88,%eax
f0105de3:	89 f9                	mov    %edi,%ecx
f0105de5:	c1 e9 0c             	shr    $0xc,%ecx
f0105de8:	39 c1                	cmp    %eax,%ecx
f0105dea:	73 19                	jae    f0105e05 <mpsearch1+0x32>
	return (void *)(pa + KERNBASE);
f0105dec:	8d 9f 00 00 00 f0    	lea    -0x10000000(%edi),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105df2:	01 d7                	add    %edx,%edi
	if (PGNUM(pa) >= npages)
f0105df4:	89 fa                	mov    %edi,%edx
f0105df6:	c1 ea 0c             	shr    $0xc,%edx
f0105df9:	39 c2                	cmp    %eax,%edx
f0105dfb:	73 1a                	jae    f0105e17 <mpsearch1+0x44>
	return (void *)(pa + KERNBASE);
f0105dfd:	81 ef 00 00 00 10    	sub    $0x10000000,%edi

	for (; mp < end; mp++)
f0105e03:	eb 27                	jmp    f0105e2c <mpsearch1+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105e05:	57                   	push   %edi
f0105e06:	68 04 68 10 f0       	push   $0xf0106804
f0105e0b:	6a 57                	push   $0x57
f0105e0d:	68 61 83 10 f0       	push   $0xf0108361
f0105e12:	e8 29 a2 ff ff       	call   f0100040 <_panic>
f0105e17:	57                   	push   %edi
f0105e18:	68 04 68 10 f0       	push   $0xf0106804
f0105e1d:	6a 57                	push   $0x57
f0105e1f:	68 61 83 10 f0       	push   $0xf0108361
f0105e24:	e8 17 a2 ff ff       	call   f0100040 <_panic>
f0105e29:	83 c3 10             	add    $0x10,%ebx
f0105e2c:	39 fb                	cmp    %edi,%ebx
f0105e2e:	73 30                	jae    f0105e60 <mpsearch1+0x8d>
f0105e30:	89 de                	mov    %ebx,%esi
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e32:	83 ec 04             	sub    $0x4,%esp
f0105e35:	6a 04                	push   $0x4
f0105e37:	68 71 83 10 f0       	push   $0xf0108371
f0105e3c:	53                   	push   %ebx
f0105e3d:	e8 d9 fd ff ff       	call   f0105c1b <memcmp>
f0105e42:	83 c4 10             	add    $0x10,%esp
f0105e45:	85 c0                	test   %eax,%eax
f0105e47:	75 e0                	jne    f0105e29 <mpsearch1+0x56>
f0105e49:	89 da                	mov    %ebx,%edx
	for (i = 0; i < len; i++)
f0105e4b:	83 c6 10             	add    $0x10,%esi
		sum += ((uint8_t *)addr)[i];
f0105e4e:	0f b6 0a             	movzbl (%edx),%ecx
f0105e51:	01 c8                	add    %ecx,%eax
f0105e53:	83 c2 01             	add    $0x1,%edx
	for (i = 0; i < len; i++)
f0105e56:	39 f2                	cmp    %esi,%edx
f0105e58:	75 f4                	jne    f0105e4e <mpsearch1+0x7b>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105e5a:	84 c0                	test   %al,%al
f0105e5c:	75 cb                	jne    f0105e29 <mpsearch1+0x56>
f0105e5e:	eb 05                	jmp    f0105e65 <mpsearch1+0x92>
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105e60:	bb 00 00 00 00       	mov    $0x0,%ebx
}
f0105e65:	89 d8                	mov    %ebx,%eax
f0105e67:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105e6a:	5b                   	pop    %ebx
f0105e6b:	5e                   	pop    %esi
f0105e6c:	5f                   	pop    %edi
f0105e6d:	5d                   	pop    %ebp
f0105e6e:	c3                   	ret    

f0105e6f <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105e6f:	f3 0f 1e fb          	endbr32 
f0105e73:	55                   	push   %ebp
f0105e74:	89 e5                	mov    %esp,%ebp
f0105e76:	57                   	push   %edi
f0105e77:	56                   	push   %esi
f0105e78:	53                   	push   %ebx
f0105e79:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105e7c:	c7 05 c0 93 23 f0 20 	movl   $0xf0239020,0xf02393c0
f0105e83:	90 23 f0 
	if (PGNUM(pa) >= npages)
f0105e86:	83 3d 88 8e 23 f0 00 	cmpl   $0x0,0xf0238e88
f0105e8d:	0f 84 a3 00 00 00    	je     f0105f36 <mp_init+0xc7>
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105e93:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105e9a:	85 c0                	test   %eax,%eax
f0105e9c:	0f 84 aa 00 00 00    	je     f0105f4c <mp_init+0xdd>
		p <<= 4;	// Translate from segment to PA
f0105ea2:	c1 e0 04             	shl    $0x4,%eax
		if ((mp = mpsearch1(p, 1024)))
f0105ea5:	ba 00 04 00 00       	mov    $0x400,%edx
f0105eaa:	e8 24 ff ff ff       	call   f0105dd3 <mpsearch1>
f0105eaf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105eb2:	85 c0                	test   %eax,%eax
f0105eb4:	75 1a                	jne    f0105ed0 <mp_init+0x61>
	return mpsearch1(0xF0000, 0x10000);
f0105eb6:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ebb:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105ec0:	e8 0e ff ff ff       	call   f0105dd3 <mpsearch1>
f0105ec5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((mp = mpsearch()) == 0)
f0105ec8:	85 c0                	test   %eax,%eax
f0105eca:	0f 84 35 02 00 00    	je     f0106105 <mp_init+0x296>
	if (mp->physaddr == 0 || mp->type != 0) {
f0105ed0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105ed3:	8b 58 04             	mov    0x4(%eax),%ebx
f0105ed6:	85 db                	test   %ebx,%ebx
f0105ed8:	0f 84 97 00 00 00    	je     f0105f75 <mp_init+0x106>
f0105ede:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105ee2:	0f 85 8d 00 00 00    	jne    f0105f75 <mp_init+0x106>
f0105ee8:	89 d8                	mov    %ebx,%eax
f0105eea:	c1 e8 0c             	shr    $0xc,%eax
f0105eed:	3b 05 88 8e 23 f0    	cmp    0xf0238e88,%eax
f0105ef3:	0f 83 91 00 00 00    	jae    f0105f8a <mp_init+0x11b>
	return (void *)(pa + KERNBASE);
f0105ef9:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
f0105eff:	89 de                	mov    %ebx,%esi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105f01:	83 ec 04             	sub    $0x4,%esp
f0105f04:	6a 04                	push   $0x4
f0105f06:	68 76 83 10 f0       	push   $0xf0108376
f0105f0b:	53                   	push   %ebx
f0105f0c:	e8 0a fd ff ff       	call   f0105c1b <memcmp>
f0105f11:	83 c4 10             	add    $0x10,%esp
f0105f14:	85 c0                	test   %eax,%eax
f0105f16:	0f 85 83 00 00 00    	jne    f0105f9f <mp_init+0x130>
f0105f1c:	0f b7 7b 04          	movzwl 0x4(%ebx),%edi
f0105f20:	01 df                	add    %ebx,%edi
	sum = 0;
f0105f22:	89 c2                	mov    %eax,%edx
	for (i = 0; i < len; i++)
f0105f24:	39 fb                	cmp    %edi,%ebx
f0105f26:	0f 84 88 00 00 00    	je     f0105fb4 <mp_init+0x145>
		sum += ((uint8_t *)addr)[i];
f0105f2c:	0f b6 0b             	movzbl (%ebx),%ecx
f0105f2f:	01 ca                	add    %ecx,%edx
f0105f31:	83 c3 01             	add    $0x1,%ebx
f0105f34:	eb ee                	jmp    f0105f24 <mp_init+0xb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105f36:	68 00 04 00 00       	push   $0x400
f0105f3b:	68 04 68 10 f0       	push   $0xf0106804
f0105f40:	6a 6f                	push   $0x6f
f0105f42:	68 61 83 10 f0       	push   $0xf0108361
f0105f47:	e8 f4 a0 ff ff       	call   f0100040 <_panic>
		p = *(uint16_t *) (bda + 0x13) * 1024;
f0105f4c:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105f53:	c1 e0 0a             	shl    $0xa,%eax
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105f56:	2d 00 04 00 00       	sub    $0x400,%eax
f0105f5b:	ba 00 04 00 00       	mov    $0x400,%edx
f0105f60:	e8 6e fe ff ff       	call   f0105dd3 <mpsearch1>
f0105f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105f68:	85 c0                	test   %eax,%eax
f0105f6a:	0f 85 60 ff ff ff    	jne    f0105ed0 <mp_init+0x61>
f0105f70:	e9 41 ff ff ff       	jmp    f0105eb6 <mp_init+0x47>
		cprintf("SMP: Default configurations not implemented\n");
f0105f75:	83 ec 0c             	sub    $0xc,%esp
f0105f78:	68 d4 81 10 f0       	push   $0xf01081d4
f0105f7d:	e8 2f d9 ff ff       	call   f01038b1 <cprintf>
		return NULL;
f0105f82:	83 c4 10             	add    $0x10,%esp
f0105f85:	e9 7b 01 00 00       	jmp    f0106105 <mp_init+0x296>
f0105f8a:	53                   	push   %ebx
f0105f8b:	68 04 68 10 f0       	push   $0xf0106804
f0105f90:	68 90 00 00 00       	push   $0x90
f0105f95:	68 61 83 10 f0       	push   $0xf0108361
f0105f9a:	e8 a1 a0 ff ff       	call   f0100040 <_panic>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105f9f:	83 ec 0c             	sub    $0xc,%esp
f0105fa2:	68 04 82 10 f0       	push   $0xf0108204
f0105fa7:	e8 05 d9 ff ff       	call   f01038b1 <cprintf>
		return NULL;
f0105fac:	83 c4 10             	add    $0x10,%esp
f0105faf:	e9 51 01 00 00       	jmp    f0106105 <mp_init+0x296>
	if (sum(conf, conf->length) != 0) {
f0105fb4:	84 d2                	test   %dl,%dl
f0105fb6:	75 22                	jne    f0105fda <mp_init+0x16b>
	if (conf->version != 1 && conf->version != 4) {
f0105fb8:	0f b6 56 06          	movzbl 0x6(%esi),%edx
f0105fbc:	80 fa 01             	cmp    $0x1,%dl
f0105fbf:	74 05                	je     f0105fc6 <mp_init+0x157>
f0105fc1:	80 fa 04             	cmp    $0x4,%dl
f0105fc4:	75 29                	jne    f0105fef <mp_init+0x180>
f0105fc6:	0f b7 4e 28          	movzwl 0x28(%esi),%ecx
f0105fca:	01 d9                	add    %ebx,%ecx
	for (i = 0; i < len; i++)
f0105fcc:	39 d9                	cmp    %ebx,%ecx
f0105fce:	74 38                	je     f0106008 <mp_init+0x199>
		sum += ((uint8_t *)addr)[i];
f0105fd0:	0f b6 13             	movzbl (%ebx),%edx
f0105fd3:	01 d0                	add    %edx,%eax
f0105fd5:	83 c3 01             	add    $0x1,%ebx
f0105fd8:	eb f2                	jmp    f0105fcc <mp_init+0x15d>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105fda:	83 ec 0c             	sub    $0xc,%esp
f0105fdd:	68 38 82 10 f0       	push   $0xf0108238
f0105fe2:	e8 ca d8 ff ff       	call   f01038b1 <cprintf>
		return NULL;
f0105fe7:	83 c4 10             	add    $0x10,%esp
f0105fea:	e9 16 01 00 00       	jmp    f0106105 <mp_init+0x296>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105fef:	83 ec 08             	sub    $0x8,%esp
f0105ff2:	0f b6 d2             	movzbl %dl,%edx
f0105ff5:	52                   	push   %edx
f0105ff6:	68 5c 82 10 f0       	push   $0xf010825c
f0105ffb:	e8 b1 d8 ff ff       	call   f01038b1 <cprintf>
		return NULL;
f0106000:	83 c4 10             	add    $0x10,%esp
f0106003:	e9 fd 00 00 00       	jmp    f0106105 <mp_init+0x296>
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f0106008:	02 46 2a             	add    0x2a(%esi),%al
f010600b:	75 1c                	jne    f0106029 <mp_init+0x1ba>
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
f010600d:	c7 05 00 90 23 f0 01 	movl   $0x1,0xf0239000
f0106014:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0106017:	8b 46 24             	mov    0x24(%esi),%eax
f010601a:	a3 00 a0 27 f0       	mov    %eax,0xf027a000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f010601f:	8d 7e 2c             	lea    0x2c(%esi),%edi
f0106022:	bb 00 00 00 00       	mov    $0x0,%ebx
f0106027:	eb 4d                	jmp    f0106076 <mp_init+0x207>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0106029:	83 ec 0c             	sub    $0xc,%esp
f010602c:	68 7c 82 10 f0       	push   $0xf010827c
f0106031:	e8 7b d8 ff ff       	call   f01038b1 <cprintf>
		return NULL;
f0106036:	83 c4 10             	add    $0x10,%esp
f0106039:	e9 c7 00 00 00       	jmp    f0106105 <mp_init+0x296>
		switch (*p) {
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)			
f010603e:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0106042:	74 11                	je     f0106055 <mp_init+0x1e6>
				bootcpu = &cpus[ncpu];
f0106044:	6b 05 c4 93 23 f0 74 	imul   $0x74,0xf02393c4,%eax
f010604b:	05 20 90 23 f0       	add    $0xf0239020,%eax
f0106050:	a3 c0 93 23 f0       	mov    %eax,0xf02393c0
			if (ncpu < NCPU) {
f0106055:	a1 c4 93 23 f0       	mov    0xf02393c4,%eax
f010605a:	83 f8 07             	cmp    $0x7,%eax
f010605d:	7f 33                	jg     f0106092 <mp_init+0x223>
				cpus[ncpu].cpu_id = ncpu;			
f010605f:	6b d0 74             	imul   $0x74,%eax,%edx
f0106062:	88 82 20 90 23 f0    	mov    %al,-0xfdc6fe0(%edx)
				ncpu++;
f0106068:	83 c0 01             	add    $0x1,%eax
f010606b:	a3 c4 93 23 f0       	mov    %eax,0xf02393c4
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0106070:	83 c7 14             	add    $0x14,%edi
	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0106073:	83 c3 01             	add    $0x1,%ebx
f0106076:	0f b7 46 22          	movzwl 0x22(%esi),%eax
f010607a:	39 d8                	cmp    %ebx,%eax
f010607c:	76 4f                	jbe    f01060cd <mp_init+0x25e>
		switch (*p) {
f010607e:	0f b6 07             	movzbl (%edi),%eax
f0106081:	84 c0                	test   %al,%al
f0106083:	74 b9                	je     f010603e <mp_init+0x1cf>
f0106085:	8d 50 ff             	lea    -0x1(%eax),%edx
f0106088:	80 fa 03             	cmp    $0x3,%dl
f010608b:	77 1c                	ja     f01060a9 <mp_init+0x23a>
			continue;
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010608d:	83 c7 08             	add    $0x8,%edi
			continue;
f0106090:	eb e1                	jmp    f0106073 <mp_init+0x204>
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0106092:	83 ec 08             	sub    $0x8,%esp
f0106095:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f0106099:	50                   	push   %eax
f010609a:	68 ac 82 10 f0       	push   $0xf01082ac
f010609f:	e8 0d d8 ff ff       	call   f01038b1 <cprintf>
f01060a4:	83 c4 10             	add    $0x10,%esp
f01060a7:	eb c7                	jmp    f0106070 <mp_init+0x201>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01060a9:	83 ec 08             	sub    $0x8,%esp
		switch (*p) {
f01060ac:	0f b6 c0             	movzbl %al,%eax
			cprintf("mpinit: unknown config type %x\n", *p);
f01060af:	50                   	push   %eax
f01060b0:	68 d4 82 10 f0       	push   $0xf01082d4
f01060b5:	e8 f7 d7 ff ff       	call   f01038b1 <cprintf>
			ismp = 0;
f01060ba:	c7 05 00 90 23 f0 00 	movl   $0x0,0xf0239000
f01060c1:	00 00 00 
			i = conf->entry;
f01060c4:	0f b7 5e 22          	movzwl 0x22(%esi),%ebx
f01060c8:	83 c4 10             	add    $0x10,%esp
f01060cb:	eb a6                	jmp    f0106073 <mp_init+0x204>
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01060cd:	a1 c0 93 23 f0       	mov    0xf02393c0,%eax
f01060d2:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01060d9:	83 3d 00 90 23 f0 00 	cmpl   $0x0,0xf0239000
f01060e0:	74 2b                	je     f010610d <mp_init+0x29e>
		ncpu = 1;
		lapicaddr = 0;
		cprintf("SMP: configuration not found, SMP disabled\n");
		return;
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f01060e2:	83 ec 04             	sub    $0x4,%esp
f01060e5:	ff 35 c4 93 23 f0    	pushl  0xf02393c4
f01060eb:	0f b6 00             	movzbl (%eax),%eax
f01060ee:	50                   	push   %eax
f01060ef:	68 7b 83 10 f0       	push   $0xf010837b
f01060f4:	e8 b8 d7 ff ff       	call   f01038b1 <cprintf>

	if (mp->imcrp) {
f01060f9:	83 c4 10             	add    $0x10,%esp
f01060fc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01060ff:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0106103:	75 2e                	jne    f0106133 <mp_init+0x2c4>
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0106105:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0106108:	5b                   	pop    %ebx
f0106109:	5e                   	pop    %esi
f010610a:	5f                   	pop    %edi
f010610b:	5d                   	pop    %ebp
f010610c:	c3                   	ret    
		ncpu = 1;
f010610d:	c7 05 c4 93 23 f0 01 	movl   $0x1,0xf02393c4
f0106114:	00 00 00 
		lapicaddr = 0;
f0106117:	c7 05 00 a0 27 f0 00 	movl   $0x0,0xf027a000
f010611e:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0106121:	83 ec 0c             	sub    $0xc,%esp
f0106124:	68 f4 82 10 f0       	push   $0xf01082f4
f0106129:	e8 83 d7 ff ff       	call   f01038b1 <cprintf>
		return;
f010612e:	83 c4 10             	add    $0x10,%esp
f0106131:	eb d2                	jmp    f0106105 <mp_init+0x296>
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0106133:	83 ec 0c             	sub    $0xc,%esp
f0106136:	68 20 83 10 f0       	push   $0xf0108320
f010613b:	e8 71 d7 ff ff       	call   f01038b1 <cprintf>
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106140:	b8 70 00 00 00       	mov    $0x70,%eax
f0106145:	ba 22 00 00 00       	mov    $0x22,%edx
f010614a:	ee                   	out    %al,(%dx)
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010614b:	ba 23 00 00 00       	mov    $0x23,%edx
f0106150:	ec                   	in     (%dx),%al
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
f0106151:	83 c8 01             	or     $0x1,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0106154:	ee                   	out    %al,(%dx)
}
f0106155:	83 c4 10             	add    $0x10,%esp
f0106158:	eb ab                	jmp    f0106105 <mp_init+0x296>

f010615a <lapicw>:
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
	lapic[index] = value;
f010615a:	8b 0d 04 a0 27 f0    	mov    0xf027a004,%ecx
f0106160:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0106163:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0106165:	a1 04 a0 27 f0       	mov    0xf027a004,%eax
f010616a:	8b 40 20             	mov    0x20(%eax),%eax
}
f010616d:	c3                   	ret    

f010616e <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f010616e:	f3 0f 1e fb          	endbr32 
	if (lapic)
f0106172:	8b 15 04 a0 27 f0    	mov    0xf027a004,%edx
		return lapic[ID] >> 24;
	return 0;
f0106178:	b8 00 00 00 00       	mov    $0x0,%eax
	if (lapic)
f010617d:	85 d2                	test   %edx,%edx
f010617f:	74 06                	je     f0106187 <cpunum+0x19>
		return lapic[ID] >> 24;
f0106181:	8b 42 20             	mov    0x20(%edx),%eax
f0106184:	c1 e8 18             	shr    $0x18,%eax
}
f0106187:	c3                   	ret    

f0106188 <lapic_init>:
{
f0106188:	f3 0f 1e fb          	endbr32 
	if (!lapicaddr)
f010618c:	a1 00 a0 27 f0       	mov    0xf027a000,%eax
f0106191:	85 c0                	test   %eax,%eax
f0106193:	75 01                	jne    f0106196 <lapic_init+0xe>
f0106195:	c3                   	ret    
{
f0106196:	55                   	push   %ebp
f0106197:	89 e5                	mov    %esp,%ebp
f0106199:	83 ec 10             	sub    $0x10,%esp
	lapic = mmio_map_region(lapicaddr, 4096);
f010619c:	68 00 10 00 00       	push   $0x1000
f01061a1:	50                   	push   %eax
f01061a2:	e8 a4 b0 ff ff       	call   f010124b <mmio_map_region>
f01061a7:	a3 04 a0 27 f0       	mov    %eax,0xf027a004
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01061ac:	ba 27 01 00 00       	mov    $0x127,%edx
f01061b1:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01061b6:	e8 9f ff ff ff       	call   f010615a <lapicw>
	lapicw(TDCR, X1);
f01061bb:	ba 0b 00 00 00       	mov    $0xb,%edx
f01061c0:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01061c5:	e8 90 ff ff ff       	call   f010615a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01061ca:	ba 20 00 02 00       	mov    $0x20020,%edx
f01061cf:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01061d4:	e8 81 ff ff ff       	call   f010615a <lapicw>
	lapicw(TICR, 10000000); 
f01061d9:	ba 80 96 98 00       	mov    $0x989680,%edx
f01061de:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01061e3:	e8 72 ff ff ff       	call   f010615a <lapicw>
	if (thiscpu != bootcpu)
f01061e8:	e8 81 ff ff ff       	call   f010616e <cpunum>
f01061ed:	6b c0 74             	imul   $0x74,%eax,%eax
f01061f0:	05 20 90 23 f0       	add    $0xf0239020,%eax
f01061f5:	83 c4 10             	add    $0x10,%esp
f01061f8:	39 05 c0 93 23 f0    	cmp    %eax,0xf02393c0
f01061fe:	74 0f                	je     f010620f <lapic_init+0x87>
		lapicw(LINT0, MASKED);
f0106200:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106205:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010620a:	e8 4b ff ff ff       	call   f010615a <lapicw>
	lapicw(LINT1, MASKED);
f010620f:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106214:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0106219:	e8 3c ff ff ff       	call   f010615a <lapicw>
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f010621e:	a1 04 a0 27 f0       	mov    0xf027a004,%eax
f0106223:	8b 40 30             	mov    0x30(%eax),%eax
f0106226:	c1 e8 10             	shr    $0x10,%eax
f0106229:	a8 fc                	test   $0xfc,%al
f010622b:	75 7c                	jne    f01062a9 <lapic_init+0x121>
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010622d:	ba 33 00 00 00       	mov    $0x33,%edx
f0106232:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106237:	e8 1e ff ff ff       	call   f010615a <lapicw>
	lapicw(ESR, 0);
f010623c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106241:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106246:	e8 0f ff ff ff       	call   f010615a <lapicw>
	lapicw(ESR, 0);
f010624b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106250:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106255:	e8 00 ff ff ff       	call   f010615a <lapicw>
	lapicw(EOI, 0);
f010625a:	ba 00 00 00 00       	mov    $0x0,%edx
f010625f:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106264:	e8 f1 fe ff ff       	call   f010615a <lapicw>
	lapicw(ICRHI, 0);
f0106269:	ba 00 00 00 00       	mov    $0x0,%edx
f010626e:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106273:	e8 e2 fe ff ff       	call   f010615a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f0106278:	ba 00 85 08 00       	mov    $0x88500,%edx
f010627d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106282:	e8 d3 fe ff ff       	call   f010615a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106287:	8b 15 04 a0 27 f0    	mov    0xf027a004,%edx
f010628d:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f0106293:	f6 c4 10             	test   $0x10,%ah
f0106296:	75 f5                	jne    f010628d <lapic_init+0x105>
	lapicw(TPR, 0);
f0106298:	ba 00 00 00 00       	mov    $0x0,%edx
f010629d:	b8 20 00 00 00       	mov    $0x20,%eax
f01062a2:	e8 b3 fe ff ff       	call   f010615a <lapicw>
}
f01062a7:	c9                   	leave  
f01062a8:	c3                   	ret    
		lapicw(PCINT, MASKED);
f01062a9:	ba 00 00 01 00       	mov    $0x10000,%edx
f01062ae:	b8 d0 00 00 00       	mov    $0xd0,%eax
f01062b3:	e8 a2 fe ff ff       	call   f010615a <lapicw>
f01062b8:	e9 70 ff ff ff       	jmp    f010622d <lapic_init+0xa5>

f01062bd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01062bd:	f3 0f 1e fb          	endbr32 
	if (lapic)
f01062c1:	83 3d 04 a0 27 f0 00 	cmpl   $0x0,0xf027a004
f01062c8:	74 17                	je     f01062e1 <lapic_eoi+0x24>
{
f01062ca:	55                   	push   %ebp
f01062cb:	89 e5                	mov    %esp,%ebp
f01062cd:	83 ec 08             	sub    $0x8,%esp
		lapicw(EOI, 0);
f01062d0:	ba 00 00 00 00       	mov    $0x0,%edx
f01062d5:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01062da:	e8 7b fe ff ff       	call   f010615a <lapicw>
}
f01062df:	c9                   	leave  
f01062e0:	c3                   	ret    
f01062e1:	c3                   	ret    

f01062e2 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01062e2:	f3 0f 1e fb          	endbr32 
f01062e6:	55                   	push   %ebp
f01062e7:	89 e5                	mov    %esp,%ebp
f01062e9:	56                   	push   %esi
f01062ea:	53                   	push   %ebx
f01062eb:	8b 75 08             	mov    0x8(%ebp),%esi
f01062ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01062f1:	b8 0f 00 00 00       	mov    $0xf,%eax
f01062f6:	ba 70 00 00 00       	mov    $0x70,%edx
f01062fb:	ee                   	out    %al,(%dx)
f01062fc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0106301:	ba 71 00 00 00       	mov    $0x71,%edx
f0106306:	ee                   	out    %al,(%dx)
	if (PGNUM(pa) >= npages)
f0106307:	83 3d 88 8e 23 f0 00 	cmpl   $0x0,0xf0238e88
f010630e:	74 7e                	je     f010638e <lapic_startap+0xac>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0106310:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0106317:	00 00 
	wrv[1] = addr >> 4;
f0106319:	89 d8                	mov    %ebx,%eax
f010631b:	c1 e8 04             	shr    $0x4,%eax
f010631e:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0106324:	c1 e6 18             	shl    $0x18,%esi
f0106327:	89 f2                	mov    %esi,%edx
f0106329:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010632e:	e8 27 fe ff ff       	call   f010615a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0106333:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0106338:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010633d:	e8 18 fe ff ff       	call   f010615a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0106342:	ba 00 85 00 00       	mov    $0x8500,%edx
f0106347:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010634c:	e8 09 fe ff ff       	call   f010615a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106351:	c1 eb 0c             	shr    $0xc,%ebx
f0106354:	80 cf 06             	or     $0x6,%bh
		lapicw(ICRHI, apicid << 24);
f0106357:	89 f2                	mov    %esi,%edx
f0106359:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010635e:	e8 f7 fd ff ff       	call   f010615a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0106363:	89 da                	mov    %ebx,%edx
f0106365:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010636a:	e8 eb fd ff ff       	call   f010615a <lapicw>
		lapicw(ICRHI, apicid << 24);
f010636f:	89 f2                	mov    %esi,%edx
f0106371:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106376:	e8 df fd ff ff       	call   f010615a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010637b:	89 da                	mov    %ebx,%edx
f010637d:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106382:	e8 d3 fd ff ff       	call   f010615a <lapicw>
		microdelay(200);
	}
}
f0106387:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010638a:	5b                   	pop    %ebx
f010638b:	5e                   	pop    %esi
f010638c:	5d                   	pop    %ebp
f010638d:	c3                   	ret    
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010638e:	68 67 04 00 00       	push   $0x467
f0106393:	68 04 68 10 f0       	push   $0xf0106804
f0106398:	68 98 00 00 00       	push   $0x98
f010639d:	68 98 83 10 f0       	push   $0xf0108398
f01063a2:	e8 99 9c ff ff       	call   f0100040 <_panic>

f01063a7 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01063a7:	f3 0f 1e fb          	endbr32 
f01063ab:	55                   	push   %ebp
f01063ac:	89 e5                	mov    %esp,%ebp
f01063ae:	83 ec 08             	sub    $0x8,%esp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01063b1:	8b 55 08             	mov    0x8(%ebp),%edx
f01063b4:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01063ba:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01063bf:	e8 96 fd ff ff       	call   f010615a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01063c4:	8b 15 04 a0 27 f0    	mov    0xf027a004,%edx
f01063ca:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01063d0:	f6 c4 10             	test   $0x10,%ah
f01063d3:	75 f5                	jne    f01063ca <lapic_ipi+0x23>
		;
}
f01063d5:	c9                   	leave  
f01063d6:	c3                   	ret    

f01063d7 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01063d7:	f3 0f 1e fb          	endbr32 
f01063db:	55                   	push   %ebp
f01063dc:	89 e5                	mov    %esp,%ebp
f01063de:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01063e1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01063e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01063ea:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01063ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01063f4:	5d                   	pop    %ebp
f01063f5:	c3                   	ret    

f01063f6 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01063f6:	f3 0f 1e fb          	endbr32 
f01063fa:	55                   	push   %ebp
f01063fb:	89 e5                	mov    %esp,%ebp
f01063fd:	56                   	push   %esi
f01063fe:	53                   	push   %ebx
f01063ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	return lock->locked && lock->cpu == thiscpu;
f0106402:	83 3b 00             	cmpl   $0x0,(%ebx)
f0106405:	75 07                	jne    f010640e <spin_lock+0x18>
	asm volatile("lock; xchgl %0, %1"
f0106407:	ba 01 00 00 00       	mov    $0x1,%edx
f010640c:	eb 34                	jmp    f0106442 <spin_lock+0x4c>
f010640e:	8b 73 08             	mov    0x8(%ebx),%esi
f0106411:	e8 58 fd ff ff       	call   f010616e <cpunum>
f0106416:	6b c0 74             	imul   $0x74,%eax,%eax
f0106419:	05 20 90 23 f0       	add    $0xf0239020,%eax
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f010641e:	39 c6                	cmp    %eax,%esi
f0106420:	75 e5                	jne    f0106407 <spin_lock+0x11>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0106422:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106425:	e8 44 fd ff ff       	call   f010616e <cpunum>
f010642a:	83 ec 0c             	sub    $0xc,%esp
f010642d:	53                   	push   %ebx
f010642e:	50                   	push   %eax
f010642f:	68 a8 83 10 f0       	push   $0xf01083a8
f0106434:	6a 41                	push   $0x41
f0106436:	68 0a 84 10 f0       	push   $0xf010840a
f010643b:	e8 00 9c ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)			//原理见：https://pdos.csail.mit.edu/6.828/2018/xv6/book-rev11.pdf  chapter 4
		asm volatile ("pause");	
f0106440:	f3 90                	pause  
f0106442:	89 d0                	mov    %edx,%eax
f0106444:	f0 87 03             	lock xchg %eax,(%ebx)
	while (xchg(&lk->locked, 1) != 0)			//原理见：https://pdos.csail.mit.edu/6.828/2018/xv6/book-rev11.pdf  chapter 4
f0106447:	85 c0                	test   %eax,%eax
f0106449:	75 f5                	jne    f0106440 <spin_lock+0x4a>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f010644b:	e8 1e fd ff ff       	call   f010616e <cpunum>
f0106450:	6b c0 74             	imul   $0x74,%eax,%eax
f0106453:	05 20 90 23 f0       	add    $0xf0239020,%eax
f0106458:	89 43 08             	mov    %eax,0x8(%ebx)
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f010645b:	89 ea                	mov    %ebp,%edx
	for (i = 0; i < 10; i++){
f010645d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106462:	83 f8 09             	cmp    $0x9,%eax
f0106465:	7f 21                	jg     f0106488 <spin_lock+0x92>
f0106467:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f010646d:	76 19                	jbe    f0106488 <spin_lock+0x92>
		pcs[i] = ebp[1];          // saved %eip
f010646f:	8b 4a 04             	mov    0x4(%edx),%ecx
f0106472:	89 4c 83 0c          	mov    %ecx,0xc(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106476:	8b 12                	mov    (%edx),%edx
	for (i = 0; i < 10; i++){
f0106478:	83 c0 01             	add    $0x1,%eax
f010647b:	eb e5                	jmp    f0106462 <spin_lock+0x6c>
		pcs[i] = 0;
f010647d:	c7 44 83 0c 00 00 00 	movl   $0x0,0xc(%ebx,%eax,4)
f0106484:	00 
	for (; i < 10; i++)
f0106485:	83 c0 01             	add    $0x1,%eax
f0106488:	83 f8 09             	cmp    $0x9,%eax
f010648b:	7e f0                	jle    f010647d <spin_lock+0x87>
	get_caller_pcs(lk->pcs);
#endif
}
f010648d:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0106490:	5b                   	pop    %ebx
f0106491:	5e                   	pop    %esi
f0106492:	5d                   	pop    %ebp
f0106493:	c3                   	ret    

f0106494 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0106494:	f3 0f 1e fb          	endbr32 
f0106498:	55                   	push   %ebp
f0106499:	89 e5                	mov    %esp,%ebp
f010649b:	57                   	push   %edi
f010649c:	56                   	push   %esi
f010649d:	53                   	push   %ebx
f010649e:	83 ec 4c             	sub    $0x4c,%esp
f01064a1:	8b 75 08             	mov    0x8(%ebp),%esi
	return lock->locked && lock->cpu == thiscpu;
f01064a4:	83 3e 00             	cmpl   $0x0,(%esi)
f01064a7:	75 35                	jne    f01064de <spin_unlock+0x4a>
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f01064a9:	83 ec 04             	sub    $0x4,%esp
f01064ac:	6a 28                	push   $0x28
f01064ae:	8d 46 0c             	lea    0xc(%esi),%eax
f01064b1:	50                   	push   %eax
f01064b2:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f01064b5:	53                   	push   %ebx
f01064b6:	e8 e0 f6 ff ff       	call   f0105b9b <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f01064bb:	8b 46 08             	mov    0x8(%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f01064be:	0f b6 38             	movzbl (%eax),%edi
f01064c1:	8b 76 04             	mov    0x4(%esi),%esi
f01064c4:	e8 a5 fc ff ff       	call   f010616e <cpunum>
f01064c9:	57                   	push   %edi
f01064ca:	56                   	push   %esi
f01064cb:	50                   	push   %eax
f01064cc:	68 d4 83 10 f0       	push   $0xf01083d4
f01064d1:	e8 db d3 ff ff       	call   f01038b1 <cprintf>
f01064d6:	83 c4 20             	add    $0x20,%esp
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f01064d9:	8d 7d a8             	lea    -0x58(%ebp),%edi
f01064dc:	eb 4e                	jmp    f010652c <spin_unlock+0x98>
	return lock->locked && lock->cpu == thiscpu;
f01064de:	8b 5e 08             	mov    0x8(%esi),%ebx
f01064e1:	e8 88 fc ff ff       	call   f010616e <cpunum>
f01064e6:	6b c0 74             	imul   $0x74,%eax,%eax
f01064e9:	05 20 90 23 f0       	add    $0xf0239020,%eax
	if (!holding(lk)) {
f01064ee:	39 c3                	cmp    %eax,%ebx
f01064f0:	75 b7                	jne    f01064a9 <spin_unlock+0x15>
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
	}

	lk->pcs[0] = 0;
f01064f2:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f01064f9:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
	asm volatile("lock; xchgl %0, %1"
f0106500:	b8 00 00 00 00       	mov    $0x0,%eax
f0106505:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0106508:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010650b:	5b                   	pop    %ebx
f010650c:	5e                   	pop    %esi
f010650d:	5f                   	pop    %edi
f010650e:	5d                   	pop    %ebp
f010650f:	c3                   	ret    
				cprintf("  %08x\n", pcs[i]);
f0106510:	83 ec 08             	sub    $0x8,%esp
f0106513:	ff 36                	pushl  (%esi)
f0106515:	68 31 84 10 f0       	push   $0xf0108431
f010651a:	e8 92 d3 ff ff       	call   f01038b1 <cprintf>
f010651f:	83 c4 10             	add    $0x10,%esp
f0106522:	83 c3 04             	add    $0x4,%ebx
		for (i = 0; i < 10 && pcs[i]; i++) {
f0106525:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0106528:	39 c3                	cmp    %eax,%ebx
f010652a:	74 40                	je     f010656c <spin_unlock+0xd8>
f010652c:	89 de                	mov    %ebx,%esi
f010652e:	8b 03                	mov    (%ebx),%eax
f0106530:	85 c0                	test   %eax,%eax
f0106532:	74 38                	je     f010656c <spin_unlock+0xd8>
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0106534:	83 ec 08             	sub    $0x8,%esp
f0106537:	57                   	push   %edi
f0106538:	50                   	push   %eax
f0106539:	e8 7b eb ff ff       	call   f01050b9 <debuginfo_eip>
f010653e:	83 c4 10             	add    $0x10,%esp
f0106541:	85 c0                	test   %eax,%eax
f0106543:	78 cb                	js     f0106510 <spin_unlock+0x7c>
					pcs[i] - info.eip_fn_addr);
f0106545:	8b 06                	mov    (%esi),%eax
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0106547:	83 ec 04             	sub    $0x4,%esp
f010654a:	89 c2                	mov    %eax,%edx
f010654c:	2b 55 b8             	sub    -0x48(%ebp),%edx
f010654f:	52                   	push   %edx
f0106550:	ff 75 b0             	pushl  -0x50(%ebp)
f0106553:	ff 75 b4             	pushl  -0x4c(%ebp)
f0106556:	ff 75 ac             	pushl  -0x54(%ebp)
f0106559:	ff 75 a8             	pushl  -0x58(%ebp)
f010655c:	50                   	push   %eax
f010655d:	68 1a 84 10 f0       	push   $0xf010841a
f0106562:	e8 4a d3 ff ff       	call   f01038b1 <cprintf>
f0106567:	83 c4 20             	add    $0x20,%esp
f010656a:	eb b6                	jmp    f0106522 <spin_unlock+0x8e>
		panic("spin_unlock");
f010656c:	83 ec 04             	sub    $0x4,%esp
f010656f:	68 39 84 10 f0       	push   $0xf0108439
f0106574:	6a 67                	push   $0x67
f0106576:	68 0a 84 10 f0       	push   $0xf010840a
f010657b:	e8 c0 9a ff ff       	call   f0100040 <_panic>

f0106580 <__udivdi3>:
f0106580:	f3 0f 1e fb          	endbr32 
f0106584:	55                   	push   %ebp
f0106585:	57                   	push   %edi
f0106586:	56                   	push   %esi
f0106587:	53                   	push   %ebx
f0106588:	83 ec 1c             	sub    $0x1c,%esp
f010658b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010658f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
f0106593:	8b 74 24 34          	mov    0x34(%esp),%esi
f0106597:	8b 5c 24 38          	mov    0x38(%esp),%ebx
f010659b:	85 d2                	test   %edx,%edx
f010659d:	75 19                	jne    f01065b8 <__udivdi3+0x38>
f010659f:	39 f3                	cmp    %esi,%ebx
f01065a1:	76 4d                	jbe    f01065f0 <__udivdi3+0x70>
f01065a3:	31 ff                	xor    %edi,%edi
f01065a5:	89 e8                	mov    %ebp,%eax
f01065a7:	89 f2                	mov    %esi,%edx
f01065a9:	f7 f3                	div    %ebx
f01065ab:	89 fa                	mov    %edi,%edx
f01065ad:	83 c4 1c             	add    $0x1c,%esp
f01065b0:	5b                   	pop    %ebx
f01065b1:	5e                   	pop    %esi
f01065b2:	5f                   	pop    %edi
f01065b3:	5d                   	pop    %ebp
f01065b4:	c3                   	ret    
f01065b5:	8d 76 00             	lea    0x0(%esi),%esi
f01065b8:	39 f2                	cmp    %esi,%edx
f01065ba:	76 14                	jbe    f01065d0 <__udivdi3+0x50>
f01065bc:	31 ff                	xor    %edi,%edi
f01065be:	31 c0                	xor    %eax,%eax
f01065c0:	89 fa                	mov    %edi,%edx
f01065c2:	83 c4 1c             	add    $0x1c,%esp
f01065c5:	5b                   	pop    %ebx
f01065c6:	5e                   	pop    %esi
f01065c7:	5f                   	pop    %edi
f01065c8:	5d                   	pop    %ebp
f01065c9:	c3                   	ret    
f01065ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01065d0:	0f bd fa             	bsr    %edx,%edi
f01065d3:	83 f7 1f             	xor    $0x1f,%edi
f01065d6:	75 48                	jne    f0106620 <__udivdi3+0xa0>
f01065d8:	39 f2                	cmp    %esi,%edx
f01065da:	72 06                	jb     f01065e2 <__udivdi3+0x62>
f01065dc:	31 c0                	xor    %eax,%eax
f01065de:	39 eb                	cmp    %ebp,%ebx
f01065e0:	77 de                	ja     f01065c0 <__udivdi3+0x40>
f01065e2:	b8 01 00 00 00       	mov    $0x1,%eax
f01065e7:	eb d7                	jmp    f01065c0 <__udivdi3+0x40>
f01065e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01065f0:	89 d9                	mov    %ebx,%ecx
f01065f2:	85 db                	test   %ebx,%ebx
f01065f4:	75 0b                	jne    f0106601 <__udivdi3+0x81>
f01065f6:	b8 01 00 00 00       	mov    $0x1,%eax
f01065fb:	31 d2                	xor    %edx,%edx
f01065fd:	f7 f3                	div    %ebx
f01065ff:	89 c1                	mov    %eax,%ecx
f0106601:	31 d2                	xor    %edx,%edx
f0106603:	89 f0                	mov    %esi,%eax
f0106605:	f7 f1                	div    %ecx
f0106607:	89 c6                	mov    %eax,%esi
f0106609:	89 e8                	mov    %ebp,%eax
f010660b:	89 f7                	mov    %esi,%edi
f010660d:	f7 f1                	div    %ecx
f010660f:	89 fa                	mov    %edi,%edx
f0106611:	83 c4 1c             	add    $0x1c,%esp
f0106614:	5b                   	pop    %ebx
f0106615:	5e                   	pop    %esi
f0106616:	5f                   	pop    %edi
f0106617:	5d                   	pop    %ebp
f0106618:	c3                   	ret    
f0106619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106620:	89 f9                	mov    %edi,%ecx
f0106622:	b8 20 00 00 00       	mov    $0x20,%eax
f0106627:	29 f8                	sub    %edi,%eax
f0106629:	d3 e2                	shl    %cl,%edx
f010662b:	89 54 24 08          	mov    %edx,0x8(%esp)
f010662f:	89 c1                	mov    %eax,%ecx
f0106631:	89 da                	mov    %ebx,%edx
f0106633:	d3 ea                	shr    %cl,%edx
f0106635:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106639:	09 d1                	or     %edx,%ecx
f010663b:	89 f2                	mov    %esi,%edx
f010663d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106641:	89 f9                	mov    %edi,%ecx
f0106643:	d3 e3                	shl    %cl,%ebx
f0106645:	89 c1                	mov    %eax,%ecx
f0106647:	d3 ea                	shr    %cl,%edx
f0106649:	89 f9                	mov    %edi,%ecx
f010664b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f010664f:	89 eb                	mov    %ebp,%ebx
f0106651:	d3 e6                	shl    %cl,%esi
f0106653:	89 c1                	mov    %eax,%ecx
f0106655:	d3 eb                	shr    %cl,%ebx
f0106657:	09 de                	or     %ebx,%esi
f0106659:	89 f0                	mov    %esi,%eax
f010665b:	f7 74 24 08          	divl   0x8(%esp)
f010665f:	89 d6                	mov    %edx,%esi
f0106661:	89 c3                	mov    %eax,%ebx
f0106663:	f7 64 24 0c          	mull   0xc(%esp)
f0106667:	39 d6                	cmp    %edx,%esi
f0106669:	72 15                	jb     f0106680 <__udivdi3+0x100>
f010666b:	89 f9                	mov    %edi,%ecx
f010666d:	d3 e5                	shl    %cl,%ebp
f010666f:	39 c5                	cmp    %eax,%ebp
f0106671:	73 04                	jae    f0106677 <__udivdi3+0xf7>
f0106673:	39 d6                	cmp    %edx,%esi
f0106675:	74 09                	je     f0106680 <__udivdi3+0x100>
f0106677:	89 d8                	mov    %ebx,%eax
f0106679:	31 ff                	xor    %edi,%edi
f010667b:	e9 40 ff ff ff       	jmp    f01065c0 <__udivdi3+0x40>
f0106680:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0106683:	31 ff                	xor    %edi,%edi
f0106685:	e9 36 ff ff ff       	jmp    f01065c0 <__udivdi3+0x40>
f010668a:	66 90                	xchg   %ax,%ax
f010668c:	66 90                	xchg   %ax,%ax
f010668e:	66 90                	xchg   %ax,%ax

f0106690 <__umoddi3>:
f0106690:	f3 0f 1e fb          	endbr32 
f0106694:	55                   	push   %ebp
f0106695:	57                   	push   %edi
f0106696:	56                   	push   %esi
f0106697:	53                   	push   %ebx
f0106698:	83 ec 1c             	sub    $0x1c,%esp
f010669b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010669f:	8b 74 24 30          	mov    0x30(%esp),%esi
f01066a3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
f01066a7:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01066ab:	85 c0                	test   %eax,%eax
f01066ad:	75 19                	jne    f01066c8 <__umoddi3+0x38>
f01066af:	39 df                	cmp    %ebx,%edi
f01066b1:	76 5d                	jbe    f0106710 <__umoddi3+0x80>
f01066b3:	89 f0                	mov    %esi,%eax
f01066b5:	89 da                	mov    %ebx,%edx
f01066b7:	f7 f7                	div    %edi
f01066b9:	89 d0                	mov    %edx,%eax
f01066bb:	31 d2                	xor    %edx,%edx
f01066bd:	83 c4 1c             	add    $0x1c,%esp
f01066c0:	5b                   	pop    %ebx
f01066c1:	5e                   	pop    %esi
f01066c2:	5f                   	pop    %edi
f01066c3:	5d                   	pop    %ebp
f01066c4:	c3                   	ret    
f01066c5:	8d 76 00             	lea    0x0(%esi),%esi
f01066c8:	89 f2                	mov    %esi,%edx
f01066ca:	39 d8                	cmp    %ebx,%eax
f01066cc:	76 12                	jbe    f01066e0 <__umoddi3+0x50>
f01066ce:	89 f0                	mov    %esi,%eax
f01066d0:	89 da                	mov    %ebx,%edx
f01066d2:	83 c4 1c             	add    $0x1c,%esp
f01066d5:	5b                   	pop    %ebx
f01066d6:	5e                   	pop    %esi
f01066d7:	5f                   	pop    %edi
f01066d8:	5d                   	pop    %ebp
f01066d9:	c3                   	ret    
f01066da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01066e0:	0f bd e8             	bsr    %eax,%ebp
f01066e3:	83 f5 1f             	xor    $0x1f,%ebp
f01066e6:	75 50                	jne    f0106738 <__umoddi3+0xa8>
f01066e8:	39 d8                	cmp    %ebx,%eax
f01066ea:	0f 82 e0 00 00 00    	jb     f01067d0 <__umoddi3+0x140>
f01066f0:	89 d9                	mov    %ebx,%ecx
f01066f2:	39 f7                	cmp    %esi,%edi
f01066f4:	0f 86 d6 00 00 00    	jbe    f01067d0 <__umoddi3+0x140>
f01066fa:	89 d0                	mov    %edx,%eax
f01066fc:	89 ca                	mov    %ecx,%edx
f01066fe:	83 c4 1c             	add    $0x1c,%esp
f0106701:	5b                   	pop    %ebx
f0106702:	5e                   	pop    %esi
f0106703:	5f                   	pop    %edi
f0106704:	5d                   	pop    %ebp
f0106705:	c3                   	ret    
f0106706:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f010670d:	8d 76 00             	lea    0x0(%esi),%esi
f0106710:	89 fd                	mov    %edi,%ebp
f0106712:	85 ff                	test   %edi,%edi
f0106714:	75 0b                	jne    f0106721 <__umoddi3+0x91>
f0106716:	b8 01 00 00 00       	mov    $0x1,%eax
f010671b:	31 d2                	xor    %edx,%edx
f010671d:	f7 f7                	div    %edi
f010671f:	89 c5                	mov    %eax,%ebp
f0106721:	89 d8                	mov    %ebx,%eax
f0106723:	31 d2                	xor    %edx,%edx
f0106725:	f7 f5                	div    %ebp
f0106727:	89 f0                	mov    %esi,%eax
f0106729:	f7 f5                	div    %ebp
f010672b:	89 d0                	mov    %edx,%eax
f010672d:	31 d2                	xor    %edx,%edx
f010672f:	eb 8c                	jmp    f01066bd <__umoddi3+0x2d>
f0106731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0106738:	89 e9                	mov    %ebp,%ecx
f010673a:	ba 20 00 00 00       	mov    $0x20,%edx
f010673f:	29 ea                	sub    %ebp,%edx
f0106741:	d3 e0                	shl    %cl,%eax
f0106743:	89 44 24 08          	mov    %eax,0x8(%esp)
f0106747:	89 d1                	mov    %edx,%ecx
f0106749:	89 f8                	mov    %edi,%eax
f010674b:	d3 e8                	shr    %cl,%eax
f010674d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0106751:	89 54 24 04          	mov    %edx,0x4(%esp)
f0106755:	8b 54 24 04          	mov    0x4(%esp),%edx
f0106759:	09 c1                	or     %eax,%ecx
f010675b:	89 d8                	mov    %ebx,%eax
f010675d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0106761:	89 e9                	mov    %ebp,%ecx
f0106763:	d3 e7                	shl    %cl,%edi
f0106765:	89 d1                	mov    %edx,%ecx
f0106767:	d3 e8                	shr    %cl,%eax
f0106769:	89 e9                	mov    %ebp,%ecx
f010676b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f010676f:	d3 e3                	shl    %cl,%ebx
f0106771:	89 c7                	mov    %eax,%edi
f0106773:	89 d1                	mov    %edx,%ecx
f0106775:	89 f0                	mov    %esi,%eax
f0106777:	d3 e8                	shr    %cl,%eax
f0106779:	89 e9                	mov    %ebp,%ecx
f010677b:	89 fa                	mov    %edi,%edx
f010677d:	d3 e6                	shl    %cl,%esi
f010677f:	09 d8                	or     %ebx,%eax
f0106781:	f7 74 24 08          	divl   0x8(%esp)
f0106785:	89 d1                	mov    %edx,%ecx
f0106787:	89 f3                	mov    %esi,%ebx
f0106789:	f7 64 24 0c          	mull   0xc(%esp)
f010678d:	89 c6                	mov    %eax,%esi
f010678f:	89 d7                	mov    %edx,%edi
f0106791:	39 d1                	cmp    %edx,%ecx
f0106793:	72 06                	jb     f010679b <__umoddi3+0x10b>
f0106795:	75 10                	jne    f01067a7 <__umoddi3+0x117>
f0106797:	39 c3                	cmp    %eax,%ebx
f0106799:	73 0c                	jae    f01067a7 <__umoddi3+0x117>
f010679b:	2b 44 24 0c          	sub    0xc(%esp),%eax
f010679f:	1b 54 24 08          	sbb    0x8(%esp),%edx
f01067a3:	89 d7                	mov    %edx,%edi
f01067a5:	89 c6                	mov    %eax,%esi
f01067a7:	89 ca                	mov    %ecx,%edx
f01067a9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
f01067ae:	29 f3                	sub    %esi,%ebx
f01067b0:	19 fa                	sbb    %edi,%edx
f01067b2:	89 d0                	mov    %edx,%eax
f01067b4:	d3 e0                	shl    %cl,%eax
f01067b6:	89 e9                	mov    %ebp,%ecx
f01067b8:	d3 eb                	shr    %cl,%ebx
f01067ba:	d3 ea                	shr    %cl,%edx
f01067bc:	09 d8                	or     %ebx,%eax
f01067be:	83 c4 1c             	add    $0x1c,%esp
f01067c1:	5b                   	pop    %ebx
f01067c2:	5e                   	pop    %esi
f01067c3:	5f                   	pop    %edi
f01067c4:	5d                   	pop    %ebp
f01067c5:	c3                   	ret    
f01067c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01067cd:	8d 76 00             	lea    0x0(%esi),%esi
f01067d0:	29 fe                	sub    %edi,%esi
f01067d2:	19 c3                	sbb    %eax,%ebx
f01067d4:	89 f2                	mov    %esi,%edx
f01067d6:	89 d9                	mov    %ebx,%ecx
f01067d8:	e9 1d ff ff ff       	jmp    f01066fa <__umoddi3+0x6a>
