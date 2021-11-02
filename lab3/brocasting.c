#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <pthread.h>
#include <semaphore.h>

#define MAX(a,b) (((a) > (b)) ? (a) : (b))

#define DEFAULT_USER_MIN_ONLINE_TIME 5
#define DEFAULT_USER_MAX_ONLINE_TIME 10
#define DEFAULT_USER_MAX_INTERVAL 5
#define DEFAULT_PROCESSING_TIME 40

time_t end_time;
sem_t users_mutex[3];
int user_counter[3] = {0}, is_film_playing[3] = {0};
// 每部纪录片播放用时
int film_time[3] = {4, 10, 8};

int has_user(){
    return user_counter[0] || user_counter[1] || user_counter[2];
}

void brocast_manager(){

    int film_index = -1, i = 0, current_film_time;

    while(time(NULL) < end_time || has_user()){

        // 顺序轮询纪录片是否有用户想要观看
        for(i=(film_index+1)%3; 1; i = (i+1)%3){
            if(user_counter[i] != 0){
                // 准备播放i号纪录片
                film_index = i;
                break;
            }
        }

        current_film_time = time(NULL) + film_time[film_index];
        // 播放该纪录片
        is_film_playing[film_index] = 1;
        printf("[FILM INFO]: The film %d has started!\n", film_index);
        while(time(NULL) < current_film_time && user_counter[film_index]);
        sem_wait(&users_mutex[film_index]);
        is_film_playing[film_index] = 0;
        // 纪录片停止播放，观看该片的用户全部退出
        user_counter[film_index] = 0;
        printf("[FILM INFO]: The film %d stopped!\n", film_index);
        sem_post(&users_mutex[film_index]);

    }

}

void user(void *arg){
    
    // 用户观看纪录片编号
    int index = *((int *)arg);

    sem_wait(&users_mutex[index]);
    printf("A new user for film %d added! current users for film %d: %d\n", index, index, user_counter[index] + 1);
    user_counter[index] ++;
    sem_post(&users_mutex[index]);
    // 用户在线最大时长
    int user_time = time(NULL) + MAX(rand() % DEFAULT_USER_MAX_ONLINE_TIME, DEFAULT_USER_MIN_ONLINE_TIME);
    // 用户等待该纪录片播放
    while(time(NULL) < user_time){
        if(is_film_playing[index]){
            break;
        }
    }

    // 用户观看该纪录片
    while(time(NULL) < user_time && is_film_playing[index]);

    // 用户退出
    sem_wait(&users_mutex[index]);
    printf("A user for film %d quit! current users for film %d: %d\n", index, index, MAX(0, user_counter[index]-1));
    user_counter[index] = MAX(0, user_counter[index]-1);
    sem_post(&users_mutex[index]);

}

// 随机生成用户，并创建用户进程
void user_manager(){

    pthread_t tid;
    pthread_attr_t attr;
    int i=0;

    pthread_attr_setdetachstate(&attr, 1);

    while(time(NULL) < end_time){
        // 随机生成用户想要观看的纪录片序号
        int index = rand()%3;
        pthread_create(&tid, &attr, (void *)user, (void *)&index);
        sleep(rand() % DEFAULT_USER_MAX_INTERVAL);
    }

}

int main(int argc, char* argv[]){
    pthread_t thread_user_manager, thread_brocast_manager;
    end_time = time(NULL) + DEFAULT_PROCESSING_TIME;
    int i;
    for(i=0; i<3; i++){
        sem_init(&users_mutex[i], 0, 1);
        printf("Time for %d: %d\n", i,film_time[i]);
    }

    printf("Starting user_manager and brocast_manager thread...\n");

    pthread_create(&thread_user_manager, NULL, (void *)user_manager, NULL);
    pthread_create(&thread_brocast_manager, NULL, (void *)brocast_manager, NULL);

    pthread_join(thread_user_manager, NULL);
    pthread_join(thread_brocast_manager, NULL);

    printf("working finished!\n");

    return 0;
}