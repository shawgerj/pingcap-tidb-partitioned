#!/bin/bash

# perform read experiments with sysbench oltp_read_only run
duration=300
tables=32
tablesize=200000


for i in {1..7}
do
    # update config
    sed -rie 's/(write-buffer-limit \= )\"\w+\"/\1'"\"${i}GB\""'/i' tikv.yoml
    sed -rie 's/(capacity \= )\"\w+\"/\1'"\"$((8-i))GB\""'/i' tikv.yoml

    echo "Running oltp_read_only with config:"
    cat tikv.yoml

    # start tidb in background screen. screen session will be destroyed when
    # tiup closes
    screen -dm tiup playground nightly --kv.config tikv.yoml --tiflash 0 --kv 1
    sleep 10 # crude and error-prone but whatever
    
    # do benchmark
    sysbench --config-file=sysbench.conf oltp_read_only --tables=$tables --table-size=$tablesize --time=$duration run > wb${i}_cap$((8-i))_readonly.out
    
    # close tidb
    killall tiup

    sleep 5
done
