#!/bin/bash

#Function to Monitor File Changes
monitor_file(){
	local file_path="$1"
	if [ ! -f "$file_path" ]
	then 
		echo "Error: File $file_path does not exist."
		exit 1
	fi

	# Get intial modification time of the file
	last_mod_time=$(stat -c %Y "$file_path")

	echo "Monitoring changes to file: $file_path"
	echo "Press CTRL+ C to stop"

	while true
	do
		# Get the current modification time
		current_mod_time=$(stat -c %Y "$file_path")
		
		#Check if the modification time has changed
		if [ "$current_mod_time" != "$last_mod_time" ]
		then 
			echo "The file '$file_path' was modified."
			last_mod_time=$current_mod_time
		fi

		#sleep for 1 sec before checking again
		sleep 1

	done
}


# Request file path from the user
read -p "Enter the path of the file to monitor: " file_path

monitor_file "$file_path"
