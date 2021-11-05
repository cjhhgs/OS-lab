#include "philosopher.h"

void philosopher(void * philosopherNumber) {
	while (1) {
		int Number = *(int*)(philosopherNumber);
		think(Number);
		pickUp(Number);
		eat(Number);
		putDown(Number);
	}
}

void think(int philosopherNumber) {
	int sleepTime = rand() % 3 + 1;
	printf("Philosopher %d will think for %d seconds\n", philosopherNumber, sleepTime);
	sleep(sleepTime);
}

void pickUp(int philosopherNumber) {
    /*Your code here*/
	pthread_mutex_lock(&mutex_all);
	pthread_mutex_lock(&chopsticks[philosopherNumber]);
	pthread_mutex_lock(&chopsticks[(philosopherNumber+1)%5]);
	pthread_mutex_unlock(&mutex_all);
}

void eat(int philosopherNumber) {
	int eatTime = rand() % 3 + 1;
	printf("Philosopher %d will eat for %d seconds\n", philosopherNumber, eatTime);
	sleep(eatTime);
}

void putDown(int philosopherNumber) {
    /*Your code here*/
	pthread_mutex_unlock(&chopsticks[philosopherNumber]);
	pthread_mutex_unlock(&chopsticks[(philosopherNumber+1)%5]);
}