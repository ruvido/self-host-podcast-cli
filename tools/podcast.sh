#!/bin/bash
DEBUG=true
if [ "$2" == "export" ]; then 
	DEBUG=false; 
	CLEAN=true
fi
#--------------------------------
speaker_name[1]="gt1"  # track-1: guest 1 
speaker_name[2]="gt2"  # track-2: guest 1
speaker_name[3]="ruv"  # track-3: ruvido
speaker_name[4]="ale"  # track-4: alescanca
#--------------------------------
master_volume="-v 1.5"
declare -A volume
volume[gt1]="-v 1.0"
volume[gt2]="-v 1.0"
volume[ruv]="-v 1.5"
volume[ale]="-v 1.2"
#--------------------------------
DIR=$1
if [ -z "$DIR" ]; then
	echo missing episode folder
	exit
fi
#--------------------------------
mp3_export="_export/$(basename $DIR).mp3"
#--------------------------------
# Number of tracks 
# - (todo) ADD number of speakers
#--------------------------------
shopt -s nullglob
audiofd=($DIR/Z*/)
shopt -u nullglob
NTRACKS=${#audiofd[@]}
if [ "$NTRACKS" -gt 2 ]; then
	echo "Too many tracks (>2)"
	exit
fi
if [ "$NTRACKS" -gt 1 ]; then
	INTRO=true
fi
NINTRO=${audiofd[0]:(-4):(3)}
NEPISO=${audiofd[1]:(-4):(3)}
#--------------------------------
# check number of speakers
list_of_speakers=""
for ii in $(seq 4); do
	chk_file=$DIR"/ZOOM0$NEPISO/ZOOM0$NEPISO""_Tr$ii.WAV"
	if [ -f "$chk_file" ]; then
		list_of_speakers=$list_of_speakers" ${speaker_name[$ii]}"
	fi
done
echo $list_of_speakers
#--------------------------------
intro_message="templates/intro-message.mp3"
mood_musiccut="templates/mood-music-cut.mp3"
final_message="templates/final-message.mp3"
#--------------------------------
intro_gt1=$DIR"/ZOOM0$NINTRO/ZOOM0$NINTRO""_Tr1.WAV"
intro_gt2=$DIR"/ZOOM0$NINTRO/ZOOM0$NINTRO""_Tr2.WAV"
intro_ruv=$DIR"/ZOOM0$NINTRO/ZOOM0$NINTRO""_Tr3.WAV"
intro_ale=$DIR"/ZOOM0$NINTRO/ZOOM0$NINTRO""_Tr4.WAV"
#--------------------------------
episo_gt1=$DIR"/ZOOM0$NEPISO/ZOOM0$NEPISO""_Tr1.WAV"
episo_gt2=$DIR"/ZOOM0$NEPISO/ZOOM0$NEPISO""_Tr2.WAV"
episo_ruv=$DIR"/ZOOM0$NEPISO/ZOOM0$NEPISO""_Tr3.WAV"
episo_ale=$DIR"/ZOOM0$NEPISO/ZOOM0$NEPISO""_Tr4.WAV"
#--------------------------------
trim=""
#---[ DEBUG SETTINGS ]--------
if $DEBUG; then
	echo DEBUG
	trim="trim 0 20"
	mp3_export="debug.mp3"
	CLEAN=false
fi
#--------------------------------
sox_components=""
for phase in intro episo; do
	echo $phase
	trim_phase=$trim
	if [ "$phase" == "intro" ]; then
		trim_phase=""
	fi
	if [ "$phase" == "episo" ]; then
		sox_components=$mood_musiccut
	fi
	for speaker in $list_of_speakers; do
		af=$phase"_"$speaker
		audio_file=${!af}
		sox ${volume[$speaker]} $audio_file $speaker.wav channels 2 $trim_phase
		sox_components=$sox_components" "$speaker.wav
	done
	echo $sox_components
	merge_cmd=""
	n_comps=$(wc -w <<< $sox_components)
	if [ $((n_comps)) -gt 1 ]; then
		merge_cmd="-m"
	fi
	sox $master_volume $merge_cmd $sox_components $phase.mp3
done
sox \
	intro.mp3 \
	$intro_message \
	episo.mp3 \
	$final_message \
	$mp3_export

# -------------------------------------------------------
for speaker in $list_of_speakers; do
	rm $speaker.wav
done
if $CLEAN; then
	echo folder cleaned!
	rm debug.mp3 intro.mp3 episo.mp3
fi
echo "Podcast file ---> $mp3_export"

