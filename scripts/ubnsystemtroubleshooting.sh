#!/bin/bash

function print_help() {
    echo "Usage: $0 [command] [all]"
    echo "Available commands:"
    echo "  uptime       Check system uptime and load"
    echo "  dmesg        Display latest system error messages"
    echo "  vmstat       Run virtual memory statistics"
    echo "  mpstat       Run CPU time breakdowns per CPU"
    echo "  pidstat      Run pid statistics showing high CPU usage"
    echo "  iostat       Run disk IO statistics"
    echo "  free         Check installed memory and buffers/cache"
    echo "  sar          Run network interface and TCP metrics"
    echo "  top          Display a dynamic real-time view of running processes"
    echo "  all          Run all commands except for top, and redirect to file."
}

function check_package() {
   if ! command -v "$1" &> /dev/null; then
       echo "Package '$1' not found. Please install it."
       return 1
   fi
}

function run_uptime() {
   echo "Checking uptime and load"
   if [ $? -eq 0 ]; then
       uptime
   fi
}

function run_dmesg() {
   echo "Display latest system error messages"
   if [ $? -eq 0 ]; then
       dmesg | tail
   fi
}

function run_vmstat() {
   check_package vmstat
   echo "Running virtual memory statistics"
   if [ $? -eq 0 ]; then
       vmstat 1 5
   fi
}

function run_mpstat() {
   check_package mpstat
   echo "Running CPU time breakdowns per CPU, which can be used to check for an imbalance. A single hot CPU can be evidence of a single-threaded application."
   if [ $? -eq 0 ]; then
       mpstat -P ALL 1 5
   fi
}

function run_pidstat() {
   check_package pidstat
   echo "Running pid statistics that show if there are any processes running high CPU.  Similar to top"
   if [ $? -eq 0 ]; then
       pidstat 1 5
   fi
}

function run_iostat() {
   check_package iostat
   echo "Running disk IO statistics..."
   if [ $? -eq 0 ]; then
       iostat -xz 1 5
   fi
}

function run_free() {
   echo "Checking Memory installed on the server. Ensure Buffers and Cache are not near zero as this could lead to high DISK IO which can be seen in iostat command"
   if [ $? -eq 0 ]; then
       free -m
   fi
}

function run_sar() {
    check_package sar
    if [ $? -eq 0 ]; then
        echo "Checking network interface throughput: rxkB/s and txkB/s, as a measure of workload. Also to check if any limit has been reached:"
        sar -n DEV 1 2
        echo "Summarized view of some key TCP metrics, May show measure of system load. Number of new accepted connections (passive), and number of downstream connections (active)"
        sar -n TCP,ETCP 1 2
    else
        echo "Installing sysstat package to provide sar..."
        sudo apt install sysstat -y  # Install silently with -y flag
        if [ $? -eq 0 ]; then
            echo "sar installed successfully. Re-running command..."
            run_sar  # Recursively call the function to execute sar now
        else
            echo "Failed to install sysstat. Please try installing manually."
        fi
    fi
}


function run_top() {
   check_package top
   if [ $? -eq 0 ]; then
       top
   fi
}


function run_all() {
   timestamp=$(hostname)_$(date +%Y-%m-%d_%H-%M-%S)
   output_file="/tmp/${timestamp}_output.log"

   run_uptime > $output_file
   run_dmesg >> $output_file
   run_sar >> $output_file
   run_iostat >> $output_file
   run_pidstat >> $output_file
   run_free >> $output_file
   run_mpstat >> $output_file
#   run_vmstat >> $output_file

   echo "All outputs are saved to $output_file"

}

if [[ $# -eq 0 || "$1" == "all" ]]; then
   run_all
else
   for command in "$@"; do
       if [[ "$command" == "uptime" ]]; then
           run_uptime
       elif [[ "$command" == "dmesg" ]]; then
           run_dmesg
       elif [[ "$command" == "sar" ]]; then
           run_sar
       elif [[ "$command" == "iostat" ]]; then
           run_iostat
       elif [[ "$command" == "pidstat" ]]; then
           run_pidstat
       elif [[ "$command" == "free" ]]; then
           run_free
       elif [[ "$command" == "mpstat" ]]; then
           run_mpstat
       elif [[ "$command" == "vmstat" ]]; then
           run_vmstat
       elif [[ "$command" == "top" ]]; then
           run_top
       else  # If no valid commands were matched
           print_help
       fi
   done
fi
