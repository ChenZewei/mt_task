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
#include "common.h"
#include <assert.h>

#define PERIOD            100
#define RELATIVE_DEADLINE 100
#define EXEC_COST         10
#define MAX_INT 					0xffffffff
#define SCALE							1
#define NUMS 4096

/* Let's create 10 threads in the example, 
 * for a total utilization of 1.
 */
#define NUM_THREADS      64

const char *usage_msg =
	"Usage:\n";


static void usage(char *error) {
	if (error)
		fprintf(stderr, "Error: %s\n\n", error);
	else {
		fprintf(stderr, "\n");
	}
	fprintf(stderr, "%s", usage_msg);
	exit(error ? EXIT_FAILURE : EXIT_SUCCESS);
}


static int cycles_ms = 2400000;
static int num[NUM_THREADS][NUMS];

typedef struct shared_resource {
	int lock_od;
	double cs_length; /* millisecond */
} shared_resource;

/* The information passed to each thread. Could be anything. */
struct thread_context {
	int id;
  double sub_wcet;
	double period;
	double deadline;
	int priority;
	long iteration;
	int cpd;
	int partition;
	shared_resource sr;
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

static noinline int loop(int count, int thread_id);
static int loop_s(double s, int thread_id);
static int loop_ms(double ms, int thread_id);
static int loop_us(double us);
static int loop_ns(double ns);

#define loop_once(id) loop(NUMS, id)
// #define loop_once() loop_us(1)

int ceil(double num) {
	int result = num;
	if (result < num)
		return result + 1;
	else
		return result;
}

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
	shared_resource 			sr;

	/* The task is in background mode upon startup. */
  long iteration, duration, partition, priority;
	int parallel_degree, constrained_pd;
	double wcet, sub_wcet, period, deadline, utilization, tmp;

	/* locking */
	int lock_od = -1;
	int resource_id = 0;
	const char *lock_namespace = "./mt_task-locks";
	int protocol = -1;
	double cs_length = 1; /* microsecond */

	wcet = 10;
	period = 100;
	deadline = 100;
	parallel_degree = 4;
	constrained_pd = 0;
	duration = 1;
	partition = MAX_INT;
	utilization = 0.3;
	priority = LITMUS_LOWEST_PRIORITY;

