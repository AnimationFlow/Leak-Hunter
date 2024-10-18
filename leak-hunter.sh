#!/bin/bash

THRESHOLD=23
SCRIPT_PATH="/usr/local/bin/leak-hunter.sh"
CRON_JOB="* * * * * $SCRIPT_PATH"
TIMEOUT=21
LOG_FILE="/var/log/leak-hunter.log"

ehco
echo " === Leak Hunter ==="
ehco
echo " --- path : $(realpath "$0")"
ehco

hunt_leaks() {
    echo " --- Hunting leaks.."
    echo

    # Get the list of processes that exceed the memory threshold (in %)
    mapfile -t leaking_ps < <(ps -eo pid,%mem,cmd --sort=-%mem | awk -v threshold="$THRESHOLD" 'NR>1 { if ($2+0 > threshold) print $1 }')

    # Get detailed info of leaking processes with CPU and memory usage
    mapfile -t list < <(ps -eo pid,%cpu,%mem,cmd --sort=-%mem | awk -v threshold="$THRESHOLD" 'NR>1 { if ($3+0 > threshold) print $0 }')

    # Print column titles before listing processes
    echo " PID   %CPU   %MEM   CMD"
    echo "----------------------------"
    for entry in "${list[@]}"; do
        echo "$entry"
    done

    if [[ ${#leaking_ps[@]} -eq 0 ]]; then
        echo
        echo " --- $(date) - No ps > $THRESHOLD% memory usage" | tee -a $LOG_FILE
        return
    fi

    echo
    echo " --- Leaks detected :"
    echo

    for i in "${!leaking_ps[@]}"; do
        echo "  $((i + 1)). PID : ${leaking_ps[i]}"
    done

    # Ask each leaking process to stop nicely
    for pid in "${leaking_ps[@]}"; do
        echo " --- $(date) - Asking process $pid to stop nicely.." | tee -a $LOG_FILE
        kill -SIGTERM "$pid" 2>&1 | tee -a $LOG_FILE

        # Wait a few seconds to allow the process to terminate
        sleep 5

        # Check if the process is still running
        if ps -p "$pid" > /dev/null; then
            echo " --- $(date) - Process $pid did not respond, killing it.." | tee -a $LOG_FILE
            kill -SIGKILL "$pid" 2>&1 | tee -a $LOG_FILE
        else
            echo " --- $(date) - Process $pid terminated gracefully" | tee -a $LOG_FILE
        fi
    done
}

copy_script_if_needed() {
    if [[ "$(realpath "$0")" != "$SCRIPT_PATH" ]]; then
        echo " --- $(date) - Copying script to $SCRIPT_PATH" | tee -a $LOG_FILE
        cp "$(realpath "$0")" "$SCRIPT_PATH" 2>&1 | tee -a $LOG_FILE
        chmod +x "$SCRIPT_PATH" 2>&1 | tee -a $LOG_FILE
    fi
}

add_cron() {
    copy_script_if_needed
    if ! crontab -l | grep -q "$SCRIPT_PATH"; then
        (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
        echo " --- $(date) - Cron job added: $CRON_JOB" | tee -a $LOG_FILE
    else
        echo " --- $(date) - Cron job already exists" | tee -a $LOG_FILE
    fi
}

remove_cron() {
    current_cron=$(crontab -l | grep -v "$SCRIPT_PATH")
    echo "$current_cron" | crontab - 2>&1 | tee -a $LOG_FILE
    echo " --- $(date) - Cron job removed" | tee -a $LOG_FILE

    # Remove the script from the designated path if it's not running from there
    if [[ "$(realpath "$0")" != "$SCRIPT_PATH" ]]; then
        echo " --- $(date) - Removing script from $SCRIPT_PATH" | tee -a $LOG_FILE
        rm -f "$SCRIPT_PATH" 2>&1 | tee -a $LOG_FILE
    fi
}

display_menu() {
    clear
    echo
    echo " === Leak Hunter started @ $(date) ==="
    echo
    echo " --- Cron jobs for leak-hunter.sh :"
    echo
    crontab -l | grep "$SCRIPT_PATH" | nl
    echo
    echo "       a : Add a cron job"
    echo "       r : Remove a cron job"
    echo
    echo " default : Hunt Leaks"
    echo
    echo " timeout : $TIMEOUT s"
    echo

    read -t $TIMEOUT -p " ---> " choice
    echo

    if [[ "$choice" == "a" ]]; then
        add_cron
    elif [[ "$choice" == "r" ]]; then
        remove_cron
    elif [[ "$choice" != "" ]]; then
        echo " --- N/A : $choice"
        echo
    else
        hunt_leaks
    fi
    
    echo
    echo " === Leak Hunter go home @ $(date) ==="
    echo
}

display_menu
