#!/bin/bash

read -p "Enter number of processes: " n
declare -a pid bt at st wt tat rt ct

for (( i=0; i<n; i++ ))
do
    pid[i]=$((i+1))
    read -p "Enter Arrival Time for Process ${pid[i]}: " at[i]
    read -p "Enter Burst Time for Process ${pid[i]}: " bt[i]
done

for ((i=0; i<n; i++)); do
    for ((j=i+1; j<n; j++)); do
        if (( at[i] > at[j] )); then
            temp=${at[i]}; at[i]=${at[j]}; at[j]=$temp
            temp=${bt[i]}; bt[i]=${bt[j]}; bt[j]=$temp
            temp=${pid[i]}; pid[i]=${pid[j]}; pid[j]=$temp
        fi
    done
done

time=0
for (( i=0; i<n; i++ ))
do
    if (( time < at[i] )); then
        time=${at[i]}
    fi

    st[i]=$time
    wt[i]=$((time - at[i]))
    rt[i]=${wt[i]}
    time=$((time + bt[i]))
    ct[i]=$time
    tat[i]=$((ct[i] - at[i]))
done

echo -e "\nProcess\tAT\tBT\tST\tCT\tWT\tTAT\tRT"
for (( i=0; i<n; i++ ))
do
    echo -e "P${pid[i]}\t${at[i]}\t${bt[i]}\t${st[i]}\t${ct[i]}\t${wt[i]}\t${tat[i]}\t${rt[i]}"
done

total_wt=0
total_tat=0
total_rt=0

for (( i=0; i<n; i++ ))
do
    total_wt=$((total_wt + wt[i]))
    total_tat=$((total_tat + tat[i]))
    total_rt=$((total_rt + rt[i]))
done

avg_wt=$(echo "scale=2; $total_wt / $n" | bc)
avg_tat=$(echo "scale=2; $total_tat / $n" | bc)
avg_rt=$(echo "scale=2; $total_rt / $n" | bc)

echo -e "\nAverage Waiting Time     = $avg_wt"
echo "Average Turnaround Time  = $avg_tat"
echo "Average Response Time    = $avg_rt"

echo -e "\nGantt Chart:"
echo -n "|"
for (( i=0; i<n; i++ ))
do
    if (( i > 0 && st[i] > ct[i-1] )); then
        echo -n "  IDLE  |"
    fi
    printf "  P${pid[i]}  |"
done
echo

echo -n "${st[0]}"
for (( i=0; i<n; i++ ))
do
    if (( i > 0 && st[i] > ct[i-1] )); then
        printf "     ${st[i]}"
    fi
    printf "     ${ct[i]}"
done
echo -e "\n"