
obj/user/badsegment:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800037:	66 b8 28 00          	mov    $0x28,%ax
  80003b:	8e d8                	mov    %eax,%ds
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  80004d:	e8 d9 00 00 00       	call   80012b <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  80005d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800062:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800067:	85 db                	test   %ebx,%ebx
  800069:	7e 07                	jle    800072 <libmain+0x34>
		binaryname = argv[0];
  80006b:	8b 06                	mov    (%esi),%eax
  80006d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800072:	83 ec 08             	sub    $0x8,%esp
  800075:	56                   	push   %esi
  800076:	53                   	push   %ebx
  800077:	e8 b7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007c:	e8 0a 00 00 00       	call   80008b <exit>
}
  800081:	83 c4 10             	add    $0x10,%esp
  800084:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800087:	5b                   	pop    %ebx
  800088:	5e                   	pop    %esi
  800089:	5d                   	pop    %ebp
  80008a:	c3                   	ret    

0080008b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008b:	f3 0f 1e fb          	endbr32 
  80008f:	55                   	push   %ebp
  800090:	89 e5                	mov    %esp,%ebp
  800092:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800095:	6a 00                	push   $0x0
  800097:	e8 4a 00 00 00       	call   8000e6 <sys_env_destroy>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	c9                   	leave  
  8000a0:	c3                   	ret    

008000a1 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a1:	f3 0f 1e fb          	endbr32 
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  8000ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b6:	89 c3                	mov    %eax,%ebx
  8000b8:	89 c7                	mov    %eax,%edi
  8000ba:	89 c6                	mov    %eax,%esi
  8000bc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000be:	5b                   	pop    %ebx
  8000bf:	5e                   	pop    %esi
  8000c0:	5f                   	pop    %edi
  8000c1:	5d                   	pop    %ebp
  8000c2:	c3                   	ret    

008000c3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c3:	f3 0f 1e fb          	endbr32 
  8000c7:	55                   	push   %ebp
  8000c8:	89 e5                	mov    %esp,%ebp
  8000ca:	57                   	push   %edi
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e6:	f3 0f 1e fb          	endbr32 
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	57                   	push   %edi
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  8000f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	89 cb                	mov    %ecx,%ebx
  800102:	89 cf                	mov    %ecx,%edi
  800104:	89 ce                	mov    %ecx,%esi
  800106:	cd 30                	int    $0x30
	if(check && ret > 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	7f 08                	jg     800114 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	50                   	push   %eax
  800118:	6a 03                	push   $0x3
  80011a:	68 0a 10 80 00       	push   $0x80100a
  80011f:	6a 23                	push   $0x23
  800121:	68 27 10 80 00       	push   $0x801027
  800126:	e8 11 02 00 00       	call   80033c <_panic>

0080012b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012b:	f3 0f 1e fb          	endbr32 
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 02 00 00 00       	mov    $0x2,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_yield>:

void
sys_yield(void)
{
  80014e:	f3 0f 1e fb          	endbr32 
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800171:	f3 0f 1e fb          	endbr32 
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  80017e:	be 00 00 00 00       	mov    $0x0,%esi
  800183:	8b 55 08             	mov    0x8(%ebp),%edx
  800186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800189:	b8 04 00 00 00       	mov    $0x4,%eax
  80018e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800191:	89 f7                	mov    %esi,%edi
  800193:	cd 30                	int    $0x30
	if(check && ret > 0)
  800195:	85 c0                	test   %eax,%eax
  800197:	7f 08                	jg     8001a1 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a1:	83 ec 0c             	sub    $0xc,%esp
  8001a4:	50                   	push   %eax
  8001a5:	6a 04                	push   $0x4
  8001a7:	68 0a 10 80 00       	push   $0x80100a
  8001ac:	6a 23                	push   $0x23
  8001ae:	68 27 10 80 00       	push   $0x801027
  8001b3:	e8 84 01 00 00       	call   80033c <_panic>

008001b8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b8:	f3 0f 1e fb          	endbr32 
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  8001c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7f 08                	jg     8001e7 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 10 80 00       	push   $0x80100a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 10 80 00       	push   $0x801027
  8001f9:	e8 3e 01 00 00       	call   80033c <_panic>

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	f3 0f 1e fb          	endbr32 
  800202:	55                   	push   %ebp
  800203:	89 e5                	mov    %esp,%ebp
  800205:	57                   	push   %edi
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  80020b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800210:	8b 55 08             	mov    0x8(%ebp),%edx
  800213:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800216:	b8 06 00 00 00       	mov    $0x6,%eax
  80021b:	89 df                	mov    %ebx,%edi
  80021d:	89 de                	mov    %ebx,%esi
  80021f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800221:	85 c0                	test   %eax,%eax
  800223:	7f 08                	jg     80022d <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80022d:	83 ec 0c             	sub    $0xc,%esp
  800230:	50                   	push   %eax
  800231:	6a 06                	push   $0x6
  800233:	68 0a 10 80 00       	push   $0x80100a
  800238:	6a 23                	push   $0x23
  80023a:	68 27 10 80 00       	push   $0x801027
  80023f:	e8 f8 00 00 00       	call   80033c <_panic>

00800244 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 0a 10 80 00       	push   $0x80100a
  80027e:	6a 23                	push   $0x23
  800280:	68 27 10 80 00       	push   $0x801027
  800285:	e8 b2 00 00 00       	call   80033c <_panic>

0080028a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80028a:	f3 0f 1e fb          	endbr32 
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	57                   	push   %edi
  800292:	56                   	push   %esi
  800293:	53                   	push   %ebx
  800294:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  800297:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029c:	8b 55 08             	mov    0x8(%ebp),%edx
  80029f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a2:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a7:	89 df                	mov    %ebx,%edi
  8002a9:	89 de                	mov    %ebx,%esi
  8002ab:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ad:	85 c0                	test   %eax,%eax
  8002af:	7f 08                	jg     8002b9 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b4:	5b                   	pop    %ebx
  8002b5:	5e                   	pop    %esi
  8002b6:	5f                   	pop    %edi
  8002b7:	5d                   	pop    %ebp
  8002b8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b9:	83 ec 0c             	sub    $0xc,%esp
  8002bc:	50                   	push   %eax
  8002bd:	6a 09                	push   $0x9
  8002bf:	68 0a 10 80 00       	push   $0x80100a
  8002c4:	6a 23                	push   $0x23
  8002c6:	68 27 10 80 00       	push   $0x801027
  8002cb:	e8 6c 00 00 00       	call   80033c <_panic>

008002d0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	57                   	push   %edi
  8002d8:	56                   	push   %esi
  8002d9:	53                   	push   %ebx
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002e5:	be 00 00 00 00       	mov    $0x0,%esi
  8002ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ed:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002f0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002f7:	f3 0f 1e fb          	endbr32 
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
  8002fe:	57                   	push   %edi
  8002ff:	56                   	push   %esi
  800300:	53                   	push   %ebx
  800301:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//??????int T_SYSCALL??????
  800304:	b9 00 00 00 00       	mov    $0x0,%ecx
  800309:	8b 55 08             	mov    0x8(%ebp),%edx
  80030c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800311:	89 cb                	mov    %ecx,%ebx
  800313:	89 cf                	mov    %ecx,%edi
  800315:	89 ce                	mov    %ecx,%esi
  800317:	cd 30                	int    $0x30
	if(check && ret > 0)
  800319:	85 c0                	test   %eax,%eax
  80031b:	7f 08                	jg     800325 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80031d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	50                   	push   %eax
  800329:	6a 0c                	push   $0xc
  80032b:	68 0a 10 80 00       	push   $0x80100a
  800330:	6a 23                	push   $0x23
  800332:	68 27 10 80 00       	push   $0x801027
  800337:	e8 00 00 00 00       	call   80033c <_panic>

0080033c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033c:	f3 0f 1e fb          	endbr32 
  800340:	55                   	push   %ebp
  800341:	89 e5                	mov    %esp,%ebp
  800343:	56                   	push   %esi
  800344:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800345:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800348:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034e:	e8 d8 fd ff ff       	call   80012b <sys_getenvid>
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 0c             	pushl  0xc(%ebp)
  800359:	ff 75 08             	pushl  0x8(%ebp)
  80035c:	56                   	push   %esi
  80035d:	50                   	push   %eax
  80035e:	68 38 10 80 00       	push   $0x801038
  800363:	e8 bb 00 00 00       	call   800423 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800368:	83 c4 18             	add    $0x18,%esp
  80036b:	53                   	push   %ebx
  80036c:	ff 75 10             	pushl  0x10(%ebp)
  80036f:	e8 5a 00 00 00       	call   8003ce <vcprintf>
	cprintf("\n");
  800374:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  80037b:	e8 a3 00 00 00       	call   800423 <cprintf>
  800380:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800383:	cc                   	int3   
  800384:	eb fd                	jmp    800383 <_panic+0x47>

00800386 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800386:	f3 0f 1e fb          	endbr32 
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	53                   	push   %ebx
  80038e:	83 ec 04             	sub    $0x4,%esp
  800391:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800394:	8b 13                	mov    (%ebx),%edx
  800396:	8d 42 01             	lea    0x1(%edx),%eax
  800399:	89 03                	mov    %eax,(%ebx)
  80039b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a7:	74 09                	je     8003b2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b0:	c9                   	leave  
  8003b1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	68 ff 00 00 00       	push   $0xff
  8003ba:	8d 43 08             	lea    0x8(%ebx),%eax
  8003bd:	50                   	push   %eax
  8003be:	e8 de fc ff ff       	call   8000a1 <sys_cputs>
		b->idx = 0;
  8003c3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c9:	83 c4 10             	add    $0x10,%esp
  8003cc:	eb db                	jmp    8003a9 <putch+0x23>

008003ce <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ce:	f3 0f 1e fb          	endbr32 
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e2:	00 00 00 
	b.cnt = 0;
  8003e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003ef:	ff 75 0c             	pushl  0xc(%ebp)
  8003f2:	ff 75 08             	pushl  0x8(%ebp)
  8003f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003fb:	50                   	push   %eax
  8003fc:	68 86 03 80 00       	push   $0x800386
  800401:	e8 20 01 00 00       	call   800526 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800406:	83 c4 08             	add    $0x8,%esp
  800409:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80040f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800415:	50                   	push   %eax
  800416:	e8 86 fc ff ff       	call   8000a1 <sys_cputs>

	return b.cnt;
}
  80041b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800421:	c9                   	leave  
  800422:	c3                   	ret    

00800423 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800423:	f3 0f 1e fb          	endbr32 
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80042d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800430:	50                   	push   %eax
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 95 ff ff ff       	call   8003ce <vcprintf>
	va_end(ap);

	return cnt;
}
  800439:	c9                   	leave  
  80043a:	c3                   	ret    

