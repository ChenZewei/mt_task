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

/* Include gettid() */
#include <sys/types.h>

/* Include threading support. */
#include <pthread.h>

/* Include the LITMUS^RT API.*/
#include "litmus.h"

#include <assert.h>

#define PERIOD            100
#define RELATIVE_DEADLINE 100
#define EXEC_COST         10
#define MAX_INT 					0xffffffff

/* Let's create 10 threads in the example, 
 * for a total utilization of 1.
 */
#define NUM_THREADS      16

/* The information passed to each thread. Could be anything. */
struct thread_context {
	int id;
  long sub_wcet;
	long period;
	long deadline;
	long iteration;
	int cpd;
	int partition;
};

/* The real-time thread program. Doesn't have to be the same for
 * all threads. Here, we only have one that will invoke job().
 */
void* rt_thread(void *tcontext);

/* Declare the periodically invoked job. 
 * Returns 1 -> task should exit.
 *         0 -> task should continue.
 */
int job(void);

void loop(long ms);

int ceiling(int numer, int denom) {
	if (0 == numer % denom)
		return numer / denom;
	else
		return (numer / denom) + 1;
}

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
  long	wcet, sub_wcet, period, deadline, parallel_degree, constrained_pd, iteration, duration, partition;

	wcet = 10;
	period = 100;
	deadline = 100;
	parallel_degree = 4;
	constrained_pd = parallel_degree;
	duration = 1;
	partition = MAX_INT;

	/*****
	 * 1) Command line paramter parsing would be done here.
	 */
	if (1 != argc) {
		for (int arg = 1; arg < argc; arg++) {
			if (0 == strcmp(argv[arg], "-e"))
				wcet = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-p"))
				period = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-d"))
				deadline = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-m"))
				parallel_degree = atoi(argv[++arg]);
			// else if (0 == strcmp(argv[arg], "-c"))
			// 	constrained_pd = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-t"))
				duration = atoi(argv[++arg]); 
			else if (0 == strcmp(argv[arg], "-P"))
        partition = atoi(argv[++arg]);
			else {
				printf("Unrecognized parameter.\n");
				exit(0);
			}
		}
	}
	assert(NUM_THREADS >= parallel_degree);

	iteration = 1000 * duration / period;
       
	/*****
	 * 2) Work environment (e.g., global data structures, file data, etc.) would
	 *    be setup here.
	 */
	
	sub_wcet = wcet / parallel_degree;
	printf("wcet: %d, sub_wcet: %d\n", wcet, sub_wcet);

	assert(sub_wcet > 0);
	assert(wcet >= sub_wcet);

	if (wcet > sub_wcet)
		constrained_pd = ceiling(wcet - sub_wcet, deadline - sub_wcet);
	else
		constrained_pd = 1;

	assert(constrained_pd > 0);


	/*****
	 * 3) Initialize LITMUS^RT.
	 *    Task parameters will be specified per thread.
	 */
	CALL(init_litmus());
	// init_rt_task_param(&param);
	// param.exec_cost = wcet;
	// param.period = period;
	// param.relative_deadline = deadline;


	// CALL(set_rt_task_param(gettid(), &param));
	// CALL(task_mode(LITMUS_RT_TASK));
	// CALL(wait_for_ts_release());

	/***** 
		* 4) Launch threads.
		*/
	for (i = 0; i < parallel_degree; i++) {
		ctx[i].id = i;
		ctx[i].sub_wcet = sub_wcet;
		ctx[i].period = period;
		ctx[i].deadline = deadline;
		ctx[i].iteration = iteration;
		ctx[i].cpd = constrained_pd;
		ctx[i].partition = partition;
		pthread_create(task + i, NULL, rt_thread, (void *) (ctx + i));
	}

	/*****
		* 5) Wait for RT threads to terminate.
		*/
	for (i = 0; i < parallel_degree; i++)
		pthread_join(task[i], NULL);
	


	// CALL(task_mode(BACKGROUND_TASK));
	/***** 
	 * 6) Clean up, maybe print results and stats, and exit.
	 */
	return 0;
}

/* A real-time thread is very similar to the main function of a single-threaded
 * real-time app. Notice, that init_rt_thread() is called to initialized per-thread
 * data structures of the LITMUS^RT user space libary.
 */
void* rt_thread(void *tcontext) {
	struct rt_task param;
	struct thread_context *ctx = (struct thread_context *) tcontext;
	/* Make presence visible. */
	printf("RT Thread %d active. Workload:%d\n", ctx->id, ctx->sub_wcet);
	
	init_rt_task_param(&param);
	param.exec_cost = ms2ns(ctx->sub_wcet);
	param.period = ms2ns(ctx->period);
	param.relative_deadline = ms2ns(ctx->deadline);
	param.constrained_parallel_degree = ctx->cpd;

	param.priority = LITMUS_LOWEST_PRIORITY;
	
	if (MAX_INT != ctx->partition) {
		param.cpu = domain_to_first_cpu(ctx->partition);
		CALL( be_migrate_to_domain(ctx->partition) );
	}
	CALL(set_rt_task_param(gettid(), &param));
	CALL(task_mode(LITMUS_RT_TASK));
	CALL(wait_for_ts_release());

	for (uint i = ctx->iteration; i > 0; i--) {
		loop(ctx->sub_wcet);
		sleep_next_period();
	}

	CALL(task_mode(BACKGROUND_TASK));
	return NULL;
}

int job(void) {
	/* Do real-time calculation. */

	/* Don't exit. */
	return 0;
}

void loop(long ms) {
	long n = 0;
	long iteration = ms * 266666;
	while (n < iteration) { n++; }
	return NULL;
}
