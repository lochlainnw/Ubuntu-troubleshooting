Usage: ./ubnsystemtroubleshooting.sh [command] [all]
Available commands:
  uptime       Check system uptime and load
  dmesg        Display latest system error messages
  vmstat       Run virtual memory statistics
  mpstat       Run CPU time breakdowns per CPU
  pidstat      Run pid statistics showing high CPU usage
  iostat       Run disk IO statistics
  free         Check installed memory and buffers/cache
  sar          Run network interface and TCP metrics
  top          Display a dynamic real-time view of running processes
  all          Run all commands except for top, and redirect to file.


The output will be saved in a file named like `hostname_YYYY-MM-DD_HH-MM-SS_output.log` in the `/tmp` directory.

## Prerequisites

- Linux environment Ubuntu preferably. 
- Required packages: `vmstat`, `mpstat`, `pidstat`, `iostat`, `sar`. The script attempts to install `sysstat` if `sar` is missing.
