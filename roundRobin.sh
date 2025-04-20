#!/bin/bash
read -p "Enter number of processes: " n
read -p "Enter Time Quantum: " tq
declare -a pid at bt rt ct tat wt st
for (( i=0; i<n; i++ ))
do
    pid[i]=$((i+1))
    read -p "Enter Arrival Time for Process ${pid[i]}: " at[i]
    read -p "Enter Burst Time for Process ${pid[i]}: " bt[i]
    rt[i]=${bt[i]}  
    st[i]=-1        
done
for ((i=0; i<n; i++)); do
    for ((j=i+1; j<n; j++)); do
        if (( at[i] > at[j] )); then
            temp=${at[i]}; at[i]=${at[j]}; at[j]=$temp
            temp=${bt[i]}; bt[i]=${bt[j]}; bt[j]=$temp
            temp=${rt[i]}; rt[i]=${rt[j]}; rt[j]=$temp
            temp=${pid[i]}; pid[i]=${pid[j]}; pid[j]=$temp
        fi
    done
done
time=0
completed=0
queue=()
timeline=()
in_queue=()
while (( completed < n )); do
    for (( i=0; i<n; i++ )); do
        if (( at[i] <= time && rt[i] > 0 && !in_queue[i] )); then
            queue+=($i)
            in_queue[i]=1
        fi
    done
    if (( ${#queue[@]} == 0 )); then
        timeline+=("IDLE")
        ((time++))
        continue
    fi
    idx=${queue[0]}
    queue=("${queue[@]:1}") 
    if (( st[idx] == -1 )); then
        st[idx]=$time
    fi
    if (( rt[idx] > tq )); then
        rt[idx]=$((rt[idx] - tq))
        time=$((time + tq))
        timeline+=("P${pid[idx]}")
    else
        time=$((time + rt[idx]))
        rt[idx]=0
        ct[idx]=$time
        tat[idx]=$((ct[idx] - at[idx]))
        wt[idx]=$((tat[idx] - bt[idx]))
        ((completed++))
        timeline+=("P${pid[idx]}")
    fi
    for (( i=0; i<n; i++ )); do
        if (( at[i] <= time && rt[i] > 0 && !in_queue[i] )); then
            queue+=($i)
            in_queue[i]=1
        fi
    done
    if (( rt[idx] > 0 )); then
        queue+=($idx)
    else
        in_queue[idx]=0
    fi
done
echo -e "\nProcess\tAT\tBT\tST\tCT\tWT\tTAT"
for (( i=0; i<n; i++ )); do
    echo -e "P${pid[i]}\t${at[i]}\t${bt[i]}\t${st[i]}\t${ct[i]}\t${wt[i]}\t${tat[i]}"
done
total_wt=0
total_tat=0
for (( i=0; i<n; i++ )); do
    total_wt=$((total_wt + wt[i]))
    total_tat=$((total_tat + tat[i]))
done
avg_wt=$(echo "scale=2; $total_wt / $n" | bc)
avg_tat=$(echo "scale=2; $total_tat / $n" | bc)
echo -e "\nAverage Waiting Time     = $avg_wt"
echo "Average Turnaround Time  = $avg_tat"
echo -e "\nGantt Chart:"
for task in "${timeline[@]}"; do
    echo -n "| $task "
done
echo "|"
