#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

#define PROCESS_TIME 30
#define USER_MAX_ENTER 3
#define USER_MIN_WATCH 1
#define USER_MAX_WATCH 10

sem_t mutex1;
sem_t mutex2;
sem_t mutex_print;
sem_t mutex_user[3];
sem_t mutex_film[3];
sem_t mutex_out[3];

time_t end_time;
int user_num[3]={0,0,0};
int film_time[3]={10,10,10};
int film_state[3]={0,0,0};
int cur_film;

void getDateTime(){
	time_t t;
    time(&t);
    struct tm * lt;
    lt = localtime(&t);
    
    printf("%2d:%2d:%2d\t",lt->tm_hour,lt->tm_min,lt->tm_sec);
}


int if_have_user(){
    int res = 1;
    int i=0;
    //查看全部3个队列是否有人
    for(i=0;i<3;i++)
        sem_wait(&mutex_user[i]);
    if(user_num[0]==0&&user_num[1]==0&&user_num[2]==0)
        res = 0;
    for(i=2;i>=0;i--)
        sem_post(&mutex_user[i]);
    return res;
}

void print_user_num(){
    int i;
    for(i=0;i<3;i++)
        sem_wait(&mutex_user[i]);
    
    sem_wait(&mutex_print);
    
    getDateTime();
    printf("当前影片：%d    ",cur_film+1);
    printf("在线人数：  影片1:%2d    影片2:%2d    影片3:%2d\n",user_num[0],user_num[1],user_num[2]);
    
    sem_post(&mutex_print);

    
    for(i=2;i>=0;i--)
        sem_post(&mutex_user[i]);
}

void broadcast(){
    while(time(NULL)<end_time){ //达到设定最大时间结束放映

        sem_wait(&mutex_print);
        getDateTime();
        printf("直播间休息中，等待用户进入\n");
        sem_post(&mutex_print);
        
        sem_wait(&mutex1);//等待第一个用户进场，开始循环放映
        sem_post(&mutex1);

        int i=0;
        
        for(i=0;1;i = (i+1)%3){// i 表示当前放映影片序号

            //检测影片 i 是否有人要看
            sem_wait(&mutex_user[i]);
            if(user_num[i]!=0){//有人要看影片i，则放映
                sem_post(&mutex_user[i]);   //查询完，不需要占用锁了

                //将该影片设为播放状态
                sem_wait(&mutex_print);
                getDateTime();
                printf("影片%d开始放映\n",i+1);
                sem_post(&mutex_print);

                film_state[i]=1;
                cur_film = i;
                sem_post(&mutex_film[i]);   //开放直播间入口

                
                int cur_end_time = time(NULL)+film_time[i]; //计算影片结束时间

                while(time(NULL)<cur_end_time){ //放映过程，时间到了结束放映
                    //每秒检测一次观影人数
                    
                    print_user_num();
                    

                    sem_wait(&mutex_user[i]);
                    int cur_user_num = user_num[i];
                    if(cur_user_num==0){//无人观看，退出
                        sem_wait(&mutex_print);
                        getDateTime();
                        printf("影片%d已无人观看\n",i+1);
                        sem_post(&mutex_print);

                        sem_post(&mutex_user[i]);
                        break;
                    }
                    else{
                        sem_post(&mutex_user[i]);
                    }
                    sleep(1);
                }

                //将该影片设为停止状态
                sem_wait(&mutex2);  //禁止新用户排队
                
                
                film_state[i]=0;            //将file_state[i]设为0后，现有观众会自行退出
                
                sem_wait(&mutex_print);
                getDateTime();
                if(time(NULL)>=cur_end_time)
                    printf("影片播放完毕，");
                printf("影片%d结束放映\n",i+1);
                sem_post(&mutex_print);

                sem_wait(&mutex_out[i]);    //等待正在观看i的观众全部离开
                sem_post(&mutex_out[i]);
                sem_wait(&mutex_film[i]);   //关闭用户进入直播间的入口
                sem_post(&mutex2);

                //sem_post(&mutex_user[i]);
            }

            else{       //没人看，则不放映
                sem_post(&mutex_user[i]);
            }

            

            //检测是否还有人在排队，没人看直播间就休息
            int flag = if_have_user();
            if(flag==0)
                break;
        }

    }
}

