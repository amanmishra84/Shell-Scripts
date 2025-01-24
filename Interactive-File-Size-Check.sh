#!/bin/bash

read -p "Enter File Path: " filepath

filesize=$(du -s $filepath)

echo "FileSize is $filesize"


