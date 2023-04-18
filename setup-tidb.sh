#!/bin/bash

# run setup-cgroups.py before running this script!
# perform write experiments with sysbench oltp benchmarks
duration=600
tables=128
tablesize=2000000
timeexe=`which time`
sysbenchcfg=/mydata/sysbench.conf

# executables and paths
exproot=/mydata
pd_bin=$exproot/tikv-bin/pd-server
tikv_bin=$exproot/tikv-bin/tikv-server
tidb_bin=$exproot/tikv-bin/tidb-server
datadir=$exproot/data
logdir=$exproot/logs

# just do the 32GB one for now
for i in 32
do
    echo "Running sysbench with config and cgroup ${i}"
    cat tikv.yoml
    
    # start pd
    $pd_bin --name=pd --data-dir=$datadir/pd --client-urls="http://127.0.0.1:2379" --peer-urls="http://127.0.0.1:2380" --initial-cluster="pd=http://127.0.0.1:2380" --log-file=$logdir/pd.log &

    sleep 8

    # start tikv
    cgexec -g memory:$i $tikv_bin --pd-endpoints="127.0.0.1:2379" --addr="127.0.0.1:20160" --data-dir=$datadir/tikv --log-file=$logdir/tikv.log --config=$exproot/tikv.yoml &

    sleep 8

    # start tidb
    cgexec -g memory:$i $tidb_bin --store=tikv --path="127.0.0.1:2379" --log-file=$logdir/tidb.log &

    sleep 10

    # setup db
    mysql -h 127.0.0.1 -P 4000 -u root -D sbtest -Be "DROP DATABASE sbtest;"
    sleep 2
    mysql -h 127.0.0.1 -P 4000 -u root -Be "create database sbtest;"
    sleep 2
    
    mysql -h 127.0.0.1 -P 4000 -u root -D sbtest -Be "SET GLOBAL tidb_disable_txn_auto_retry = 0;"
    sleep 2
    
    mysql -h 127.0.0.1 -P 4000 -u root -D sbtest -Be "SET GLOBAL tidb_retry_limit = 10000;"
    sleep 2

    # do benchmark
    fname=wb8_cap8_mem$i
    $timeexe -o ${fname}_prepare.time sysbench --config-file=$sysbenchcfg oltp_read_only --tables=$tables --table-size=$tablesize --time=$duration prepare &> ${fname}_prepare.out

    sleep 5

    $timeexe -o ${fname}_rw.time sysbench --config-file=$sysbenchcfg oltp_read_write --tables=$tables --table-size=$tablesize --time=$duration run &> ${fname}_rw.out
    
    
    $timeexe -o ${fname}_readonly.time sysbench --config-file=$sysbenchcfg oltp_read_only --tables=$tables --table-size=$tablesize --time=$duration run &> ${fname}_readonly.out

    # clean up
    killall tidb-server
    sleep 2
    killall tikv-server
    sleep 2
    killall pd-server
    sleep 2
    rm -r $datadir/*
done