0080043b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80043b:	55                   	push   %ebp
  80043c:	89 e5                	mov    %esp,%ebp
  80043e:	57                   	push   %edi
  80043f:	56                   	push   %esi
  800440:	53                   	push   %ebx
  800441:	83 ec 1c             	sub    $0x1c,%esp
  800444:	89 c7                	mov    %eax,%edi
  800446:	89 d6                	mov    %edx,%esi
  800448:	8b 45 08             	mov    0x8(%ebp),%eax
  80044b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044e:	89 d1                	mov    %edx,%ecx
  800450:	89 c2                	mov    %eax,%edx
  800452:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800455:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800458:	8b 45 10             	mov    0x10(%ebp),%eax
  80045b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80045e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800461:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800468:	39 c2                	cmp    %eax,%edx
  80046a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80046d:	72 3e                	jb     8004ad <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80046f:	83 ec 0c             	sub    $0xc,%esp
  800472:	ff 75 18             	pushl  0x18(%ebp)
  800475:	83 eb 01             	sub    $0x1,%ebx
  800478:	53                   	push   %ebx
  800479:	50                   	push   %eax
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800480:	ff 75 e0             	pushl  -0x20(%ebp)
  800483:	ff 75 dc             	pushl  -0x24(%ebp)
  800486:	ff 75 d8             	pushl  -0x28(%ebp)
  800489:	e8 12 09 00 00       	call   800da0 <__udivdi3>
  80048e:	83 c4 18             	add    $0x18,%esp
  800491:	52                   	push   %edx
  800492:	50                   	push   %eax
  800493:	89 f2                	mov    %esi,%edx
  800495:	89 f8                	mov    %edi,%eax
  800497:	e8 9f ff ff ff       	call   80043b <printnum>
  80049c:	83 c4 20             	add    $0x20,%esp
  80049f:	eb 13                	jmp    8004b4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	56                   	push   %esi
  8004a5:	ff 75 18             	pushl  0x18(%ebp)
  8004a8:	ff d7                	call   *%edi
  8004aa:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004ad:	83 eb 01             	sub    $0x1,%ebx
  8004b0:	85 db                	test   %ebx,%ebx
  8004b2:	7f ed                	jg     8004a1 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	56                   	push   %esi
  8004b8:	83 ec 04             	sub    $0x4,%esp
  8004bb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004be:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c1:	ff 75 dc             	pushl  -0x24(%ebp)
  8004c4:	ff 75 d8             	pushl  -0x28(%ebp)
  8004c7:	e8 e4 09 00 00       	call   800eb0 <__umoddi3>
  8004cc:	83 c4 14             	add    $0x14,%esp
  8004cf:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004d6:	50                   	push   %eax
  8004d7:	ff d7                	call   *%edi
}
  8004d9:	83 c4 10             	add    $0x10,%esp
  8004dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004df:	5b                   	pop    %ebx
  8004e0:	5e                   	pop    %esi
  8004e1:	5f                   	pop    %edi
  8004e2:	5d                   	pop    %ebp
  8004e3:	c3                   	ret    

