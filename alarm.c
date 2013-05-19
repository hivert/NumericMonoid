#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include "alarm.h"

#define PERIOD 10
int nloops=0;
void sigalrm_handler( int sig )
{
  printf("\nNloops = %i\n", nloops++);
  progress_report();
  alarm(PERIOD);
}

void start_alarm(void)
{
    struct sigaction sact;

    sigemptyset(&sact.sa_mask);
    sact.sa_flags = 0;
    sact.sa_handler = sigalrm_handler;
    sigaction(SIGALRM, &sact, NULL);

    alarm(PERIOD);
}

