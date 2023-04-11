#!/bin/bash

# perform write experiments with sysbench oltp benchmarks
# run setup-cgroups.py before running this script!
duration=600
tables=128
tablesize=2000000
timeexe=`which time`
sysbenchcfg=/mydata/sysbench.conf

# write-buffer-limit (total for memtables)
# capacity (block cache quota)
# assuming cgroup memory sizes 12GB, 16GB, ..., 32GB

for i in {1..6}
do
    wb=4
    cap=4
	 
    # update config
    sed -rie 's/(write-buffer-limit \= )\"\w+\"/\1'"\"${wb}GB\""'/i' tikv.yoml
    sed -rie 's/(capacity \= )\"\w+\"/\1'"\"${cap}GB\""'/i' tikv.yoml

    echo "Running benchmarks with config:"
    cat tikv.yoml

    # start tidb in background screen. screen session will be destroyed when
    # tiup closes
    #    screen -dm tiup playground nightly --kv.config tikv.yoml --tiflash 0 --kv 1
    screen -dm cgexec -g memory:$i tiup playground nightly --kv.config tikv.yoml --tiflash 0 --kv 1
    sleep 30 # crude and error-prone but whatever

    # remove previous db not necessary. playground cleans itself up
    # setup db
    mysql -h 127.0.0.1 -P 4000 -u root -Be "create database sbtest;"
    sleep 2
    
    mysql -h 127.0.0.1 -P 4000 -u root -D sbtest -Be "SET GLOBAL tidb_disable_txn_auto_retry = 0;"
    sleep 2
    
    mysql -h 127.0.0.1 -P 4000 -u root -D sbtest -Be "SET GLOBAL tidb_retry_limit = 10000;"
    sleep 2
    
    # do benchmark
    fname=wb${wb}_cap${cap}_mem$((8+(i*4)))
    $timeexe -o ${fname}_prepare.time sysbench --config-file=$sysbenchcfg oltp_read_only --tables=$tables --table-size=$tablesize --time=$duration prepare &> ${fname}_prepare.out

    sleep 5

    $timeexe -o ${fname}_rw.time sysbench --config-file=$sysbenchcfg oltp_read_write --tables=$tables --table-size=$tablesize --time=$duration run &> ${fname}_rw.out
    
    
    $timeexe -o ${fname}_readonly.time sysbench --config-file=$sysbenchcfg oltp_read_only --tables=$tables --table-size=$tablesize --time=$duration run &> ${fname}_readonly.out
    
    # close tidb
    killall tiup
    sleep 5
done