008004e4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e4:	f3 0f 1e fb          	endbr32 
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f2:	8b 10                	mov    (%eax),%edx
  8004f4:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f7:	73 0a                	jae    800503 <sprintputch+0x1f>
		*b->buf++ = ch;
  8004f9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fc:	89 08                	mov    %ecx,(%eax)
  8004fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800501:	88 02                	mov    %al,(%edx)
}
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <printfmt>:
{
  800505:	f3 0f 1e fb          	endbr32 
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80050f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800512:	50                   	push   %eax
  800513:	ff 75 10             	pushl  0x10(%ebp)
  800516:	ff 75 0c             	pushl  0xc(%ebp)
  800519:	ff 75 08             	pushl  0x8(%ebp)
  80051c:	e8 05 00 00 00       	call   800526 <vprintfmt>
}
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <vprintfmt>:
{
  800526:	f3 0f 1e fb          	endbr32 
  80052a:	55                   	push   %ebp
  80052b:	89 e5                	mov    %esp,%ebp
  80052d:	57                   	push   %edi
  80052e:	56                   	push   %esi
  80052f:	53                   	push   %ebx
  800530:	83 ec 3c             	sub    $0x3c,%esp
  800533:	8b 75 08             	mov    0x8(%ebp),%esi
  800536:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800539:	8b 7d 10             	mov    0x10(%ebp),%edi
  80053c:	e9 8e 03 00 00       	jmp    8008cf <vprintfmt+0x3a9>
		padc = ' ';
  800541:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800545:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80054c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800553:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055f:	8d 47 01             	lea    0x1(%edi),%eax
  800562:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800565:	0f b6 17             	movzbl (%edi),%edx
  800568:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056b:	3c 55                	cmp    $0x55,%al
  80056d:	0f 87 df 03 00 00    	ja     800952 <vprintfmt+0x42c>
  800573:	0f b6 c0             	movzbl %al,%eax
  800576:	3e ff 24 85 20 11 80 	notrack jmp *0x801120(,%eax,4)
  80057d:	00 
  80057e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800581:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800585:	eb d8                	jmp    80055f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80058e:	eb cf                	jmp    80055f <vprintfmt+0x39>
  800590:	0f b6 d2             	movzbl %dl,%edx
  800593:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800596:	b8 00 00 00 00       	mov    $0x0,%eax
  80059b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80059e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ab:	83 f9 09             	cmp    $0x9,%ecx
  8005ae:	77 55                	ja     800605 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8005b0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b3:	eb e9                	jmp    80059e <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8b 00                	mov    (%eax),%eax
  8005ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8d 40 04             	lea    0x4(%eax),%eax
  8005c3:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005cd:	79 90                	jns    80055f <vprintfmt+0x39>
				width = precision, precision = -1;
  8005cf:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005dc:	eb 81                	jmp    80055f <vprintfmt+0x39>
  8005de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8005e8:	0f 49 d0             	cmovns %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f1:	e9 69 ff ff ff       	jmp    80055f <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800600:	e9 5a ff ff ff       	jmp    80055f <vprintfmt+0x39>
  800605:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800608:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060b:	eb bc                	jmp    8005c9 <vprintfmt+0xa3>
			lflag++;
  80060d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800610:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800613:	e9 47 ff ff ff       	jmp    80055f <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8d 78 04             	lea    0x4(%eax),%edi
  80061e:	83 ec 08             	sub    $0x8,%esp
  800621:	53                   	push   %ebx
  800622:	ff 30                	pushl  (%eax)
  800624:	ff d6                	call   *%esi
			break;
  800626:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800629:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062c:	e9 9b 02 00 00       	jmp    8008cc <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8d 78 04             	lea    0x4(%eax),%edi
  800637:	8b 00                	mov    (%eax),%eax
  800639:	99                   	cltd   
  80063a:	31 d0                	xor    %edx,%eax
  80063c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063e:	83 f8 08             	cmp    $0x8,%eax
  800641:	7f 23                	jg     800666 <vprintfmt+0x140>
  800643:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80064a:	85 d2                	test   %edx,%edx
  80064c:	74 18                	je     800666 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80064e:	52                   	push   %edx
  80064f:	68 7e 10 80 00       	push   $0x80107e
  800654:	53                   	push   %ebx
  800655:	56                   	push   %esi
  800656:	e8 aa fe ff ff       	call   800505 <printfmt>
  80065b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800661:	e9 66 02 00 00       	jmp    8008cc <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800666:	50                   	push   %eax
  800667:	68 75 10 80 00       	push   $0x801075
  80066c:	53                   	push   %ebx
  80066d:	56                   	push   %esi
  80066e:	e8 92 fe ff ff       	call   800505 <printfmt>
  800673:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800676:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800679:	e9 4e 02 00 00       	jmp    8008cc <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	83 c0 04             	add    $0x4,%eax
  800684:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80068c:	85 d2                	test   %edx,%edx
  80068e:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  800693:	0f 45 c2             	cmovne %edx,%eax
  800696:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800699:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069d:	7e 06                	jle    8006a5 <vprintfmt+0x17f>
  80069f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a3:	75 0d                	jne    8006b2 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a8:	89 c7                	mov    %eax,%edi
  8006aa:	03 45 e0             	add    -0x20(%ebp),%eax
  8006ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b0:	eb 55                	jmp    800707 <vprintfmt+0x1e1>
  8006b2:	83 ec 08             	sub    $0x8,%esp
  8006b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8006b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8006bb:	e8 46 03 00 00       	call   800a06 <strnlen>
  8006c0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c3:	29 c2                	sub    %eax,%edx
  8006c5:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8006cd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d4:	85 ff                	test   %edi,%edi
  8006d6:	7e 11                	jle    8006e9 <vprintfmt+0x1c3>
					putch(padc, putdat);
  8006d8:	83 ec 08             	sub    $0x8,%esp
  8006db:	53                   	push   %ebx
  8006dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006df:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e1:	83 ef 01             	sub    $0x1,%edi
  8006e4:	83 c4 10             	add    $0x10,%esp
  8006e7:	eb eb                	jmp    8006d4 <vprintfmt+0x1ae>
  8006e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f3:	0f 49 c2             	cmovns %edx,%eax
  8006f6:	29 c2                	sub    %eax,%edx
  8006f8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006fb:	eb a8                	jmp    8006a5 <vprintfmt+0x17f>
					putch(ch, putdat);
  8006fd:	83 ec 08             	sub    $0x8,%esp
  800700:	53                   	push   %ebx
  800701:	52                   	push   %edx
  800702:	ff d6                	call   *%esi
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80070c:	83 c7 01             	add    $0x1,%edi
  80070f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800713:	0f be d0             	movsbl %al,%edx
  800716:	85 d2                	test   %edx,%edx
  800718:	74 4b                	je     800765 <vprintfmt+0x23f>
  80071a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071e:	78 06                	js     800726 <vprintfmt+0x200>
  800720:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800724:	78 1e                	js     800744 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800726:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072a:	74 d1                	je     8006fd <vprintfmt+0x1d7>
  80072c:	0f be c0             	movsbl %al,%eax
  80072f:	83 e8 20             	sub    $0x20,%eax
  800732:	83 f8 5e             	cmp    $0x5e,%eax
  800735:	76 c6                	jbe    8006fd <vprintfmt+0x1d7>
					putch('?', putdat);
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	53                   	push   %ebx
  80073b:	6a 3f                	push   $0x3f
  80073d:	ff d6                	call   *%esi
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	eb c3                	jmp    800707 <vprintfmt+0x1e1>
  800744:	89 cf                	mov    %ecx,%edi
  800746:	eb 0e                	jmp    800756 <vprintfmt+0x230>
				putch(' ', putdat);
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	53                   	push   %ebx
  80074c:	6a 20                	push   $0x20
  80074e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800750:	83 ef 01             	sub    $0x1,%edi
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 ff                	test   %edi,%edi
  800758:	7f ee                	jg     800748 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  80075a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
  800760:	e9 67 01 00 00       	jmp    8008cc <vprintfmt+0x3a6>
  800765:	89 cf                	mov    %ecx,%edi
  800767:	eb ed                	jmp    800756 <vprintfmt+0x230>
	if (lflag >= 2)
  800769:	83 f9 01             	cmp    $0x1,%ecx
  80076c:	7f 1b                	jg     800789 <vprintfmt+0x263>
	else if (lflag)
  80076e:	85 c9                	test   %ecx,%ecx
  800770:	74 63                	je     8007d5 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 00                	mov    (%eax),%eax
  800777:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077a:	99                   	cltd   
  80077b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 40 04             	lea    0x4(%eax),%eax
  800784:	89 45 14             	mov    %eax,0x14(%ebp)
  800787:	eb 17                	jmp    8007a0 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800789:	8b 45 14             	mov    0x14(%ebp),%eax
  80078c:	8b 50 04             	mov    0x4(%eax),%edx
  80078f:	8b 00                	mov    (%eax),%eax
  800791:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800794:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 40 08             	lea    0x8(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a6:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8007ab:	85 c9                	test   %ecx,%ecx
  8007ad:	0f 89 ff 00 00 00    	jns    8008b2 <vprintfmt+0x38c>
				putch('-', putdat);
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	6a 2d                	push   $0x2d
  8007b9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007be:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c1:	f7 da                	neg    %edx
  8007c3:	83 d1 00             	adc    $0x0,%ecx
  8007c6:	f7 d9                	neg    %ecx
  8007c8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007d0:	e9 dd 00 00 00       	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8b 00                	mov    (%eax),%eax
  8007da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007dd:	99                   	cltd   
  8007de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8d 40 04             	lea    0x4(%eax),%eax
  8007e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ea:	eb b4                	jmp    8007a0 <vprintfmt+0x27a>
	if (lflag >= 2)
  8007ec:	83 f9 01             	cmp    $0x1,%ecx
  8007ef:	7f 1e                	jg     80080f <vprintfmt+0x2e9>
	else if (lflag)
  8007f1:	85 c9                	test   %ecx,%ecx
  8007f3:	74 32                	je     800827 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  8007f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f8:	8b 10                	mov    (%eax),%edx
  8007fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ff:	8d 40 04             	lea    0x4(%eax),%eax
  800802:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800805:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80080a:	e9 a3 00 00 00       	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8b 10                	mov    (%eax),%edx
  800814:	8b 48 04             	mov    0x4(%eax),%ecx
  800817:	8d 40 08             	lea    0x8(%eax),%eax
  80081a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081d:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800822:	e9 8b 00 00 00       	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800831:	8d 40 04             	lea    0x4(%eax),%eax
  800834:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800837:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80083c:	eb 74                	jmp    8008b2 <vprintfmt+0x38c>
	if (lflag >= 2)
  80083e:	83 f9 01             	cmp    $0x1,%ecx
  800841:	7f 1b                	jg     80085e <vprintfmt+0x338>
	else if (lflag)
  800843:	85 c9                	test   %ecx,%ecx
  800845:	74 2c                	je     800873 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800847:	8b 45 14             	mov    0x14(%ebp),%eax
  80084a:	8b 10                	mov    (%eax),%edx
  80084c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800851:	8d 40 04             	lea    0x4(%eax),%eax
  800854:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800857:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80085c:	eb 54                	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80085e:	8b 45 14             	mov    0x14(%ebp),%eax
  800861:	8b 10                	mov    (%eax),%edx
  800863:	8b 48 04             	mov    0x4(%eax),%ecx
  800866:	8d 40 08             	lea    0x8(%eax),%eax
  800869:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80086c:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  800871:	eb 3f                	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8b 10                	mov    (%eax),%edx
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800883:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800888:	eb 28                	jmp    8008b2 <vprintfmt+0x38c>
			putch('0', putdat);
  80088a:	83 ec 08             	sub    $0x8,%esp
  80088d:	53                   	push   %ebx
  80088e:	6a 30                	push   $0x30
  800890:	ff d6                	call   *%esi
			putch('x', putdat);
  800892:	83 c4 08             	add    $0x8,%esp
  800895:	53                   	push   %ebx
  800896:	6a 78                	push   $0x78
  800898:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089a:	8b 45 14             	mov    0x14(%ebp),%eax
  80089d:	8b 10                	mov    (%eax),%edx
  80089f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a4:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a7:	8d 40 04             	lea    0x4(%eax),%eax
  8008aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ad:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008b2:	83 ec 0c             	sub    $0xc,%esp
  8008b5:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8008b9:	57                   	push   %edi
  8008ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8008bd:	50                   	push   %eax
  8008be:	51                   	push   %ecx
  8008bf:	52                   	push   %edx
  8008c0:	89 da                	mov    %ebx,%edx
  8008c2:	89 f0                	mov    %esi,%eax
  8008c4:	e8 72 fb ff ff       	call   80043b <printnum>
			break;
  8008c9:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8008cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8008cf:	83 c7 01             	add    $0x1,%edi
  8008d2:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008d6:	83 f8 25             	cmp    $0x25,%eax
  8008d9:	0f 84 62 fc ff ff    	je     800541 <vprintfmt+0x1b>
			if (ch == '\0')										
  8008df:	85 c0                	test   %eax,%eax
  8008e1:	0f 84 8b 00 00 00    	je     800972 <vprintfmt+0x44c>
			putch(ch, putdat);
  8008e7:	83 ec 08             	sub    $0x8,%esp
  8008ea:	53                   	push   %ebx
  8008eb:	50                   	push   %eax
  8008ec:	ff d6                	call   *%esi
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	eb dc                	jmp    8008cf <vprintfmt+0x3a9>
	if (lflag >= 2)
  8008f3:	83 f9 01             	cmp    $0x1,%ecx
  8008f6:	7f 1b                	jg     800913 <vprintfmt+0x3ed>
	else if (lflag)
  8008f8:	85 c9                	test   %ecx,%ecx
  8008fa:	74 2c                	je     800928 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  8008fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ff:	8b 10                	mov    (%eax),%edx
  800901:	b9 00 00 00 00       	mov    $0x0,%ecx
  800906:	8d 40 04             	lea    0x4(%eax),%eax
  800909:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80090c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800911:	eb 9f                	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800913:	8b 45 14             	mov    0x14(%ebp),%eax
  800916:	8b 10                	mov    (%eax),%edx
  800918:	8b 48 04             	mov    0x4(%eax),%ecx
  80091b:	8d 40 08             	lea    0x8(%eax),%eax
  80091e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800921:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800926:	eb 8a                	jmp    8008b2 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800928:	8b 45 14             	mov    0x14(%ebp),%eax
  80092b:	8b 10                	mov    (%eax),%edx
  80092d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800932:	8d 40 04             	lea    0x4(%eax),%eax
  800935:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800938:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80093d:	e9 70 ff ff ff       	jmp    8008b2 <vprintfmt+0x38c>
			putch(ch, putdat);
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	53                   	push   %ebx
  800946:	6a 25                	push   $0x25
  800948:	ff d6                	call   *%esi
			break;
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	e9 7a ff ff ff       	jmp    8008cc <vprintfmt+0x3a6>
			putch('%', putdat);
  800952:	83 ec 08             	sub    $0x8,%esp
  800955:	53                   	push   %ebx
  800956:	6a 25                	push   $0x25
  800958:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80095a:	83 c4 10             	add    $0x10,%esp
  80095d:	89 f8                	mov    %edi,%eax
  80095f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800963:	74 05                	je     80096a <vprintfmt+0x444>
  800965:	83 e8 01             	sub    $0x1,%eax
  800968:	eb f5                	jmp    80095f <vprintfmt+0x439>
  80096a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80096d:	e9 5a ff ff ff       	jmp    8008cc <vprintfmt+0x3a6>
}
  800972:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5f                   	pop    %edi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80097a:	f3 0f 1e fb          	endbr32 
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	83 ec 18             	sub    $0x18,%esp
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80098a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80098d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800991:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800994:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80099b:	85 c0                	test   %eax,%eax
  80099d:	74 26                	je     8009c5 <vsnprintf+0x4b>
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	7e 22                	jle    8009c5 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009a3:	ff 75 14             	pushl  0x14(%ebp)
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ac:	50                   	push   %eax
  8009ad:	68 e4 04 80 00       	push   $0x8004e4
  8009b2:	e8 6f fb ff ff       	call   800526 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009c0:	83 c4 10             	add    $0x10,%esp
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    
		return -E_INVAL;
  8009c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8009ca:	eb f7                	jmp    8009c3 <vsnprintf+0x49>

008009cc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009cc:	f3 0f 1e fb          	endbr32 
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009d6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009d9:	50                   	push   %eax
  8009da:	ff 75 10             	pushl  0x10(%ebp)
  8009dd:	ff 75 0c             	pushl  0xc(%ebp)
  8009e0:	ff 75 08             	pushl  0x8(%ebp)
  8009e3:	e8 92 ff ff ff       	call   80097a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ea:	f3 0f 1e fb          	endbr32 
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009fd:	74 05                	je     800a04 <strlen+0x1a>
		n++;
  8009ff:	83 c0 01             	add    $0x1,%eax
  800a02:	eb f5                	jmp    8009f9 <strlen+0xf>
	return n;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a06:	f3 0f 1e fb          	endbr32 
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
  800a18:	39 d0                	cmp    %edx,%eax
  800a1a:	74 0d                	je     800a29 <strnlen+0x23>
  800a1c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a20:	74 05                	je     800a27 <strnlen+0x21>
		n++;
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	eb f1                	jmp    800a18 <strnlen+0x12>
  800a27:	89 c2                	mov    %eax,%edx
	return n;
}
  800a29:	89 d0                	mov    %edx,%eax
  800a2b:	5d                   	pop    %ebp
  800a2c:	c3                   	ret    

