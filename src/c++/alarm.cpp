#include <unistd.h>
#include <signal.h>
#include <stdio.h>
#include "alarm.hpp"

int nloops=0;
void sigalrm_handler( int sig )
{
  printf("\nProgress report no %i\n", nloops++);
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

    int nloops=0;
    alarm(PERIOD);
}

void stop_alarm(void)
{
    alarm(0);
}


