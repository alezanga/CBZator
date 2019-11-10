#!/bin/bash

usage () {
    cat <<EOM
Usage: $(basename $0) [-h] <input_directory> <output_directory>
EOM
	exit 0
}

# Option -h dispays usage message and if not exactly 2 args promps error.
[[ $1 == -h ]] && { usage; } || [ $# -ne 2 ] && { echo "Wrong number of arguments."; usage; }

# Save input dir and output dir removing trailing /
INDIR=`realpath -s $1`
OUTDIR=`realpath -s $2`
TEMPDIR=$OUTDIR/temp
echo "Input dir = ${INDIR}"
echo "Output dir = ${OUTDIR}"
# Creates OUTDIR if it doesn't exists
if [ ! -d "$OUTDIR" ]
then
	mkdir $OUTDIR
fi
# Creates a temp/ folder inside OUTDIR if it does not exist, otherwise empties it.
if [ ! -d "$TEMPDIR" ]
then
	mkdir $TEMPDIR
else
	echo "Warning: deleting ${TEMPDIR} content..."
	rm -rf $TEMPDIR/*
	echo "Warning: ${TEMPDIR} already existed and content has been deleted."
fi
# Removes white spaces and strange characters from filenames
detox -r $INDIR

# Finds number of images in subfolders
N_IMG=`find "${INDIR}" -maxdepth 2 -type f -regex ".*.[jpg|jpeg]" | wc -l`
echo "Found ${N_IMG} images."
# Finds number of digit to use to pad numbers
N_DIGIT=${#N_IMG}

echo "Preparing files for compression..."
# Initialises counter to number each page (first page is number 1)
COUNT=1
# Lists all first level dirs sorted with version number sort (change sort options if something different is required)
# This command should return directories in the order in which they should be analyzed in order to produce the correct order of pages
for DIRNAME in `find "${INDIR}" -maxdepth 1 -type d | sort -V`;
do
	# Iterates over filenames of images in sorted numerical order, inside DIRNAME
	for FILENAME in `find "${DIRNAME}" -maxdepth 1 -type f -regex ".*.[jpg|jpeg]" | sort -V`;
	do
		# Copy and rename images inside TEMPDIR. Change 'cp' to 'mv' in order to delete original files.
		# Also applies zero padding as necessary (e.g. 1.jpg -> 0001.jpg)
		cp "${FILENAME}" "${TEMPDIR}/`printf \"%0${N_DIGIT}d\" ${COUNT}`.${FILENAME##*.}"
		# Next page will have increasing number.
		COUNT=`expr $COUNT + 1`
	done
done
COUNT=`expr $COUNT - 1`
echo "Done."
echo "Generating cbz archive with ${COUNT} images...can take time..."
# Produce archive with all files in dir. '-j' discard original folder structure
zip -j -q $OUTDIR/my_archive.cbz $TEMPDIR/*
rm -rf $TEMPDIR
echo "Produced cbz file."
# Opens output in file manager. Comment if desired.
# xdg-open $OUTDIR &