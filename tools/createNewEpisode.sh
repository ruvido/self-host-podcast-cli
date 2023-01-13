# install sox
# install jq (go version)
# pip install python-slugify
# pip install mutagen
#!/bin/bash
#----------------------------------------------
# CONFIG
#----------------------------------------------
SHOWDAY="Thursday" 
MEDIA="media"
RSS="rss"
EDITOR=vi
COVER=static/images/uomini-forti.jpg
#----------------------------------------------
#----------------------------------------------
HEADER=".header.yml"
TEXT="default.md"
FILE=$1
DATA=$2
if [ -z "$FILE" ]; then
	echo missing file
	exit
fi

#----------------------------------------------
if [ -z "$DATA" ]; then
	DATA="last_episode.md"

	echo Episode title?
	read TITLE

	SLUG=$(slugify $TITLE)
	SEASON=$(ls $MEDIA | grep  "^s." | wc -l)
	if [ -z "$(ls $MEDIA/s$SEASON)" ]; then
		NUMBER=1
	else
		NUMBER=$(ls $MEDIA/s$SEASON/*.mp3 | wc -l)
		NUMBER=$(( NUMBER + 1 ))
	fi
	SLUG=$NUMBER-$SLUG
	LENGTH=$(wc -c < $FILE)
	DURATION=$(soxi -D $FILE | awk '{printf "%.0f\n", $1}')
	DATE=$(date -d "next Thursday" +%Y-%m-%d)
	GUID=$DATE-$DURATION
	MP3FILE=$MEDIA/s$SEASON/$SLUG.mp3

	echo ""
	echo ""

#----------------------------------------------
	cat << EOF > $HEADER
---
title:    "$TITLE"
season:   $SEASON
number:   $NUMBER
date:     "$DATE"
file:     "$MP3FILE"
length:   $LENGTH
duration: $DURATION
guid:     "$GUID"           
slug:     "$SLUG"
---
EOF
cat $HEADER $TEXT > $DATA
$EDITOR $DATA
#----------------------------------------------

	echo [Enter to continue]
	read OK

else
	MP3FILE=$(yq '.file'   $DATA)
	SEASON=$( yq '.season' $DATA)
	NUMBER=$( yq '.number' $DATA)
	TITLE=$(  yq '.title'  $DATA)
	SLUG=$(   yq '.slug'   $DATA)
fi

#----------------------------------------------
cp $FILE $MP3FILE
mid3v2 \
	-a "Emanuele e Francesco" \
	-A "Realmen | Season $SEASON" \
	-t "$TITLE" \
	-c "Tempi duri forgiano uomini forti" \
	-g "podcast" \
	-y "2023" \
	-T "$NUMBER" \
	-p "$COVER:FRONT_COVER" \
	$FILE

#mid3v2 -l $MP3FILE

#----------------------------------------------
mdfolder=$RSS/episodes/s$SEASON
if [ ! -d  "$mdfolder" ]; then mkdir -p $mdfolder; fi
cp $DATA $mdfolder/$SLUG.md
