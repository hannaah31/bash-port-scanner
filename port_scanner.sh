#!/bin/bash

# Function to display help
usage() {
    echo "Usage: $0 -h <host> -p <start_port>-<end_port>"
    echo "  -h <host>         Hostname or IP address to scan"
    echo "  -p <start_port>-<end_port>  Port range to scan (e.g., 1-65535)"
    exit 1
}

# Parse command line arguments
while getopts ":h:p:" opt; do
    case ${opt} in
        h )
            host=$OPTARG
            ;;
        p )
            port_range=$OPTARG
            ;;
        \? )
            usage
            ;;
        : )
            echo "Invalid option: -$OPTARG requires an argument" >&2
            usage
            ;;
    esac
done

# Check if host and port_range are set
if [ -z "${host}" ] || [ -z "${port_range}" ]; then
    usage
fi

# Extract start and end ports from the range
IFS="-" read -r start_port end_port <<< "$port_range"

# Check if port range is valid
if ! [[ "$start_port" =~ ^[0-9]+$ ]] || ! [[ "$end_port" =~ ^[0-9]+$ ]] || [ "$start_port" -gt "$end_port" ]; then
    echo "Invalid port range"
    exit 1
fi

# Perform the port scan
echo "Scanning ports ${start_port}-${end_port} on host ${host}..."

for ((port=start_port; port<=end_port; port++)); do
    timeout 1 bash -c "echo > /dev/tcp/${host}/${port}" 2>/dev/null && echo "Port ${port} is open"
done
