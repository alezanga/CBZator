#!/bin/bash

usage () {
    cat <<EOM
Usage: $(basename $0) [-h] <input_directory> <output_directory>
EOM
	exit 0
}

# Option -h dispays usage message
[ -h $1 ] && { usage; }
# If not exactly 2 args show usage.
[ $# -ne 2 ] && { usage; }

# START_SCRIPT

# Save input dir and output dir removing trailing /
# !NOTE: DO NOT give path with spaces inside as OUTDIR (second arg)
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
# Initialises counter to number each page (first page is number 1)
COUNT=1
# Lists all first level dirs sorted with version number sort (change sort options if something different is required)
# This command should return directories in the order in which they should be analyzed in order to produce the correct order of pages
for DIRNAME in `find "${INDIR}" -maxdepth 1 -type d | sort -V`;
do
	# Iterates over filenames of images in sorted numerical order, inside DIRNAME
	for FILENAME in `find "${DIRNAME}" -maxdepth 1 -type f -name "*.jpg" | sort -V`;
	do
		# Copy and rename images inside TEMPDIR. Change 'cp' to 'mv' in order to delete original files.
		# Adjust zero padding accordingly: '%05d' is a 5 digit integer. Increase 5 to 6,7.. if necessary.
		cp "${FILENAME}" "${TEMPDIR}/`printf \"%05d\" ${COUNT}`.${FILENAME##*.}"
		# Next page will have increasing number.
		COUNT=`expr $COUNT + 1`
	done
done
echo "Generated ${COUNT} files."
echo "Generating cbz archive...could take time..."
# Produce archive with all files in dir. '-j' discard original folder structure
zip -j -q $OUTDIR/my_archive.cbz $TEMPDIR/*
rm -rf $TEMPDIR
echo "Produced cbz file."
# Opens output in file manager. Comment if desired.
xdg-open $OUTDIR &

# END_SCRIPT