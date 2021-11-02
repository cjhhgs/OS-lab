#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

sem_t mutex1;
sem_t mutex_user[3];

time_t end_time;
int user_num[3]={0};

int if_have_user(){
    int res = 1;
    int i;
    for(i=0;i<3;i++)
        sem_wait(mutex_user[i]);
    if(user_num[0]==0&&user_num[1]==0&&user_num[2]==0)
        res = 0;
    return res;
}

void broadcast(){
    while(time(NULL)<end_time){ //达到设定最大时间结束放映
        
        sem_wait(&mutex1);//等待第一个用户进场，开始循环放映

        int i = 0;
        for(i=0;1;i = (i+1)%3){
            //检测影片 i 是否有人要看
            sem_wait(&mutex_user[i]);
            if(user_num[i]!=0){//有人要看这部影片，则放映

            }
            
            else{       //没人排这队，则不放映

            }


        }

    }
}