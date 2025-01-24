#!/bin/bash

# Create an array of fortunes
fortunes=(
    "You will find great success in your next project."
    "An unexpected opportunity is headed your way."
    "Hard work pays off; stay consistent and watch the rewards roll in."
    "The solution you seek will come to you when you least expect it."
    "You will meet someone who will greatly influence your career path."
    "Keep learning, and the future will always remain bright for you."
    "Trust your instincts; they are sharper than you realize."
    "A new skill you learn today will open doors tomorrow."
    "Your dedication will inspire others around you."
    "Something you’ve been waiting for will finally happen soon."
)

while true
do
	# Randomly pick a fortune
	echo "${fortunes[$RANDOM % ${#fortunes[@]}]}"
	sleep 3
	read -p "Do you want to Another Continue(Y/N): " Another_Fortune
	if [ "$Another_Fortune" == "Y" ]
	then
		continue
	elif [ "$Another_Fortune" == "N" ]
	then 
		exit 1
	else
		echo "Invalid Option"
	fi
done
