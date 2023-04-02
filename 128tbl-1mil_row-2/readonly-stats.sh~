#/bin/bash

outfile='readonly.summary.stats'

printf 'wb\tcap\ttps\tqps\tlat-avg\tlat-95\n' > $outfile

for i in {1..15}
do
    wb=$((32-(i*2)))
    cap=$((i*2))

    infile=wb${wb}_cap${cap}_readonly.out
    awk -v w="${wb}" -v c="${cap}" '/transactions/ { tps=$2 } /queries/ { qps=$2 } /avg:/ { latavg=$2 } /95th/ { lat95=$3 } END {print w, c, tps, qps, latavg, lat95}' OFS="\t" $infile >> $outfile
done

