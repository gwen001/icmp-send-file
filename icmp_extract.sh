#!/bin/bash

function usage() {
  echo "Usage: "$0" <file_to_transfer> [<send n packet>]" 
  if [ -n "$1" ] ; then
    echo "Error: "$1"!"
  fi
  exit
}

function extract() {
  data=$1
  packet_size=$[$2*2]
  offset=$[$3*2]
  data_size=$4
  strlen=${#data}
  n_packet=$[$strlen/$packet_size]
  i=0

  while [ $i -lt $n_packet ] ; do
    pos=$[$i*$packet_size+$offset]
    str=$str${data:$pos:$data_size}
    i=$[$i+1]
  done

  echo $str
}


if ! [ $# -eq 1 ] ; then
  usage
fi

file=$1
if ! [ -f $file ] ; then
  usage "file not found"
fi

sep="\*\*\*"
offset=58
packet_size=98
data_size=16
step=$[$packet_size-$offset-$data_size]
data=`cat $file | grep -v "echo request" | cut -d ':' -f 2 | tr -d [:space:]`

str=$(extract $data $packet_size $offset $data_size)
decrypt=`echo $str | perl -e 'local $/; print pack "H*", <>'`
dest=`echo $decrypt | awk -F $sep '{print $2}'`
txt=`echo $decrypt | awk -F $sep '{print $3}'`

echo $txt | base64 -d | tr ' ' '\n' > $dest
exit


