#!/bin/bash

# Get memory blocks from user
echo "Enter memory blocks (in MB, space-separated):"
read -a memory_blocks

# Get processes from user
echo "Enter process sizes (in MB, space-separated):"
read -a processes

# Backup original memory for reuse
original_memory=("${memory_blocks[@]}")

# First Fit
first_fit() {
    echo "=== First Fit ==="
    memory=("${original_memory[@]}")
    for p in "${processes[@]}"; do
        allocated=0
        for i in "${!memory[@]}"; do
            if [ "${memory[$i]}" -ge "$p" ]; then
                echo "Process $p MB allocated to block ${i} (${memory[$i]} MB)"
                memory[$i]=$(( memory[$i] - p ))
                allocated=1
                break
            fi
        done
        if [ "$allocated" -eq 0 ]; then
            echo "Process $p MB cannot be allocated"
        fi
    done
    echo
}

# Next Fit
next_fit() {
    echo "=== Next Fit ==="
    memory=("${original_memory[@]}")
    last_index=0
    for p in "${processes[@]}"; do
        allocated=0
        for ((j=0; j<${#memory[@]}; j++)); do
            i=$(( (last_index + j) % ${#memory[@]} ))
            if [ "${memory[$i]}" -ge "$p" ]; then
                echo "Process $p MB allocated to block ${i} (${memory[$i]} MB)"
                memory[$i]=$(( memory[$i] - p ))
                last_index=$i
                allocated=1
                break
            fi
        done
        if [ "$allocated" -eq 0 ]; then
            echo "Process $p MB cannot be allocated"
        fi
    done
    echo
}

# Best Fit
best_fit() {
    echo "=== Best Fit ==="
    memory=("${original_memory[@]}")
    for p in "${processes[@]}"; do
        best_index=-1
        for i in "${!memory[@]}"; do
            if [ "${memory[$i]}" -ge "$p" ]; then
                if [ "$best_index" -eq -1 ] || [ "${memory[$i]}" -lt "${memory[$best_index]}" ]; then
                    best_index=$i
                fi
            fi
        done
        if [ "$best_index" -ne -1 ]; then
            echo "Process $p MB allocated to block $best_index (${memory[$best_index]} MB)"
            memory[$best_index]=$(( memory[$best_index] - p ))
        else
            echo "Process $p MB cannot be allocated"
        fi
    done
    echo
}

# Worst Fit
worst_fit() {
    echo "=== Worst Fit ==="
    memory=("${original_memory[@]}")
    for p in "${processes[@]}"; do
        worst_index=-1
        for i in "${!memory[@]}"; do
            if [ "${memory[$i]}" -ge "$p" ]; then
                if [ "$worst_index" -eq -1 ] || [ "${memory[$i]}" -gt "${memory[$worst_index]}" ]; then
                    worst_index=$i
                fi
            fi
        done
        if [ "$worst_index" -ne -1 ]; then
            echo "Process $p MB allocated to block $worst_index (${memory[$worst_index]} MB)"
            memory[$worst_index]=$(( memory[$worst_index] - p ))
        else
            echo "Process $p MB cannot be allocated"
        fi
    done
    echo
}

first_fit
next_fit
best_fit
worst_fit