00800a2d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	53                   	push   %ebx
  800a35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a38:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a44:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	84 d2                	test   %dl,%dl
  800a4c:	75 f2                	jne    800a40 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a4e:	89 c8                	mov    %ecx,%eax
  800a50:	5b                   	pop    %ebx
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a53:	f3 0f 1e fb          	endbr32 
  800a57:	55                   	push   %ebp
  800a58:	89 e5                	mov    %esp,%ebp
  800a5a:	53                   	push   %ebx
  800a5b:	83 ec 10             	sub    $0x10,%esp
  800a5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a61:	53                   	push   %ebx
  800a62:	e8 83 ff ff ff       	call   8009ea <strlen>
  800a67:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a6a:	ff 75 0c             	pushl  0xc(%ebp)
  800a6d:	01 d8                	add    %ebx,%eax
  800a6f:	50                   	push   %eax
  800a70:	e8 b8 ff ff ff       	call   800a2d <strcpy>
	return dst;
}
  800a75:	89 d8                	mov    %ebx,%eax
  800a77:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7a:	c9                   	leave  
  800a7b:	c3                   	ret    

00800a7c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	8b 75 08             	mov    0x8(%ebp),%esi
  800a88:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8b:	89 f3                	mov    %esi,%ebx
  800a8d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a90:	89 f0                	mov    %esi,%eax
  800a92:	39 d8                	cmp    %ebx,%eax
  800a94:	74 11                	je     800aa7 <strncpy+0x2b>
		*dst++ = *src;
  800a96:	83 c0 01             	add    $0x1,%eax
  800a99:	0f b6 0a             	movzbl (%edx),%ecx
  800a9c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a9f:	80 f9 01             	cmp    $0x1,%cl
  800aa2:	83 da ff             	sbb    $0xffffffff,%edx
  800aa5:	eb eb                	jmp    800a92 <strncpy+0x16>
	}
	return ret;
}
  800aa7:	89 f0                	mov    %esi,%eax
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5d                   	pop    %ebp
  800aac:	c3                   	ret    

