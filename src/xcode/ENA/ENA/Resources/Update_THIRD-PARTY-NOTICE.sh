#!/bin/bash
PLISTBUDDY="/usr/libexec/PlistBuddy -c"
KEY="licenses"

while [ $# -gt 0 ]; do
  case "$1" in
    --input*|-i*)
      if [[ "$1" != *=* ]]; then shift; fi
      INPUT_PATH="${1#*=}"
      ;;
    --template*|-t*)
      if [[ "$1" != *=* ]]; then shift; fi
      TEMPLATE_PATH="${1#*=}"
      ;;
 	--output*|-o*)
      if [[ "$1" != *=* ]]; then shift; fi
      OUTPUT_PATH="${1#*=}"
      ;;
    *)
      >&2 printf "Error: Invalid argument\n"
      exit 1
      ;;
  esac
  shift
done

echo $INPUT_PATH
echo $TEMPLATE_PATH
echo $OUTPUT_PATH

appendLicenseOverviews(){
	i=0
	while true ; do
	   $PLISTBUDDY "Print :$KEY:$i" "$INPUT_PATH" >/dev/null 2>/dev/null
	   if [ $? -ne 0 ]; then
	      break
	   fi

		echo "Component:	$($PLISTBUDDY "Print :$KEY:$i:component" "$INPUT_PATH")" >> $OUTPUT_PATH
		echo "Licensor: 	$($PLISTBUDDY "Print :$KEY:$i:licensor" "$INPUT_PATH")" >> $OUTPUT_PATH
		echo "Website:	$($PLISTBUDDY "Print :$KEY:$i:website" "$INPUT_PATH")" >> $OUTPUT_PATH
		echo "License:	$($PLISTBUDDY "Print :$KEY:$i:license" "$INPUT_PATH")" >> $OUTPUT_PATH
		echo "" >> $OUTPUT_PATH

		i=$(($i + 1))
	done
}

appendFullLicenses(){

	SEPARATOR="--------------------------------------------------------------------------------"

	i=0
	while true ; do
	   $PLISTBUDDY "Print :$KEY:$i" "$INPUT_PATH" >/dev/null 2>/dev/null
	   if [ $? -ne 0 ]; then
	      break
	   fi

		echo "$SEPARATOR" >> $OUTPUT_PATH
		echo "$($PLISTBUDDY "Print :$KEY:$i:fullLicense" "$INPUT_PATH")" >> $OUTPUT_PATH

		i=$(($i + 1))
	done
}

cp -rf $TEMPLATE_PATH $OUTPUT_PATH

appendLicenseOverviews
appendFullLicenses