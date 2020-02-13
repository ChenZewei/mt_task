/* based_mt_task.c -- A basic multi-threaded real-time task skeleton. 
 *
 * This (by itself useless) task demos how to setup a multi-threaded LITMUS^RT
 * real-time task. Familiarity with the single threaded example (base_task.c)
 * is assumed.
 *
 * Currently, liblitmus still lacks automated support for real-time
 * tasks, but internaly it is thread-safe, and thus can be used together
 * with pthreads.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

/* Include gettid() */
#include <sys/types.h>

/* Include threading support. */
#include <pthread.h>

/* Include the LITMUS^RT API.*/
#include "litmus.h"

#define PERIOD            100
#define RELATIVE_DEADLINE 100
#define EXEC_COST         10
#define MAX_INT 					0xffffffff

#define NUM_THREADS      16 

// #define s2ms(second) 1000*second


/* The information passed to each thread. Could be anything. */
struct thread_context {
	uint32_t id;
  uint32_t wcet;
  uint32_t period;
  uint32_t deadline;
	uint32_t cpd;
	uint32_t ins_num;
	uint32_t partition;
};

/* The real-time thread program. Doesn't have to be the same for
 * all threads. Here, we only have one that will invoke job().
 */
void* rt_thread(void *tcontext);

/* Declare the periodically invoked job. 
 * Returns 1 -> task should exit.
 *         0 -> task should continue.
 */
int job(uint64_t ns);

void loop(uint64_t ns);

uint32_t ceiling(uint32_t numer, uint32_t demon);


/* Catch errors.
 */
