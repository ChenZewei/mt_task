#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <litmus.h>

#define EXEC_COST     10
#define PERIOD        1000
#define DEADLINE			1000

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

	void loop(int ns);

	int main() {
		struct rt_task param;
		CALL(init_litmus());
		init_rt_task_param(&param);
		param.exec_cost = EXEC_COST;
		param.period = PERIOD;
		param.relative_deadline = DEADLINE;

		CALL(set_rt_task_param(gettid(), &param));
		CALL(task_mode(LITMUS_RT_TASK));
		// CALL(wait_for_ts_release());

				printf("Father thread pid: %d.\n",(int)getpid());
				printf("Father thread tid: %d.\n",(int)gettid());
		do {
			#pragma omp parallel num_threads(4)
			{
				printf("Child thread pid: %d.\n",(int)getpid());
				printf("Child thread tid: %d.\n",(int)gettid());
				loop(ms2ns(EXEC_COST));
			}
			sleep_next_period();
		} while(1);

		CALL(task_mode(BACKGROUND_TASK));
		return 0;
	}

void loop(int ns) {
	long n = 0;
	long iteration = ns * 0.8;
	while (++n < iteration) {}
	return NULL;
}
