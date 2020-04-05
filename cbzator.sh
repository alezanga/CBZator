#!/bin/bash

usage () {
    cat <<EOM
Usage: $(basename $0) [-h] [-m <archive_name> <input_directory>] [<input_directory> <output_directory>]
EOM
}

# Global variables
FILE_PATTERN='.*.[jpg|jpeg|JPG|JPEG]'
OUT_NAME='my_archive.cbz'

# Needs two arguments, the INDIR with the images to compress and OUTDIR
createArchive () {
	# Save input dir and output dir removing trailing /
	local INDIR="$1"
	local OUTDIR="$2"
	local TEMPDIR="$OUTDIR/temp"
	echo "Input dir = ${INDIR}"
	echo "Output dir = ${OUTDIR}"

	# Creates a temp/ folder inside OUTDIR if it does not exist, otherwise empties it.
	if [ ! -d "$TEMPDIR" ]
	then
		mkdir $TEMPDIR
	else
		echo "Warning: deleting ${TEMPDIR} content..."
		rm -rf $TEMPDIR/*
		echo "Warning: ${TEMPDIR} already existed and content has been deleted."
	fi

	# Finds number of images in subfolders
	local N_IMG=`find "$INDIR" -maxdepth 2 -type f -regex $FILE_PATTERN | wc -l`
	echo "Found $N_IMG images."
	# Finds number of digit to use to pad numbers
	local N_DIGIT=${#N_IMG}

	echo "Preparing files for compression..."
	# Initialises counter to number each page (first page is number 1)
	local COUNT=1
	# Lists all first level dirs sorted with version number sort (change sort options if something different is required)
	# This command should return directories in the order in which they should be analyzed in order to produce the correct order of pages
	# Use process substitution
	while IFS= read -r -d '' DIRNAME; do
		echo "Dir: $DIRNAME"
		while IFS= read -r -d '' FILENAME; do
			echo "File: $FILENAME"
			# Copy and rename images inside TEMPDIR. Change 'cp' to 'mv' in order to delete original files.
			# Also applies zero padding as necessary (e.g. 1.jpg -> 0001.jpg)
			# Extension will be lowercase (e.g. JPG -> jpg)
			EXT=${FILENAME##*.}
			cp "${FILENAME}" "${TEMPDIR}/`printf \"%0${N_DIGIT}d\" ${COUNT}`.${EXT,,}"
			# Next page will have increasing number.
			COUNT=`expr $COUNT + 1`
		done< <(find "$DIRNAME" -maxdepth 1 -type f -regex $FILE_PATTERN -print0 | sort -z -V)
	done< <(find "$INDIR" -maxdepth 1 -type d -print0 | sort -z -V)

	COUNT=`expr $COUNT - 1`
	echo "Done."
	echo "Generating cbz archive with $COUNT images...can take time..."
	# Produce archive with all files in dir. '-j' discard original folder structure
	zip -j -q $OUTDIR/$OUT_NAME $TEMPDIR/*
	rm -rf $TEMPDIR
	echo "Produced cbz file."
	# Opens output in file manager. Uncomment if desired.
	# xdg-open $OUTDIR &
}

if [ "$1" == "-h" ]
then
	usage;
	exit 0
elif [ "$1" == "-m" ] || [ "$1" == "--merge" ]
then
	[ $# -ne 3 ] && { echo "Error: wrong number of arguments."; usage; exit 1; }
	[ ! -f "$2" ] && { echo "Error: merge option require the target archive in second parameter."; usage; exit 1; }
	INDIR=`realpath -s "$3"`
	[ ! -d "$INDIR" ] && { echo "Error: $INDIR is not a valid input directory."; exit 1; }
	echo "Merging $2 with $INDIR..."
	# Take directory of archive to merge
	OUTDIR=`realpath -s $(dirname "$2")`
	TEMPDIR=$OUTDIR/tmpfolder
	TEMPDIR1=$TEMPDIR/tmp1
	TEMPDIR2=$TEMPDIR/tmp2
	if [ ! -d "$TEMPDIR1" ]; then mkdir --parents $TEMPDIR1; else rm -rf $TEMPDIR1/*; fi
	if [ ! -d "$TEMPDIR2" ]; then mkdir --parents $TEMPDIR2; else rm -rf $TEMPDIR2/*; fi
	# Unzip all archive files into tmp1
	unzip -j -q $2 -d $TEMPDIR1
	# Move every file to add in tmp2
	find "$INDIR" -mindepth 1 -maxdepth 2 -type f -regex $FILE_PATTERN -print0 | sort -V | \
		while IFS= read -r -d '' FILENAME; do
			cp "$FILENAME" $TEMPDIR2
		done
	createArchive "$TEMPDIR" "$OUTDIR"
	# Delete tmp folder
	rm -rf $TEMPDIR
	exit 0
elif [ $# -eq 2 ]
then
	INDIR=`realpath -s "$1"`
	[ ! -d "$INDIR" ] && { echo "Error: $INDIR is not a valid input directory."; exit 1; }
	OUTDIR=`realpath -s "$2"`
	# Creates OUTDIR if it doesn't exists
	if [ ! -d "$OUTDIR" ]; then mkdir --parents $OUTDIR;
	else
		# Ask for confirmation if the output file already exists
		if [ -f "$OUTDIR/$OUT_NAME" ]
		then
			echo "Warning: output file '$OUTDIR/$OUT_NAME' is already present and will be deleted."
			read -p "Do you want this to happen (y/n)? Press 'n' to abort. " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
			    rm -f "$OUTDIR/$OUT_NAME"
			    echo "Deleted."
			else
				echo
				echo "Aborted."
				exit 0
			fi
		fi
	fi

	createArchive "$INDIR" "$OUTDIR"
	exit 0
else
	echo "Wrong usage. See -h option."
	exit 1
fi