00800aad <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aad:	f3 0f 1e fb          	endbr32 
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	56                   	push   %esi
  800ab5:	53                   	push   %ebx
  800ab6:	8b 75 08             	mov    0x8(%ebp),%esi
  800ab9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abc:	8b 55 10             	mov    0x10(%ebp),%edx
  800abf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac1:	85 d2                	test   %edx,%edx
  800ac3:	74 21                	je     800ae6 <strlcpy+0x39>
  800ac5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ac9:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800acb:	39 c2                	cmp    %eax,%edx
  800acd:	74 14                	je     800ae3 <strlcpy+0x36>
  800acf:	0f b6 19             	movzbl (%ecx),%ebx
  800ad2:	84 db                	test   %bl,%bl
  800ad4:	74 0b                	je     800ae1 <strlcpy+0x34>
			*dst++ = *src++;
  800ad6:	83 c1 01             	add    $0x1,%ecx
  800ad9:	83 c2 01             	add    $0x1,%edx
  800adc:	88 5a ff             	mov    %bl,-0x1(%edx)
  800adf:	eb ea                	jmp    800acb <strlcpy+0x1e>
  800ae1:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ae3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae6:	29 f0                	sub    %esi,%eax
}
  800ae8:	5b                   	pop    %ebx
  800ae9:	5e                   	pop    %esi
  800aea:	5d                   	pop    %ebp
  800aeb:	c3                   	ret    

00800aec <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aec:	f3 0f 1e fb          	endbr32 
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800af9:	0f b6 01             	movzbl (%ecx),%eax
  800afc:	84 c0                	test   %al,%al
  800afe:	74 0c                	je     800b0c <strcmp+0x20>
  800b00:	3a 02                	cmp    (%edx),%al
  800b02:	75 08                	jne    800b0c <strcmp+0x20>
		p++, q++;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	83 c2 01             	add    $0x1,%edx
  800b0a:	eb ed                	jmp    800af9 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0c:	0f b6 c0             	movzbl %al,%eax
  800b0f:	0f b6 12             	movzbl (%edx),%edx
  800b12:	29 d0                	sub    %edx,%eax
}
  800b14:	5d                   	pop    %ebp
  800b15:	c3                   	ret    

00800b16 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b16:	f3 0f 1e fb          	endbr32 
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	53                   	push   %ebx
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b29:	eb 06                	jmp    800b31 <strncmp+0x1b>
		n--, p++, q++;
  800b2b:	83 c0 01             	add    $0x1,%eax
  800b2e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b31:	39 d8                	cmp    %ebx,%eax
  800b33:	74 16                	je     800b4b <strncmp+0x35>
  800b35:	0f b6 08             	movzbl (%eax),%ecx
  800b38:	84 c9                	test   %cl,%cl
  800b3a:	74 04                	je     800b40 <strncmp+0x2a>
  800b3c:	3a 0a                	cmp    (%edx),%cl
  800b3e:	74 eb                	je     800b2b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b40:	0f b6 00             	movzbl (%eax),%eax
  800b43:	0f b6 12             	movzbl (%edx),%edx
  800b46:	29 d0                	sub    %edx,%eax
}
  800b48:	5b                   	pop    %ebx
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    
		return 0;
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b50:	eb f6                	jmp    800b48 <strncmp+0x32>

