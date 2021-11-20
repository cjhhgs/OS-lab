#include <inc/assert.h>
#include <inc/x86.h>
#include <kern/spinlock.h>
#include <kern/env.h>
#include <kern/pmap.h>
#include <kern/monitor.h>

#define MAXTIME 20
int curTime=0;		//当前时间片
int nexTime=0;		//用于判断是否到了下一个时间片
int curQ=0;			//当前的优先级
const int limite[4]={1,2,4,20};		//各优先级的时间片数

void sched_halt(void);


// MFQ 调度算法
void sched_yield(void)
{
	struct Env *idle;

	int flag =0;
	int j=0;
	if(nexTime>curTime){	//时钟中断会使nexTime+1, 以此判断何种情况调度了sched_yield
		curTime+=1;
		flag=1;
	}

	int start = 0;

	//如果是一个时间片到了。
	if(flag==1){		
		if(curTime == MAXTIME){		//当时间片到了最大20
			//cprintf("max time slice\n");
			curTime=0;		//重置
			nexTime=0;
			curQ=0;
			for(int i=0;i<NENV;i++){	//所有env的优先级变0, 重置runtime
				envs[i].Q=0;
				envs[i].runtime=0;
				
			}
		}

		if(curenv){
			curenv->runtime+=1;
			start= ENVX(curenv->env_id) + 1;
			//如果运行时间到了，优先级降级，换下一个运行
			if(curenv->runtime >= limite[curenv->Q]){
				curenv->Q+=1;
				curenv->runtime = 0;
			}
			//如果还没到，继续运行
			else{
				env_run(curenv);
			}
		}

		//选择下一个运行的env
		for(curQ=0;curQ<4;curQ++){		//优先级从高到低
			for (int i = 0; i < NENV ; i++){	//从curenv的下一个开始选，循环整个数组
				j = (start + i) % NENV;
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)	//不仅要RUNNABLE,还要Q==curQ
				{
					//cprintf("yield %d\n",j);
					env_run(&envs[j]);
				}
			}
			//找了一圈，没有curQ优先级的了，找下一个优先级
		}
		//如果到这里了，说明没找到可以运行的
		if (curenv && curenv->env_status == ENV_RUNNING)
		{
			env_run(curenv);
		}
		sched_halt();
	}

	else{	//没到一个时间片，是env主动放弃
		
		if (curenv)
		{
			start = ENVX(curenv->env_id) + 1; 
		}

		//选择下一个运行的env
		for(curQ=0;curQ<4;curQ++){
			for (int i = 0; i < NENV ; i++){
				j = (start + i) % NENV;
				if (envs[j].env_status == ENV_RUNNABLE && envs[j].Q==curQ)
				{
					//cprintf("yield  %d\n",j);
					env_run(&envs[j]);
				}
			}
		}
		
		if (curenv && curenv->env_status == ENV_RUNNING)
		{
			env_run(curenv);
		}
		sched_halt();
	}

}

//原来的调度算法
// Choose a user environment to run and run it.
void sched_yield2(void)
{
	struct Env *idle;


	// Implement simple round-robin scheduling.
	//
	// Search through 'envs' for an ENV_RUNNABLE environment in
	// circular fashion starting just after the env this CPU was
	// last running.  Switch to the first such environment found.
	//
	// If no envs are runnable, but the environment previously
	// running on this CPU is still ENV_RUNNING, it's okay to
	// choose that environment.
	//
	// Never choose an environment that's currently running on
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.

	int start = 0;
	int j;

	if (curenv)
	{
		start = ENVX(curenv->env_id) + 1; 
	}
	for (int i = 0; i < NENV ; i++)
	{
		j = (start + i) % NENV;
		if (envs[j].env_status == ENV_RUNNABLE )
		{
			//cprintf("yield  %d\n",j);
			env_run(&envs[j]);
		}
	}
	if (curenv && curenv->env_status == ENV_RUNNING)
	{
		env_run(curenv);
	}
	sched_halt();
}

// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void sched_halt(void)
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++)
	{
		if ((envs[i].env_status == ENV_RUNNABLE ||
			 envs[i].env_status == ENV_RUNNING ||
			 envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV)
	{
		cprintf("No runnable environments in the system!\n");
		while (1)
			monitor(NULL);
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
	lcr3(PADDR(kern_pgdir));

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile(
		"movl $0, %%ebp\n"
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		// Uncomment the following line after completing exercise 13
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
		:
		: "a"(thiscpu->cpu_ts.ts_esp0));
}