	/*****
	 * 1) Command line paramter parsing would be done here.
	 */
	if (1 != argc) {
		for (int arg = 1; arg < argc; arg++) {
			if (0 == strcmp(argv[arg], "-a"))
				cycles_ms = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-u"))
				utilization = atof(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-p"))
				period = ms2ns(atof(argv[++arg]))*SCALE;
			else if (0 == strcmp(argv[arg], "-d"))
				deadline = ms2ns(atof(argv[++arg]))*SCALE;
			else if (0 == strcmp(argv[arg], "-q")) {
				priority = atoi(argv[++arg]);
				if (!litmus_is_valid_fixed_prio(priority))
					priority = LITMUS_LOWEST_PRIORITY;
			} else if (0 == strcmp(argv[arg], "-m"))
				parallel_degree = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-c"))
				constrained_pd = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-t"))
				duration = ms2ns(atoi(argv[++arg]));
			else if (0 == strcmp(argv[arg], "-P"))
        partition = atoi(argv[++arg]);
			else if (0 == strcmp(argv[arg], "-L")) {
				protocol = lock_protocol_for_name(argv[++arg]);
				if (protocol < 0)
					printf("Unknown locking protocol specified.\n");
			} else if (0 == strcmp(argv[arg], "-R"))
        resource_id = want_non_negative_int(argv[++arg], "-R");
			else if (0 == strcmp(argv[arg], "-L"))
        cs_length = want_positive_double(argv[++arg], "-L");
			else if (0 == strcmp(argv[arg], "-P"))
        partition = atoi(argv[++arg]);
			else {
				printf("Unrecognized parameter.\n");
				exit(0);
			}
		}
	}
	assert(NUM_THREADS >= parallel_degree);

	iteration = duration / period;
	wcet = utilization * period;
  
	/*****
	 * 2) Work environment (e.g., global data structures, file data, etc.) would
	 *    be setup here.
	 */
	
	sub_wcet = wcet / parallel_degree;
	// printf("wcet: %f ns (%f ms), sub_wcet: %f ns (%f ms)\n", wcet, ns2ms(wcet), sub_wcet, ns2ms(sub_wcet));

	assert(sub_wcet > 0);
	assert(wcet >= sub_wcet);

	// if (wcet > sub_wcet)
	// 	constrained_pd = ceiling(wcet - sub_wcet, deadline - sub_wcet);
	// else
	// 	constrained_pd = 1;

	// constrained_pd = ceiling(priority, 3);

	if (0 == constrained_pd) {
		constrained_pd = ceil(utilization * 4.0);
	}

	// if (constrained_pd > 2)
	// 	constrained_pd = 2;

	assert(constrained_pd > 0);
	printf("utilization: %f, constrained_pd: %d\n", utilization, constrained_pd);

	if (protocol >= 0) {
		/* open reference to semaphore */
		lock_od = litmus_open_lock(protocol, resource_id, lock_namespace, &partition);
		if (lock_od < 0) {
			printf("litmus_open_lock\n");
			printf("Could not open lock.\n");
		}
	}
	sr.lock_od = lock_od;
	sr.cs_length = cs_length;



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
		ctx[i].priority = priority;
		ctx[i].iteration = iteration;
		ctx[i].cpd = constrained_pd;
		ctx[i].partition = partition;
		ctx[i].sr = sr;
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
	printf("RT Thread [%d] active.\n", ctx->id);
	// if (ctx->priority != LITMUS_LOWEST_PRIORITY)
	// 	printf("priority: %d.\n", ctx->priority);
	
	init_rt_task_param(&param);
	param.exec_cost = ctx->sub_wcet;
	param.period = ctx->period;
	param.relative_deadline = ctx->deadline;
	param.constrained_parallel_degree = ctx->cpd;
	param.priority = ctx->priority;
	
	
	if (MAX_INT != ctx->partition) {
		param.cpu = domain_to_first_cpu(ctx->partition);
		CALL( be_migrate_to_domain(ctx->partition) );
	}
	CALL(set_rt_task_param(gettid(), &param));
	CALL(task_mode(LITMUS_RT_TASK));
	CALL(wait_for_ts_release());

	for (uint i = ctx->iteration; i > 0; i--) {


		loop_ms(ns2ms(ctx->sub_wcet), ctx->id);

		// // non-critical section 1
		// loop_ms(ns2ms(ctx->sub_wcet/2));

		// // critical section
		// if (-1 != ctx->sr.lock_od) {
		// 	litmus_lock(ctx->sr.lock_od);
		// 	loop_us(ctx->sr.cs_length);
		// 	litmus_unlock(ctx->sr.lock_od);
		// }

		// // non-critical section 2
		// loop_ms(ns2ms(ctx->sub_wcet/2));


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

static noinline int loop(int count, int thread_id)
{
	int i, j = 0;
	/* touch some numbers and do some math */
	for (i = 0; i < count; i++) {
		int index = i % NUMS;
		j += num[thread_id][index]++;
		if (j > num[index])
			num[thread_id][index] = (j / 2) + 1;
	}
	return j;
}

static int loop_s(double s, int thread_id) {
	int tmp = 0;
	double last_loop = 0, loop_start;
	double start = cputime();
	double now = cputime();

	while (now + last_loop < start + s) {
		loop_start = now;
		tmp = loop_once(thread_id);
		now = cputime();
		last_loop = now - loop_start;
	}
	return tmp;
}

// static int loop_ms(double ms) {
// 	int tmp;
// 	double gap = ms;
// 	// double start = cputime();
// 	// double now;
// 	long iteration = ms * 267000;
// 	while (++tmp < iteration) {}
// 	// now = cputime();
// 	// gap = (now - start) * 1000;
// 	// if (0 < gap) {
// 	// 	iteration = gap * 267000;
// 	// 	tmp = 0;
// 	// 	while (++tmp < iteration) {}
// 	// }
// 	return tmp;
// }

static int loop_ms(double ms, int thread_id) {
	int tmp = 0;
	double max_loop = 0, loop_start;
	double start = cputime();
	double now = cputime();
	// long tstamp1, tstamp2, tstamp3, tstamp4;

	while (now + max_loop < start + (ms/1000)) {
		// rdtscll(tstamp1);
		loop_start = cputime();
		// rdtscll(tstamp2);
		tmp = loop_once(thread_id);
		tmp++;
		// rdtscll(tstamp3);
		now = cputime();
		// rdtscll(tstamp4);

		// if (ms/1000 < (now-start)) {
		// 	printf("Actually execute for %8.6f ms (suppose to be %8.6f ms)\n", (now-start)*1000, ms);
		// 	printf("Max loop: %8.6f ms, this loop %8.6f ms.\n", max_loop*1000, (now-loop_start)*1000);

		// 	printf("t1: %llu, t2: %llu u, t3: %llu \n", tstamp2 - tstamp1, tstamp3 - tstamp2, tstamp4 - tstamp3);
		// }
		if (max_loop < (now - loop_start))
			max_loop = now - loop_start;
	}
	return tmp;
	// long iteration = ms * 267000;
	// while (++n < iteration) {}
	return tmp;
}

static int loop_us(double us) {
	int tmp = 0;
	long iteration = us * 267;
	while (++tmp < iteration) {}
	return tmp;
}

static int loop_ns(double ns) {
	int tmp = 0;
	// double count = cycles_ms * ns2ms(ns);
	// tmp += loop(count);
	long iteration = ns * 0.267;
	while (++tmp < iteration) {}
	return tmp;
}
