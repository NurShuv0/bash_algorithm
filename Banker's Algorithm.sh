#!/bin/bash

num_processes=3
num_resources=2

declare -a available
declare -A max_demand
declare -A allocated
declare -A need

echo "Enter the available resources:"
for ((i = 0; i < num_resources; i++)); do
    read -p "Resource $((i + 1)): " available[$i]
done

echo "Enter the maximum demand for each process:"
for ((i = 0; i < num_processes; i++)); do
    echo "For Process $((i + 1))"
    for ((j = 0; j < num_resources; j++)); do
        read -p "Resource $((j + 1)): " max_demand[$i,$j]
    done
done

echo "Enter the currently allocated resources for each process:"
for ((i = 0; i < num_processes; i++)); do
    echo "For Process $((i + 1))"
    for ((j = 0; j < num_resources; j++)); do
        read -p "Resource $((j + 1)): " allocated[$i,$j]
    done
done


for ((i = 0; i < num_processes; i++)); do
    for ((j = 0; j < num_resources; j++)); do
        need[$i,$j]=$((${max_demand[$i,$j]} - ${allocated[$i,$j]}))
    done
done


function safety_algorithm {
    local work=("${available[@]}")
    local finish=()
    for ((i = 0; i < num_processes; i++)); do
        finish[$i]=0
    done

    local safe_sequence=()

    local i=0
    local count=0
    while [ $count -lt $num_processes ]; do
        if [ "${finish[$i]}" -eq 0 ] && [ "${need[$i,0]}" -le "${work[0]}" ] && [ "${need[$i,1]}" -le "${work[1]}" ]; then
            work[0]=$((${work[0]} + ${allocated[$i,0]}))
            work[1]=$((${work[1]} + ${allocated[$i,1]}))
            finish[$i]=1
            safe_sequence+=("$i")
            ((count++))
        fi

        ((i = (i + 1) % $num_processes))
    done

    if [ $count -eq $num_processes ]; then
        echo "System is in a safe state"
        echo "Safe Sequence: ${safe_sequence[@]}"
    else
        echo "System is in an unsafe state"
    fi
}