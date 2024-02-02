./ubnsystemtroubleshooting.sh all


The output will be saved in a file named like `hostname_YYYY-MM-DD_HH-MM-SS_output.log` in the `/tmp` directory.

## Prerequisites

- Linux environment Ubuntu preferably. 
- Required packages: `vmstat`, `mpstat`, `pidstat`, `iostat`, `sar`. The script attempts to install `sysstat` if `sar` is missing.