#define CALL( exp ) do { \
		int ret; \
		ret = exp; \
		if (ret != 0) \
			fprintf(stderr, "%s failed: %m\n", #exp);\
		else \
			fprintf(stderr, "%s ok.\n", #exp); \
	} while (0)


/* Basic setup is the same as in the single-threaded example. However, 
 * we do some thread initiliazation first before invoking the job.
 */
int main(int argc, char** argv)
{
	int i;
	struct thread_context ctx[NUM_THREADS];
	pthread_t             task[NUM_THREADS];

	/* The task is in background mode upon startup. */		

  uint32_t wcet, sub_wcet, period, deadline, parallel_degree, constrained_pd, duration, ins_num, partition;

  // Set default value.
  wcet = 10;
  period = 100;
  deadline = 100;
  parallel_degree = 4;
  constrained_pd = parallel_degree;
	duration = 10;  // in seconds
	partition = MAX_INT;

	/*****
	 * 1) Command line paramter parsing would be done here.
	 */
  if (1 != argc) {
    for (uint arg = 1; arg < argc; arg++) {
      if (0 == strcmp(argv[arg], "-C")) {
        wcet = atoi(argv[++arg]);
      } else if (0 == strcmp(argv[arg], "-T")) {
        period = atoi(argv[++arg]);
      } else if (0 == strcmp(argv[arg], "-D")) {
        deadline = atoi(argv[++arg]);
      } else if (0 == strcmp(argv[arg], "-m")) {
        parallel_degree = atoi(argv[++arg]);
      } else if (0 == strcmp(argv[arg], "-d")) {
        duration = atoi(argv[++arg]);
      } else if (0 == strcmp(argv[arg], "-p")) {
        partition = atoi(argv[++arg]);
      }  else {
        printf("Unrecognized parameter.\n");
        exit(0);
      }
    }
  }
  assert(NUM_THREADS >= parallel_degree);

	/*****
	 * 2) Work environment (e.g., global data structures, file data, etc.) would
	 *    be setup here.
	 */
  sub_wcet = wcet/parallel_degree;
	assert(sub_wcet <= wcet);
	assert(sub_wcet < deadline);

	ins_num = ceiling(s2ms(duration), period);
	assert(ins_num > 0);

	if (wcet == sub_wcet) {
		constrained_pd = 1;
	} else {
		constrained_pd = ceiling(wcet - sub_wcet, deadline - sub_wcet);
	}
	
	/*****
	 * 3) Initialize LITMUS^RT.
	 *    Task parameters will be specified per thread.
	 */
	init_litmus();

  // do {

  // } while();

	/***** 
	 * 4) Launch threads.
	 */
	// for (i = 0; i < NUM_THREADS; i++) {
	for (i = 0; i < parallel_degree; i++) {
		ctx[i].id = i;
		ctx[i].wcet = sub_wcet;
		ctx[i].period = period;
		ctx[i].deadline = deadline;
		ctx[i].cpd = constrained_pd;
		ctx[i].ins_num = ins_num;
		ctx[i].partition = partition;
		pthread_create(task + i, NULL, rt_thread, (void *) (ctx + i));
	}

	
	/*****
	 * 5) Wait for RT threads to terminate.
	 */
	// for (i = 0; i < NUM_THREADS; i++)
	for (i = 0; i < parallel_degree; i++)
		pthread_join(task[i], NULL);
	

	/***** 
	 * 6) Clean up, maybe print results and stats, and exit.
	 */
	return 0;
}



/* A real-time thread is very similar to the main function of a single-threaded
 * real-time app. Notice, that init_rt_thread() is called to initialized per-thread
 * data structures of the LITMUS^RT user space libary.
 */
void* rt_thread(void *tcontext)
{
	int do_exit;
	uint64_t wcet;
	struct thread_context *ctx = (struct thread_context *) tcontext;
	struct rt_task param;

	/* Set up task parameters */
	init_rt_task_param(&param);
	param.exec_cost = ms2ns(ctx->wcet);
	param.period = ms2ns(ctx->period);
	param.relative_deadline = ms2ns(ctx->deadline);
	param.constrained_parallel_degree = ctx->cpd;
	do_exit = ctx->ins_num;
	wcet = ms2ns(ctx->wcet);
	
	/* What to do in the case of budget overruns? */
	param.budget_policy = NO_ENFORCEMENT;

	/* The task class parameter is ignored by most plugins. */
	// param.cls = RT_CLASS_SOFT;

	/* The priority parameter is only used by fixed-priority plugins. */
	param.priority = LITMUS_LOWEST_PRIORITY;

	/* Make presence visible. */
	printf("RT Thread %d active.\n", ctx->id);

	/*****
	 * 1) Initialize real-time settings.
	 */
	CALL( init_rt_thread() );

	/* To specify a partition, do
	 *
	 * param.cpu = CPU;
	 * be_migrate_to(CPU);
	 *
	 * where CPU ranges from 0 to "Number of CPUs" - 1 before calling
	 * set_rt_task_param().
	 */
	if (MAX_INT != ctx->partition) {
		param.cpu = domain_to_first_cpu(ctx->partition);
		CALL( be_migrate_to_domain(ctx->partition) );
	}

	CALL( set_rt_task_param(gettid(), &param) );

	/**
	 * 
	 * 
	 **/

	/*****
	 * 2) Transition to real-time mode.
	 */
	CALL( task_mode(LITMUS_RT_TASK) );

	CALL( wait_for_ts_release() );

	/* The task is now executing as a real-time task if the call didn't fail. 
	 */



	/*****
	 * 3) Invoke real-time jobs.
	 */
	do {
		/* Wait until the next job is released. */
		sleep_next_period();
		/* Invoke job. */
		job(wcet);
	} while (--do_exit);

	/*****
	 * 4) Transition to background mode.
	 */
	CALL( task_mode(BACKGROUND_TASK) );

	return NULL;
}

int job(uint64_t ns) 
{
	/* Do real-time calculation. */
  loop(ns);

	/* Don't exit. */
	return 0;
}

void loop(uint64_t ns) {
  uint64_t n = 0;
  uint64_t iteration = ns * 800;
  while (n++ < iteration) {}
}

uint32_t ceiling(uint32_t numer, uint32_t denom) {
	if (0 != numer % denom) {
		return numer / denom + 1;
	} else {
		return numer / denom;
	}
}
