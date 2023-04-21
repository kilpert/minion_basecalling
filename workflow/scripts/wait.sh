#!/usr/bin/env bash


## usage: wait.sh 
## usage: wait.sh -l wait.log -s 15 -v


verbose="false"

while getopts l:s:vh optname # parameters with value have ':' after letter
do
    case "${optname}" in
        l) wait_log=${OPTARG};;
        s) min_wait=${OPTARG};;
        v) verbose="true";;
        h) echo "usage: wait.sh [ -l wait.log ] [ -w SECONDS ] "
            exit 0;;
    esac
done


## defaults
[ -z "$wait_log" ] && wait_log="wait.log" # default
[ -z "$min_wait" ] && min_wait=10 # default


if [ $verbose == true ]; then
    echo "wait_log: $wait_log"
    echo "min_wait: $min_wait"
fi



function time_to_epoch {
    echo $(date -d "$1" +"%s")
}

function epoch_to_time {
    echo $(date -d "@$1" +"%T")
}


now=$(date +%T) # time format (%H:%M:%S)
now=$(date +%s) # epoch format (seconds)
[ $verbose == true ] && echo -e "now:\t$now\t$(epoch_to_time $now) "



## now_time=$(epoch_to_time $now)
## echo $now_time

## now_time_now=$(time_to_epoch $now_time)
## echo "now: $now_time_now"



if [ -f "$wait_log" ]; then
    last=$(time_to_epoch $(tail -1 "$wait_log"))
    [ $verbose == true ] && echo -e "last:\t$last\t$(epoch_to_time $last)"
    goal=$((last + min_wait)) 
else
    echo -e "last:\tNA"
    goal=$((now + min_wait))
fi


[ $verbose == true ] && echo -e "goal:\t$goal\t$(epoch_to_time $goal)"
echo $(epoch_to_time $goal) >>"$wait_log"


delta=$((goal - now))
[ $verbose == true ] && echo -e "delta:\t$delta"


if [[ "$delta" -gt 0 ]]; then
    echo -e "sleep $delta"
    sleep "$delta"
fi

