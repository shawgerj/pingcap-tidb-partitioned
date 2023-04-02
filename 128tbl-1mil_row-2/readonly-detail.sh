#/bin/bash

for i in {1..7}
do
    wb=$((8-i))
    cap=$((i))

    infile=wb${wb}_cap${cap}_readonly.out
    outfile=readonly-detail.wb${wb}_cap${cap}.data
    
    printf 'tps\tqps\tlat-95\n' > $outfile
    awk -v w="${wb}" -v c="${cap}" '/^\[/ { print $7, $9, $14 }' OFS="\t" $infile >> $outfile
done
