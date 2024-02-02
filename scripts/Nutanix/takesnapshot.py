#!/opt/hostedtoolcache/Python/3.10.11/x64/bin/python3.10

"""
Take snapshots of two test VMs in Nutanix client.  Deletes any existing snapshots on the hosts first.  Post success message to datadog
re-reqs: Add Prism central IP address, secrets to log in.
"""
__author__ = "LW"

import sys
import requests
import json
import os
import urllib3
from requests.auth import HTTPBasicAuth
from urllib3.exceptions import InsecureRequestWarning
from datetime import datetime
from datadog_api_client import ApiClient, Configuration
from datadog_api_client.v1.api.events_api import EventsApi
from datadog_api_client.v1.model.event_create_request import EventCreateRequest

urllib3.disable_warnings(InsecureRequestWarning)

prism_central_ip = ""
prism_central_username = os.environ.get('')
prism_central_password = os.environ.get('')

#API endpoints
api_endpoint = f"https://{prism_central_ip}:9440/api/nutanix/v3/vms/list"
vms_url = f"https://{prism_central_ip}:9440/api/nutanix/v3/vms"
snapshots_endpoint = f"https://{prism_central_ip}:9440/PrismGateway/services/rest/v2.0/snapshots/"
view_snapshots_endpoint = f"https://{prism_central_ip}:9440/PrismGateway/services/rest/v2.0/snapshots/?vm_uuid="

#Headers used for API calls
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

payload = {
    "kind": "vm",
    "length": 250
}

proxies = {
    "http": None,
    "https": None
}

#This is the function that creates a new snapshot
def create_snapshot(vm_uuid, snapshot_name, vm_name):
    snapshot_data = {
        "snapshot_specs": [
            {
                "snapshot_name": snapshot_name,
                "vm_uuid": vm_uuid
            }
        ]
    }

    snapshot_response = requests.post(
        snapshots_endpoint,
        headers=headers,
        json=snapshot_data,
        verify=False,
        proxies=proxies,
        auth=(prism_central_username, prism_central_password)
    )
    print("snapshot_response: ")
    print(snapshot_response)

    if snapshot_response.status_code == 201:
        print("Snapshot created successfully:", snapshot_name)
    else:
        print("Failed to create snapshot:", snapshot_name)
        print("Status code:", snapshot_response.status_code)

#This is the function that deletes an existing snapshot
def delete_snapshot(snapshot_uuid, snapshot_name, vm_name, vm_uuid):
    del_snapshot_url = snapshots_endpoint + snapshot_uuid
    snapshot_response = requests.delete(
        del_snapshot_url,
        headers=headers,
        verify=False,
        proxies=proxies,
        auth=(prism_central_username, prism_central_password)
    )
    print("snapshot_response: ")
    print(snapshot_response)

    if snapshot_response.status_code == 201:
        print("Snapshot deleted successfully")
        snapshot_name = f"{vm_name}_{datetime.now().strftime('%Y%m%d%H%M')}"
        print("Taking a new snapshot...")
        create_snapshot(vm_uuid, snapshot_name, vm_name)
    else:
        print("Failed to Delete snapshot:", snapshot_uuid, snapshot_name)
        print("Status code:", snapshot_response.status_code)

#Start of process here to find test VMs by hostname
response = requests.post(
    api_endpoint,
    headers=headers,
    json=payload,
    verify=False,
    proxies=proxies,
    auth=(prism_central_username, prism_central_password)
)

if response.status_code == 200:
    data = response.json()
    vm_list = data.get("entities", [])
    vm_names_to_search = ["test1", "test2"]
    found_vms = []

    for vm in vm_list:
        status = vm.get("status")
        metadata = vm.get("metadata")
        vm_name = status.get("name")
        vm_uuid = metadata.get("uuid")

        if vm_name in vm_names_to_search:
            found_vms.append(vm)

    for vm in found_vms:
        status = vm.get("status")
        metadata = vm.get("metadata")
        vm_name = status.get("name")
        vm_uuid = metadata.get("uuid")

        print("Found VM:")
        print("Name:", vm_name)
        print("UUID:", vm_uuid)
        print()

        snapshot_url = view_snapshots_endpoint + vm_uuid
        snapshot_response = requests.get(
            snapshot_url,
            headers=headers,
            verify=False,
            proxies=proxies,
            auth=(prism_central_username, prism_central_password)
        )

        if snapshot_response.status_code == 200:
            snapshot_data = snapshot_response.json()
            snapshots = snapshot_data.get("entities", [])

            if len(snapshots) > 0:
                print("Existing Snapshots:")
                for snapshot in snapshots:
                    snapshot_name = snapshot.get("snapshot_name")
                    snapshot_uuid = snapshot.get("uuid")
                    print("Snapshot Name:", snapshot_name)
                    print("Snapshot uuid:", snapshot_uuid)
                    print("This snapshot is going to be deleted and a new one created...")
                    delete_snapshot(snapshot_uuid, snapshot_name, vm_name, vm_uuid)

            else:
                print("No existing snapshots found.")
                print("Taking a new one....")
                snapshot_name = f"{vm_name}_{datetime.now().strftime('%Y%m%d%H%M')}"
                create_snapshot(vm_uuid, snapshot_name, vm_name)
        else:
            print("Failed to retrieve snapshots for VM:", vm_name)
            print("Status code:", snapshot_response.status_code)
        print()

else:
    print("Failed to retrieve VMs. Status code:", response.status_code)
