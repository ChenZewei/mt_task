import numpy as np
import random, os, stat, sys, math

def StaffordRandFixedSum(n, u, nsets):
    """
    Copyright 2010 Paul Emberson, Roger Stafford, Robert Davis.
    All rights reserved.

    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:

    1. Redistributions of source code must retain the above copyright notice,
        this list of conditions and the following disclaimer.

    2. Redistributions in binary form must reproduce the above copyright notice,
        this list of conditions and the following disclaimer in the documentation
        and/or other materials provided with the distribution.

    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY EXPRESS
    OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
    EVENT SHALL THE AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
    LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
    OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
    LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
    OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

    The views and conclusions contained in the software and documentation are
    those of the authors and should not be interpreted as representing official
    policies, either expressed or implied, of Paul Emberson, Roger Stafford or
    Robert Davis.

    Includes Python implementation of Roger Stafford's randfixedsum implementation
    http://www.mathworks.com/matlabcentral/fileexchange/9700
    Adapted specifically for the purpose of taskset generation with fixed
    total utilisation value

    Please contact paule@rapitasystems.com or robdavis@cs.york.ac.uk if you have
    any questions regarding this software.
    """
    # if n < u:
    #     return None

    #deal with n=1 case
    if n == 1:
        return np.tile(np.array([u]), [nsets, 1])

    k = min(int(u), n - 1)
    s = u
    s1 = s - np.arange(k, k - n, -1.)
    s2 = np.arange(k + n, k, -1.) - s

    tiny = np.finfo(float).tiny
    huge = np.finfo(float).max

    w = np.zeros((n, n + 1))
    w[0, 1] = huge
    t = np.zeros((n - 1, n))

    for i in np.arange(2, n + 1):
        tmp1 = w[i - 2, np.arange(1, i + 1)] * s1[np.arange(0, i)] / float(i)
        tmp2 = w[i - 2, np.arange(0, i)] * s2[np.arange(n - i, n)] / float(i)
        w[i - 1, np.arange(1, i + 1)] = tmp1 + tmp2
        tmp3 = w[i - 1, np.arange(1, i + 1)] + tiny
        tmp4 = s2[np.arange(n - i, n)] > s1[np.arange(0, i)]
        t[i - 2, np.arange(0, i)] = (tmp2 / tmp3) * tmp4 + \
            (1 - tmp1 / tmp3) * (np.logical_not(tmp4))

    x = np.zeros((n, nsets))
    rt = np.random.uniform(size=(n - 1, nsets))  # rand simplex type
    rs = np.random.uniform(size=(n - 1, nsets))  # rand position in simplex
    s = np.repeat(s, nsets)
    j = np.repeat(k + 1, nsets)
    sm = np.repeat(0, nsets)
    pr = np.repeat(1, nsets)

    for i in np.arange(n - 1, 0, -1):  # iterate through dimensions
        # decide which direction to move in this dimension (1 or 0):
        e = rt[(n - i) - 1, ...] <= t[i - 1, j - 1]
        sx = rs[(n - i) - 1, ...] ** (1.0 / i)  # next simplex coord
        sm = sm + (1.0 - sx) * pr * s / (i + 1)
        pr = sx * pr
        x[(n - i) - 1, ...] = sm + pr * e
        s = s - e
        j = j - e  # change transition table column if required

    x[n - 1, ...] = sm + pr * s

    #iterated in fixed dimension order but needs to be randomised
    #permute x row order within each column
    for i in range(0, nsets):
        x[..., i] = x[np.random.permutation(n), i]

    return x.T.tolist()

def gen_randfixedsum(nsets, u, n):
    """
    Stafford's RandFixedSum algorithm implementated in Python.

    Based on the Python implementation given by Paul Emberson, Roger Stafford,
    and Robert Davis. Available under the Simplified BSD License.

    Args:
        - `n`: The number of tasks in a task set.
        - `u`: Total utilization of the task set.
        - `nsets`: Number of sets to generate.
    """
    return StaffordRandFixedSum(n, u, nsets)

def gen_randfixedsum_rescale(nsets, u, n, l_bound, u_bound):
  U = StaffordRandFixedSum(n, u, nsets)
#   print(U)
  for i in range(nsets):
    for j in range(n):
        U[i][j] = U[i][j] * (u_bound - l_bound) + l_bound
#   print(U)
  return U

# print("argv:", len(sys.argv))
# print("argc:", str(sys.argv))

# n = int(sys.argv[1])
p_num = int(sys.argv[1])
m = int(sys.argv[2])
duration = int(sys.argv[3])
# n = 0.5 * p_num
n=4
id = int(sys.argv[4])
u_ratio = float(sys.argv[5])
lb = 0.1
ub=2

