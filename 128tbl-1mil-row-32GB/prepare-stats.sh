#/bin/bash

outfile='prepare.summary'

printf '%s\t%s\t%s\n' 'wb' 'cap' 'time' > $outfile

for i in {1..15}
do
    wb=$((32-(i*2)))
    cap=$((i*2))

    infile=wb${wb}_cap${cap}_prepare.time
    awk -v w="${wb}" -v c="${cap}" 'NR==1 { print w, c, substr($3,0,8) }' OFS="\t" $infile >> $outfile
done

