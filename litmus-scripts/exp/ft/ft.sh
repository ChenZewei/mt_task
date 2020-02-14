# (1) Sort
ft-sort-traces overheads_*.bin 2>&1 | tee -a overhead-processing.log

# (2) Split
ft-extract-samples overheads_*.bin 2>&1 | tee -a overhead-processing.log

# (3) Combine
ft-combine-samples --std overheads_*.float32 2>&1 | tee -a overhead-processing.log

# (4) Count available samples
ft-count-samples  combined-overheads_*.float32 > counts.csv

# (5) Shuffle & truncate
ft-select-samples counts.csv combined-overheads_*.float32 2>&1 | tee -a overhead-processing.log

# (6) Compute statistics
ft-compute-stats -b 600 --hist combined-overheads_*.sf32 > $1_stats.csv

# (7) Compute statistics
ft-compute-stats combined-overheads_*.sf32 > $1_stats_2.csv
