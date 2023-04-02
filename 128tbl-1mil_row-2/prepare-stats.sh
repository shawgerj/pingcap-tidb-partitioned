#/bin/bash

outfile='prepare.summary'

printf '%s\t%s\t%s\n' 'wb' 'cap' 'time' > $outfile

for i in {1..7}
do
    wb=$((8-i))
    cap=$((i))

    infile=wb${wb}_cap${cap}_prepare.time
    awk -v w="${wb}" -v c="${cap}" 'NR==1 { print w, c, substr($3,0,8) }' OFS="\t" $infile >> $outfile
done

