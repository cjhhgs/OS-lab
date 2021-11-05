#include "philosopher.h"

int main() {
	int i;
	srand(time(NULL));
	pthread_mutex_init(&mutex_all,NULL);
	for (i = 0; i < NUMBER_OF_PHILOSOPHERS; ++i) {
		pthread_mutex_init(&chopsticks[i], NULL);
	}

	for (i = 0; i < NUMBER_OF_PHILOSOPHERS; ++i) {
		pthread_attr_init(&attributes[i]);
	}
	
	for (i = 0; i < NUMBER_OF_PHILOSOPHERS; ++i) {
		int *j = (int*)malloc(sizeof(int));
		*j=i;
		pthread_create(&philosophers[i], NULL, (void *)philosopher, (void *)(j));
	}

	for (i = 0; i < NUMBER_OF_PHILOSOPHERS; ++i) {
		pthread_join(philosophers[i], NULL);
	}
	return 0;
}

