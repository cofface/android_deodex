#!/bin/bash
#
# Deodex for android 6.0
# Author:cofface@foxmail.com

WORKDIR=$(pwd)
output=$WORKDIR/output

if [ -f "DeodexJarList.txt" ]; then
	rm DeodexJarList.txt
fi

if [ -f "classes.dex" ]; then
	rm classes.dex
fi

if [ ! -f "boot.oat" ]; then
	echo "error:please put boot.oat!"
	exit 1;
fi

if [ -d $output ]; then
	rm -rf $output/*
fi

if [ ! -d $output ]; then
	mkdir $output
fi

#deodex jar files
(ls *.jar | grep -v 'baksmali.jar' | grep -v 'smali.jar') > $WORKDIR/DeodexJarList.txt;
cat $WORKDIR/DeodexJarList.txt | while read line;
do
#echo $line
filename=${line%.*}
if [ ! -f "$filename.odex" ]; then
	echo "warning:hadn't found $filename.odex!"
fi

if [ -f "$filename.odex" ]; then
#echo $filename
    if [ -d $filename ]; then
	rm -rf $filename
    fi
    echo "Deodex $filename ..."
    java -jar baksmali.jar -a 23 -x -c boot.oat -d . -b -s $filename.odex -o $filename
    java -jar smali.jar -a 23 -j 1 -o classes.dex $filename
    jar -cvf $filename.jar classes.dex 1> /dev/null 2> /dev/null 
fi
mv $filename.jar $output/$filename.jar

#clean files
rm -rf $filename
rm -rf classes.dex
rm -rf $filename.odex

done

rm -rf DeodexJarList.txt
echo "Done."
