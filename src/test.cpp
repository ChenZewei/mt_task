#include <iostream>
#include <ctime>
#include <ratio>
#include <chrono>

using namespace std::chrono;

void loop_ms(long ms) {
	long n = 0;
	long iteration = ms * 267000;
	while (++n < iteration) {}
}

void loop_us(long us) {
	long n = 0;
	long iteration = us * 267;
	while (++n < iteration) {}
}


int main() {

  steady_clock::time_point t1 = steady_clock::now();

  std::cout << "printing out 1000 stars...\n";
  loop_ms(100);
  std::cout << std::endl;

  steady_clock::time_point t2 = steady_clock::now();

  duration<double> time_span = duration_cast<duration<double> >(t2 - t1);

  std::cout << "It took me " << time_span.count() << " seconds.";
  std::cout << std::endl;

  return 0;
}