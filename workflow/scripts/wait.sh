#!/usr/bin/env bash


## usage: wait.sh wait.log
## usage: wait.sh wait.log 15


wait_log="$1"
[ -z "$wait_log" ] && wait_log="wait.log" # default


min_wait="$2"
[ -z "$min_wait" ] && min_wait=10 # default


now=$(date +%s)
## echo "now: $now"


if [ -f "$wait_log" ]; then
    last=$(tail -1 "$wait_log")
    ## echo "last: $last"
    goal=$((last + min_wait)) 
else
    ## echo "last: NA"
    goal=$((now + min_wait)) 
fi


## echo "goal: $goal"
echo $goal >>"$wait_log"

elapsed=$((goal - now))
## echo "elapsed: $elapsed"


delta=$((goal - now))
## echo "delta: $delta"


if [[ "$delta" -gt 0 ]]; then
    echo "sleep $delta"
    sleep "$delta"
fi

