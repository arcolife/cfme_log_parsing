#!/bin/bash

printf "%0.s-" {1..70}

# example: DB_master-raw_logs__evm.log-20170311__ems_refresh_timings.out
log_file=$1

# example: 
ems_type=$2

start_time=$3
# '2017-03-10T10:45'

end_time=$4
# '2017-03-10T11:45'

# get blocks of data matching pattern of EMS Refresh event type $ems_type
egrep '.*Message state.*ok' -B 20 -A 2 $log_file | \
    awk '/Worker PID/ { r=""; f=1 } f { r = (r ? r ORS : "") $0 } /Message delivered in/ { if (f && r ~ /.*'$ems_type'.*/) print r; f=0 }' | \
    egrep 'delivered in|start time' | awk '{print $(NF-1)" "$NF}' > /tmp/temp.out

./logs_postprocessor.py $start_time $end_time

# timings=(` echo /tmp/temp.out | grep 'delivered in' | awk '{print $(NF-1)}'`)

# total=`echo "${timings[@]}" | tr ' ' '\n' | awk '{sum+=$1};END{print sum}'`
# average=`echo "$total/${#timings[@]}" | bc -l`

# echo
# echo ${timings[@]}
# echo
# spark ${timings[@]}
# echo
# printf "Average: $average\n"
# printf "%0.s-" {1..70}
echo
