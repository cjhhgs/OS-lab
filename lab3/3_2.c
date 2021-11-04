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
int film_time[3]={10,10,10};
int cur_movie;

int if_have_user(){
    int res = 1;
    int i;
    //查看全部3个队列是否有人
    for(i=0;i<3;i++)
        sem_wait(&mutex_user[i]);
    if(user_num[0]==0&&user_num[1]==0&&user_num[2]==0)
        res = 0;
    for(i=2;i>=0;i--)
        sem_post(&mutex_user[i]);
    return res;
}

void broadcast(){
    while(time(NULL)<end_time){ //达到设定最大时间结束放映
        printf("直播间休息中")；
        
        sem_wait(&mutex1);//等待第一个用户进场，开始循环放映

        int i = cur_movie;  //从第一个用户选择的影片开始放映
        for(;1;i = (i+1)%3){// i 表示当前放映影片序号

            //检测影片 i 是否有人要看
            sem_wait(&mutex_user[i]);
            if(user_num[i]!=0){//有人要看影片i，则放映
                sem_post(&mutex_user[i]);   //查询完，不需要占用锁了

                printf("影片%d开始放映\n",i);
                int cur_end_time = time(NULL)+film_time[i]; //计算影片结束时间

                while(time(NULL)<cur_end_time){ //放映过程，时间到了结束放映
                    sleep(1);   //每秒检测一次观影人数
                    sem_wait(&mutex_user[i]);
                    int cur_user_num = user_num[i];
                    printf("当前观看人数：%d\n",cur_user_num);
                    if(cur_user_num==0){//无人观看，退出
                        printf("影片%d已无人观看\n",i);
                        sem_post(&mutex_user[i]);
                        break;
                    }
                    else{
                        sem_post(&mutex_user[i]);
                    }
                }
                printf("影片%d结束放映\n",i);

            }

            else{       //没人看，则不放映
                sem_post(&mutex_user[i]);
            }

            //检测是否有人在看，没人看直播间就休息
            int flag = if_have_user();
            if(flag==0)
                break;
        }

    }
}