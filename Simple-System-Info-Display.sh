#!/bin/bash

current_user=$(whoami)
host_name=$(hostname)
operating_system=$(uname -o -r)

echo "You are logged in as : $current_user"
echo "Hostname your machine is : $host_name"
echo "Operating System  information is : $operating_system"