void user(void * arg){

    sem_wait(&mutex2);
    sem_post(&mutex2);
    //用户进入直播间过程
    int film = *((int *)arg);
    sem_wait(&mutex_user[film]);    //访问user_num[i]
    if(user_num[film]==0){          //mutex_out[i]的作用为broadcast进程等待所有观众离开后再切换影片
        sem_wait(&mutex_out[film]); //mutex_out[i]为0时表示还有观众，为1时表示观众全部退出
    }                               //第一个观众进入让其变为0，最后一个退出时将其变为1                               
    user_num[film] ++;              //观影人数加1

    sem_wait(&mutex_print);
    getDateTime();
    printf("影片%d排队+1\n",film+1);
    sem_post(&mutex_print);

    sem_post(&mutex_user[film]);

    sem_post(&mutex1);              //每进一个人就让mutex+1，退出时-1,表示还有没有人在看，控制直播间休息还是继续运行

    // 用户等待该纪录片播放
    sem_wait(&mutex_film[film]);    //等待broadcast进程将mutex_file[i]变为1
    sem_wait(&mutex_print);
    getDateTime();
    printf("1个用户进入直播间%d\n",cur_film+1);
    sem_post(&mutex_print);
    sem_post(&mutex_film[film]);

    
    //观看过程
    int user_time = time(NULL)+rand()%(USER_MAX_WATCH-USER_MIN_WATCH)+USER_MIN_WATCH;
    while(time(NULL)<user_time&&film_state[film]);  //用户观看时间到或影片结束，用户退出


    //用户退出
    sem_wait(&mutex_user[film]);
    user_num[film]--;
    sem_wait(&mutex_print);
    getDateTime();
    printf("1个用户退出直播间%d，直播间剩余人数：%d\n",cur_film+1,user_num[film]);
    sem_post(&mutex_print);
    if(user_num[film]==0){
        sem_post(&mutex_out[film]); //最后一个退出的将mutex_out[i]变1，作用如上所述
    }
    sem_post(&mutex_user[film]);
    sem_wait(&mutex1);
}

void user_manager(){
    pthread_t p;
    pthread_attr_t attr;
    pthread_attr_setdetachstate(&attr, 1);

    while(time(NULL) < end_time){
        // 随机生成纪录片序号
        int * index = (int *) malloc (sizeof(int));
        *index = rand()%3;
        pthread_create(&p, &attr, (void *)user, (void *)index);
        sleep(rand() % USER_MAX_ENTER);
    }
    sleep(1);
}

int main(int argc, char* argv[]){

    pthread_t p1,p2;
    int i;
    for(i=0;i<3;i++){       //初始化信号量
        sem_init(&mutex_user[i],0,1);
        sem_init(&mutex_film[i],0,0);
        sem_init(&mutex_out[i],0,1);
    }

    sem_init(&mutex1,0,0);
    sem_init(&mutex2,0,1);
    sem_init(&mutex_print,0,1);
    end_time = time(NULL)+PROCESS_TIME; //设置进程运行时间
    
    sem_wait(&mutex_print);
    getDateTime();
    printf("broadcast thread starting\n");
    sem_post(&mutex_print);
    pthread_create(&p1,NULL,(void *)broadcast,NULL);//启动直播间进程
    
    sem_wait(&mutex_print);
    getDateTime();
    printf("user thread starting\n");
    sem_post(&mutex_print);
    pthread_create(&p2,NULL,(void *)user_manager,NULL);//启动用户管理员进程


    pthread_join(p2,NULL);
    sem_wait(&mutex_print);
    getDateTime();
    printf("user thread ending, no more new user\n");
    sem_post(&mutex_print);
    pthread_join(p1,NULL);
    sem_wait(&mutex_print);
    getDateTime();
    printf("broadcast thread ending\n");
    sem_post(&mutex_print);

    return 0;
}
//gcc -o 3_2.out 3_2.c -lpthread
// ./3_2.out