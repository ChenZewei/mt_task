import numpy as np
import random, sys, math

n = 24
Periods = [1, 2, 4, 5, 8, 10, 20, 25, 40, 50, 100, 200, 250, 400, 500, 1000]


index = [random.randint(0,15) for _ in range(n)]



for i in range(n):
  print(Periods[index[i]])