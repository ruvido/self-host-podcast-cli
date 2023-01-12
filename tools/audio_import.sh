#!/bin/bash
DIR=/run/media/ruvido/H6_SD/FOLDER01
IMP=_import
EPI=$*
if [ -z "$EPI" ]; then
	ls $DIR
	echo missing episode numbers
	exit
fi
ls -1 $IMP | tail -3
echo "-------------------"
echo Episode name?
read ENAME
for ii in $EPI; do
	#cp -rp 
	echo $ii $IMP/"$ENAME" 
	rsync -avz $DIR/ZOOM0$ii $IMP/"$ENAME"/
done