00800b52 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b52:	f3 0f 1e fb          	endbr32 
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b60:	0f b6 10             	movzbl (%eax),%edx
  800b63:	84 d2                	test   %dl,%dl
  800b65:	74 09                	je     800b70 <strchr+0x1e>
		if (*s == c)
  800b67:	38 ca                	cmp    %cl,%dl
  800b69:	74 0a                	je     800b75 <strchr+0x23>
	for (; *s; s++)
  800b6b:	83 c0 01             	add    $0x1,%eax
  800b6e:	eb f0                	jmp    800b60 <strchr+0xe>
			return (char *) s;
	return 0;
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b75:	5d                   	pop    %ebp
  800b76:	c3                   	ret    

00800b77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b77:	f3 0f 1e fb          	endbr32 
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b85:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b88:	38 ca                	cmp    %cl,%dl
  800b8a:	74 09                	je     800b95 <strfind+0x1e>
  800b8c:	84 d2                	test   %dl,%dl
  800b8e:	74 05                	je     800b95 <strfind+0x1e>
	for (; *s; s++)
  800b90:	83 c0 01             	add    $0x1,%eax
  800b93:	eb f0                	jmp    800b85 <strfind+0xe>
			break;
	return (char *) s;
}
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ba4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	74 31                	je     800bdc <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bab:	89 f8                	mov    %edi,%eax
  800bad:	09 c8                	or     %ecx,%eax
  800baf:	a8 03                	test   $0x3,%al
  800bb1:	75 23                	jne    800bd6 <memset+0x3f>
		c &= 0xFF;
  800bb3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb7:	89 d3                	mov    %edx,%ebx
  800bb9:	c1 e3 08             	shl    $0x8,%ebx
  800bbc:	89 d0                	mov    %edx,%eax
  800bbe:	c1 e0 18             	shl    $0x18,%eax
  800bc1:	89 d6                	mov    %edx,%esi
  800bc3:	c1 e6 10             	shl    $0x10,%esi
  800bc6:	09 f0                	or     %esi,%eax
  800bc8:	09 c2                	or     %eax,%edx
  800bca:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bcc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800bcf:	89 d0                	mov    %edx,%eax
  800bd1:	fc                   	cld    
  800bd2:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd4:	eb 06                	jmp    800bdc <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd9:	fc                   	cld    
  800bda:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	5b                   	pop    %ebx
  800bdf:	5e                   	pop    %esi
  800be0:	5f                   	pop    %edi
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be3:	f3 0f 1e fb          	endbr32 
  800be7:	55                   	push   %ebp
  800be8:	89 e5                	mov    %esp,%ebp
  800bea:	57                   	push   %edi
  800beb:	56                   	push   %esi
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf5:	39 c6                	cmp    %eax,%esi
  800bf7:	73 32                	jae    800c2b <memmove+0x48>
  800bf9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bfc:	39 c2                	cmp    %eax,%edx
  800bfe:	76 2b                	jbe    800c2b <memmove+0x48>
		s += n;
		d += n;
  800c00:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c03:	89 fe                	mov    %edi,%esi
  800c05:	09 ce                	or     %ecx,%esi
  800c07:	09 d6                	or     %edx,%esi
  800c09:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c0f:	75 0e                	jne    800c1f <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c11:	83 ef 04             	sub    $0x4,%edi
  800c14:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c17:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c1a:	fd                   	std    
  800c1b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c1d:	eb 09                	jmp    800c28 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c1f:	83 ef 01             	sub    $0x1,%edi
  800c22:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c25:	fd                   	std    
  800c26:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c28:	fc                   	cld    
  800c29:	eb 1a                	jmp    800c45 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2b:	89 c2                	mov    %eax,%edx
  800c2d:	09 ca                	or     %ecx,%edx
  800c2f:	09 f2                	or     %esi,%edx
  800c31:	f6 c2 03             	test   $0x3,%dl
  800c34:	75 0a                	jne    800c40 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c36:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	fc                   	cld    
  800c3c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c3e:	eb 05                	jmp    800c45 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c40:	89 c7                	mov    %eax,%edi
  800c42:	fc                   	cld    
  800c43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c45:	5e                   	pop    %esi
  800c46:	5f                   	pop    %edi
  800c47:	5d                   	pop    %ebp
  800c48:	c3                   	ret    

00800c49 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c49:	f3 0f 1e fb          	endbr32 
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c53:	ff 75 10             	pushl  0x10(%ebp)
  800c56:	ff 75 0c             	pushl  0xc(%ebp)
  800c59:	ff 75 08             	pushl  0x8(%ebp)
  800c5c:	e8 82 ff ff ff       	call   800be3 <memmove>
}
  800c61:	c9                   	leave  
  800c62:	c3                   	ret    

00800c63 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c63:	f3 0f 1e fb          	endbr32 
  800c67:	55                   	push   %ebp
  800c68:	89 e5                	mov    %esp,%ebp
  800c6a:	56                   	push   %esi
  800c6b:	53                   	push   %ebx
  800c6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c72:	89 c6                	mov    %eax,%esi
  800c74:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c77:	39 f0                	cmp    %esi,%eax
  800c79:	74 1c                	je     800c97 <memcmp+0x34>
		if (*s1 != *s2)
  800c7b:	0f b6 08             	movzbl (%eax),%ecx
  800c7e:	0f b6 1a             	movzbl (%edx),%ebx
  800c81:	38 d9                	cmp    %bl,%cl
  800c83:	75 08                	jne    800c8d <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c85:	83 c0 01             	add    $0x1,%eax
  800c88:	83 c2 01             	add    $0x1,%edx
  800c8b:	eb ea                	jmp    800c77 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c8d:	0f b6 c1             	movzbl %cl,%eax
  800c90:	0f b6 db             	movzbl %bl,%ebx
  800c93:	29 d8                	sub    %ebx,%eax
  800c95:	eb 05                	jmp    800c9c <memcmp+0x39>
	}

	return 0;
  800c97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9c:	5b                   	pop    %ebx
  800c9d:	5e                   	pop    %esi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    

