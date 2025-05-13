#!/bin/bash

# Assinging colors for message output
RED='\033[0;31m'
NC='\033[0m'

# Get directory in which this script is being called
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "${RED} Your MF.matR clone is installed locally in${NC} $DIR\n"

echo -e "***${RED}Make sure you are in the parent folder for the files you want to register,\n 
only files with MMStack_Pos0.ome in the filename will be registered${NC}***\n
"

### Check if Fiji is in standard location does not exist ###
if [ ! -d "/Applications/Fiji.app/Contents/MacOS/" ] 
then
    echo "Fiji installed in a non-standard location, should be /Applications/Fiji.app" 
    exit 9999 # die with error code 9999
fi

cp $DIR/registerGCaMP_auto_batch.ijm /Applications/Fiji.app/macros/ 

prominence=$1

register_auto() {
	local filename=$1
	/Applications/Fiji.app/Contents/MacOS/ImageJ-macosx -batch registerGCaMP_auto_batch.ijm $filename $prominence
}

export -f register_auto

# Get files recursively from the current folder position:
files=$(find ~+ -name "*ome.tif*") 
#| { while read i; do dirname $i; done })

#print names of files to be registered
echo $files

# Do the registration
for i in $files; do
	echo -e "${RED} Registering file $i with prominence $prominence${NC}"
	register_auto "$i,$prominence"
done

