#!/bin/bash
# Works for MAC

function print_help() {
  echo "Usage: $0 [command] [all]"
  echo "Available commands:"
  echo "  uptime     Check system uptime and load"
  echo "  dmesg      Display latest system error messages"
  echo "  vm_stat    Run virtual memory statistics"
  echo "  top        Run CPU time breakdowns per CPU and overall system usage"
  echo "  iostat     Run disk IO statistics"
  echo "  netstat    Run network interface statistics"
  echo "  all        Run all commands except for top, and redirect to file."
}

function run_uptime() {
  echo "Checking uptime and load"
  uptime
}

function run_dmesg() {
  echo "Display latest system error messages"
  dmesg | tail
}

function run_vm_stat() {
  echo "Running virtual memory statistics"
  vm_stat
}

function run_top() {
  echo "Running CPU time breakdowns per CPU and overall system usage"
  top
}

function run_iostat() {
  echo "Running disk IO statistics..."
  iostat -c 5 -w 1 
}

function run_netstat() {
  echo "Checking network interface throughput"
  netstat -ibn | grep -v Name
}

function run_all() {
  timestamp=$(hostname)_$(date +%Y-%m-%d_%H-%M-%S)
  output_file="/tmp/${timestamp}_output.log"

  run_uptime > $output_file
  run_dmesg >> $output_file
  run_vm_stat >> $output_file
  run_iostat >> $output_file
  run_netstat >> $output_file

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
    elif [[ "$command" == "vm_stat" ]]; then
      run_vm_stat
    elif [[ "$command" == "top" ]]; then
      run_top
    elif [[ "$command" == "iostat" ]]; then
      run_iostat
    elif [[ "$command" == "netstat" ]]; then
      run_netstat
    else  # If no valid commands were matched
      print_help
    fi
  done
fi

