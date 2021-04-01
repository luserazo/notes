#!/bin/bash

## TODO 
## Find out why markserv process is being 
## disowned and reserve cleanup for system interrupts only
##

DATE=$(date '+%m_%d_%y')
FILE_NAME="$DATE.md"
LOG_DIR="${PWD}/var/log"
TMP_DIR="${PWD}/var/tmp"
PID_FILE="${TMP_DIR}/${DATE}.pid"

function cleanup {
	echo "Exit code: $?"
	echo "Cleaning Up...."
	if [ -f "${PID_FILE}" ]; then
		echo "Killing PID: $(cat "${PID_FILE}")"
		kill $(cat "${PID_FILE}")
		echo "Deleting PID File ${PID_FILE}"
		rm -f "${PID_FILE}"

	else
		echo "No File: ${PID_FILE} exists"
	fi
}

if [ -z "$(command -v markserv)" ]; then 
	echo "<<<Markserv not installed>>>"
	exit 1
fi

if [ -f "$FILE_NAME" ]; then
	echo "$FILE_NAME exists already."
	exit 1
else 
	if [ -f "${PID_FILE}" ]; then	
		echo "Removing Existing PID File: ${PID_FILE}"
		rm -f ${PID_FILE}
	fi
	echo "creating file: $FILE_NAME."
	printf "# Todo $(sed 's/_/-/g' <<< $DATE) (Work)\n " >> $FILE_NAME 
	mkdir -p "${LOG_DIR}"
	mkdir -p "${TMP_DIR}"
	markserv $FILE_NAME >> "${LOG_DIR}/${DATE}.log" 2>&1 & 
	echo $! >> "${PID_FILE}"
	vim $FILE_NAME 
	#fg # bring server to foreground 

fi
trap cleanup SIGINT SIGTERM KILL EXIT # remove exit after solving todo
