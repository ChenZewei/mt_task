import random, sys

print("argv:", len(sys.argv))
print("argc:", str(sys.argv))

p_num = int(sys.argv[1])
m = int(sys.argv[2])
duration = int(sys.argv[3])

T=[random.randint(100,1000) for _ in range(3 * p_num)]

# print(T)
# for global scheduling
g = open('./global_test.sh', 'w')
for t in T:
  g.write('./mt_task -e %d -p %d -d %d -m %d -t %d &\n' % (t/10, t, t, m, duration))
g.close()


# for partitioned scheduling
p = open('./partitioned_test.sh', 'w')
i = 0
for t in T:
  pid = i % p_num
  p.write('./mt_task -e %d -p %d -d %d -m %d -t %d -P %d &\n' % (t/10, t, t, m, duration, pid))
  i = i + 1
p.close()