00800ca0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca0:	f3 0f 1e fb          	endbr32 
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	8b 45 08             	mov    0x8(%ebp),%eax
  800caa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cad:	89 c2                	mov    %eax,%edx
  800caf:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb2:	39 d0                	cmp    %edx,%eax
  800cb4:	73 09                	jae    800cbf <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb6:	38 08                	cmp    %cl,(%eax)
  800cb8:	74 05                	je     800cbf <memfind+0x1f>
	for (; s < ends; s++)
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	eb f3                	jmp    800cb2 <memfind+0x12>
			break;
	return (void *) s;
}
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc1:	f3 0f 1e fb          	endbr32 
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cce:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd1:	eb 03                	jmp    800cd6 <strtol+0x15>
		s++;
  800cd3:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cd6:	0f b6 01             	movzbl (%ecx),%eax
  800cd9:	3c 20                	cmp    $0x20,%al
  800cdb:	74 f6                	je     800cd3 <strtol+0x12>
  800cdd:	3c 09                	cmp    $0x9,%al
  800cdf:	74 f2                	je     800cd3 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ce1:	3c 2b                	cmp    $0x2b,%al
  800ce3:	74 2a                	je     800d0f <strtol+0x4e>
	int neg = 0;
  800ce5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cea:	3c 2d                	cmp    $0x2d,%al
  800cec:	74 2b                	je     800d19 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cee:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf4:	75 0f                	jne    800d05 <strtol+0x44>
  800cf6:	80 39 30             	cmpb   $0x30,(%ecx)
  800cf9:	74 28                	je     800d23 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d02:	0f 44 d8             	cmove  %eax,%ebx
  800d05:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d0d:	eb 46                	jmp    800d55 <strtol+0x94>
		s++;
  800d0f:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d12:	bf 00 00 00 00       	mov    $0x0,%edi
  800d17:	eb d5                	jmp    800cee <strtol+0x2d>
		s++, neg = 1;
  800d19:	83 c1 01             	add    $0x1,%ecx
  800d1c:	bf 01 00 00 00       	mov    $0x1,%edi
  800d21:	eb cb                	jmp    800cee <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d23:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d27:	74 0e                	je     800d37 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d29:	85 db                	test   %ebx,%ebx
  800d2b:	75 d8                	jne    800d05 <strtol+0x44>
		s++, base = 8;
  800d2d:	83 c1 01             	add    $0x1,%ecx
  800d30:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d35:	eb ce                	jmp    800d05 <strtol+0x44>
		s += 2, base = 16;
  800d37:	83 c1 02             	add    $0x2,%ecx
  800d3a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d3f:	eb c4                	jmp    800d05 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d41:	0f be d2             	movsbl %dl,%edx
  800d44:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d47:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4a:	7d 3a                	jge    800d86 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d4c:	83 c1 01             	add    $0x1,%ecx
  800d4f:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d53:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d55:	0f b6 11             	movzbl (%ecx),%edx
  800d58:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d5b:	89 f3                	mov    %esi,%ebx
  800d5d:	80 fb 09             	cmp    $0x9,%bl
  800d60:	76 df                	jbe    800d41 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d62:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d65:	89 f3                	mov    %esi,%ebx
  800d67:	80 fb 19             	cmp    $0x19,%bl
  800d6a:	77 08                	ja     800d74 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d6c:	0f be d2             	movsbl %dl,%edx
  800d6f:	83 ea 57             	sub    $0x57,%edx
  800d72:	eb d3                	jmp    800d47 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d74:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d77:	89 f3                	mov    %esi,%ebx
  800d79:	80 fb 19             	cmp    $0x19,%bl
  800d7c:	77 08                	ja     800d86 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d7e:	0f be d2             	movsbl %dl,%edx
  800d81:	83 ea 37             	sub    $0x37,%edx
  800d84:	eb c1                	jmp    800d47 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d86:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8a:	74 05                	je     800d91 <strtol+0xd0>
		*endptr = (char *) s;
  800d8c:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d8f:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d91:	89 c2                	mov    %eax,%edx
  800d93:	f7 da                	neg    %edx
  800d95:	85 ff                	test   %edi,%edi
  800d97:	0f 45 c2             	cmovne %edx,%eax
}
  800d9a:	5b                   	pop    %ebx
  800d9b:	5e                   	pop    %esi
  800d9c:	5f                   	pop    %edi
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    
  800d9f:	90                   	nop

00800da0 <__udivdi3>:
  800da0:	f3 0f 1e fb          	endbr32 
  800da4:	55                   	push   %ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
  800da8:	83 ec 1c             	sub    $0x1c,%esp
  800dab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800daf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800db3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800db7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dbb:	85 d2                	test   %edx,%edx
  800dbd:	75 19                	jne    800dd8 <__udivdi3+0x38>
  800dbf:	39 f3                	cmp    %esi,%ebx
  800dc1:	76 4d                	jbe    800e10 <__udivdi3+0x70>
  800dc3:	31 ff                	xor    %edi,%edi
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	89 f2                	mov    %esi,%edx
  800dc9:	f7 f3                	div    %ebx
  800dcb:	89 fa                	mov    %edi,%edx
  800dcd:	83 c4 1c             	add    $0x1c,%esp
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5f                   	pop    %edi
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    
  800dd5:	8d 76 00             	lea    0x0(%esi),%esi
  800dd8:	39 f2                	cmp    %esi,%edx
  800dda:	76 14                	jbe    800df0 <__udivdi3+0x50>
  800ddc:	31 ff                	xor    %edi,%edi
  800dde:	31 c0                	xor    %eax,%eax
  800de0:	89 fa                	mov    %edi,%edx
  800de2:	83 c4 1c             	add    $0x1c,%esp
  800de5:	5b                   	pop    %ebx
  800de6:	5e                   	pop    %esi
  800de7:	5f                   	pop    %edi
  800de8:	5d                   	pop    %ebp
  800de9:	c3                   	ret    
  800dea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800df0:	0f bd fa             	bsr    %edx,%edi
  800df3:	83 f7 1f             	xor    $0x1f,%edi
  800df6:	75 48                	jne    800e40 <__udivdi3+0xa0>
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	72 06                	jb     800e02 <__udivdi3+0x62>
  800dfc:	31 c0                	xor    %eax,%eax
  800dfe:	39 eb                	cmp    %ebp,%ebx
  800e00:	77 de                	ja     800de0 <__udivdi3+0x40>
  800e02:	b8 01 00 00 00       	mov    $0x1,%eax
  800e07:	eb d7                	jmp    800de0 <__udivdi3+0x40>
  800e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e10:	89 d9                	mov    %ebx,%ecx
  800e12:	85 db                	test   %ebx,%ebx
  800e14:	75 0b                	jne    800e21 <__udivdi3+0x81>
  800e16:	b8 01 00 00 00       	mov    $0x1,%eax
  800e1b:	31 d2                	xor    %edx,%edx
  800e1d:	f7 f3                	div    %ebx
  800e1f:	89 c1                	mov    %eax,%ecx
  800e21:	31 d2                	xor    %edx,%edx
  800e23:	89 f0                	mov    %esi,%eax
  800e25:	f7 f1                	div    %ecx
  800e27:	89 c6                	mov    %eax,%esi
  800e29:	89 e8                	mov    %ebp,%eax
  800e2b:	89 f7                	mov    %esi,%edi
  800e2d:	f7 f1                	div    %ecx
  800e2f:	89 fa                	mov    %edi,%edx
  800e31:	83 c4 1c             	add    $0x1c,%esp
  800e34:	5b                   	pop    %ebx
  800e35:	5e                   	pop    %esi
  800e36:	5f                   	pop    %edi
  800e37:	5d                   	pop    %ebp
  800e38:	c3                   	ret    
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 f9                	mov    %edi,%ecx
  800e42:	b8 20 00 00 00       	mov    $0x20,%eax
  800e47:	29 f8                	sub    %edi,%eax
  800e49:	d3 e2                	shl    %cl,%edx
  800e4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	d3 ea                	shr    %cl,%edx
  800e55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e59:	09 d1                	or     %edx,%ecx
  800e5b:	89 f2                	mov    %esi,%edx
  800e5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e61:	89 f9                	mov    %edi,%ecx
  800e63:	d3 e3                	shl    %cl,%ebx
  800e65:	89 c1                	mov    %eax,%ecx
  800e67:	d3 ea                	shr    %cl,%edx
  800e69:	89 f9                	mov    %edi,%ecx
  800e6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e6f:	89 eb                	mov    %ebp,%ebx
  800e71:	d3 e6                	shl    %cl,%esi
  800e73:	89 c1                	mov    %eax,%ecx
  800e75:	d3 eb                	shr    %cl,%ebx
  800e77:	09 de                	or     %ebx,%esi
  800e79:	89 f0                	mov    %esi,%eax
  800e7b:	f7 74 24 08          	divl   0x8(%esp)
  800e7f:	89 d6                	mov    %edx,%esi
  800e81:	89 c3                	mov    %eax,%ebx
  800e83:	f7 64 24 0c          	mull   0xc(%esp)
  800e87:	39 d6                	cmp    %edx,%esi
  800e89:	72 15                	jb     800ea0 <__udivdi3+0x100>
  800e8b:	89 f9                	mov    %edi,%ecx
  800e8d:	d3 e5                	shl    %cl,%ebp
  800e8f:	39 c5                	cmp    %eax,%ebp
  800e91:	73 04                	jae    800e97 <__udivdi3+0xf7>
  800e93:	39 d6                	cmp    %edx,%esi
  800e95:	74 09                	je     800ea0 <__udivdi3+0x100>
  800e97:	89 d8                	mov    %ebx,%eax
  800e99:	31 ff                	xor    %edi,%edi
  800e9b:	e9 40 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800ea0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ea3:	31 ff                	xor    %edi,%edi
  800ea5:	e9 36 ff ff ff       	jmp    800de0 <__udivdi3+0x40>
  800eaa:	66 90                	xchg   %ax,%ax
  800eac:	66 90                	xchg   %ax,%ax
  800eae:	66 90                	xchg   %ax,%ax

