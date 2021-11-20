/* See COPYRIGHT for copyright information. */
/*

kern/trap.c
trap_dispatch(){
    ……
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_TIMER)
	{
		nexTime+=1;
		lapic_eoi();
		sched_yield();
		return;
	}

}

kern/env.c
env_alloc(){
    ……
    e->runtime=0;
	e->Q=0;
}


inc/env.h
struct Env{
    ……
    int runtime;
	int Q;
}

*/





#ifndef JOS_KERN_SCHED_H
#define JOS_KERN_SCHED_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

// This function does not return.
void sched_yield(void) __attribute__((noreturn));
void sched_yield2(void) __attribute__((noreturn));




#endif	// !JOS_KERN_SCHED_H
