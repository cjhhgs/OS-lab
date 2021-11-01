#include <stdio.h>
#include <semaphore.h>
#include <pthread.h>
#include <unistd.h>
#include <time.h>
#define N 4     //等待区椅子数量

void getDateTime();

sem_t customers;
sem_t barbers;
sem_t mutex,mutex2;

int waiting;
int now;


void getDateTime(){
	time_t t;
    time(&t);
    struct tm * lt;
    lt = localtime(&t);
    
    printf("%2d:%2d:%2d\t",lt->tm_hour,lt->tm_min,lt->tm_sec);
}

void barber(){
    getDateTime();
    printf("barber线程启动:\n");
    getDateTime();
    printf("理发师在睡觉\n");
    while(1){           //循环
        sem_wait(&customers);//等待有客人来才开始工作，customers初值为0，来一个客人+1
        
        sem_wait(&mutex2);  //等客人坐上理发椅才开始理发，需加锁，不然会出现先理发,客人再坐上理发椅
        getDateTime();
        printf("为顾客%d理发\n",now);
        sleep(5);     //理发需要的时间（s）

        sem_wait(&mutex);//检查waiting，是否还有等待的客人
        if(waiting==0){ //没有在等待的客人，理发师就可以休息了
            getDateTime();
            printf("无等待顾客，理发师睡觉\n");
        }
        sem_post(&mutex);

        sem_post(&barbers); //客人离开,理发椅空出，mutex2解锁
        getDateTime();
        printf("顾客%d离开\n",now);
    }
}

void customer(void *arg){
    int num = (int)arg;     //传入参数为客人编号
    sem_wait(&mutex);       //获取waiting的锁
    if(waiting < N){    //有空位，可以进入
        getDateTime();
        printf("顾客%d进入理发店\n",num);
        waiting = waiting + 1;  //等待的人数增加
        sem_post(&mutex);
        sem_post(&customers);   //顾客数增加，第一个客人可以唤醒理发师

        sem_wait(&barbers);     //客人等待坐上理发椅子

        sem_wait(&mutex);
        waiting = waiting -1;   //客人坐上理发椅,等待列表-1
        sem_post(&mutex);
        getDateTime();
        printf("顾客%d坐上理发椅\n",num);

        now = num;//现在在理发的是几号客人
        sem_post(&mutex2);      //表示客人坐上位置了，理发师可以开始理发
    }
    else{//没有空位，就离开
        getDateTime();
        printf("由于人满，顾客%d离开\n",num);
        sem_post(&mutex);
        
    }
}

int main(){
    //init sem
    waiting = 0;
    sem_init(&customers,0,0);   //店内顾客数量，影响理发师是否工作
    sem_init(&barbers,0,1);     //理发椅是否空
    sem_init(&mutex,0,1);       //对waiting的锁
    sem_init(&mutex2,0,0);      //理发师需等顾客坐上椅子才开始理发的锁


    getDateTime();
    printf("main线程启动:\n");
    pthread_t p1[3];
    pthread_t p2;
    
    pthread_create(&p2,NULL,barber,NULL);   //开启barber线程
    int i=0;
    int cus_num =8;    //顾客数量

    srand((unsigned)time(NULL));
    int a;
    for(i=0;i<cus_num;i++){
        a=rand()%6+1;       //1~6
        sleep(a);
        pthread_create(&(p1[i]),NULL,customer,(void *)i);
    }
    

    pthread_join(p2,NULL);
    for(i=0;i<cus_num;i++){
        
        pthread_join(p1[i],NULL);
    }
    
    
}

//gcc -o 3_1.out 3_1.c -lpthread
// ./3_1.out