00800eb0 <__umoddi3>:
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	57                   	push   %edi
  800eb6:	56                   	push   %esi
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 1c             	sub    $0x1c,%esp
  800ebb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800ebf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ec3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ec7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	75 19                	jne    800ee8 <__umoddi3+0x38>
  800ecf:	39 df                	cmp    %ebx,%edi
  800ed1:	76 5d                	jbe    800f30 <__umoddi3+0x80>
  800ed3:	89 f0                	mov    %esi,%eax
  800ed5:	89 da                	mov    %ebx,%edx
  800ed7:	f7 f7                	div    %edi
  800ed9:	89 d0                	mov    %edx,%eax
  800edb:	31 d2                	xor    %edx,%edx
  800edd:	83 c4 1c             	add    $0x1c,%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    
  800ee5:	8d 76 00             	lea    0x0(%esi),%esi
  800ee8:	89 f2                	mov    %esi,%edx
  800eea:	39 d8                	cmp    %ebx,%eax
  800eec:	76 12                	jbe    800f00 <__umoddi3+0x50>
  800eee:	89 f0                	mov    %esi,%eax
  800ef0:	89 da                	mov    %ebx,%edx
  800ef2:	83 c4 1c             	add    $0x1c,%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    
  800efa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f00:	0f bd e8             	bsr    %eax,%ebp
  800f03:	83 f5 1f             	xor    $0x1f,%ebp
  800f06:	75 50                	jne    800f58 <__umoddi3+0xa8>
  800f08:	39 d8                	cmp    %ebx,%eax
  800f0a:	0f 82 e0 00 00 00    	jb     800ff0 <__umoddi3+0x140>
  800f10:	89 d9                	mov    %ebx,%ecx
  800f12:	39 f7                	cmp    %esi,%edi
  800f14:	0f 86 d6 00 00 00    	jbe    800ff0 <__umoddi3+0x140>
  800f1a:	89 d0                	mov    %edx,%eax
  800f1c:	89 ca                	mov    %ecx,%edx
  800f1e:	83 c4 1c             	add    $0x1c,%esp
  800f21:	5b                   	pop    %ebx
  800f22:	5e                   	pop    %esi
  800f23:	5f                   	pop    %edi
  800f24:	5d                   	pop    %ebp
  800f25:	c3                   	ret    
  800f26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f2d:	8d 76 00             	lea    0x0(%esi),%esi
  800f30:	89 fd                	mov    %edi,%ebp
  800f32:	85 ff                	test   %edi,%edi
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x91>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f7                	div    %edi
  800f3f:	89 c5                	mov    %eax,%ebp
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f5                	div    %ebp
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	f7 f5                	div    %ebp
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	eb 8c                	jmp    800edd <__umoddi3+0x2d>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	89 e9                	mov    %ebp,%ecx
  800f5a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f5f:	29 ea                	sub    %ebp,%edx
  800f61:	d3 e0                	shl    %cl,%eax
  800f63:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f67:	89 d1                	mov    %edx,%ecx
  800f69:	89 f8                	mov    %edi,%eax
  800f6b:	d3 e8                	shr    %cl,%eax
  800f6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f71:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f75:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f79:	09 c1                	or     %eax,%ecx
  800f7b:	89 d8                	mov    %ebx,%eax
  800f7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f81:	89 e9                	mov    %ebp,%ecx
  800f83:	d3 e7                	shl    %cl,%edi
  800f85:	89 d1                	mov    %edx,%ecx
  800f87:	d3 e8                	shr    %cl,%eax
  800f89:	89 e9                	mov    %ebp,%ecx
  800f8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800f8f:	d3 e3                	shl    %cl,%ebx
  800f91:	89 c7                	mov    %eax,%edi
  800f93:	89 d1                	mov    %edx,%ecx
  800f95:	89 f0                	mov    %esi,%eax
  800f97:	d3 e8                	shr    %cl,%eax
  800f99:	89 e9                	mov    %ebp,%ecx
  800f9b:	89 fa                	mov    %edi,%edx
  800f9d:	d3 e6                	shl    %cl,%esi
  800f9f:	09 d8                	or     %ebx,%eax
  800fa1:	f7 74 24 08          	divl   0x8(%esp)
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	89 f3                	mov    %esi,%ebx
  800fa9:	f7 64 24 0c          	mull   0xc(%esp)
  800fad:	89 c6                	mov    %eax,%esi
  800faf:	89 d7                	mov    %edx,%edi
  800fb1:	39 d1                	cmp    %edx,%ecx
  800fb3:	72 06                	jb     800fbb <__umoddi3+0x10b>
  800fb5:	75 10                	jne    800fc7 <__umoddi3+0x117>
  800fb7:	39 c3                	cmp    %eax,%ebx
  800fb9:	73 0c                	jae    800fc7 <__umoddi3+0x117>
  800fbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fc3:	89 d7                	mov    %edx,%edi
  800fc5:	89 c6                	mov    %eax,%esi
  800fc7:	89 ca                	mov    %ecx,%edx
  800fc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fce:	29 f3                	sub    %esi,%ebx
  800fd0:	19 fa                	sbb    %edi,%edx
  800fd2:	89 d0                	mov    %edx,%eax
  800fd4:	d3 e0                	shl    %cl,%eax
  800fd6:	89 e9                	mov    %ebp,%ecx
  800fd8:	d3 eb                	shr    %cl,%ebx
  800fda:	d3 ea                	shr    %cl,%edx
  800fdc:	09 d8                	or     %ebx,%eax
  800fde:	83 c4 1c             	add    $0x1c,%esp
  800fe1:	5b                   	pop    %ebx
  800fe2:	5e                   	pop    %esi
  800fe3:	5f                   	pop    %edi
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
  800fe6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fed:	8d 76 00             	lea    0x0(%esi),%esi
  800ff0:	29 fe                	sub    %edi,%esi
  800ff2:	19 c3                	sbb    %eax,%ebx
  800ff4:	89 f2                	mov    %esi,%edx
  800ff6:	89 d9                	mov    %ebx,%ecx
  800ff8:	e9 1d ff ff ff       	jmp    800f1a <__umoddi3+0x6a>
