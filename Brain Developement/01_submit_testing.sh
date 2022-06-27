#!/bin/bash

# Usage: ./01_submit.sh <File with list of data> <Absolute path to directory>

cat $1 | while read LINE
do
	sh ./06_0MLCall.sh $LINE $2
done
