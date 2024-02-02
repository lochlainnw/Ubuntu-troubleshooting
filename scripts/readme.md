### Usage:

```bash
./ubnsystemtroubleshooting.sh [command] [all]


* `[command]`: Specifies the individual command to run (e.g., `uptime`, `dmesg`).
* `[all]`: Executes all commands except `top` and saves the combined output to a file.

### Available Commands:

| Command | Description |
|---|---|
| `uptime` | Checks system uptime and load. |
| `dmesg` | Displays the latest system error messages. |
| `vmstat` | Runs virtual memory statistics. |
| `mpstat` | Runs CPU time breakdowns per CPU. |
| `pidstat` | Runs pid statistics showing high CPU usage. |
| `iostat` | Runs disk IO statistics. |
| `free` | Checks installed memory and buffers/cache. |
| `sar` | Runs network interface and TCP metrics. |
| `top` | Displays a dynamic real-time view of running processes (not included in "all" output).


The output will be saved in a file named like `hostname_YYYY-MM-DD_HH-MM-SS_output.log` in the `/tmp` directory.

## Prerequisites

- Linux environment Ubuntu preferably. 
- Required packages: `vmstat`, `mpstat`, `pidstat`, `iostat`, `sar`. The script attempts to install `sysstat` if `sar` is missing.
