#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
//#include <unistd.h>       //estava usando pra testes (pra usar o usleep)

#define n_threads 3     //numero de threads
#define LIMITE 15       //limite do contador global

int global = 0;         //contador global
sem_t sem[n_threads];

// funcao executada pelas 3 threads "filho"
void* regiaoCritica(void* arg) {
    int id = *(int*)arg;  // pega o id (usado pelo semaforo)

    while (1) {
        sem_wait(&sem[id]);  // espera a sua vez

        if (global >= LIMITE) {     //testa se chegou no limite do contador global
            sem_post(&sem[(id + 1) % n_threads]);  // libera o proximo semaforo/thread (evita travar(deadlock) a proxima)
            pthread_exit(NULL);     // encerra a thread atual
        }

        global++;
        printf("thread %d: global = %d\n", id, global);

        sem_post(&sem[(id + 1) % n_threads]);  // libera o proximo semaforo/thread

        //usleep(100000);  // pausa curta so pra visualizar melhor
    }

    return NULL;
}

void* thread_principal(void* arg) {
    pthread_t threads[n_threads];   //vetor de threads "filho"
    int ids[n_threads];             //auxiliar para identificar as threads/semaforos

    for (int i = 0; i < n_threads; i++) {
        sem_init(&sem[i], 0, 0);    //inicializa os semaforos com valor zero
    }

    sem_post(&sem[0]);              // libera a thread 0 para comecar

    // cria as 3 threads "filho"
    for (int i = 0; i < n_threads; i++) {
        ids[i] = i;
        pthread_create(&threads[i], NULL, regiaoCritica, &ids[i]);
    }
    // espera todas threads terminarem
    for (int i = 0; i < n_threads; i++) {
        pthread_join(threads[i], NULL);
    }
    // destroi os semaforos
    for (int i = 0; i < n_threads; i++) {
        sem_destroy(&sem[i]);
    }

    return NULL;
}

int main() {
    pthread_t principal;  // a thread "pai"

    pthread_create(&principal, NULL, thread_principal, NULL); // cria a thread principal e chama a funçao
    pthread_join(principal, NULL);// espera a thread principal terminar

    return 0;
}
