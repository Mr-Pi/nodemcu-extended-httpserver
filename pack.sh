#!/bin/bash
fwfile=$(date +%Y%m%d.fw)
paths="."
if [ $# -ge 1 ]; then
	if [ "${1: -3}" == ".fw" ]; then
		fwfile=$1
		shift
		if [ $# -ge 1 ]; then
			paths=$@
		fi
	else
		paths=$@
	fi
fi
echo "packing firmware into: $fwfile"
if [ -f "$fwfile" ]; then
	rm -i "$fwfile"
fi

function packFile {
file=$*
if [ -f "$file" ]; then
	filename=${file:$pathLen}
	filename=${filename#/}
	if [ "${file: -7}" != "pack.sh" -a "${file: -3}" != ".fw" ]; then
		echo "filename=$filename" | tee -a $fwfile
		base64 $file >>$fwfile
	fi
fi
}

for path in $paths; do
	if [ -d "$path" ]; then
		pathLen=${#path}
		IFS=$(echo -en "\n\b")
		for file in $(tree -fi $path); do
			packFile $file
		done
	else
		packFile $path
	fi
done
