#include <stdio.h>
#include <stdlib.h>

#define N           5           //numero de filosofos
#define LEFT        (i+N-1)%N   //numero do vizinho a esquerda de i
#define RIGHT       (i+1)%N     //numero do vizinho a direita de i
#define THINKING    0           //o filosofo esta pensando
#define HUNGRY      1           //o filosofo esta tentando pegar os garfos
#define EATING      2           //o filosofo esta comendo

typedef int semaphore;          //semaforo são um tipo especial de int
int state[N];                   //arranjo para controlar o estado de cada um
semaphore mutex = 1;            //exclusao mutua para as regioes criticas
semaphore s[N];                 //um semaforo por filosofo

void philosopher(int i){        //i: o numero do filosofo, de 0 a N-1
    while (true)                
    {
        think();
        take_forks(i);
        eat();
        put_forks(i);
    }
    
}

void take_forks(int i){         //i: o numero do filosofo, de 0 a N-1
    down(&mutex);
    state[i] = HUNGRY;
    test(i);
    up(&mutex);
    down(&s[i]);
}

void put_forks(i){
    down(&mutex);
    state[i] = THINKING;
    test(LEFT);
    test(RIGHT);
    up(&mutex);
}

void test(i){                   //i: o numero do filosofo, de 0 a N-1
    if(state[i] == HUNGRY && state[LEFT] != EATING && state[RIGHT] != EATING){
        state[i] = EATING;
        up(&s[i]);
    }
}


int main(){
	philosopher(N);
}
