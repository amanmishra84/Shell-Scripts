#!/bin/shell
date=$(date +"%A, %d %B %Y %R")
user=$(whoami)

while true
do
	echo "Welcome,$user! Its $date"
	sleep 60s
done

