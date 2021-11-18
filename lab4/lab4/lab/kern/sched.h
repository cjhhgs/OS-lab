/* See COPYRIGHT for copyright information. */

#ifndef JOS_KERN_SCHED_H
#define JOS_KERN_SCHED_H
#ifndef JOS_KERNEL
# error "This is a JOS kernel header; user programs should not #include it"
#endif

#define MAXTIME  20

// This function does not return.
void sched_yield(void) __attribute__((noreturn));
void sched_yield2(void) __attribute__((noreturn));

int time_slice;
int limite[4]={1,2,4,20};
int curQ;


#endif	// !JOS_KERN_SCHED_H
