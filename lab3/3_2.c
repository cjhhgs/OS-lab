#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

sem_t mutex1;

time_t end_time;

void broadcast(){
    while(time(NULL)<end_time){ //达到设定最大时间结束放映
        
        sem_wait(&mutex1);//等待第一个用户进场，开始循环放映

        int i = 0;
        for(i=0;1;i = (i+1)%3){
            
        }

    }
}