# takesnapshot.py

## Overview

This script automates the process of taking snapshots of two test VMs in a Nutanix environment and posting a success message to Datadog.

## Key Features

- Automatically deletes any existing snapshots on the target VMs before creating new ones.
- Posts a success message to Datadog upon successful completion.

## Prerequisites

- Nutanix Prism Central IP address
- Credentials (username and password) for logging into Prism Central
- Datadog API and application key for posting messages
- Proxy settings if applicable

## Usage

1. Install python and the libraries needed
   
2. Update the script with your Nutanix and Datadog credentials:
   - Set the `PRISM_CENTRAL_IP` variable to your Prism Central IP address.
   - Set the `PRISM_USER` and `PRISM_PASSWORD` variables to your Nutanix credentials.
   - Set the `DATADOG_API_KEY` and `DATADOG_APP_KEY` variables to your Datadog API and application keys.
3. Run the script:
   python takesnapshot.py