# Periods = [1,2,4,5,10, 20, 25, 50, 100]
Periods = [5,10,20,25,50,100]
# Periods = [1,2,4,5,8,10, 20, 25, 40, 50, 100, 125, 200, 250, 500, 1000]
# Periods = [10, 20, 25, 40, 50, 100, 125, 200, 250, 500, 1000]
# Periods = [100,125,200,250,400,500,625,1000,1250,2000,2500,5000,10000]

# U=gen_randfixedsum(1, p_num, n)
U=gen_randfixedsum_rescale(1, (u_ratio * p_num - n * lb)/(ub - lb), n, lb, ub)
T=[random.randint(100,1000) for _ in range(n)]
# index = [random.randint(0,8) for _ in range(n)]
index = [random.randint(0,5) for _ in range(n)]
# index = [random.randint(0,15) for _ in range(n)]
# index = [random.randint(0,10) for _ in range(n)]
# index = [random.randint(0,12) for _ in range(n)]

index.sort()

# cab_edf=(3+math.sqrt(5))/2
# cab_fp=(4+math.sqrt(12))/2

cab_edf=1
cab_fp=1

# for global scheduling
file_name_1 = './global_edf_'+sys.argv[1]+'_'+sys.argv[2]+'_'+sys.argv[3]+'_'+sys.argv[4]+'_'+sys.argv[5]+'.sh'
g = open(file_name_1, 'w')
file_name_2 = './global_fp_'+sys.argv[1]+'_'+sys.argv[2]+'_'+sys.argv[3]+'_'+sys.argv[4]+'_'+sys.argv[5]+'.sh'
g2 = open(file_name_2, 'w')
cpd_sum=0
for i in range(n):

  cpu=U[0][i]/m
  cpl=cpu*Periods[index[i]]
  # print("cpl:", cpl)


  cpd = math.ceil((U[0][i] * Periods[index[i]] - cpl)/(Periods[index[i]] - cpl))

  # print("cpd:", cpd)


  # cpd_edf=m
  # for cpd_edf in range(int(m),0,-1):
  #   if(1 == cpd_edf):
  #     break
  #   if((1/cab_edf) < math.ceil(float(m)/(cpd_edf-1))*cpu):
  #     break

  # cpd_fp=m
  # for cpd_fp in range(int(m),0,-1):
  #   if(1 == cpd_fp):
  #     break
  #   if((1/cab_fp) < math.ceil(float(m)/(cpd_fp-1))*cpu):
  #     break

  priority = 1 + i;

  g.write('./mt_task -u %f -p %d -d %d -q %d -m %d -c %d -t %d &\n' % (U[0][i], Periods[index[i]], Periods[index[i]], priority, m, cpd, duration))
  g2.write('./mt_task -u %f -p %d -d %d -q %d -m %d -c %d -t %d &\n' % (U[0][i], Periods[index[i]], Periods[index[i]], priority, m, cpd, duration))
  g.write('sleep 0.1\n')
  g2.write('sleep 0.1\n')
g.close()
g2.close()

# for t in T:
  


# for partitioned scheduling
# file_name_3 = './partitioned_'+sys.argv[1]+'_'+sys.argv[2]+'_'+sys.argv[3]+'_'+sys.argv[4]+'_'+sys.argv[5]+'.sh'
# p = open(file_name_3, 'w')
# for i in range(n):
  # b_m=math.ceil(4*U[0][i])
  # # ub_m=math.floor(8*U[0][i])
  # ub_m=32
  
  # if (lb_m >= ub_m):
  #   m=lb_m
  # else:
  #   m=random.randint(lb_m,ub_m)
  # cpd=m
  # cpu=U[0][i]/m
  # for cpd in range(int(m),0,-1):
  #   if(1 == cpd):
  #     break
  #   if(0.25 < math.ceil(float(m)/(cpd-1))*cpu):
  #     break
#   pid = i % p_num
#   priority = 1 + m *i;
#   # p.write('./mt_task -u %f -p %d -d %d -m %d -c %d -t %d -P %d &\n' % (U[0][i], T[i], T[i], priority, m, cpd, duration, pid))
#   p.write('./mt_task -u %f -p %d -d %d -m %d -c %d -t %d -P %d &\n' % (U[0][i], Periods[index[i]], Periods[index[i]], priority, m, cpd, duration, pid))
# p.close()


os.chmod(file_name_1, stat.S_IRWXU)
os.chmod(file_name_2, stat.S_IRWXU)
# os.chmod(file_name_3, stat.S_IRWXU)
