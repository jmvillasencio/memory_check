#!/bin/bash

lineSep="\n\n###########################################"
TOTAL_MEMORY=$(free | grep Mem: | awk '{print $2}')
USED_MEMORY=$(free | grep Mem: | awk '{print ($3/$2)*100}')
FREE_NEMORY=$(free | grep Mem: | awk '{print ($4/$2)*100}')
wThresh=""
cThresh=""
userMail=""
warnFlag=""
critFlag=""

getWarn(){
	wThresh=$1
	echo "Current warning threshold set to : $wThresh"
}

getCrit(){
	cThresh=$1
	echo "Current critical threshold set to : $cThresh"
}

getEmail(){
	userMail=$1
	echo "Email address: $userMail"
}

critMail(){
	toDate=$(date +'%Y%m%d %H:%M')
	SUBJECT="$toDate memory check - critical"
	scriptDir=$(pwd)
	top -b -n 2 -o %MEM | sed -n '7,17p' > $scriptDir/top10.txt
	cat $scriptDir/top10.txt | mailx -r taffertywilliams@gmail.com -s "$SUBJECT" $userMail
}

while getopts "w:c:e:" options; do
	case "${options}" in
		w)
			getWarn ${OPTARG};
			if ! [[ $wThresh =~ [0-9] ]]; then
				echo -e $lineSep
				echo "Warning Threshold is required [1-100]!"
				exit 4
			fi;;

		c)
			getCrit ${OPTARG};
			if ! [[ $cThresh =~ [0-9] ]]; then
				echo -e $lineSep
				echo "Critical Threshold is required [1-100]!"
				exit 4
			fi;;

		e)
			getEmail ${OPTARG};;

		*)
			echo "Invald Parameter / Argument Detected!" ; 
			exit 3;;
	esac
done


if [ "cThresh" == "" ]; then
	echo "Critical Threshold is required, user the parameter -c (e.g. -c 70)"
	exit 4

elif [ "$wThresh" == "" ]; then
	echo "Warning Threshold is required, user the parameter -w (e.g. -w 70)"
	exit 4

elif [ "$userMail" == "" ]; then
	echo "User email is required for the critical notification, use the parameter -e."
	exit 4
fi


if [ $cThresh -lt $wThresh ]; then
	echo -e $lineSep
	echo "Critical Threshold should be always greater than Warning Threshold!"
	exit 5
fi

warnFlag=$(echo $USED_MEMORY $wThresh $cThresh | awk '{if ($1 >= $2 && $1 < $3) print '1'; else print '0'}')

critFlag=$(echo $USED_MEMORY $cThresh | awk '{if ($1 >= $2) print '1'; else print '0'}')

if [ $warnFlag -eq 1 ]; then
	echo -e $lineSep
	echo "Memory Utilization Status: WARNING!"
	echo "Current Memory Usage: $USED_MEMORY"
	exit 1

elif [ $critFlag -eq 1 ]; then
	echo -e $lineSep
	critMail
	echo "Memory Utilization Status: CRITICAL!"
	echo "Current Memory Usage: $USED_MEMORY"
	exit 2

else
	echo -e $lineSep
	echo "Memory Utilization Status: NORMAL"
	echo "Current Memory Usage: $USED_MEMORY"
	exit 0
fi

exit 0




			










