#!/bin/bash

read -p "Enter Countdown Time: " time

while [[ $time -gt 0 ]]
do
	echo " CountDown Ends in : $time"
	sleep 1s
	let time--
done

